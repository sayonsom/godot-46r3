# Native Android Host App

This folder contains a native Android host application that embeds the Godot project from the repository root using the official Godot Android library.

## What it does

- Hosts Godot inside a native `Activity` via `GodotFragment`.
- Copies the Godot project files into `app/src/main/assets` during `preBuild`.
- Launches `res://scenes/android_home.tscn`, which renders a fixed-camera 2-bedroom home.
- Exposes a native multi-select shader dropdown with `Apply` and `Reset`.
- Sends the selected shader IDs into Godot through a runtime `GodotPlugin`.

## Build prerequisites

- Android SDK with at least platform `android-35`
- Java 17
- Gradle 8+

## Key integration points

- `app/src/main/java/com/smartthings/shaderhome/MainActivity.kt`
- `app/src/main/java/com/smartthings/shaderhome/ShaderHostPlugin.kt`
- `app/build.gradle.kts`
