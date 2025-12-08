package com.abdulrahman.tailorx

import android.content.ContentValues
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.io.OutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.abdulrahman.tailorx/gallery"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "saveImageToGallery" -> {
                    val imageBytes = call.argument<ByteArray>("imageBytes")
                    val fileName = call.argument<String>("fileName")
                    if (imageBytes != null && fileName != null) {
                        val saved = saveImageToGallery(imageBytes, fileName)
                        result.success(saved)
                    } else {
                        result.error("INVALID_ARGUMENT", "Image bytes or file name is null", null)
                    }
                }
                "getAndroidVersion" -> {
                    result.success(Build.VERSION.SDK_INT)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun saveImageToGallery(imageBytes: ByteArray, fileName: String): Boolean {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                // Android 10+ (API 29+): Use MediaStore API
                saveImageUsingMediaStore(imageBytes, fileName)
            } else {
                // Android 9 and below: Save to external storage and scan
                saveImageLegacy(imageBytes, fileName)
            }
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    @Suppress("DEPRECATION")
    private fun saveImageLegacy(imageBytes: ByteArray, fileName: String): Boolean {
        val picturesDir = File(
            getExternalFilesDir(android.os.Environment.DIRECTORY_PICTURES),
            "TailorX"
        )
        if (!picturesDir.exists()) {
            picturesDir.mkdirs()
        }

        val file = File(picturesDir, fileName)
        FileOutputStream(file).use { it.write(imageBytes) }

        // Scan the file to make it appear in gallery
        MediaScannerConnection.scanFile(
            this,
            arrayOf(file.absolutePath),
            arrayOf("image/png"),
            null
        )
        return true
    }

    private fun saveImageUsingMediaStore(imageBytes: ByteArray, fileName: String): Boolean {
        val contentValues = ContentValues().apply {
            put(MediaStore.Images.Media.DISPLAY_NAME, fileName)
            put(MediaStore.Images.Media.MIME_TYPE, "image/png")
            put(MediaStore.Images.Media.RELATIVE_PATH, "Pictures/TailorX")
            put(MediaStore.Images.Media.IS_PENDING, 1)
        }

        val uri = contentResolver.insert(
            MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
            contentValues
        ) ?: return false

        try {
            contentResolver.openOutputStream(uri)?.use { outputStream: OutputStream ->
                outputStream.write(imageBytes)
            }

            // Mark as not pending so it appears in gallery
            contentValues.clear()
            contentValues.put(MediaStore.Images.Media.IS_PENDING, 0)
            contentResolver.update(uri, contentValues, null, null)

            return true
        } catch (e: Exception) {
            contentResolver.delete(uri, null, null)
            e.printStackTrace()
            return false
        }
    }
}

