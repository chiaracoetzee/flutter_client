import AVFoundation
import CallKit
import Flutter
import PushKit
import UIKit
import UserNotifications
import flutter_callkit_incoming

final class VoipPushHandler: NSObject, PKPushRegistryDelegate, CXProviderDelegate {
  static let shared = VoipPushHandler()

  private var registry: PKPushRegistry?
  private var fallbackProvider: CXProvider?
  private var reportedProvider: CXProvider?
  private var ringingMessageIds = Set<String>()
  private var calls: [String: flutter_callkit_incoming.Data] = [:]
  private var pendingAnswerId: String?
  private var answerAttempts = 0
  private var pendingVoipTokenHex: String?

  func start() {
    if registry != nil {
      return
    }
    let registry = PKPushRegistry(queue: .main)
    registry.delegate = self
    registry.desiredPushTypes = [.voIP]
    self.registry = registry
  }

  func pushRegistry(
    _ registry: PKPushRegistry,
    didUpdate pushCredentials: PKPushCredentials,
    for type: PKPushType
  ) {
    guard type == .voIP else {
      return
    }
    let hex = pushCredentials.token.map { String(format: "%02x", $0) }.joined()
    pendingVoipTokenHex = hex
    applyPendingVoipToken()
  }

  func applyPendingVoipToken() {
    guard let hex = pendingVoipTokenHex, !hex.isEmpty else {
      return
    }
    SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP(hex)
  }

