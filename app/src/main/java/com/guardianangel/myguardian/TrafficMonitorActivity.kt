package com.guardianangel.myguardian

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.os.Environment
import android.util.Log
import android.view.View
import android.widget.Button
import android.widget.EditText
import com.google.maps.DirectionsApi
import com.google.maps.GeoApiContext
import com.google.maps.model.DirectionsResult
import com.google.maps.model.LatLng
import com.google.maps.model.TravelMode
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import java.io.File
import java.time.Instant

class TrafficMonitorActivity : AppCompatActivity() {

    private lateinit var sourceAddressEditText: EditText
    private lateinit var destinationAddressEditText: EditText
    private val trafficDataList = mutableListOf<TrafficData>()

    data class TrafficData(
//        val waypoint: LatLng,
//        val nextWaypoint: LatLng,
        val trafficConditions: String,
        val distance: String,
        val duration: String,
        val startAddress: String,
        val endAddress: String
    )

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.traffic_monitor)

        sourceAddressEditText = findViewById(R.id.source)
        destinationAddressEditText = findViewById(R.id.destination)

    }

    fun startTrafficMonitoring(view: View) {
        val sourceAddress = sourceAddressEditText.text.toString()
        val destinationAddress = destinationAddressEditText.text.toString()
        val now: Instant = Instant.now()

        // Initialize the GeoApiContext with your API key
        val context = GeoApiContext.Builder().apiKey("AIzaSyD0JJdFan2SZGn_R_SV4kEP-3bC3KbvF-c").build()
        Log.d("TrafficMonitorActivity", "Starting traffic monitoring for source: $sourceAddress, destination: $destinationAddress")

        // Request directions between source and destination
        GlobalScope.launch(Dispatchers.IO) {
            try {
                val request = DirectionsApi.getDirections(context, sourceAddress, destinationAddress)
                    .mode(TravelMode.DRIVING)
                    .departureTime(now)
                    .await()
                handleDirectionsResult(request)
            } catch (e: Exception) {
                Log.e("API Request Error", e.message, e)
            }
        }
    }

    private fun handleDirectionsResult(result: DirectionsResult) {
        if (result.routes.isNotEmpty()) {
            val route = result.routes[0]
            val path = route.overviewPolyline.decodePath()

            // Access route details and print them
            val distance = route.legs[0].distance
            val duration = route.legs[0].duration
            val startAddress = route.legs[0].startAddress
            val endAddress = route.legs[0].endAddress
            val traffic = route.legs[0].durationInTraffic

            // Log the route details
            Log.d("Route Details", "Distance: ${distance.humanReadable}")
            Log.d("Route Details", "Duration: ${duration.humanReadable}")
            Log.d("Route Details", "Start Address: $startAddress")
            Log.d("Route Details", "End Address: $endAddress")
            Log.d("Traffic Details", "Traffic: $traffic")

            trafficDataList.add(
                TrafficData(
                    traffic.humanReadable, distance.humanReadable, duration.humanReadable,
                    startAddress, endAddress
                )
            )

//            sampleTrafficData(path)

        }
    }

    private fun sampleTrafficData(path: List<LatLng>) {
        val sampleRate = 50 // Sample every 50 coordinates
        val context = GeoApiContext.Builder().apiKey("AIzaSyD0JJdFan2SZGn_R_SV4kEP-3bC3KbvF-c").build()
        val now: Instant = Instant.now()

        for (i in 0 until path.size step sampleRate) {
            val waypoint = path[i]
            val nextWaypoint = if (i + sampleRate < path.size) path[i + sampleRate] else path.last()

            GlobalScope.launch(Dispatchers.IO) {
                try {
                    val request = DirectionsApi.getDirections(context, waypoint.toUrlValue(), nextWaypoint.toUrlValue())
                        .mode(TravelMode.DRIVING)
                        .departureTime(now) // Specify "now" for real-time traffic data
                        .await()

                    handleTrafficDataResult(request, waypoint, nextWaypoint)
                } catch (e: Exception) {
                    Log.e("Traffic Data Request Error", e.message, e)
                }
            }
        }
    }

    private fun handleTrafficDataResult(result: DirectionsResult, waypoint: LatLng, nextWaypoint: LatLng) {
        if (result.routes.isNotEmpty()) {
            val route = result.routes[0]

            if (route.legs.isNotEmpty()) {
                val leg = route.legs[0]

                // Extract traffic information from the route and handle it.
                val trafficConditions = leg.durationInTraffic
                val distance = leg.distance
                val duration = leg.duration
                val startAddress = leg.startAddress
                val endAddress = leg.endAddress

                if (trafficConditions != null) {
                    Log.d("Traffic Data", "Waypoint: $waypoint to $nextWaypoint")
                    Log.d("Traffic Data", "Traffic Conditions: ${trafficConditions.humanReadable}")
                    Log.d("Traffic Data", "Distance: ${distance.humanReadable}")
                    Log.d("Traffic Data", "Duration: ${duration.humanReadable}")
                    Log.d("Traffic Data", "Start Address: $startAddress")
                    Log.d("Traffic Data", "End Address: $endAddress")

//                    trafficDataList.add(
//                        TrafficData(
//                            waypoint, nextWaypoint, trafficConditions.humanReadable, distance.humanReadable, duration.humanReadable,
//                            startAddress, endAddress
//                        )
//                    )

                } else {
                    Log.d("Traffic Data", "No traffic data available for this waypoint.")
                }
            } else {
                Log.d("Traffic Data", "No legs in the route.")
            }
        } else {
            Log.d("Traffic Data", "No routes in the result.")
        }
    }

    fun onExportButtonClick(view: View) {
        exportTrafficDataToFile()
        Log.d("Save Message", "The traffic data has been successfully collected.")
    }

    private fun exportTrafficDataToFile() {
        val directory = File(Environment.getExternalStorageDirectory(), "ASU/Semester_2/Mobile_Computing/project_3_sample")

        if (!directory.exists()) {
            directory.mkdirs()
        }

        val outputFile = File(directory, "traffic_data.txt")
        val outputWriter = outputFile.bufferedWriter()

        trafficDataList.forEach { data ->
            outputWriter.write(
                    "${data.trafficConditions},${data.distance},${data.duration}," +
                    "${data.startAddress},${data.endAddress}\n")
        }
        outputWriter.close()
    }
}