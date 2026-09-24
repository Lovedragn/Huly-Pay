# ============================================================
# ML Kit — keep ALL classes, not just barcode-specific ones
# ML Kit uses internal DI that breaks if any class is renamed
# ============================================================
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_barcode.** { *; }
-keep class com.google.android.gms.vision.** { *; }

# ============================================================
# CameraX — required by mobile_scanner
# ============================================================
-keep class androidx.camera.** { *; }

# ============================================================
# mobile_scanner plugin
# ============================================================
-keep class dev.steenbakker.mobile_scanner.** { *; }

# ============================================================
# Geolocator (used by LocationService)
# ============================================================
-keep class com.baseflow.geolocator.** { *; }

# ============================================================
# Flutter engine — never strip
# ============================================================
-keep class io.flutter.** { *; }

# ============================================================
# Play Core split-install (referenced by Flutter engine but
# not bundled — suppress warnings so R8 doesn't fail)
# ============================================================
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task
