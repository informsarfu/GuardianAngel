package com.guardianangel.myguardian

import android.content.Context
import android.graphics.Bitmap
import android.media.MediaMetadataRetriever
import android.net.Uri
import android.util.Log

class FrameExtractor(private val context: Context) {

    fun extractFramesFromVideo(videoResource: Int, frameRate: Int, frameInterval: Int): List<Bitmap> {
        val retriever = MediaMetadataRetriever()
        val frameList = ArrayList<Bitmap>()

        try {
            val videoUri = Uri.parse("android.resource://${context.packageName}/$videoResource")
            retriever.setDataSource(context, videoUri)

            val duration =
                retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)?.toLong() ?: 0
            val numFrames = (duration * frameRate / 1000).toInt()

            for (i in 0 until numFrames step frameInterval) {
                val timeUs = (i * 1000000L / frameRate)
                val frame = retriever.getFrameAtTime(timeUs, MediaMetadataRetriever.OPTION_CLOSEST)
                if (frame != null) {
                    frameList.add(frame)
                    Log.d("Frame Extraction", "Extracted frame $i")
                }
            }

        } catch (e: Exception) {
            e.printStackTrace()
            Log.e("Frame Extraction", "Error extracting frames from video: ${e.message}")
        } finally {
            retriever.release()
        }

        return frameList
    }
}
