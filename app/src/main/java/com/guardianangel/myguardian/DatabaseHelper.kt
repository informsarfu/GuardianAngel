package com.guardianangel.myguardian

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper

class DatabaseHelper(context: Context) : SQLiteOpenHelper(context, DATABASE_NAME, null, DATABASE_VERSION) {
    companion object {
        const val DATABASE_NAME = "Symptom_Readings.db"
        const val DATABASE_VERSION = 1
        const val TABLE_NAME = "readings"
    }

    override fun onCreate(db: SQLiteDatabase) {
        val createTableQuery = StringBuilder()
        createTableQuery.append("CREATE TABLE $TABLE_NAME (_id INTEGER PRIMARY KEY AUTOINCREMENT, ")

        // List of symptoms
        val symptoms = listOf("Heart_Rate","Respiratory_Rate", "Nausea", "Headache", "Diarrhea", "Soar_Throat", "Fever", "Muscle_Ache","Loss_of_Smell_or_Taste", "Cough", "Shortness_of_Breadth", "Feeling_Tired")

        // Add columns for each symptom with an initial value of 0.0
        for (symptom in symptoms) {
            createTableQuery.append("$symptom REAL DEFAULT 0.0, ")
        }

        // Remove the trailing comma and space
        createTableQuery.delete(createTableQuery.length - 2, createTableQuery.length)
        createTableQuery.append(")")

        db.execSQL(createTableQuery.toString())
    }

    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
    }
}