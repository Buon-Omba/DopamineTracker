package it.buonomba.DopamineTracker

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale

class HomeWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onDeleted(context: Context, appWidgetIds: IntArray) {
        val prefs = context.getSharedPreferences("WidgetPrefs", Context.MODE_PRIVATE).edit()
        for (appWidgetId in appWidgetIds) {
            prefs.remove("widget_${appWidgetId}_id")
            prefs.remove("widget_${appWidgetId}_name")
        }
        prefs.apply()
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == ACTION_LOG_TRIGGER) {
            val appWidgetId = intent.getIntExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID)
            if (appWidgetId != AppWidgetManager.INVALID_APPWIDGET_ID) {
                logTriggerFromWidget(context, appWidgetId)

                // Update all widgets or just this one? Usually all to keep consistency if multiple widgets track same addiction
                val appWidgetManager = AppWidgetManager.getInstance(context)
                val appWidgetIds = appWidgetManager.getAppWidgetIds(
                    ComponentName(context, HomeWidgetProvider::class.java)
                )
                for (id in appWidgetIds) {
                    updateAppWidget(context, appWidgetManager, id)
                }
            }
        }
    }

    companion object {
        private const val ACTION_LOG_TRIGGER = "it.buonomba.DopamineTracker.action.LOG_TRIGGER"

        fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
            val views = RemoteViews(context.packageName, R.layout.widget_layout)

            val widgetPrefs = context.getSharedPreferences("WidgetPrefs", Context.MODE_PRIVATE)
            val addictionId = widgetPrefs.getString("widget_${appWidgetId}_id", null)
            val addictionName = widgetPrefs.getString("widget_${appWidgetId}_name", "Dopamine")

            val prefs: SharedPreferences = context.getSharedPreferences(
                "FlutterSharedPreferences", Context.MODE_PRIVATE
            )

            // --- Today's count ---
            val todayCount = if (addictionId != null) getTodayCount(prefs, addictionId) else 0
            views.setTextViewText(R.id.tv_smoked_today, todayCount.toString())
            
            // Update title with addiction name
            views.setTextViewText(R.id.tv_widget_title, addictionName)
            views.setTextViewText(R.id.tv_today_label, "OGGI")

            // --- Log button ---
            val intent = Intent(context, HomeWidgetProvider::class.java).apply {
                action = ACTION_LOG_TRIGGER
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            }
            val pendingIntent = PendingIntent.getBroadcast(
                context, appWidgetId, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.btn_log_cigarette, pendingIntent)

            // --- Open app on tap on the widget body ---
            val launchIntent = Intent(context, MainActivity::class.java)
            val launchPendingIntent = PendingIntent.getActivity(
                context, appWidgetId + 1000, launchIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_container, launchPendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        private fun getTodayCount(prefs: SharedPreferences, addictionId: String): Int {
            val key = "flutter.dopamineLog_$addictionId"
            val logString = prefs.getString(key, null) ?: return 0
            return try {
                val log = JSONObject(logString)
                val calendar = Calendar.getInstance()
                val today = String.format(Locale.US, "%04d-%02d-%02d", 
                    calendar.get(Calendar.YEAR), 
                    calendar.get(Calendar.MONTH) + 1, 
                    calendar.get(Calendar.DAY_OF_MONTH))
                log.optInt(today, 0)
            } catch (e: Exception) {
                0
            }
        }

        private fun logTriggerFromWidget(context: Context, appWidgetId: Int) {
            val widgetPrefs = context.getSharedPreferences("WidgetPrefs", Context.MODE_PRIVATE)
            val addictionId = widgetPrefs.getString("widget_${appWidgetId}_id", null) ?: return

            val prefs: SharedPreferences = context.getSharedPreferences(
                "FlutterSharedPreferences", Context.MODE_PRIVATE
            )

            val logKey = "flutter.dopamineLog_$addictionId"
            val lastTriggerKey = "flutter.lastTrigger_$addictionId"

            val logString = prefs.getString(logKey, null)
            val log = if (logString != null) {
                try {
                    JSONObject(logString)
                } catch (e: Exception) {
                    JSONObject()
                }
            } else {
                JSONObject()
            }

            val calendar = Calendar.getInstance()
            val today = String.format(Locale.US, "%04d-%02d-%02d", 
                calendar.get(Calendar.YEAR), 
                calendar.get(Calendar.MONTH) + 1, 
                calendar.get(Calendar.DAY_OF_MONTH))

            val currentCount = log.optInt(today, 0)
            log.put(today, currentCount + 1)

            val now = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS", Locale.US).format(Date())
            
            val editor = prefs.edit()
            editor.putString(logKey, log.toString())
            editor.putString(lastTriggerKey, now)
            editor.putBoolean("flutter.hasStarted", true)
            editor.commit()
        }
    }
}
