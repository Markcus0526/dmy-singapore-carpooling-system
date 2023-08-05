package com.carpool;

import org.json.JSONObject;

import com.CommService.CommMgr;
import com.HttpConn.JsonHttpResponseHandler;
import com.STData.STPairInfo;
import com.STData.STPairResponse;
import com.STData.StringContainer;

import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;

@SuppressLint("HandlerLeak")
public class MatchingActivity extends Activity {
	
	private static final int SEND_THREAD_INFOMATION = 0;
    private static final int SEND_THREAD_STOP_MESSAGE = 1;    
    private static final int TIME_ONE_SECOND = 1000;

    /*
     * request time <== 120 min = 2 hour
     * request period 30 second
     */
    private static final int REQUEST_COUNT = 720;
    private static final int REQUEST_PERIOD = 10;
    
    private int mRequestNo = 0;
    
    private SendMessageHandler mMainHandler = null;
    private SendRequestThread mRequestThread = null;
	
	private Button btnSetting;
	private Button btnCheckOut;
	
	private boolean m_bReRequest = false;

	private STPairInfo m_stPairInfo = new STPairInfo();
	private StringContainer m_stRequestPair = new StringContainer();
	private STPairResponse m_stPairResponse = new STPairResponse();
	private JsonHttpResponseHandler handlerPairInfo = null;
	private JsonHttpResponseHandler handlerIsPaired = null;
		
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.matching);

		m_stPairInfo = getIntent().getParcelableExtra("PairInfo");
		m_bReRequest = getIntent().getBooleanExtra("ReRequest", false);
		
		/*
		m_stPairInfo.SrcLat = 44;
		m_stPairInfo.SrcLon = 123;
		m_stPairInfo.DstLat = 45.003;
		m_stPairInfo.DstLon = 124;
		m_stPairInfo.Destination = "ShenYang";
		*/
		SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
		m_stPairInfo.Uid = pref.getLong(GlobalData.g_SharedPreferencesUserID, 0);

		mMainHandler = new SendMessageHandler();
		
		handlerPairInfo = new JsonHttpResponseHandler()
		{
			int result = 0;
			@Override
			public void onSuccess(JSONObject jsonData)
			{
				result = 1;
				m_stRequestPair = CommMgr.commService.GetRequestPairFromJsonData(jsonData);
				if ( m_stRequestPair.Result == 1 )
				{
					if (mRequestThread == null)
					{
						mRequestThread = new SendRequestThread();
						mRequestThread.start();
					}
				}
				else
					result = 2;
			}
			
			@Override
			public void onFailure(Throwable ex, String exception) {}			
			@Override
			public void onFinish() 
			{
				if (result == 0)
				{
					GlobalData.showToast(MatchingActivity.this, getString(R.string.server_connection_error));
					MatchingActivity.this.finish();
				}
				else if (result == 2)
				{
					GlobalData.showToast(MatchingActivity.this, m_stRequestPair.Value);
					MatchingActivity.this.finish();
				}
			}
		};
		
		handlerIsPaired = new JsonHttpResponseHandler()
		{			
			@Override
			public void onSuccess(JSONObject jsonData)
			{
				m_stPairResponse = CommMgr.commService.GetIsPairedFromJsonData(jsonData);
				if ( m_stPairResponse.ErrCode == 1 )
				{
					mRequestThread.stopThread();
					
					SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
					SharedPreferences.Editor editor = pref.edit();
					editor.putLong(GlobalData.g_SharedPreferences_PairID, m_stPairResponse.OppoID);					
					editor.putString(GlobalData.g_SharedPreferences_PairName, m_stPairResponse.Name);
					editor.putString(GlobalData.g_SharedPreferences_PairDestination, m_stPairResponse.Destination);
					editor.putString(GlobalData.g_SharedPreferences_PairTopColor, m_stPairResponse.Color);
					editor.putString(GlobalData.g_SharedPreferences_PairOtherFeature,  m_stPairResponse.OtherFeature);
					editor.putInt(GlobalData.g_SharedPreferences_PairCount, m_stPairResponse.Count);
					editor.putInt(GlobalData.g_SharedPreferences_PairGrpGender, m_stPairResponse.GrpGender);
					editor.putFloat(GlobalData.g_SharedPreferences_PairSaveMoney, (float)m_stPairResponse.SaveMoney);
					editor.putFloat(GlobalData.g_SharedPreferences_PairLostTime, (float)m_stPairResponse.LostTime);
					editor.putInt(GlobalData.g_SharedPreferences_MyQueueOrder, m_stPairResponse.QueueOrder);
					editor.commit();
					
					if (m_stPairResponse.QueueOrder == 0)
						GlobalData.showNotification(MatchingActivity.this, "Pairing Success");
					if (m_stPairResponse.QueueOrder == 1)
						GlobalData.showNotification(MatchingActivity.this, "Pairing Success");

					Intent intent = new Intent(MatchingActivity.this, MatchInfoActivity.class);
					intent.putExtra("PairResponse", m_stPairResponse);
					startActivity(intent);
				}
			}
			
			@Override
			public void onFailure(Throwable ex, String exception) {}			
			@Override
			public void onFinish() {}
		};		
		
		btnSetting = (Button) findViewById(R.id.btnMatching_Setting);
		btnSetting.setOnClickListener( new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				Intent intent = new Intent(MatchingActivity.this, SettingActivity.class);
				intent.setFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
				startActivity(intent);
			}
		});
		
		btnCheckOut = (Button) findViewById(R.id.btnMatching_CheckOut);
		btnCheckOut.setOnClickListener( new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				if ( mRequestThread != null && mRequestThread.isAlive() )
				{
					mRequestThread.stopThread();
				}
				
				JsonHttpResponseHandler handler = new JsonHttpResponseHandler()
				{
					@Override
					public void onSuccess(JSONObject jsonData) {}					
					@Override
					public void onFailure(Throwable ex, String exception) {}					
					@Override
					public void onFinish() {}
					
				};
				SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
				long nUid = pref.getLong(GlobalData.g_SharedPreferencesUserID, 0);
				CommMgr.commService.RequestPairOff(nUid, handler);
				
				Intent intent = new Intent(MatchingActivity.this, SelectPositionActivity.class);
				intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
				startActivity(intent);
				finish();
				return;
			}
		});

		if (m_bReRequest == false)
			RunBackgroundHandler();
		else
		{
			mRequestThread = new SendRequestThread();
			mRequestThread.start();
		}
						
		ResolutionSet._instance.iterateChild(findViewById(R.id.llMatchingLayout));		
	}	
	
	@Override
	public void onStart()
	{
		super.onStart();
		return;
	}
	
	@Override
	public void onResume()
	{
		super.onResume();
				
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
	
	class SendMessageHandler extends Handler 
	{
        @Override
        public void handleMessage(Message msg) 
        {
            super.handleMessage(msg);
             
            switch (msg.what) {
            case SEND_THREAD_INFOMATION:
            	SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
            	long nID = pref.getLong(GlobalData.g_SharedPreferencesUserID, 0);
            	CommMgr.commService.RequestIsPaired(nID, handlerIsPaired);
                break;
                 
            case SEND_THREAD_STOP_MESSAGE:
            	mRequestThread.stopThread();
            	MatchingActivity.this.finish();
                break;
 
            default:
                break;
            }
        }         
    };
    
    class SendRequestThread extends Thread implements Runnable {
        
        private boolean isPlay = false;
         
        public SendRequestThread() 
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
            	if ( mRequestNo < REQUEST_COUNT )
            		mMainHandler.sendEmptyMessage(SEND_THREAD_INFOMATION);
            	else
            		mMainHandler.sendEmptyMessage(SEND_THREAD_STOP_MESSAGE);
            	
            	mRequestNo++;
                
                try 
                { 
                	Thread.sleep(TIME_ONE_SECOND * REQUEST_PERIOD); 
                } 
                catch (InterruptedException e)
                {
                	e.printStackTrace(); 
                }
            }            
        }
    }
    
    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event)
	{
    	if( keyCode == KeyEvent.KEYCODE_BACK )
    	{
    		if ( mRequestThread != null && mRequestThread.isAlive() )
			{
				mRequestThread.stopThread();
			}
    		
    		MatchingActivity.this.finish();
    	}
	  
    	return super.onKeyDown(keyCode, event);
	 }
    
    private void RunBackgroundHandler()
    {
    	CommMgr.commService.RequestPair(m_stPairInfo, handlerPairInfo);
    	return;
    }
}