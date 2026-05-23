package com.example.ai_agent_mobile_app

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.media.session.MediaController
import android.media.session.MediaSessionManager
import android.media.session.PlaybackState
import android.net.Uri
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MusicControllerPlugin(private val context: Context) : MethodChannel.MethodCallHandler {
    private var mediaController: MediaController? = null
    private val sessionManager = context.getSystemService(Context.MEDIA_SESSION_SERVICE) as MediaSessionManager

    private val callback = object : MediaController.Callback() {
        override fun onPlaybackStateChanged(state: PlaybackState?) {}
        override fun onMetadataChanged(metadata: android.media.MediaMetadata?) {}
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "connect" -> connect(result)
            "getNowPlaying" -> getNowPlaying(result)
            "play" -> sendCommand("play", result)
            "pause" -> sendCommand("pause", result)
            "skipNext" -> sendCommand("skipNext", result)
            "skipPrevious" -> sendCommand("skipPrevious", result)
            "openMusicApp" -> openMusicApp(call.argument("package") ?: "", result)
            "searchSong" -> searchSong(call.argument("query") ?: "", result)
            else -> result.notImplemented()
        }
    }

    private fun connect(result: MethodChannel.Result) {
        try {
            val controllers = sessionManager.getActiveSessions(
                ComponentName(context, NotificationListener::class.java)
            )
            if (controllers.isNotEmpty()) {
                mediaController?.unregisterCallback(callback)
                mediaController = controllers[0]
                mediaController?.registerCallback(callback)
                result.success(true)
            } else {
                result.success(false)
            }
        } catch (e: SecurityException) {
            result.success(false)
        }
    }

    private fun getNowPlaying(result: MethodChannel.Result) {
        val ctrl = mediaController ?: run { result.success(null); return }
        val metadata = ctrl.metadata
        if (metadata == null) { result.success(null); return }
        result.success(mapOf(
            "title" to (metadata.getString(android.media.MediaMetadata.METADATA_KEY_TITLE) ?: ""),
            "artist" to (metadata.getString(android.media.MediaMetadata.METADATA_KEY_ARTIST) ?: ""),
            "isPlaying" to (ctrl.playbackState?.state == PlaybackState.STATE_PLAYING),
            "appName" to (ctrl.packageName ?: "")
        ))
    }

    private fun sendCommand(action: String, result: MethodChannel.Result) {
        val ctrl = mediaController ?: run { result.success(false); return }
        try {
            val tc = ctrl.transportControls
            when (action) {
                "play" -> tc.play()
                "pause" -> tc.pause()
                "skipNext" -> tc.skipToNext()
                "skipPrevious" -> tc.skipToPrevious()
            }
            result.success(true)
        } catch (e: Exception) {
            result.success(false)
        }
    }

    private fun openMusicApp(packageName: String, result: MethodChannel.Result) {
        val pkgs = listOf(
            "com.netease.cloudmusic",
            "com.tencent.qqmusic",
            "com.kugou.android",
            "com.spotify.music"
        )
        val target = if (packageName.isNotEmpty()) listOf(packageName) else pkgs

        for (pkg in target) {
            try {
                val intent = context.packageManager.getLaunchIntentForPackage(pkg)
                if (intent != null) {
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    context.startActivity(intent)
                    result.success(mapOf("package" to pkg, "opened" to true))
                    return
                }
            } catch (_: Exception) {}
        }
        // fallback: open NetEase web
        try {
            val intent = Intent(Intent.ACTION_VIEW).apply {
                data = Uri.parse("https://music.163.com")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            context.startActivity(intent)
            result.success(mapOf("package" to "", "opened" to true))
        } catch (_: Exception) {
            result.success(mapOf("package" to "", "opened" to false))
        }
    }

    private fun searchSong(query: String, result: MethodChannel.Result) {
        try {
            val encoded = Uri.encode(query)
            // 优先尝试打开网易云音乐搜索
            val intent = Intent(Intent.ACTION_VIEW).apply {
                data = Uri.parse("https://music.163.com/#/search/m/?s=$encoded")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            context.startActivity(intent)
            result.success(true)
        } catch (_: Exception) {
            result.success(false)
        }
    }

    fun release() {
        mediaController?.unregisterCallback(callback)
        mediaController = null
    }
}