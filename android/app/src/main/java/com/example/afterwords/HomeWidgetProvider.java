package com.example.afterwords;

import android.annotation.TargetApi;
import android.appwidget.AppWidgetProvider;
import android.appwidget.AppWidgetManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.widget.RemoteViews;
import android.app.PendingIntent;
import android.util.Log;
import android.content.SharedPreferences;
import android.os.AsyncTask;

import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;

import org.json.JSONObject;

@TargetApi(Build.VERSION_CODES.CUPCAKE)
public class HomeWidgetProvider extends AppWidgetProvider {

    private static final String ACTION_CHECK_IN = "com.example.afterwords.CHECK_IN";
    private static final String TAG = "HomeWidgetProvider";

    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {

        for (int appWidgetId : appWidgetIds) {
            RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.home_widget);

            // Retrieve data from SharedPreferences
            SharedPreferences prefs = context.getSharedPreferences("afterwords_prefs", Context.MODE_PRIVATE);
            int checkInFreq = prefs.getInt("checkInFreq", 0);
            String lastLogin = prefs.getString("lastLogin", "N/A");

            // Update widget views
            views.setTextViewText(R.id.textViewCheckInFreq, "Check-Ins: " + checkInFreq);
            views.setTextViewText(R.id.textViewLastLogin, "Last Login: " + lastLogin);

            // Set up the Check In button click to trigger ACTION_CHECK_IN
            Intent intent = new Intent(context, HomeWidgetProvider.class);
            intent.setAction(ACTION_CHECK_IN);
            PendingIntent pendingIntent = PendingIntent.getBroadcast(
                    context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
            views.setOnClickPendingIntent(R.id.buttonCheckIn, pendingIntent);

            Log.d(TAG, "Updating widget ID: " + appWidgetId);

            appWidgetManager.updateAppWidget(appWidgetId, views);
        }
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        super.onReceive(context, intent);

        if (ACTION_CHECK_IN.equals(intent.getAction())) {
            Log.d(TAG, "Check In button clicked");

            // Handle the Check In action
            handleCheckIn(context);
        }
    }

    private void handleCheckIn(Context context) {
        // Retrieve user ID from SharedPreferences
        SharedPreferences prefs = context.getSharedPreferences("afterwords_prefs", Context.MODE_PRIVATE);
        int userId = prefs.getInt("userId", -1);

        if (userId == -1) {
            Log.d(TAG, "User not logged in. Cannot perform check-in.");
            return;
        }

        // Perform network operation in AsyncTask
        new CheckInTask(context, userId).execute();
    }

    private static class CheckInTask extends AsyncTask<Void, Void, Boolean> {

        private Context mContext;
        private int mUserId;

        CheckInTask(Context context, int userId) {
            mContext = context;
            mUserId = userId;
        }

        @Override
        protected Boolean doInBackground(Void... voids) {
            try {
                URL url = new URL("http://161.35.116.218:5000/api/checkIn");
                HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                conn.setRequestMethod("POST");
                conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
                conn.setDoOutput(true);

                JSONObject jsonParam = new JSONObject();
                jsonParam.put("UserId", mUserId);

                OutputStream os = conn.getOutputStream();
                os.write(jsonParam.toString().getBytes("UTF-8"));
                os.close();

                int responseCode = conn.getResponseCode();
                Log.d(TAG, "Check-in response code: " + responseCode);

                if (responseCode == HttpURLConnection.HTTP_OK) {
                    // Update SharedPreferences
                    SharedPreferences prefs = mContext.getSharedPreferences("afterwords_prefs", Context.MODE_PRIVATE);
                    SharedPreferences.Editor editor = prefs.edit();

                    int checkInFreq = prefs.getInt("checkInFreq", 0) + 1;
                    String lastLogin = java.text.DateFormat.getDateTimeInstance().format(new java.util.Date());

                    editor.putInt("checkInFreq", checkInFreq);
                    editor.putString("lastLogin", lastLogin);
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.GINGERBREAD) {
                        editor.apply();
                    }

                    // Update the widget
                    AppWidgetManager appWidgetManager = AppWidgetManager.getInstance(mContext);
                    ComponentName thisWidget = new ComponentName(mContext, HomeWidgetProvider.class);
                    int[] appWidgetIds = appWidgetManager.getAppWidgetIds(thisWidget);

                    new HomeWidgetProvider().onUpdate(mContext, appWidgetManager, appWidgetIds);

                    return true;
                } else {
                    Log.d(TAG, "Check-in failed with response code: " + responseCode);
                    return false;
                }
            } catch (Exception e) {
                Log.e(TAG, "Error during check-in", e);
                return false;
            }
        }
    }
}
