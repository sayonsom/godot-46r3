plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("org.jetbrains.kotlin.plugin.compose")
}

val godotProjectDir = rootProject.projectDir.parentFile
val godotAssetsDir = layout.projectDirectory.dir("src/main/assets")
val androidResFontDir = layout.projectDirectory.dir("src/main/res/font")

android {
    namespace = "com.smartthings.shaderhome"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.smartthings.shaderhome"
        minSdk = 24
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"

        ndk {
            abiFilters += listOf("arm64-v8a")
        }

        aaptOptions {
            ignoreAssetsPattern = "!.svn:!.git:!.gitignore:!.ds_store:!*.scc:<dir>_*:!CVS:!thumbs.db:!picasa.ini:!*~"
        }
    }

    buildTypes {
        release {
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

    buildFeatures {
        compose = true
    }

    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
    }
}

val syncGodotProject by tasks.registering(Copy::class) {
    from(godotProjectDir) {
        include("project.godot")
        include("assets/**")
        include("data/**")
        include("GLB/**")
        include("materials/**")
        include("SmartThingsIcons/**")
        include(".godot/imported/**")
        include(".godot/imported/WoodFloor040*")
        include("generated_shaders/**")
        include("shaders/**")
        include("scenes/**")
        include("scripts/**")

        exclude("GLB/**/*.glb")
        exclude("GLB/**/*.png")
        exclude("GLB/**/*.jpg")
        exclude("GLB/**/*.jpeg")
        exclude("GLB/**/*.webp")
        exclude("assets/**/*.png")
        exclude("assets/**/*.jpg")
        exclude("assets/**/*.jpeg")
        exclude("assets/**/*.webp")
    }
    into(godotAssetsDir)
    doFirst {
        delete(godotAssetsDir)
    }
    outputs.upToDateWhen { false }
}

val syncSamsungFonts by tasks.registering(Copy::class) {
    val fontCandidates = mapOf(
        "samsungone_400.ttf" to listOf(
            "assets/fonts/samsungone_400.ttf",
            "assets/fonts/SamsungOne-400.ttf",
        ),
        "samsungone_500.ttf" to listOf(
            "assets/fonts/samsungone_500.ttf",
            "assets/fonts/SamsungOne-500.ttf",
        ),
        "samsungone_600.ttf" to listOf(
            "assets/fonts/samsungone_600.ttf",
            "assets/fonts/SamsungOne-600.ttf",
        ),
        "samsungone_700.ttf" to listOf(
            "assets/fonts/samsungone_700.ttf",
            "assets/fonts/SamsungOne-700.ttf",
        ),
    )

    fontCandidates.forEach { (targetFileName, candidates) ->
        val sourceFile = candidates
            .asSequence()
            .map(godotProjectDir::resolve)
            .firstOrNull { it.exists() }
            ?: error("Missing SamsungOne font for $targetFileName. Checked: ${candidates.joinToString()}")

        from(sourceFile) {
            rename { targetFileName }
        }
    }
    into(androidResFontDir)
    doFirst {
        delete(androidResFontDir)
    }
    outputs.upToDateWhen { false }
}

tasks.named("preBuild") {
    dependsOn(syncGodotProject)
    dependsOn(syncSamsungFonts)
}

dependencies {
    val composeBom = platform("androidx.compose:compose-bom:2024.06.00")

    implementation(composeBom)
    androidTestImplementation(composeBom)

    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.appcompat:appcompat:1.7.0")
    implementation("com.google.android.material:material:1.12.0")
    implementation("androidx.activity:activity-compose:1.9.2")
    implementation("androidx.compose.material:material-icons-extended")
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.fragment:fragment-ktx:1.8.4")
    // ExploreByTouchHelper for the TalkBack virtual-view tree (see
    // accessibility/HomeExploreByTouchHelper.kt). Pulled in transitively by
    // appcompat already; declared explicitly so the version is pinned.
    implementation("androidx.customview:customview:1.1.0")
    implementation("org.godotengine:godot:4.6.2.stable")

    debugImplementation("androidx.compose.ui:ui-tooling")
    debugImplementation("androidx.compose.ui:ui-test-manifest")
}
