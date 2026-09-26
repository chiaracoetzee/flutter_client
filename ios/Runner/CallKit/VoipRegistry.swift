import Flutter
import PushKit
import flutter_callkit_incoming

final class VoipRegistry: NSObject, PKPushRegistryDelegate {
  static let shared = VoipRegistry()

  private let reporter = IncomingCallReporter()
  private var registry: PKPushRegistry?
  private var pendingTokenHex: String?

  func start() {
    if registry != nil {
      return
    }
    reporter.start()
    let registry = PKPushRegistry(queue: reporter.queue)
    registry.delegate = self
    registry.desiredPushTypes = [.voIP]
    self.registry = registry
  }

  func register(messenger: FlutterBinaryMessenger) {
    reporter.register(messenger: messenger)
    applyPendingVoipToken()
  }

  func applyPendingVoipToken() {
    guard let hex = pendingTokenHex, !hex.isEmpty else {
      return
    }
    SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP(hex)
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
    pendingTokenHex = hex
    applyPendingVoipToken()
  }

  func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
    guard type == .voIP else {
      return
    }
    pendingTokenHex = nil
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
    reporter.handle(payload: payload, completion: completion)
  }

  @available(iOS 26.4, *)
  func pushRegistry(
    _ registry: PKPushRegistry,
    didReceiveIncomingVoIPPushWith payload: PKPushPayload,
    metadata: PKVoIPPushMetadata,
    withCompletionHandler completion: @escaping () -> Void
  ) {
    reporter.handle(payload: payload, completion: completion)
  }
}
