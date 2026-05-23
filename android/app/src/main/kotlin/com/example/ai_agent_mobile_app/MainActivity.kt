package com.example.ai_agent_mobile_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var musicController: MusicControllerPlugin? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        musicController = MusicControllerPlugin(this)
        flutterEngine
            .dartExecutor
            .binaryMessenger
            .let { messenger ->
                io.flutter.plugin.common.MethodChannel(messenger, "music_controller")
                    .setMethodCallHandler(musicController!!)
            }
    }

    override fun onDestroy() {
        musicController?.release()
        super.onDestroy()
    }
}