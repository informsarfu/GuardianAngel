import android.app.AlertDialog
import android.app.Dialog
import android.content.DialogInterface
import android.os.Bundle
import androidx.fragment.app.DialogFragment

class SymptomsDialogFragment : DialogFragment() {

    override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
        val symptoms = arrayOf("Fever", "Cough", "Fatigue", "Headache", "Nausea")
        val checkedItems = booleanArrayOf(false, false, false, false, false)

        val builder = AlertDialog.Builder(requireActivity())
        builder.setTitle("Select Symptoms")
            .setMultiChoiceItems(symptoms, checkedItems) { _, which, isChecked ->
                checkedItems[which] = isChecked
            }
            .setPositiveButton("OK") { _, _ ->
                val selectedSymptoms = mutableListOf<String>()
                for (i in checkedItems.indices) {
                    if (checkedItems[i]) {
                        selectedSymptoms.add(symptoms[i])
                    }
                }
                // Handle selected symptoms here
            }
            .setNegativeButton("Cancel") { dialog, _ ->
                dialog.dismiss()
            }

        return builder.create()
    }
}