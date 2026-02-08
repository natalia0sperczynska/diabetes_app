package com.example.diabetes_app

import androidx.activity.ComponentActivity
import androidx.activity.result.ActivityResultLauncher
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.PermissionController
import androidx.health.connect.client.permission.HealthPermission
import androidx.health.connect.client.records.HeartRateRecord
import androidx.health.connect.client.records.StepsRecord
import androidx.health.connect.client.request.ReadRecordsRequest
import androidx.health.connect.client.time.TimeRangeFilter
import androidx.lifecycle.lifecycleScope
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.launch
import java.time.Instant

class HealthConnectPermissions(
    private val activity: ComponentActivity
) : MethodChannel.MethodCallHandler {

    private val permissions = setOf(
        HealthPermission.getReadPermission(StepsRecord::class)
    )

    private var pendingResult: MethodChannel.Result? = null

    private val permissionLauncher: ActivityResultLauncher<Set<String>> =
        activity.registerForActivityResult(
            PermissionController.createRequestPermissionResultContract()
        ) { granted: Set<String> ->
            val ok = granted.containsAll(permissions)
            pendingResult?.success(ok)
            pendingResult = null
        }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "requestHealthConnectPermissions" -> {
                val status = HealthConnectClient.getSdkStatus(activity)
                if (status != HealthConnectClient.SDK_AVAILABLE) {
                    result.success(false)
                    return
                }

                // Prevent double calls
                if (pendingResult != null) {
                    result.error("IN_PROGRESS", "Permission request already in progress", null)
                    return
                }

                pendingResult = result
                permissionLauncher.launch(permissions)
            }

            /**
             * Reads HR samples (HeartRateRecord) from Health Connect.
             * Returns List<Map<String, Any>> with keys:
             * - t: Long (epoch millis)
             * - bpm: Double
             *
             * Arguments (Map):
             * - startMillis: Long
             * - endMillis: Long
             * - allowedPackages: List<String> (optional) -> filters by DataOrigin.packageName
             */
            "readHeartRateSeries" -> {
                val status = HealthConnectClient.getSdkStatus(activity)
                if (status != HealthConnectClient.SDK_AVAILABLE) {
                    result.success(emptyList<Map<String, Any>>())
                    return
                }

                val args = call.arguments as? Map<*, *>
                val startMillis = (args?.get("startMillis") as? Number)?.toLong()
                val endMillis = (args?.get("endMillis") as? Number)?.toLong()
                val allowedPackages = (args?.get("allowedPackages") as? List<*>)?.mapNotNull { it?.toString() }

                if (startMillis == null || endMillis == null) {
                    result.error("BAD_ARGS", "startMillis/endMillis required", null)
                    return
                }

                activity.lifecycleScope.launch {
                    try {
                        val client = HealthConnectClient.getOrCreate(activity)

                        val start = Instant.ofEpochMilli(startMillis)
                        val end = Instant.ofEpochMilli(endMillis)

                        val response = client.readRecords(
                            ReadRecordsRequest(
                                recordType = HeartRateRecord::class,
                                timeRangeFilter = TimeRangeFilter.between(start, end),
                                pageSize = 5000
                            )
                        )

                        val out = ArrayList<Map<String, Any>>(response.records.size)

                        for (record in response.records) {
                            if (!allowedPackages.isNullOrEmpty()) {
                                val originPkg = record.metadata.dataOrigin.packageName
                                if (!allowedPackages.contains(originPkg)) continue
                            }

                            for (sample in record.samples) {
                                out.add(
                                    mapOf(
                                        "t" to sample.time.toEpochMilli(),
                                        "bpm" to sample.beatsPerMinute.toDouble()
                                    )
                                )
                            }
                        }

                        out.sortBy { (it["t"] as Long) }

                        result.success(out)
                    } catch (e: Exception) {
                        result.error("HC_READ_ERROR", e.message, null)
                    }
                }
            }

            else -> result.notImplemented()
        }
    }
}
