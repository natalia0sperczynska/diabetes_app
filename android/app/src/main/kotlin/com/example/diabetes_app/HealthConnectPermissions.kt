package com.example.diabetes_app

import androidx.activity.ComponentActivity
import androidx.activity.result.ActivityResultLauncher
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.permission.HealthPermission
import androidx.health.connect.client.records.StepsRecord
import androidx.health.connect.client.PermissionController
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class HealthConnectPermissions(private val activity: ComponentActivity) : MethodChannel.MethodCallHandler {

    private val permissions = setOf(
        HealthPermission.getReadPermission(StepsRecord::class)
        // Add more later if you want:
        // HealthPermission.getReadPermission(HeartRateRecord::class),
        // HealthPermission.getReadPermission(BloodGlucoseRecord::class),
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
            else -> result.notImplemented()
        }
    }
}
