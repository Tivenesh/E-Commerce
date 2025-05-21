plugins {
    id("com.android.application")
    kotlin("android") // ✅ Do not specify version here
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}


android {
    namespace = "com.example.e_commerce" // ✅ matches Firebase package name
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"


    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.e_commerce" // ✅ important for Firebase
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug") // ❗️change for real release
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ✅ Firebase BoM: Manages versions for Firebase dependencies
    implementation(platform("com.google.firebase:firebase-bom:33.13.0"))

    // ✅ Add Firebase SDKs you need — example:
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
    implementation("com.google.firebase:firebase-storage")
}
