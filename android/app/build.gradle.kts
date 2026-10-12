import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

configurations.all {
    val tinkAndroid = "com.google.crypto.tink:tink-android:1.21.0"
    resolutionStrategy {
        force(tinkAndroid)
        dependencySubstitution {
            substitute(module("com.google.crypto.tink:tink")).using(module(tinkAndroid))
        }
    }
}

val requestedTasks = gradle.startParameter.taskNames.joinToString(" ").lowercase()
val googleServicesJson = file("google-services.json")
if (googleServicesJson.exists() || requestedTasks.contains("fcm")) {
    apply(plugin = "com.google.gms.google-services")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasKeystoreProperties = keystorePropertiesFile.exists()
if (hasKeystoreProperties) {
    keystorePropertiesFile.inputStream().use { inputStream ->
        keystoreProperties.load(inputStream)
    }
}

fun readMeasureConfigValue(
    propertyKey: String,
    envVar: String,
    measureProperties: Properties,
    localProperties: Properties,
): String {
    measureProperties.getProperty(propertyKey)?.trim()?.takeIf { it.isNotEmpty() }?.let { return it }
    localProperties.getProperty(propertyKey)?.trim()?.takeIf { it.isNotEmpty() }?.let { return it }
    System.getenv(envVar)?.trim()?.takeIf { it.isNotEmpty() }?.let { return it }
    return ""
}

val measureProperties = Properties()
val measurePropertiesFile = rootProject.file("measure.properties")
if (measurePropertiesFile.exists()) {
    measurePropertiesFile.inputStream().use { inputStream ->
        measureProperties.load(inputStream)
    }
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { inputStream ->
        localProperties.load(inputStream)
    }
}

val measureApiKey = readMeasureConfigValue(
    propertyKey = "measure.apiKey",
    envVar = "MEASURE_ANDROID_API_KEY",
    measureProperties = measureProperties,
    localProperties = localProperties,
)
val measureApiUrl = readMeasureConfigValue(
    propertyKey = "measure.apiUrl",
    envVar = "MEASURE_API_URL",
    measureProperties = measureProperties,
    localProperties = localProperties,
)

android {
    namespace = "com.fluxer"
    compileSdk = 37
    ndkVersion = flutter.ndkVersion
    flavorDimensions += listOf("environment", "push")

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    signingConfigs {
        getByName("debug") {
            storeFile = file("debug.keystore")
            storePassword = "canary-debug"
            keyAlias = "canary"
            keyPassword = "canary-debug"
        }
    }

    defaultConfig {
        applicationId = "com.fluxer"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
        manifestPlaceholders["appLabel"] = "Fluxer"
        manifestPlaceholders["buildEnvironment"] = "stable"
        manifestPlaceholders["pushProvider"] = "fcm"
        manifestPlaceholders["appIconAliasPrefix"] = "com.fluxer.MainActivity"
        manifestPlaceholders["measureApiKey"] = measureApiKey
        manifestPlaceholders["measureApiUrl"] = measureApiUrl
        // Fork: the scheme of the links the app opens (AndroidManifest.xml). Upstream's flavours keep fluxer.
        manifestPlaceholders["deepLinkScheme"] = "fluxer"
    }

    productFlavors {
        create("canary") {
            dimension = "environment"
            // Fork: this flavour is what the fork ships, as "Tyne", an app of its own (upstream's name
            // and marks policy). Its ID is under tyne.chat and must never change once a build has
            // shipped: Android would take the app for a different one. Upstream's canary build is
            // com.fluxer.canary, which the fork's builds used to share and could not be installed next to.
            applicationId = "chat.tyne.app"
            versionNameSuffix = "-canary"
            manifestPlaceholders["appLabel"] = "Tyne"
            // Fork: Tyne opens tyne:// links and leaves fluxer:// to the official app, so the two do not
            // compete for each other's links when both are installed.
            manifestPlaceholders["deepLinkScheme"] = "tyne"
            manifestPlaceholders["buildEnvironment"] = "canary"
            manifestPlaceholders["appIconAliasPrefix"] = "com.fluxer.canary.MainActivity"
        }
        create("stable") {
            dimension = "environment"
            manifestPlaceholders["appLabel"] = "Fluxer"
            manifestPlaceholders["buildEnvironment"] = "stable"
        }
        create("beta") {
            dimension = "environment"
            manifestPlaceholders["appLabel"] = "Fluxer Beta"
            manifestPlaceholders["buildEnvironment"] = "beta"
        }
        create("fcm") {
            dimension = "push"
            manifestPlaceholders["pushProvider"] = "fcm"
        }
        create("unifiedpush") {
            dimension = "push"
            manifestPlaceholders["pushProvider"] = "unifiedpush"
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            ndk {
                debugSymbolLevel = "FULL"
            }
            signingConfig = if (hasKeystoreProperties) {
                signingConfigs.create("release") {
                    val storeFilePath = keystoreProperties["storeFile"] as String
                    storeFile = file(storeFilePath)
                    storePassword = keystoreProperties["storePassword"] as String
                    keyAlias = keystoreProperties["keyAlias"] as String
                    keyPassword = keystoreProperties["keyPassword"] as String
                }
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }

    testOptions {
        unitTests.isIncludeAndroidResources = true
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    testImplementation("junit:junit:4.13.2")
    testImplementation("org.robolectric:robolectric:4.14.1")
    implementation("org.unifiedpush.android:embedded-fcm-distributor:3.1.0")
    add("fcmImplementation", platform("com.google.firebase:firebase-bom:33.9.0"))
    add("fcmImplementation", "com.google.firebase:firebase-messaging")
    add("fcmImplementation", "com.google.android.gms:play-services-cloud-messaging")
}
