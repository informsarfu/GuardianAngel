package com.guardianangel.myguardian

import android.content.ContentValues
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.Button
import android.widget.RatingBar
import android.widget.TextView
import android.widget.Toast

class SymptomSelectionActivity : AppCompatActivity(), SymptomsDialogFragment.SymptomSelectionListener {

    private lateinit var selectedSymptomTextView: TextView
    private lateinit var symptomRatingBar: RatingBar
    private var shouldInsertData = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_symptom_selection)

        val symptomSelector = findViewById<Button>(R.id.symptomSelector)
        symptomRatingBar = findViewById<RatingBar>(R.id.symptomRatingBar)
        selectedSymptomTextView = findViewById<TextView>(R.id.selectedSymptomTextView)
        val backButton = findViewById<Button>(R.id.backButton)

        symptomSelector.setOnClickListener (View.OnClickListener{
            val dialogFragment = SymptomsDialogFragment(this)
            dialogFragment.show(supportFragmentManager, "SymptomsDialog")
        })

        symptomRatingBar.setOnRatingBarChangeListener { _, rating, fromUser ->
            if(fromUser) {
                Toast.makeText(this, "Selected Rating: $rating", Toast.LENGTH_SHORT).show()
                Log.d("SymptomSelectionActivity", "Selected Rating: $rating")
                shouldInsertData = true
                insertIntoDatabase()
            }
        }

        backButton.setOnClickListener{
            onBackPressed()
        }
    }

    override fun onSymptomSelected(symptom: String) {
        updateSelectedSymptom(symptom)
        symptomRatingBar.rating = 0.0f
        shouldInsertData = true
        insertIntoDatabase()
    }


    private fun insertIntoDatabase() {
        val dbHelper = DatabaseHelper(this)
        val db = dbHelper.writableDatabase
        val symptom = selectedSymptomTextView.text.toString()
        val rating = symptomRatingBar.rating

        val values = ContentValues()
        values.put(symptom, rating)

        val affectedRows = db.update(
            DatabaseHelper.TABLE_NAME,
            values,
            "_id = ?",
            arrayOf("1")
        )

        if (affectedRows == 0) {
            val newRowId = db.insert(DatabaseHelper.TABLE_NAME, null, values)

            if (newRowId != -1L) {
                Toast.makeText(this, "New row inserted into the database", Toast.LENGTH_SHORT).show()
            } else {
                Toast.makeText(this, "Data insertion failed", Toast.LENGTH_SHORT).show()
            }
        } else {
            Toast.makeText(this, "Data updated in the database", Toast.LENGTH_SHORT).show()
        }

        db.close()
    }



    private fun updateSelectedSymptom(symptom: String) {
        selectedSymptomTextView.text = "$symptom"
    }

}