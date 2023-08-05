package com.carpool;

import java.util.regex.Pattern;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.media.MediaPlayer;
import android.os.Vibrator;
import android.view.View;
import android.widget.Toast;

public class GlobalData
{
	public static final String g_SharedPreferencesName = "Ride2Gather";
	public static final String g_SharedPreferencesIntro = "Intro";
	public static final String g_SharedPreferencesUserID = "UserID";
	public static final String g_SharedPreferencesUserName = "UserName";
	public static final String g_SharedPreferencesEmailAddress = "EmailAddress";
	public static final String g_SharedPreferencesSrcAddress = "SrcAddress";
	public static final String g_SharedPreferencesSrcLatitude = "SrcLatitude";
	public static final String g_SharedPreferencesSrcLongitude = "SrcLongitude";
	public static final String g_SharedPreferencesDstLatitude = "DstLatitude";
	public static final String g_SharedPreferencesDstLongitude = "DstLongitude";
	public static final String g_SharedPreferencesUserPassword = "UserPassword";
	
	public static final String g_SharedPreferences_MyInfoDestination = "MyInfoDestination";
	public static final String g_SharedPreferences_MyInfoCount = "MyInfoCount";
	public static final String g_SharedPreferences_MyInfoGrpGender = "MyInfoGrpGender";
	public static final String g_SharedPreferences_MyInfoColor = "MyInfoColor";
	public static final String g_SharedPreferences_MyInfoOtherFeature = "MyInfoOtherFeature";
	public static final String g_SharedPreferences_MyQueueOrder = "MyQueueOrder";
	
	public static final String g_SharedPreferences_PairID = "PairID";
	public static final String g_SharedPreferences_PairName = "PairName";
	public static final String g_SharedPreferences_PairDestination = "PairDestination";
	public static final String g_SharedPreferences_PairTopColor = "PairTopColor";
	public static final String g_SharedPreferences_PairCount = "PairCount";
	public static final String g_SharedPreferences_PairGrpGender = "PairGrpGender";
	public static final String g_SharedPreferences_PairOtherFeature = "PairOtherFeature";
	public static final String g_SharedPreferences_PairSaveMoney = "PairSaveMoney";
	public static final String g_SharedPreferences_PairLostTime = "PairLostTime";
	public static final String g_SharedPreferences_PairPairingTime = "PairPairingTime";
	
	public static final String g_SharedPreferences_SettingFlag = "SettingFlag";

	// 0 : Normal Login	
	// 1 : Facebook Login	
	// 2 : LinkedIn Login
	public static final String g_SharedPreferences_LoginKind = "LoginKind";
	
	public static final String g_SharedPreferences_FGender = "FGender";
	public static final String g_SharedPreferences_FBirthYear = "FBirthYear";
	public static final String g_SharedPreferences_FEmail = "FEmail";
	public static final String g_SharedPreferences_FPhoneNumber = "FPhoneNumber";
	
	public static final String g_SharedPreferences_LGender = "LGender";
	public static final String g_SharedPreferences_LBirthYear = "LBirthYear";
	public static final String g_SharedPreferences_LEmail = "LEmail";
	public static final String g_SharedPreferences_LPhoneNumber = "LPhoneNumber";
	
	public static int g_nFLLogin = -1;
		
	public static final String g_PublicKey = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAzvOzplmcJrBB/VSrkgiMmNE6biR+BS3e+lUsGSXfoEmp0z4/d+z1x4daduPAbScOlhLvjAQixqBN6B59s8sD+KksFf0z1n8/+X+wlV1SsDuyqXNaVOFEOD5sZwLuEb5r7ZAqcA8eWqvdkbUD/CUMLNUkSdh+6EncvcxVBHjP+EDuoUemilMtZOH9ELtIgBr5EEf4ZKRQombxmvfoF47RLHFSifHQ4xGvUMHy92+1wZ+zZJTrYZck0hYD4j2aSPE8GwmWDbBa8UT2MCKrh38L1Q5RwqpawtICDxFNOVgobjf4p7OmJ8R9ttmsAy3ctKJytZ5AFYPv88e/mPA/tNaVSQIDAQAB";
	
	private static final Pattern EMAIL_ADDRESS_PATTERN = Pattern.compile(
	          "[a-zA-Z0-9\\+\\.\\_\\%\\-\\+]{1,256}" +
	          "\\@" +
	          "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
	          "(" +
	          "\\." +
	          "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
	          ")+"
	      );
	
	private static Toast g_Toast = null;
	public static void showToast(Context context, String toastStr)
	{
		if ((g_Toast == null) || (g_Toast.getView().getWindowVisibility() != View.VISIBLE))
		{
			g_Toast = Toast.makeText(context, toastStr, Toast.LENGTH_SHORT);
			g_Toast.show();
		}

		return;
	}
		
	public static boolean isValidEmail(String strEmail)
	{
		return EMAIL_ADDRESS_PATTERN.matcher(strEmail).matches();
	}
	

    public static MediaPlayer soundPlayer = null;
	public static void playSoundAndVibrate(Context context)
	{
		Vibrator vib = (Vibrator) context.getSystemService(Context.VIBRATOR_SERVICE);
		vib.vibrate(1000);
		
		soundPlayer = new MediaPlayer();
		soundPlayer = MediaPlayer.create(context, R.raw.notify);
        //audioManager = (AudioManager) context.getSystemService(context.AUDIO_SERVICE);
        
        try {
            if (soundPlayer != null) {
            	soundPlayer.stop();
            }
            soundPlayer.prepare();
            soundPlayer.start();

        } catch (IllegalStateException e) {
            e.printStackTrace();
        } catch (Exception e) {
            e.printStackTrace();
        }
	}
	
	@SuppressWarnings({ "deprecation" })
	public static void generateNotification(Context context, String strData)
	{
        int icon = R.drawable.ic_launcher;
        long when = System.currentTimeMillis();
        NotificationManager notificationManager = (NotificationManager)context.getSystemService(Context.NOTIFICATION_SERVICE);

        Notification notification = new Notification(icon, strData, when);

        Intent notificationIntent = new Intent(context, NotificationActivity.class);
        notificationIntent.putExtra("Content", strData);        
        notificationIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);

        PendingIntent intent = PendingIntent.getActivity(context, 100, notificationIntent, PendingIntent.FLAG_CANCEL_CURRENT);
        notification.setLatestEventInfo(context, strData, "", intent);
        notification.flags |= Notification.FLAG_AUTO_CANCEL;
        notificationManager.notify(100, notification);
    }
	
	public static void showNotification(Context context, String strData)
	{
		generateNotification(context, strData);
		playSoundAndVibrate(context);
		
		return;
	}
}