  func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
    guard type == .voIP else {
      return
    }
    pendingVoipTokenHex = nil
    SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP("")
  }

  func pushRegistry(
    _ registry: PKPushRegistry,
    didReceiveIncomingPushWith payload: PKPushPayload,
    for type: PKPushType,
    completion: @escaping () -> Void
  ) {
    guard type == .voIP else {
      completion()
      return
    }
    let callId = UUID().uuidString
    let data = Self.placeholderCall(id: callId)
    calls[callId] = data
    let encoded = payload.dictionaryPayload["p"] as? String
    reportIncoming(data) {
      let outcome = Self.resolve(
        encoded: encoded,
        ringingMessageIds: self.ringingMessageIds,
        isForeground: UIApplication.shared.applicationState == .active
      )
      switch outcome {
      case .end:
        self.endReportedCall(data)
      case .ring(let fields):
        self.ringingMessageIds.insert(fields.messageId)
        self.apply(fields, to: data)
        self.updateReportedCaller(data)
        self.publishIncoming(data)
        self.collapseCallMessageNotification(messageId: fields.messageId)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
          self.collapseCallMessageNotification(messageId: fields.messageId)
        }
        self.deliverPendingAnswer()
      }
      completion()
    }
  }

  func providerDidReset(_ provider: CXProvider) {}

  func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
    action.fulfill()
    pendingAnswerId = action.callUUID.uuidString
    answerAttempts = 0
    deliverPendingAnswer()
  }

  func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
    action.fulfill()
  }

  func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {}

  func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {}

  private func reportIncoming(
    _ data: flutter_callkit_incoming.Data,
    reported: @escaping () -> Void
  ) {
    if let plugin = SwiftFlutterCallkitIncomingPlugin.sharedInstance {
      plugin.showCallkitIncoming(data, fromPushKit: true) {
        self.reportedProvider = self.providerForUpdate()
        DispatchQueue.main.async(execute: reported)
      }
      return
    }
    let provider = fallback()
    reportedProvider = provider
    guard let uuid = UUID(uuidString: data.uuid) else {
      reported()
      return
    }
    let update = CXCallUpdate()
    update.localizedCallerName = data.nameCaller
    update.remoteHandle = CXHandle(type: .generic, value: data.handle)
    update.hasVideo = false
    provider.reportNewIncomingCall(with: uuid, update: update) { _ in
      DispatchQueue.main.async(execute: reported)
    }
  }

  private func deliverPendingAnswer() {
    guard let id = pendingAnswerId else {
      return
    }
    answerAttempts += 1
    if answerAttempts > 40 {
      pendingAnswerId = nil
      return
    }
    let channel = calls[id]?.extra["channelId"] as? String
    if let plugin = SwiftFlutterCallkitIncomingPlugin.sharedInstance,
      let data = calls[id],
      let channel,
      !channel.isEmpty
    {
      plugin.sendEventCustom(
        "com.hiennv.flutter_callkit_incoming.ACTION_CALL_ACCEPT",
        body: data.toJSON() as NSDictionary
      )
      pendingAnswerId = nil
      return
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      self.deliverPendingAnswer()
    }
  }

  private func updateReportedCaller(_ data: flutter_callkit_incoming.Data) {
    guard let uuid = UUID(uuidString: data.uuid) else {
      return
    }
    let update = CXCallUpdate()
    update.localizedCallerName = data.nameCaller
    update.remoteHandle = CXHandle(type: .generic, value: data.handle)
    update.hasVideo = false
    if let provider = reportedProvider ?? providerForUpdate() {
      provider.reportCall(with: uuid, updated: update)
    }
  }

  private func endReportedCall(_ data: flutter_callkit_incoming.Data) {
    calls.removeValue(forKey: data.uuid)
    if let fallback = fallbackProvider, reportedProvider === fallback {
      guard let uuid = UUID(uuidString: data.uuid) else {
        return
      }
      fallback.reportCall(with: uuid, endedAt: Date(), reason: .failed)
      return
    }
    SwiftFlutterCallkitIncomingPlugin.sharedInstance?.endCall(data)
  }

  private func publishIncoming(_ data: flutter_callkit_incoming.Data) {
    SwiftFlutterCallkitIncomingPlugin.sharedInstance?.sendEventCustom(
      "com.hiennv.flutter_callkit_incoming.ACTION_CALL_INCOMING",
      body: data.toJSON() as NSDictionary
    )
  }

  private func collapseCallMessageNotification(messageId: String) {
    guard !messageId.isEmpty else {
      return
    }
    let center = UNUserNotificationCenter.current()
    center.removePendingNotificationRequests(withIdentifiers: [messageId])
    center.removeDeliveredNotifications(withIdentifiers: [messageId])
    center.getDeliveredNotifications { notifications in
      let identifiers = notifications.compactMap { notification -> String? in
        let userInfo = notification.request.content.userInfo
        let id = PushNotificationPayload.resolveMessageId(from: userInfo)
        return id == messageId ? notification.request.identifier : nil
      }
      guard !identifiers.isEmpty else {
        return
      }
      center.removeDeliveredNotifications(withIdentifiers: identifiers)
    }
  }

  private func providerForUpdate() -> CXProvider? {
    if let plugin = SwiftFlutterCallkitIncomingPlugin.sharedInstance {
      let mirror = Mirror(reflecting: plugin)
      for child in mirror.children {
        if child.label == "sharedProvider" {
          if let provider = child.value as? CXProvider {
            return provider
          }
          let nested = Mirror(reflecting: child.value)
          if nested.displayStyle == .optional,
            let some = nested.children.first,
            let provider = some.value as? CXProvider
          {
            return provider
          }
        }
      }
    }
    return fallbackProvider
  }

  private func fallback() -> CXProvider {
    if let fallbackProvider {
      return fallbackProvider
    }
    let config = CXProviderConfiguration(localizedName: "Fluxer")
    config.supportsVideo = false
    config.maximumCallGroups = 1
    config.maximumCallsPerCallGroup = 1
    config.supportedHandleTypes = [.generic]
    config.ringtoneSound = "incoming_ring.caf"
    config.includesCallsInRecents = true
    let provider = CXProvider(configuration: config)
    provider.setDelegate(self, queue: .main)
    fallbackProvider = provider
    return provider
  }

  private static func resolve(
    encoded: String?,
    ringingMessageIds: Set<String>,
    isForeground: Bool
  ) -> CallRingOutcome {
    guard let encoded,
      let record = WebPushKeychain.decodeBase64Url(encoded),
      let decrypted = WebPushRecordDecryptor.decryptVoip(record: record)
    else {
      return .end
    }
    return CallRingResolver.resolve(
      plaintext: decrypted.plaintext,
      accountUserId: decrypted.userId,
      nowMs: Int64(Date().timeIntervalSince1970 * 1000),
      ringingMessageIds: ringingMessageIds,
      isForeground: isForeground
    )
  }

  private func apply(_ fields: CallRingFields, to data: flutter_callkit_incoming.Data) {
    data.nameCaller = fields.callerName
    data.handle = fields.handle
    data.duration = fields.durationMs
    if let avatar = fields.callerAvatarUrl {
      data.avatar = avatar
    }
    data.extra = [
      "channelId": fields.channelId,
      "messageId": fields.messageId,
    ] as NSDictionary
  }

  private static func placeholderCall(id: String) -> flutter_callkit_incoming.Data {
    let data = flutter_callkit_incoming.Data(
      id: id,
      nameCaller: CallRingResolver.fallbackName,
      handle: CallRingResolver.fallbackHandle,
      type: 0
    )
    data.appName = "Fluxer"
    data.duration = 45_000
    data.supportsVideo = false
    data.configureAudioSession = false
    data.audioSessionMode = "videoChat"
    data.audioSessionActive = true
    data.handleType = "generic"
    data.ringtonePath = "incoming_ring.caf"
    data.isShowMissedCallNotification = false
    return data
  }
}
