// android/build.gradle.kts

plugins {
    id("com.android.application")
    kotlin("android")
    id("com.google.gms.google-services") // Firebase plugin
}

android {
    namespace = "com.amrah.bunnypages" // <-- your package name
    compileSdk = 34

    defaultConfig {
        applicationId = "com.amrah.bunnypages" // <-- same as namespace
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }
}

dependencies {
    // Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:34.6.0"))

    // Firebase SDKs you want
    implementation("com.google.firebase:firebase-analytics-ktx")
    implementation("com.google.firebase:firebase-firestore-ktx") // for reviews
    implementation("com.google.firebase:firebase-auth-ktx") // optional

    // AndroidX Core
    implementation("androidx.core:core-ktx:1.12.0")
}
