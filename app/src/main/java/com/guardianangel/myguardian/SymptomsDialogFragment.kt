package com.guardianangel.myguardian

import android.app.AlertDialog
import android.app.Dialog
import android.content.DialogInterface
import android.os.Bundle
import androidx.fragment.app.DialogFragment
import android.widget.RatingBar

class SymptomsDialogFragment(private val listener: SymptomSelectionListener) : DialogFragment() {

    interface SymptomSelectionListener {
        fun onSymptomSelected(symptom: String)
    }

    override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
        val symptoms = arrayOf("Nausea", "Headache", "Diarrhea", "Soar Throat", "Fever", "Muscle Ache","Loss of Smell or Taste", "Cough", "Shortness of Breadth", "Feeling Tired")

        val builder = AlertDialog.Builder(requireActivity())

        builder.setTitle("Select a Symptom")
            .setSingleChoiceItems(symptoms, -1) { _, which ->
                val selectedSymptom = symptoms[which]
                listener.onSymptomSelected(selectedSymptom)
                dismiss()
            }

            .setNegativeButton("Cancel") { dialog, _ ->
                dialog.dismiss()
            }

        return builder.create()
    }
}
