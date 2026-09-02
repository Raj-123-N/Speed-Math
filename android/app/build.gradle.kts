import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) keystoreProperties.load(FileInputStream(keystorePropertiesFile))

android {
    namespace = "com.rajan.speedmath"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion
    compileOptions { sourceCompatibility = JavaVersion.VERSION_17; targetCompatibility = JavaVersion.VERSION_17; isCoreLibraryDesugaringEnabled = true }
    defaultConfig { applicationId = "com.rajan.speedmath"; minSdk = flutter.minSdkVersion; targetSdk = flutter.targetSdkVersion; versionCode = flutter.versionCode; versionName = flutter.versionName }
    signingConfigs { create("release") { if (keystorePropertiesFile.exists()) { keyAlias = keystoreProperties["keyAlias"] as? String; keyPassword = keystoreProperties["keyPassword"] as? String; storeFile = keystoreProperties["storeFile"]?.let { file(it) }; storePassword = keystoreProperties["storePassword"] as? String } } }
    buildTypes { release { isMinifyEnabled = true; isShrinkResources = true; signingConfig = if (keystorePropertiesFile.exists() && keystoreProperties.containsKey("keyAlias")) signingConfigs.getByName("release") else signingConfigs.getByName("debug") } }
}

dependencies { coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5") }
kotlin { compilerOptions { jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17 } }
flutter { source = "../.." }
