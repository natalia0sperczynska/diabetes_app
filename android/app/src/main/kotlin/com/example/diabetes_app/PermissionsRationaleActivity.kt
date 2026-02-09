package com.example.diabetes_app

import android.app.Activity
import android.os.Bundle
import android.widget.TextView

class PermissionsRationaleActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Minimal placeholder. Replace with your real privacy policy / rationale UI.
        val tv = TextView(this)
        tv.text = "This app requests Health Connect permissions to read steps, heart rate, and blood glucose for diabetes tracking."
        tv.textSize = 16f
        setContentView(tv)
    }
}
