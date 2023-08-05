package com.carpool;

import org.json.JSONObject;
import com.CommService.CommMgr;
import com.HttpConn.JsonHttpResponseHandler;
import com.STData.STPairAgree;
import com.STData.STPairInfo;
import com.STData.STPairResponse;
import com.STData.StringContainer;

import android.os.Bundle;
import android.os.CountDownTimer;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.TextView;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.content.SharedPreferences;

public class MatchInfoActivity extends Activity {
	
	private Button btnViewRoute;
	private Button btnReject;
	private Button btnSetting;
	private Button btnReturn;
	private TextView lblPairResponse;
	
	private STPairAgree m_stPairAgree = new STPairAgree();
	private STPairResponse m_stPairResponse = new STPairResponse();
	private JsonHttpResponseHandler handler = new JsonHttpResponseHandler();
	private JsonHttpResponseHandler handlerReject = new JsonHttpResponseHandler();
	
	private ProgressDialog dialog = null;
	private ProgressDialog progDialog = null;
	
	boolean bFlag = true;
	int g_Count = 0;
	
	private CountDownTimer mTimer = null;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.matchinfo);
		
		m_stPairResponse = getIntent().getParcelableExtra("PairResponse");
		
		btnViewRoute = (Button) findViewById(R.id.btnMatchInfo_ViewRoute);
		btnViewRoute.setOnClickListener(new OnClickListener(){
			@Override
			public void onClick(View v)
			{
				bFlag = false;
				if (mTimer != null)
				{
					mTimer.cancel();
					mTimer = null;
				}
				Intent intent = new Intent(MatchInfoActivity.this, ViewRouteActivity.class);
				intent.putExtra("PairResponse", m_stPairResponse);
				intent.putExtra("CurCount", g_Count);
				startActivity(intent);
				MatchInfoActivity.this.finish();
			}
		});
		
		btnSetting = (Button) findViewById(R.id.btnMatchInfo_Setting);
		btnSetting.setOnClickListener(new OnClickListener(){
			@Override
			public void onClick(View v)
			{
				Intent intent = new Intent(MatchInfoActivity.this, SettingActivity.class);
				intent.setFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
				startActivity(intent);
			}
		});
		
		btnReject = (Button) findViewById(R.id.btnMatchInfo_Reject);
		btnReject.setOnClickListener( new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				bFlag = false;
				if (mTimer != null)
				{
					mTimer.cancel();
					mTimer = null;
				}
				
				SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
				m_stPairAgree.Uid = pref.getLong(GlobalData.g_SharedPreferencesUserID, 0);
				m_stPairAgree.IsAgree = false;
				
				progDialog = ProgressDialog.show(
						MatchInfoActivity.this,
						"", 
						getString(R.string.waiting),
						true,
						true,
						null);
				
				CommMgr.commService.RequestPairAgree(m_stPairAgree, handlerReject);				
			}
		});
		
		btnReturn = (Button) findViewById(R.id.btnMatchInfo_Return);
		btnReturn.setOnClickListener( new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				bFlag = false;
				if (mTimer != null)
				{
					mTimer.cancel();
					mTimer = null;
				}
				
				RunBackgroundHandler();
			}
		});
		
		mTimer = new CountDownTimer(120000, 1000)
		{
			@Override
			public void onFinish() 
			{
				if (bFlag == true)
				{
					SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
					m_stPairAgree.Uid = pref.getLong(GlobalData.g_SharedPreferencesUserID, 0);
					m_stPairAgree.IsAgree = false;
					
					progDialog = ProgressDialog.show(
							MatchInfoActivity.this,
							"", 
							getString(R.string.waiting),
							true,
							true,
							null);
					
					CommMgr.commService.RequestPairAgree(m_stPairAgree, handlerReject);
				}
			}

			@Override
			public void onTick(long millisUntilFinished) 
			{
				g_Count++;
			}
		}.start();
		
		
		lblPairResponse = (TextView) findViewById(R.id.lblMatchInfo_PairResponse);
		String strData = "The other party is \"" + m_stPairResponse.Name + "\"" + System.getProperty("line.separator")
				 + "Number of people is " + m_stPairResponse.Count + System.getProperty ("line.separator");
		
		String strBuf = "";
		if (m_stPairResponse.Count == 1)
		{
			if (m_stPairResponse.GrpGender == 0)
				strBuf += "His destination is ";
			if (m_stPairResponse.GrpGender == 1)
				strBuf += "Her destination is ";
			if (m_stPairResponse.GrpGender == 2)
				strBuf += "Their destination is ";
		}
		else
			strBuf += "Their destination is ";
		strData += strBuf + m_stPairResponse.Destination + System.getProperty ("line.separator");
		
		if (m_stPairResponse.OffOrder == 0)
			strData += "You are first to alight";
		else
			strData += "You are second to alight";
		strData += System.getProperty("line.separator");
		strData += "Saving for this trip : " + "S$" + m_stPairResponse.SaveMoney + System.getProperty("line.separator");
		strData += "Possible slight delay : " + m_stPairResponse.LostTime + "minutes";
		lblPairResponse.setText(strData);
		
		handlerReject = new JsonHttpResponseHandler()
		{
			int result = 0;
			@Override
			public void onSuccess(JSONObject jsonData)
			{
				result = 1;
				progDialog.dismiss();
				StringContainer retVal = CommMgr.commService.GetPairAgreeFromJsonData(jsonData);
				if ( retVal.Result == 1 )
				{
					STPairInfo stPairInfo = new STPairInfo();
					SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
					stPairInfo.Uid = pref.getLong(GlobalData.g_SharedPreferencesUserID, 0);
					stPairInfo.SrcLat = pref.getFloat(GlobalData.g_SharedPreferencesSrcLatitude, 0.0f);
					stPairInfo.SrcLon = pref.getFloat(GlobalData.g_SharedPreferencesSrcLongitude, 0.0f);
					stPairInfo.DstLat = pref.getFloat(GlobalData.g_SharedPreferencesDstLatitude, 0.0f);
					stPairInfo.DstLon = pref.getFloat(GlobalData.g_SharedPreferencesDstLongitude, 0.0f);
					stPairInfo.Destination = pref.getString(GlobalData.g_SharedPreferences_MyInfoDestination, "");
					stPairInfo.Count = pref.getInt(GlobalData.g_SharedPreferences_MyInfoCount, 0);
					stPairInfo.GrpGender = pref.getInt(GlobalData.g_SharedPreferences_MyInfoGrpGender, 0);
					stPairInfo.Color = pref.getString(GlobalData.g_SharedPreferences_MyInfoColor, "");
					stPairInfo.OtherFeature = pref.getString(GlobalData.g_SharedPreferences_MyInfoOtherFeature, "");
					
					Intent intent = new Intent(MatchInfoActivity.this, MatchingActivity.class);
					intent.putExtra("PairInfo", stPairInfo);
					intent.putExtra("ReRequest", true);
					intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
					startActivity(intent);
					finish();
				}
				else
					result = 2;
			}
			
			@Override
			public void onFailure(Throwable ex, String exception) {}
			
			@Override
			public void onFinish()
			{
				progDialog.dismiss();
				if (result == 0)
				{
					GlobalData.showToast(MatchInfoActivity.this, getString(R.string.server_connection_error));
				}
				
				if (result == 2)
				{
					GlobalData.showToast(MatchInfoActivity.this, getString(R.string.service_error));
				}
				
				result = 0;
			}			
		};
						
		ResolutionSet._instance.iterateChild(findViewById(R.id.llMatchInfoLayout));		
	}
	
	private void RunBackgroundHandler()
	{
		handler = new JsonHttpResponseHandler()
		{
			int result = 0;
			StringContainer stRes = new StringContainer();
			@Override
			public void onSuccess(JSONObject jsonData)
			{
				result = 1;
				stRes = CommMgr.commService.GetPairOffFromJsonData(jsonData);
				if ( stRes.Result == 1 )
				{	
					dialog.dismiss();

					Intent intent = new Intent(MatchInfoActivity.this, SelectPositionActivity.class);
					intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
					startActivity(intent);
					MatchInfoActivity.this.finish();
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
				dialog.dismiss();
				if (result == 0)
				{
					GlobalData.showToast(MatchInfoActivity.this, getString(R.string.server_connection_error));
				}
				
				if (result == 2)
				{
					GlobalData.showToast(MatchInfoActivity.this, stRes.Value);
				}
				
				result = 0;
			}
			
		};
		
		SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
		long nUid = pref.getLong(GlobalData.g_SharedPreferencesUserID, 0);
		CommMgr.commService.RequestPairOff(nUid, handler);
		dialog = ProgressDialog.show(MatchInfoActivity.this,
									"",
									getString(R.string.waiting),
									true,
									true,
									null);
		
		return;
	}
	
	@Override
	public void onStart()
	{
		super.onStart();
		return;
	}
	
	@Override
	public void onPause()
	{
		super.onPause();
		return;
	}
	
	@Override
	public void onRestart()
	{
		super.onRestart();
		return;
	}
	
	@Override
	public void onDestroy()
	{
		super.onDestroy();
		return;
	}
	
	@SuppressLint("InlinedApi")
	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event)
	{
		if( keyCode == KeyEvent.KEYCODE_BACK )
		{
			Intent intent = new Intent(MatchInfoActivity.this, SelectPositionActivity.class);
			intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_CLEAR_TASK | Intent.FLAG_ACTIVITY_NEW_TASK);
			startActivity(intent);
			
			return true;
		}
	  
		return super.onKeyDown(keyCode, event);
	}
}