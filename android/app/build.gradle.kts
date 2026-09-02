import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

// Production signing credentials are loaded only from android/key.properties.
// Never commit key.properties or the keystore itself. CI creates a temporary,
// non-production keystore solely to validate release packaging.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
}

val releaseKeyAlias = keystoreProperties["keyAlias"] as? String
val releaseKeyPassword = keystoreProperties["keyPassword"] as? String
val releaseStorePassword = keystoreProperties["storePassword"] as? String
val releaseStoreFilePath = keystoreProperties["storeFile"] as? String
val releaseStoreFile = releaseStoreFilePath?.let(::file)
val releaseSigningConfigured = listOf(
    releaseKeyAlias,
    releaseKeyPassword,
    releaseStorePassword,
    releaseStoreFilePath,
).all { !it.isNullOrBlank() } && releaseStoreFile?.isFile == true

android {
    namespace = "com.rajan.speedmath"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "com.rajan.speedmath"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (releaseSigningConfigured) {
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
                storeFile = releaseStoreFile
                storePassword = releaseStorePassword
            }
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

// Never silently fall back to the debug certificate for a release artifact.
// This prevents accidental publication with the wrong signing identity.
if (gradle.startParameter.taskNames.any { it.contains("Release", ignoreCase = true) } && !releaseSigningConfigured) {
    throw GradleException(
        "Production release signing is not configured. Create android/key.properties " +
            "from android/key.properties.example and keep the keystore private."
    )
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
