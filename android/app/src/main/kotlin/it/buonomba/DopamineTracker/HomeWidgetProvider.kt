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

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == ACTION_LOG_TRIGGER) {
            logTriggerFromWidget(context)

            // Update all widgets
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(
                ComponentName(context, HomeWidgetProvider::class.java)
            )
            for (appWidgetId in appWidgetIds) {
                updateAppWidget(context, appWidgetManager, appWidgetId)
            }
        }
    }

    companion object {
        private const val ACTION_LOG_TRIGGER = "it.buonomba.DopamineTracker.action.LOG_TRIGGER"

        fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
            val views = RemoteViews(context.packageName, R.layout.widget_layout)

            val prefs: SharedPreferences = context.getSharedPreferences(
                "FlutterSharedPreferences", Context.MODE_PRIVATE
            )

            // --- Today's smoke count ---
            val todayCount = getTodayCount(prefs)
            views.setTextViewText(R.id.tv_smoked_today, todayCount.toString())

            // --- Log cigarette button ---
            val intent = Intent(context, HomeWidgetProvider::class.java).apply {
                action = ACTION_LOG_TRIGGER
            }
            val pendingIntent = PendingIntent.getBroadcast(
                context, 0, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.btn_log_cigarette, pendingIntent) // Il pulsante rimane lo stesso, solo l'azione cambia.

            // --- Open app on tap on the widget body ---
            val launchIntent = Intent(context, MainActivity::class.java)
            val launchPendingIntent = PendingIntent.getActivity(
                context, 1, launchIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_container, launchPendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        private fun getTodayCount(prefs: SharedPreferences): Int {
            val smokeLogString = prefs.getString("flutter.smokeLog", null) ?: return 0
            return try {
                val smokeLog = JSONObject(smokeLogString)
                val calendar = Calendar.getInstance()
                val year = calendar.get(Calendar.YEAR)
                val month = calendar.get(Calendar.MONTH) + 1 // Month is 0-indexed
                val day = calendar.get(Calendar.DAY_OF_MONTH)
                val today = String.format(Locale.US, "%04d-%02d-%02d", year, month, day)
                smokeLog.optInt(today, 0)
            } catch (e: Exception) {
                0
            }
        }

        private fun logTriggerFromWidget(context: Context) {
            val prefs: SharedPreferences = context.getSharedPreferences(
                "FlutterSharedPreferences", Context.MODE_PRIVATE
            )

            // Update smokeLog
            val smokeLogString = prefs.getString("flutter.smokeLog", null)
            val smokeLog = if (smokeLogString != null) {
                try {
                    JSONObject(smokeLogString)
                } catch (e: Exception) {
                    JSONObject()
                }
            } else {
                JSONObject()
            }

            val calendar = Calendar.getInstance()
            val year = calendar.get(Calendar.YEAR)
            val month = calendar.get(Calendar.MONTH) + 1 // Month is 0-indexed
            val day = calendar.get(Calendar.DAY_OF_MONTH)
            val today = String.format(Locale.US, "%04d-%02d-%02d", year, month, day)

            val currentCount = smokeLog.optInt(today, 0)
            smokeLog.put(today, currentCount + 1)

            val editor = prefs.edit()
            editor.putString("flutter.smokeLog", smokeLog.toString())

            // Update lastSmoked timestamp
            val now = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS", Locale.US).format(Date())
            editor.putString("flutter.lastSmoked", now)
            editor.putBoolean("flutter.hasStarted", true)

            editor.apply()
        }
    }
}
