package com.guardianangel.myguardian

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Color
import android.util.Log
import android.widget.Toast

class CalculateHeartRate(private val context: Context) {

    fun calculateBPM(frameList: List<Bitmap>): Int{
        val redValues = ArrayList<Long>()
        for (frame in frameList) {
            var redBucket: Long = 0
            for (y in 150 until 250) {
                for (x in 150 until 250) {
                    val c: Int = frame.getPixel(x, y)
                    redBucket += Color.red(c)
                }
            }
            redValues.add(redBucket)
        }

        var count = 0
        for (i in 1 until redValues.size) {
            if (redValues[i] - redValues[i - 1] > 3500) {
                count++
            }
        }

        val heartRate = (((count.toFloat() / (redValues.size - 1)) * 60)*2).toInt()
        val message = "Heart Rate Calculated: $heartRate BPM"
        Log.d("Heart Rate", message)
        showToast(message)
        return heartRate
    }

    private fun showToast(message: String) {
        Toast.makeText(context, message, Toast.LENGTH_SHORT).show()
    }
}
