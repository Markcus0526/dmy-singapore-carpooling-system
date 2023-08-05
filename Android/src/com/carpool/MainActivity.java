package com.carpool;

import java.lang.reflect.Method;
import org.json.JSONObject;
import com.CommService.CommMgr;
import com.HttpConn.JsonHttpResponseHandler;
import com.STData.STAuthUser;
import com.STData.STFLAuthInfo;
import com.STData.STLoginResult;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.Display;
import android.view.WindowManager;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;

@SuppressLint("HandlerLeak")
public class MainActivity extends Activity {
		
	private JsonHttpResponseHandler handler = null;
	public STAuthUser m_stAuthUser = new STAuthUser();
	public STFLAuthInfo m_stFLAuthUser = new STFLAuthInfo();
	public STLoginResult m_stLoginResult = new STLoginResult();
	
	private int nVal = 0;
	private int m_nLoginType = 0;
	
	private boolean getInternetConnected()
	{
		ConnectivityManager conMgr =  (ConnectivityManager)getSystemService(Context.CONNECTIVITY_SERVICE);
		
		NetworkInfo i = conMgr.getActiveNetworkInfo();
		  if (i == null)
		    return false;
		  if (!i.isConnected())
		    return false;
		  if (!i.isAvailable())
		    return false;
		  return true;
	}
	

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.main);
						
		if (getInternetConnected() == false)
		{
			GlobalData.showToast(MainActivity.this, getString(R.string.NetworkState_Error));
			MainActivity.this.finish();
			return;
		}
		
		WindowManager winManager = (WindowManager) getSystemService(WINDOW_SERVICE);
        Display display = winManager.getDefaultDisplay();
        @SuppressWarnings("deprecation")
		int nWidth = display.getWidth(), nHeight = display.getHeight();
        
       	int result = getStatusBarHeight();
       	
       	ResolutionSet._instance.setResolution(nWidth, nHeight - result);
       	ResolutionSet._instance.iterateChild(findViewById(R.id.llSplash));
       			
		Handler handler= new Handler() {
			public void handleMessage(Message msg){
				startActivity(new Intent(MainActivity.this, LoginActivity.class));
				finish();
			}
		};		

		SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
		m_nLoginType =  pref.getInt(GlobalData.g_SharedPreferences_LoginKind, 0);
		if (m_nLoginType  == 0)
		{
			m_stAuthUser.Email = pref.getString(GlobalData.g_SharedPreferencesEmailAddress, "");
			m_stAuthUser.Password = pref.getString(GlobalData.g_SharedPreferencesUserPassword, "");
			
			if (m_stAuthUser.Email != null && m_stAuthUser.Email.length() > 0)
				nVal = 1;
			else
				nVal = 0;
		}
		else if (m_nLoginType == 1)
		{
			m_stFLAuthUser.Email = pref.getString(GlobalData.g_SharedPreferences_FEmail, "");
			m_stFLAuthUser.BirthYear = pref.getInt(GlobalData.g_SharedPreferences_FBirthYear, 0);
			m_stFLAuthUser.Gender = pref.getInt(GlobalData.g_SharedPreferences_FGender, 0);
			m_stFLAuthUser.PhoneNum = pref.getString(GlobalData.g_SharedPreferences_FPhoneNumber, "");
			m_stFLAuthUser.ImageData = "img";
			
			if (m_stFLAuthUser.Email != null && m_stFLAuthUser.Email.length() > 0)
				nVal = 1;
			else
				nVal = 0;
		}
		else if (m_nLoginType == 2)
		{
			m_stFLAuthUser.Email = pref.getString(GlobalData.g_SharedPreferences_LEmail, "");
			m_stFLAuthUser.BirthYear = pref.getInt(GlobalData.g_SharedPreferences_LBirthYear, 0);
			m_stFLAuthUser.Gender = pref.getInt(GlobalData.g_SharedPreferences_LGender, 0);
			m_stFLAuthUser.PhoneNum = pref.getString(GlobalData.g_SharedPreferences_LPhoneNumber, "");
			m_stFLAuthUser.ImageData = "img";
			
			if (m_stFLAuthUser.Email != null && m_stFLAuthUser.Email.length() > 0)
				nVal = 1;
			else
				nVal = 0;
		}
				
		if ( nVal == 0 )
       	{
			SharedPreferences.Editor editor = pref.edit();
			editor.commit();
       		handler.sendEmptyMessageDelayed(0, 2000);
       	}
       	else
       	{
       		if (m_nLoginType == 0)
       			RunBackgroundHandler();
       		else
       			RunBackgroundHandler_FL();       			
       	}
	}
	
	 public int getStatusBarHeight()
	 {
	        int statusBarHeight = 0;

	        if (!hasOnScreenSystemBar()) {
	            int resourceId = getResources().getIdentifier("status_bar_height", "dimen", "android");
	            if (resourceId > 0) {
	                statusBarHeight = getResources().getDimensionPixelSize(resourceId);
	            }
	        }

	        return statusBarHeight;
	    }
	 
	 private boolean hasOnScreenSystemBar()
	 {
        Display display = getWindowManager().getDefaultDisplay();
        int rawDisplayHeight = 0;
        try {
            Method getRawHeight = Display.class.getMethod("getRawHeight");
            rawDisplayHeight = (Integer) getRawHeight.invoke(display);
        } catch (Exception ex) {
        }

        @SuppressWarnings("deprecation")
		int UIRequestedHeight = display.getHeight();

        return rawDisplayHeight - UIRequestedHeight > 0;
	 }
	 
	 private void RunBackgroundHandler()
	{
		 handler = new JsonHttpResponseHandler()
		{
			int result = 0;
			
			@Override
			public void onSuccess(JSONObject jsonData)
			{
				result = 1;
				m_stLoginResult = CommMgr.commService.GetUserLoginFromJsonData(jsonData);
				if ( m_stLoginResult.ResultCode > 0 )
				{							
					SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
					SharedPreferences.Editor editor = pref.edit();
					editor.putLong(GlobalData.g_SharedPreferencesUserID, m_stLoginResult.ResultCode);
					editor.putString(GlobalData.g_SharedPreferencesUserName, m_stLoginResult.Name);
					editor.commit();

					Intent intent = new Intent(MainActivity.this, SelectPositionActivity.class);
					startActivity(intent);
					MainActivity.this.finish();
				}
				else
				{
					result = 2;
				}
			}
			
			@Override
			public void onFailure(Throwable ex, String exception) {
			}
			
			@Override
			public void onFinish()
			{
				if (result == 0)
				{
					GlobalData.showToast(MainActivity.this, getString(R.string.server_connection_error));
					MainActivity.this.finish();
				}
				
				if (result == 2)
				{
					GlobalData.showToast(MainActivity.this, m_stLoginResult.Message);
					Intent intent = new Intent(MainActivity.this, LoginActivity.class);
					startActivity(intent);
					MainActivity.this.finish();
				}
				
				result = 0;
			}
			
		};
		
		CommMgr.commService.RequestUserLogin(m_stAuthUser, handler);
		
		return;
	}
	 
	 private void RunBackgroundHandler_FL()
		{
			 handler = new JsonHttpResponseHandler()
			{
				int result = 0;
				
				@Override
				public void onSuccess(JSONObject jsonData)
				{
					result = 1;
					m_stLoginResult = CommMgr.commService.GetUserLoginFromJsonData(jsonData);
					if ( m_stLoginResult.ResultCode > 0 )
					{							
						SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
						SharedPreferences.Editor editor = pref.edit();
						editor.putLong(GlobalData.g_SharedPreferencesUserID, m_stLoginResult.ResultCode);
						editor.putString(GlobalData.g_SharedPreferencesUserName, m_stLoginResult.Name);
						editor.commit();

						Intent intent = new Intent(MainActivity.this, SelectPositionActivity.class);
						startActivity(intent);
						MainActivity.this.finish();
					}
					else
					{
						result = 2;
					}
				}
				
				@Override
				public void onFailure(Throwable ex, String exception) {
				}
				
				@Override
				public void onFinish()
				{
					if (result == 0)
					{
						GlobalData.showToast(MainActivity.this, getString(R.string.server_connection_error));
						MainActivity.this.finish();
					}
					
					if (result == 2)
					{
						GlobalData.showToast(MainActivity.this, m_stLoginResult.Message);
						Intent intent = new Intent(MainActivity.this, LoginActivity.class);
						startActivity(intent);
						MainActivity.this.finish();
					}
					
					result = 0;
				}
				
			};
			
			CommMgr.commService.RequestFLLogin(m_stFLAuthUser, handler);
			
			return;
		}
}
