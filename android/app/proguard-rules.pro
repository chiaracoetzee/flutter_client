# Extra R8 rules for this app. The Flutter Gradle plugin always merges in
# packages/flutter_tools/gradle/flutter_proguard_rules.pro from the Flutter SDK.

-keepattributes Signature
-keepattributes *Annotation*
-keep class kotlin.Metadata { *; }
-keep class com.hiennv.flutter_callkit_incoming.** { *; }
-keep class org.unifiedpush.android.embedded_fcm_distributor.** { *; }