import android.content.Context
import android.net.Uri
import android.provider.MediaStore

object UriUtils {
    fun convertMediaUriToPath(context: Context, uri: Uri): String? {
//        if (uri == null) {
//            return ""  // Handle null URI as needed
//        }
//
//        val resourceId = context.resources.getIdentifier(uri.lastPathSegment, "raw", context.packageName)
//
//        if (resourceId == 0) {
//            return ""  // Resource not found
//        }
//
//        return "android.resource://$context.packageName/$resourceId"
        val proj = arrayOf(MediaStore.Images.Media.DATA)
        val cursor = context.contentResolver.query(uri, proj, null, null, null)
        cursor?.use {
            if (it.moveToFirst()) {
                val column_index = it.getColumnIndexOrThrow(MediaStore.Images.Media.DATA)
                return it.getString(column_index)
            }
        }
        return null // Return null if there's no valid path
    }
}
