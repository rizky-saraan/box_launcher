package com.example.box_launcher

import android.app.WallpaperManager
import android.content.Context
import android.os.BatteryManager
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.TransparencyMode
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import kotlinx.coroutines.*
import org.xmlpull.v1.XmlPullParser

class MainActivity: FlutterActivity() {
    override fun getTransparencyMode(): TransparencyMode {
        return TransparencyMode.transparent
    }

    private val CHANNEL = "com.box_launcher/apps"
    private val scope = CoroutineScope(Dispatchers.IO + Job())

    private var currentIconPack: String? = null
    private val iconPackCache = mutableMapOf<String, String>()

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
                "getInstalledIconPacks" -> {
                    scope.launch {
                        val packs = getInstalledIconPacks()
                        withContext(Dispatchers.Main) {
                            result.success(packs)
                        }
                    }
                }
                "setIconPack" -> {
                    val packName = call.argument<String>("packageName")
                    scope.launch {
                        loadIconPack(packName)
                        withContext(Dispatchers.Main) {
                            result.success(true)
                        }
                    }
                }
                "openWallpaperPicker" -> {
                    val intent = Intent(Intent.ACTION_SET_WALLPAPER)
                    startActivity(Intent.createChooser(intent, "Select Wallpaper"))
                    result.success(true)
                }
                "updateWallpaperOffset" -> {
                    val offset = call.argument<Double>("offset") ?: 0.0
                    updateWallpaperOffset(offset.toFloat())
                    result.success(true)
                }
                "getBatteryLevel" -> {
                    val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
                    val level = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
                    result.success(level)
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

    private fun getInstalledIconPacks(): List<Map<String, String>> {
        val pm = packageManager
        val intentNova = Intent("com.novalauncher.THEME")
        val resolveInfosNova = pm.queryIntentActivities(intentNova, 0)
        
        val intentAdw = Intent("org.adw.launcher.THEMES")
        val resolveInfosAdw = pm.queryIntentActivities(intentAdw, 0)
        
        val allInfos = (resolveInfosNova + resolveInfosAdw).distinctBy { it.activityInfo.packageName }
        
        val packs = mutableListOf<Map<String, String>>()
        packs.add(mapOf("packageName" to "", "label" to "System Default"))
        
        for (info in allInfos) {
            packs.add(mapOf(
                "packageName" to info.activityInfo.packageName,
                "label" to info.loadLabel(pm).toString()
            ))
        }
        return packs
    }

    private fun loadIconPack(packageName: String?) {
        iconPackCache.clear()
        currentIconPack = packageName
        
        if (packageName.isNullOrEmpty()) return
        
        try {
            val pm = packageManager
            val res = pm.getResourcesForApplication(packageName)
            val resId = res.getIdentifier("appfilter", "xml", packageName)
            if (resId != 0) {
                val parser = res.getXml(resId)
                var eventType = parser.eventType
                while (eventType != XmlPullParser.END_DOCUMENT) {
                    if (eventType == XmlPullParser.START_TAG && parser.name == "item") {
                        val component = parser.getAttributeValue(null, "component")
                        val drawable = parser.getAttributeValue(null, "drawable")
                        if (component != null && drawable != null) {
                            val pkg = component.substringAfter("{").substringBefore("/")
                            if (!iconPackCache.containsKey(pkg)) {
                                iconPackCache[pkg] = drawable
                            }
                        }
                    }
                    eventType = parser.next()
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun getAppIcon(packageName: String): ByteArray? {
        try {
            val pm = packageManager
            
            if (!currentIconPack.isNullOrEmpty()) {
                val drawableName = iconPackCache[packageName]
                if (drawableName != null) {
                    try {
                        val packRes = pm.getResourcesForApplication(currentIconPack!!)
                        val resId = packRes.getIdentifier(drawableName, "drawable", currentIconPack!!)
                        if (resId != 0) {
                            val drawable = packRes.getDrawable(resId, null)
                            return drawableToByteArray(drawable)
                        }
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }
                }
            }
            
            val icon = pm.getApplicationIcon(packageName)
            return drawableToByteArray(icon)
        } catch (e: PackageManager.NameNotFoundException) {
            return null
        } catch (e: Exception) {
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
        
        val scaledBitmap = Bitmap.createScaledBitmap(bitmap, 128, 128, true)
        val stream = ByteArrayOutputStream()
        scaledBitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
        return stream.toByteArray()
    }

    private fun updateWallpaperOffset(offset: Float) {
        try {
            val wallpaperManager = WallpaperManager.getInstance(this)
            val windowToken = window.decorView.windowToken
            if (windowToken != null) {
                runOnUiThread {
                    try {
                        wallpaperManager.setWallpaperOffsets(windowToken, 0.5f, offset)
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        scope.cancel()
    }
}
