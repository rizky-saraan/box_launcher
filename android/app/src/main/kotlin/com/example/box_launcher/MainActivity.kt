package com.example.box_launcher

import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import kotlinx.coroutines.*

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.box_launcher/apps"
    private val scope = CoroutineScope(Dispatchers.IO + Job())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getInstalledApps" -> {
                    scope.launch {
                        val apps = getInstalledApps()
                        withContext(Dispatchers.Main) {
                            result.success(apps)
                        }
                    }
                }
                "openApp" -> {
                    val packageName = call.argument<String>("packageName")
                    if (packageName != null) {
                        val success = openApp(packageName)
                        result.success(success)
                    } else {
                        result.error("INVALID_PACKAGE", "Package name is null", null)
                    }
                }
                "getAppIcon" -> {
                    val packageName = call.argument<String>("packageName")
                    if (packageName != null) {
                        scope.launch {
                            val icon = getAppIcon(packageName)
                            withContext(Dispatchers.Main) {
                                if (icon != null) {
                                    result.success(icon)
                                } else {
                                    result.error("NO_ICON", "Icon not found", null)
                                }
                            }
                        }
                    } else {
                        result.error("INVALID_PACKAGE", "Package name is null", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun getInstalledApps(): List<Map<String, Any>> {
        val pm = packageManager
        val mainIntent = Intent(Intent.ACTION_MAIN, null)
        mainIntent.addCategory(Intent.CATEGORY_LAUNCHER)
        val resolveInfos = pm.queryIntentActivities(mainIntent, 0)
        
        val apps = mutableListOf<Map<String, Any>>()
        for (resolveInfo in resolveInfos) {
            val packageName = resolveInfo.activityInfo.packageName
            if (packageName == context.packageName) continue

            val label = resolveInfo.loadLabel(pm).toString()
            val map = mapOf(
                "packageName" to packageName,
                "label" to label
            )
            apps.add(map)
        }
        return apps.sortedBy { (it["label"] as String).lowercase() }
    }

    private fun getAppIcon(packageName: String): ByteArray? {
        try {
            val pm = packageManager
            val icon = pm.getApplicationIcon(packageName)
            return drawableToByteArray(icon)
        } catch (e: PackageManager.NameNotFoundException) {
            return null
        }
    }

    private fun openApp(packageName: String): Boolean {
        val pm = packageManager
        val intent = pm.getLaunchIntentForPackage(packageName)
        if (intent != null) {
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
            return true
        }
        return false
    }

    private fun drawableToByteArray(drawable: Drawable): ByteArray {
        val bitmap = if (drawable is BitmapDrawable) {
            drawable.bitmap
        } else {
            val bitmap = Bitmap.createBitmap(
                drawable.intrinsicWidth.takeIf { it > 0 } ?: 1,
                drawable.intrinsicHeight.takeIf { it > 0 } ?: 1,
                Bitmap.Config.ARGB_8888
            )
            val canvas = Canvas(bitmap)
            drawable.setBounds(0, 0, canvas.width, canvas.height)
            drawable.draw(canvas)
            bitmap
        }
        
        // Resize icon to save memory over bridge
        val scaledBitmap = Bitmap.createScaledBitmap(bitmap, 128, 128, true)
        val stream = ByteArrayOutputStream()
        scaledBitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
        return stream.toByteArray()
    }

    override fun onDestroy() {
        super.onDestroy()
        scope.cancel()
    }
}
