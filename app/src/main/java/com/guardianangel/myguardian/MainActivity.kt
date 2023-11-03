package com.guardianangel.myguardian

import android.content.ContentValues
import android.content.Intent
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.view.View
import android.widget.Button
import android.widget.Toast
import android.util.Log


class MainActivity : AppCompatActivity() {

    private lateinit var csvUtils: CsvUtils
    private lateinit var respiratoryCalculator: RespiratoryCalculator


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        csvUtils = CsvUtils(assets)
        respiratoryCalculator = RespiratoryCalculator()

        val symptomButton = findViewById<Button>(R.id.symptomsButton)
        val heartRateButton = findViewById<Button>(R.id.heartButton)
        val respiratoryButton = findViewById<Button>(R.id.respiratoryButton)
        val trafficButton = findViewById<Button>(R.id.trafficMonitorButton)


        symptomButton.setOnClickListener(View.OnClickListener {
            val intent = Intent(this, SymptomSelectionActivity::class.java)
            startActivity(intent)
        })

        trafficButton.setOnClickListener(View.OnClickListener {
            val intent = Intent(this, TrafficMonitorActivity::class.java)
            startActivity(intent)
        })


        heartRateButton.setOnClickListener {
            val videoResource = R.raw.heartratevideo
            val frameExtractor = FrameExtractor(this)

            val frameRate = 30 // Adjust frame rate as needed
            val frameInterval = 5 // Set the frame interval (skip frames)

            val dbHelper = DatabaseHelper(this)
            val db = dbHelper.writableDatabase

            val columnName = "Heart_Rate"

            val frameList = frameExtractor.extractFramesFromVideo(videoResource, frameRate, frameInterval)

            if (frameList.isEmpty()) {
                Log.e("Error", "No valid frames found, heart rate calculation failed.")
            } else {
                val calculateHeartRate = CalculateHeartRate(this)
                val heartBeat = calculateHeartRate.calculateBPM(frameList)

                val values = ContentValues().apply {
                    put(columnName, heartBeat)
                }

                // Update the database`=
                val rowsUpdated = db.update(
                    DatabaseHelper.TABLE_NAME,
                    values,
                    null,
                    null
                )

                db.close()

                // Check if the update was successful and display a message
                if (rowsUpdated > 0) {
                    val message = "Heart Rate updated: $heartBeat BPM"
                    showToast(message)
                } else {
                    val message = "Failed to update Heart Rate"
                    showToast(message)
                }

            }
        }

        respiratoryButton.setOnClickListener {
            val randomCsvFileName = csvUtils.getRandomCsvFileName()
            val accelValues = csvUtils.readCsvFromAssets(randomCsvFileName)
            val respiratoryRate = respiratoryCalculator.calculateRespiratoryRate(accelValues)

            val dbHelper = DatabaseHelper(this)
            val db = dbHelper.writableDatabase

            val columnName = "Respiratory_Rate"

            // Create a ContentValues object to store the new value
            val values = ContentValues().apply {
                put(columnName, respiratoryRate)
            }

            // Update the database
            val rowsUpdated = db.update(
                DatabaseHelper.TABLE_NAME,
                values,
                null,
                null
            )

            db.close()

            // Check if the update was successful and display a message
            if (rowsUpdated > 0) {
                val message = "Respiratory Rate updated: $respiratoryRate BPM"
                showToast(message)
            } else {
                val message = "Failed to update Respiratory Rate"
                showToast(message)
            }
        }
    }

    private fun showToast(message: String) {
        Toast.makeText(this, message, Toast.LENGTH_SHORT).show()
    }

}

