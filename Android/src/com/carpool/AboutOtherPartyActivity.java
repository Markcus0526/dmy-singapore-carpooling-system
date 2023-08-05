package com.carpool;

import org.json.JSONObject;

import com.CommService.CommMgr;
import com.HttpConn.JsonHttpResponseHandler;
import com.STData.StringContainer;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.TextView;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.content.SharedPreferences;

public class AboutOtherPartyActivity extends Activity {

	private static final int GETRESPONSE_THREAD_INFOMATION = 1;
    private static final int TIME_ONE_SECOND = 1000;
	
	private Button btnOk;
	private TextView lblInfo;	
	
	private String strName;
	private String strSource;
	private String strDestination;
	private String strTopColor;
	private String strOtherFeature;
	private float fSaveMoney;
	private float fLostTime;
	private long nOppoID;
	private long nMyID;
	private int nCount;
	private int nGrpGender;
	private String strPairTime;
	
	private boolean m_bShowNotification = false;
	private JsonHttpResponseHandler handlerGetFirstUserResponse;
    private GetFirstUserResponseHandler mResponseHandler = null;
    private GetFirstUserResponseThread mResponseThread = null;
	
	private JsonHttpResponseHandler handler = null;
	private ProgressDialog dialog = null;
		
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.aboutotherparty);
		
		m_bShowNotification = getIntent().getBooleanExtra("ShowNotification", false);
				
		lblInfo = (TextView) findViewById(R.id.lblAboutOtherParty_Data);
		SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
		strName = pref.getString(GlobalData.g_SharedPreferences_PairName, "");
		strSource = pref.getString(GlobalData.g_SharedPreferencesSrcAddress, "");
		strDestination = pref.getString(GlobalData.g_SharedPreferences_PairDestination, "");
		strTopColor = pref.getString(GlobalData.g_SharedPreferences_PairTopColor, "");
		strOtherFeature = pref.getString(GlobalData.g_SharedPreferences_PairOtherFeature, "");
		nCount = pref.getInt(GlobalData.g_SharedPreferences_PairCount, 1);
		nGrpGender = pref.getInt(GlobalData.g_SharedPreferences_PairGrpGender, 0);
		fSaveMoney = pref.getFloat(GlobalData.g_SharedPreferences_PairSaveMoney, 0.0f);
		fLostTime = pref.getFloat(GlobalData.g_SharedPreferences_PairLostTime, 0.0f);
		nOppoID = pref.getLong(GlobalData.g_SharedPreferences_PairID, 0);
		nMyID = pref.getLong(GlobalData.g_SharedPreferencesUserID, 0);
		strPairTime = pref.getString(GlobalData.g_SharedPreferences_PairPairingTime, "");
		String strData = "Your party is \"" + strName + "\"" + System.getProperty ("line.separator")
		         + "Destination is " + strDestination + System.getProperty ("line.separator");
		
		String strBuf = "Color of ";
		if (nCount == 1)
		{
			if (nGrpGender == 0)
				strBuf += "his top is ";
			if (nGrpGender == 1)
				strBuf += "her top is ";
			if (nGrpGender == 2)
				strBuf += "their top is ";
		}
		else
			strBuf += "their top is ";
		
		strData += strBuf + strTopColor + System.getProperty ("line.separator");
		if ( strOtherFeature.length() > 0 )
			strData += "Other identifiable feature is " + strOtherFeature + System.getProperty ("line.separator");
		strData += "Saving for this trip : " + "S$" + Float.toString(fSaveMoney) + System.getProperty ("line.separator");
		strData += "Possible slight delay : " + Float.toString(fLostTime) + "minutes";
		lblInfo.setText(strData);
	
		btnOk = (Button) findViewById(R.id.btnAboutOtherParty_Ok);
		if (m_bShowNotification == false)
			btnOk.setText(getString(R.string.AboutOtherParty_RateYourParty));
			
		btnOk.setOnClickListener(new OnClickListener(){
			@Override
			public void onClick(View v)
			{
				SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
				int nQueueOrder = pref.getInt(GlobalData.g_SharedPreferences_MyQueueOrder, 0);
				if (nQueueOrder == 0)
					RunBackgroundHandler();
				else
				{
					if ( mResponseThread != null && mResponseThread.isAlive() )
					{
						mResponseThread.stopThread();
					};
					
					Intent intent = new Intent(AboutOtherPartyActivity.this, RatingActivity.class);
					intent.putExtra("MyID", nMyID);
					intent.putExtra("YourID", nOppoID);
					intent.putExtra("Name", strName);
					intent.putExtra("SrcAddress", strSource);
					intent.putExtra("DstAddress", strDestination);
					intent.putExtra("PairTime", strPairTime);
					intent.putExtra("Flag", true);
					startActivity(intent);
					AboutOtherPartyActivity.this.finish();
				}
				return;
			}
		});
		
		handlerGetFirstUserResponse = new JsonHttpResponseHandler()
		{
			StringContainer stResult = new StringContainer();
			
			@Override
			public void onSuccess(JSONObject jsonData)
			{
				stResult = CommMgr.commService.GetPairIsNextFromJsonData(jsonData);
				if (stResult.Result == 1)
				{
					mResponseThread.stopThread();
					GlobalData.showNotification(AboutOtherPartyActivity.this, "Your Party is in the taxistand.");
					m_bShowNotification = true;
				}
			}
			
			@Override
			public void onFailure(Throwable ex, String exception) {}			
			@Override
			public void onFinish() {}
		};
		
		int nQueueOrder = pref.getInt(GlobalData.g_SharedPreferences_MyQueueOrder, 0);		
		if (nQueueOrder == 1)
		{
			if (m_bShowNotification == false)
			{
				mResponseHandler = new GetFirstUserResponseHandler();
				mResponseThread = new GetFirstUserResponseThread();
				mResponseThread.start();
			}
		}
		
		ResolutionSet._instance.iterateChild(findViewById(R.id.llAboutOtherPartyLayout));		
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
	
	private void RunBackgroundHandler()
	{
		handler = new JsonHttpResponseHandler()
		{
			int result = 0;
			StringContainer stResult = new StringContainer();
			
			@Override
			public void onSuccess(JSONObject jsonData)
			{
				result = 1;
				stResult = CommMgr.commService.GetSetNextTurnFromJsonData(jsonData);
				if ( stResult.Result > 0 )
				{
					Intent intent = new Intent(AboutOtherPartyActivity.this, RatingActivity.class);
					intent.putExtra("MyID", nMyID);
					intent.putExtra("YourID", nOppoID);
					intent.putExtra("Name", strName);
					intent.putExtra("SrcAddress", strSource);
					intent.putExtra("DstAddress", strDestination);
					intent.putExtra("PairTime", strPairTime);
					intent.putExtra("Flag", true);
					startActivity(intent);
					
					AboutOtherPartyActivity.this.finish();
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
					GlobalData.showToast(AboutOtherPartyActivity.this, getString(R.string.server_connection_error));
				}
				
				if (result == 2)
				{
					GlobalData.showToast(AboutOtherPartyActivity.this, stResult.Value);
				}
				
				result = 0;
			}
			
		};

		SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
		long nUid = pref.getLong(GlobalData.g_SharedPreferencesUserID, 0);
		
		dialog = ProgressDialog.show(
				AboutOtherPartyActivity.this,
				"", 
				getString(R.string.waiting),
				true,
				true,
				null);
		
		CommMgr.commService.RequestSetNextTurn(Long.toString(nUid), handler);
		
		return;
	}
	
	@SuppressLint("HandlerLeak")
	class GetFirstUserResponseHandler extends Handler 
	{
        @Override
        public void handleMessage(Message msg) 
        {
            super.handleMessage(msg);
             
            switch (msg.what) {
            case GETRESPONSE_THREAD_INFOMATION:
            	SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
            	long nID = pref.getLong(GlobalData.g_SharedPreferencesUserID, 0);
            	CommMgr.commService.RequestPairIsNext(Long.toString(nID), handlerGetFirstUserResponse);
                break;
 
            default:
                break;
            }
        }         
    };
    
    class GetFirstUserResponseThread extends Thread implements Runnable {
        
        private boolean isPlay = false;
         
        public GetFirstUserResponseThread() 
        {
            isPlay = true;
        }
         
        public void isThreadState(boolean isPlay) 
        {
            this.isPlay = isPlay;
        }
         
        public void stopThread() 
        {
            isPlay = false;
        }
         
		@Override
        public void run() 
        {
            super.run();
            while (isPlay) 
            {
            	mResponseHandler.sendEmptyMessage(GETRESPONSE_THREAD_INFOMATION);
                
                try 
                { 
                	Thread.sleep(TIME_ONE_SECOND * 10); 
                } 
                catch (InterruptedException e)
                {
                	e.printStackTrace(); 
                }
            }            
        }
    }
}