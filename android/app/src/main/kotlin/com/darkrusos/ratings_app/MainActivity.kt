package com.darkrusos.ratings_app

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.util.Log
import androidx.annotation.NonNull
import androidx.documentfile.provider.DocumentFile
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.darkrusos.ratings_app"
    private val REQUEST_CODE_OPEN_DOCUMENT_TREE = 1001
    private var resultCallback: MethodChannel.Result? = null
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            resultCallback = result

            when (call.method) {
                "pickFolder" -> { openFolderPicker() }

                "writeFile" -> {
                    val uri = call.argument<String>("uri")
                    val fileName = call.argument<String>("fileName")
                    val bytes = call.argument<ByteArray>("bytes")
                    writeFile(uri!!, fileName!!, bytes!!)
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }
    private fun openFolderPicker() {
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION or Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION)
        }
        startActivityForResult(intent, REQUEST_CODE_OPEN_DOCUMENT_TREE)
    }
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_CODE_OPEN_DOCUMENT_TREE && resultCode == Activity.RESULT_OK) {
            val uri = data?.data
            if (uri != null) {
                contentResolver.takePersistableUriPermission(uri,
                    Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
                resultCallback?.success(uri.toString())
            } else {
                resultCallback?.error("FOLDER_SELECTION_CANCELLED", "No folder was selected.", null)
            }
        }
    }
    fun writeFile(uri: String, fileName: String, bytes: ByteArray) {
        val uri = Uri.parse(uri)

        val folder = DocumentFile.fromTreeUri(this, uri)!!

        var file = folder.findFile(fileName)

        if (file == null) {
            file = folder.createFile(
                "application/octet-stream",
                fileName
            )!!
        }

        contentResolver.openOutputStream(file.uri, "rwt")!!.use {
            it.write(bytes)
        }
    }
}