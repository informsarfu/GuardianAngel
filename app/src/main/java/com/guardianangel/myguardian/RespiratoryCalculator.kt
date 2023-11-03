package com.guardianangel.myguardian

import kotlin.math.sqrt
import kotlin.math.pow


class RespiratoryCalculator {
    fun calculateRespiratoryRate(accelValues: List<Float>): Int {
        var previousValue = 0f
        var currentValue = 0f
        previousValue = 10f
        var k = 0

        // Process the x values (first 1280 values)
        for (i in 0 until 1280) {
            val xValue = accelValues[i] // Access the x value from the CSV data
            currentValue = sqrt(xValue.toDouble().pow(2.0)).toFloat() // Calculate current value (x-axis)
            if (Math.abs(previousValue - currentValue) > 0.15) {
                k++
            }
            previousValue = currentValue
        }

        // Process the y values (next 1280 values)
        for (i in 1280 until 2560) {
            val yValue = accelValues[i] // Access the y value from the CSV data
            currentValue = sqrt(yValue.toDouble().pow(2.0)).toFloat() // Calculate current value (y-axis)
            if (Math.abs(previousValue - currentValue) > 0.15) {
                k++
            }
            previousValue = currentValue
        }

        // Process the z values (last 1280 values)
        for (i in 2560 until 3840) {
            val zValue = accelValues[i] // Access the z value from the CSV data
            currentValue = sqrt(zValue.toDouble().pow(2.0)).toFloat() // Calculate current value (z-axis)
            if (Math.abs(previousValue - currentValue) > 0.15) {
                k++
            }
            previousValue = currentValue
        }

        val ret = k / 45.0
        return (ret * 60).toInt()
    }
}