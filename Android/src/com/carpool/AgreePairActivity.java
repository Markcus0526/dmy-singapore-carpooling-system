package com.carpool;

import org.json.JSONObject;
import com.CommService.CommMgr;
import com.HttpConn.JsonHttpResponseHandler;
import com.STData.STAgreeResponse;
import com.STData.STPairAgree;
import com.STData.STPairInfo;
import com.STData.StringContainer;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.TextView;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;

public class AgreePairActivity extends Activity {

	private static final int SEND_THREAD_INFOMATION = 0;
	
	private static final int GETRESPONSE_THREAD_INFOMATION = 1;

    private static final int TIME_ONE_SECOND = 1000;
    private static final int REQUEST_PERIOD = 20;
    	
	private Button btnOk;
	private TextView lblAgreePairInfo;
	
	private boolean m_bShowNotification = false;
	
	private STPairAgree m_stPairAgree = new STPairAgree();
	private StringContainer m_stRes = new StringContainer();
	private STAgreeResponse m_stAgreeResponse = new STAgreeResponse();
	private JsonHttpResponseHandler handler;
	private JsonHttpResponseHandler handlerResponse;
	
	private SendMessageHandler mMainHandler = null;
    private SendRequestThread mRequestThread = null;
    
    private JsonHttpResponseHandler handlerGetFirstUserResponse;
    private GetFirstUserResponseHandler mResponseHandler = null;
    private GetFirstUserResponseThread mResponseThread = null;
		
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.agreepair);
		
		SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
		m_stPairAgree.Uid = pref.getLong(GlobalData.g_SharedPreferencesUserID, 0);
		m_stPairAgree.IsAgree = true;
		
		handler = new JsonHttpResponseHandler()
		{
			int result = 0;
			@Override
			public void onSuccess(JSONObject jsonData)
			{
				result = 1;
				m_stRes = CommMgr.commService.GetPairAgreeFromJsonData(jsonData);
				if ( m_stRes.Result == 1 )
				{
					mRequestThread = new SendRequestThread();
					mRequestThread.start();
				}
				else
				{
					result = 2;
				}
			}
			
			@Override
			public void onFailure(Throwable ex, String exception) {}			
			@Override
			public void onFinish() 
			{
				if (result == 0)
				{
					GlobalData.showToast(AgreePairActivity.this, getString(R.string.server_connection_error));
					AgreePairActivity.this.finish();
				}
				else if (result == 2)
				{
					GlobalData.showToast(AgreePairActivity.this, m_stRes.Value);
					AgreePairActivity.this.finish();
				}				
			}
		};
		
		handlerResponse = new JsonHttpResponseHandler()
		{			
			@Override
			public void onSuccess(JSONObject jsonData)
			{
				m_stAgreeResponse = CommMgr.commService.GetOppoAgreeFromJsonData(jsonData);
				if ( m_stAgreeResponse.ErrCode == 1 )
				{
					if (mRequestThread != null && mRequestThread.isPlay)
					{
						mRequestThread.stopThread();
						mRequestThread = null;
					}
											
					lblAgreePairInfo.setText(getString(R.string.AgreePair_SuccessResponse));
					btnOk.setVisibility(View.VISIBLE);
					btnOk.setText(getString(R.string.AgreePair_SuccessResponse_ButtonTitle));
					
					SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
					int nQueueOrder = pref.getInt(GlobalData.g_SharedPreferences_MyQueueOrder, 0);
					SharedPreferences.Editor editor = pref.edit();
					editor.putString(GlobalData.g_SharedPreferences_PairPairingTime, m_stAgreeResponse.PairTime);
					editor.commit();
					if (nQueueOrder == 1)
					{
						mResponseHandler = new GetFirstUserResponseHandler();
						mResponseThread = new GetFirstUserResponseThread();
						mResponseThread.start();
					}
					else
					{
						GlobalData.showNotification(AgreePairActivity.this, "Your party agree to ride with you");
					}
				}
				else if ( m_stAgreeResponse.ErrCode == 2 )
				{
					lblAgreePairInfo.setText(getString(R.string.AgreePair_FailResponse));
	            	btnOk.setVisibility(View.VISIBLE);
	            	btnOk.setText(getString(R.string.AgreePair_FailResponse_ButtonTitle));
	            	
	            	GlobalData.showNotification(AgreePairActivity.this, "Your party disagree to ride with you");
				}
			}
			
			@Override
			public void onFailure(Throwable ex, String exception) {}			
			@Override
			public void onFinish() {}
		};
		
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
					GlobalData.showNotification(AgreePairActivity.this, "Your Party is in the taxistand.");
					m_bShowNotification = true;
				}
			}
			
			@Override
			public void onFailure(Throwable ex, String exception) {}			
			@Override
			public void onFinish() {}
		};
		
		mMainHandler = new SendMessageHandler();
		
		lblAgreePairInfo = (TextView) findViewById(R.id.lblAgreePair_Data);
		lblAgreePairInfo.setText(getString(R.string.AgreePair_WaitingResponse));
	
		btnOk = (Button) findViewById(R.id.btnAgreePair_Ok);
		btnOk.setOnClickListener(new OnClickListener(){
			@SuppressLint("SimpleDateFormat")
			@Override
			public void onClick(View v)
			{
				String strCaption = btnOk.getText().toString();
				if ( strCaption.equals( getString(R.string.AgreePair_SuccessResponse_ButtonTitle) ) )
				{
					SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
					SharedPreferences.Editor editor = pref.edit();
					editor.putString(GlobalData.g_SharedPreferences_PairPairingTime, m_stAgreeResponse.PairTime);
					editor.commit();
					
					if ( mResponseThread != null && mResponseThread.isAlive() )
					{
						mResponseThread.stopThread();
					}
					
					Intent intent = new Intent(AgreePairActivity.this, AboutOtherPartyActivity.class);
					intent.putExtra("ShowNotification", m_bShowNotification);
					startActivity(intent);
					AgreePairActivity.this.finish();
				}
				else if ( strCaption.equals( getString(R.string.AgreePair_FailResponse_ButtonTitle) ) )
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
					
					Intent intent = new Intent(AgreePairActivity.this, MatchingActivity.class);
					intent.putExtra("PairInfo", stPairInfo);
					intent.putExtra("ReRequest", true);
					intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
					startActivity(intent);
					finish();
				}
				
				return;
			}
		});
		
		ResolutionSet._instance.iterateChild(findViewById(R.id.llAgreePairLayout));
		
		RunBackground();
	}
	
	private void RunBackground()
	{
		CommMgr.commService.RequestPairAgree(m_stPairAgree, handler);
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
	
	@SuppressLint("HandlerLeak")
	class SendMessageHandler extends Handler 
	{
        @Override
        public void handleMessage(Message msg) 
        {
            super.handleMessage(msg);
             
            switch (msg.what) {
            case SEND_THREAD_INFOMATION:
            	long nUid = 0;
            	SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
            	nUid = pref.getLong(GlobalData.g_SharedPreferencesUserID, 0);
            	CommMgr.commService.RequestOppoAgree(nUid, handlerResponse);
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
            	mMainHandler.sendEmptyMessage(SEND_THREAD_INFOMATION);
                
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
	    return super.onKeyDown(keyCode, event);
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