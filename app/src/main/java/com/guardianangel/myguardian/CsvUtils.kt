package com.guardianangel.myguardian
import android.content.res.AssetManager

class CsvUtils(private val assetManager: AssetManager) {
    fun getRandomCsvFileName(): String {
        val csvFiles = listOf("CSVBreathe19.csv", "CSVBreathe27V1.csv", "CSVBreathe27V2.csv","CSVBreathe44.csv")
        return csvFiles.random()
    }

    fun readCsvFromAssets(fileName: String): List<Float> {
        val inputStream = assetManager.open(fileName)
        val lines = mutableListOf<Float>()
        inputStream.bufferedReader().useLines { lines.addAll(it.map { line -> line.toFloat() }) }
        return lines
    }
}