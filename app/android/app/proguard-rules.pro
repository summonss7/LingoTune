-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class com.google.firebase.** { *; }
-keep class com.squareup.okhttp.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

# sherpa_onnx native bindings — keep JNI entry points and the Java/JNI bridge
# classes so R8 doesn't rename/remove them. Without this, release builds crash
# with UnsatisfiedLinkError on first OfflineTts() construction.
-keep class com.k2fsa.sherpa.onnx.** { *; }
-keep class com.k2fsa.sherpa.onnx.**$* { *; }
-keepclassmembers class com.k2fsa.sherpa.onnx.** {
    *;
}
# Native symbols loaded via System.loadLibrary("sherpa-onnx-jni")
-dontwarn com.k2fsa.sherpa.onnx.**
