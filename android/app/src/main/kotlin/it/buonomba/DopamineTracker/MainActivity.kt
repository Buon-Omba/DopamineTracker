package it.buonomba.DopamineTracker

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import it.buonomba.DopamineTracker.HomeWidgetProvider

class MainActivity : FlutterActivity() {
    private val CHANNEL = "it.buonomba.DopamineTracker/app_widgets"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "updateHomeWidgets") {
                    updateAllWidgets()
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun updateAllWidgets() {
        val appWidgetManager = AppWidgetManager.getInstance(applicationContext)

        // Update HomeWidgetProvider widgets
        val homeWidgetIds = appWidgetManager.getAppWidgetIds(
            ComponentName(applicationContext, HomeWidgetProvider::class.java)
        )
        for (id in homeWidgetIds) {
            HomeWidgetProvider.updateAppWidget(applicationContext, appWidgetManager, id)
        }
    }
}
