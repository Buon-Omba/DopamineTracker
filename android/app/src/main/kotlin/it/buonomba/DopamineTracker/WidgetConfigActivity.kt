package it.buonomba.DopamineTracker

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Bundle
import android.widget.ArrayAdapter
import android.widget.ListView
import org.json.JSONArray
import org.json.JSONObject

class WidgetConfigActivity : Activity() {

    private var appWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setResult(RESULT_CANCELED)
        setContentView(R.layout.widget_config_layout)

        val intent = intent
        val extras = intent.extras
        if (extras != null) {
            appWidgetId = extras.getInt(
                AppWidgetManager.EXTRA_APPWIDGET_ID,
                AppWidgetManager.INVALID_APPWIDGET_ID
            )
        }

        if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
            finish()
            return
        }

        val lvAddictions: ListView = findViewById(R.id.lv_addictions)
        val addictions = getAddictions()

        val adapter = ArrayAdapter(
            this,
            android.R.layout.simple_list_item_1,
            addictions.map { it.name }
        )
        lvAddictions.adapter = adapter

        lvAddictions.setOnItemClickListener { _, _, position, _ ->
            val selectedAddiction = addictions[position]
            saveWidgetPreference(appWidgetId, selectedAddiction.id, selectedAddiction.name)

            val appWidgetManager = AppWidgetManager.getInstance(this)
            HomeWidgetProvider.updateAppWidget(this, appWidgetManager, appWidgetId)

            val resultValue = Intent().apply {
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            }
            setResult(RESULT_OK, resultValue)
            finish()
        }
    }

    private fun getAddictions(): List<AddictionInfo> {
        val prefs: SharedPreferences = getSharedPreferences(
            "FlutterSharedPreferences", Context.MODE_PRIVATE
        )
        val addictionsJson = prefs.getString("flutter.addictions", null) ?: return emptyList()
        val list = mutableListOf<AddictionInfo>()
        try {
            val array = JSONArray(addictionsJson)
            for (i in 0 until array.length()) {
                val obj = array.getJSONObject(i)
                list.add(AddictionInfo(obj.getString("id"), obj.getString("name")))
            }
        } catch (e: Exception) {
            // handle error
        }
        return list
    }

    private fun saveWidgetPreference(appWidgetId: Int, addictionId: String, addictionName: String) {
        val prefs = getSharedPreferences("WidgetPrefs", Context.MODE_PRIVATE).edit()
        prefs.putString("widget_${appWidgetId}_id", addictionId)
        prefs.putString("widget_${appWidgetId}_name", addictionName)
        prefs.commit()
    }

    data class AddictionInfo(val id: String, val name: String)
}
