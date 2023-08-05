package com.carpool;

import org.brickred.socialauth.android.DialogListener;
import org.brickred.socialauth.android.SocialAuthAdapter;
import org.brickred.socialauth.android.SocialAuthError;
import org.brickred.socialauth.android.SocialAuthListener;
import org.brickred.socialauth.android.SocialAuthAdapter.Provider;
import org.json.JSONObject;

import com.CommService.CommMgr;
import com.HttpConn.AsyncHttpResponseHandler;
import com.HttpConn.JsonHttpResponseHandler;
import com.STData.STShareLog;

import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.content.SharedPreferences;

public class FacebookPostActivity extends Activity {
	
	private Button btnSetting;
	private Button btnSubmit;
	private Button btnShare;
	private EditText txtContent;
	
	private SocialAuthAdapter adapter;
	private boolean bFlag = false;

	private STShareLog m_stShareLog = new STShareLog();
	private JsonHttpResponseHandler handler = null;
	private AsyncHttpResponseHandler handlerSharable = null;
	private ProgressDialog progDialog = null;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.facebookpost);	
				
		btnSetting = (Button) findViewById(R.id.btnFacebookPost_Setting);
		btnSetting.setOnClickListener( new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				Intent intent = new Intent(FacebookPostActivity.this, SettingActivity.class);
				intent.setFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
				startActivity(intent);
			}
		});
		
		btnSubmit = (Button) findViewById(R.id.btnFacebookPost_Submit);
		btnSubmit.setEnabled(false);
		btnSubmit.setOnClickListener( new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				if (bFlag == true)
				{
					String strData = txtContent.getText().toString();
					if (strData == null || strData.length() == 0)
					{
						GlobalData.showToast(FacebookPostActivity.this, getString(R.string.FacebookPost_PostContentError));
						return;
					}
					adapter.updateStatus(strData, new MessageListener(), false);
				}
				else
				{
					GlobalData.showToast(FacebookPostActivity.this, getString(R.string.FacebookPost_PostError));
					return;
				}
				return;
			}
		});
		
		btnShare = (Button) findViewById(R.id.btnFacebookPost_Share);
		
		txtContent = (EditText) findViewById(R.id.txtFacebookPost_Content);

		adapter = new SocialAuthAdapter(new ResponseListener());
		adapter.addProvider(Provider.FACEBOOK, R.drawable.facebook);
		adapter.addProvider(Provider.LINKEDIN, R.drawable.linkedin);
		adapter.enable(btnShare);
		
		ResolutionSet._instance.iterateChild(findViewById(R.id.llFacebookPostLayout));
		
		RunBackgroundHandler();
	}
	
	private void RunBackgroundHandler()
	{
		handlerSharable = new AsyncHttpResponseHandler()
		{
			int result = 0;
			
			@Override
			public void onSuccess(String strData)
			{
				result = 1;

				progDialog.dismiss();
				
				int nSharable = CommMgr.commService.GetSharableFromJsonData(strData);
								
				if ( nSharable == 0 )
				{
					GlobalData.showToast(FacebookPostActivity.this, getString(R.string.facebookpost_error));
					FacebookPostActivity.this.finish();
				}				
				
				if (nSharable < 0)
				{	
					GlobalData.showToast(FacebookPostActivity.this, getString(R.string.service_error));
					FacebookPostActivity.this.finish();					
				}				
			}
			
			@Override
			public void onFailure(Throwable ex, String exception) {}
			
			@Override
			public void onFinish()
			{
				progDialog.dismiss();
				if (result == 0)
					GlobalData.showToast(FacebookPostActivity.this, getString(R.string.server_connection_error));				
				
				result = 0;
			}
			
		};
		
		progDialog = ProgressDialog.show(
				FacebookPostActivity.this,
				"", 
				getString(R.string.waiting),
				true,
				true,
				null);
		
		SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
		long Uid = pref.getLong(GlobalData.g_SharedPreferencesUserID, 0);
		
		CommMgr.commService.RequestUserCredits(Long.toString(Uid), handlerSharable);
		
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
	
	private final class ResponseListener implements DialogListener {
		@Override
		public void onComplete(Bundle values) {
			bFlag = true;
			GlobalData.showToast(FacebookPostActivity.this, "Authentication Successful");
			btnSubmit.setEnabled(true);
		}

		@Override
		public void onError(SocialAuthError error) {
			GlobalData.showToast(FacebookPostActivity.this, "Authentication Error: " + error.getMessage());
		}

		@Override
		public void onCancel() {
			GlobalData.showToast(FacebookPostActivity.this, "Authentication Cancelled");
		}

		@Override
		public void onBack() {
			GlobalData.showToast(FacebookPostActivity.this, "Dialog Closed by pressing Back Key");
		}

	}

	private final class MessageListener implements SocialAuthListener<Integer> {
		@Override
		public void onExecute(String provider, Integer t) 
		{
			Integer status = t;
			if (status.intValue() == 200 || status.intValue() == 201 || status.intValue() == 204)
			{
				handler = new JsonHttpResponseHandler()
				{
					@Override
        			public void onSuccess(JSONObject objData) {}
        			
        			@Override
        			public void onFailure(Throwable ex, String exception) {}
        			
        			@Override
        			public void onFinish() {};
        		};

        		SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
        		m_stShareLog.Uid = pref.getLong(GlobalData.g_SharedPreferencesUserID, 0);
        		m_stShareLog.Content = txtContent.getText().toString();
        		CommMgr.commService.RequestShareLog(m_stShareLog, handler);
				
				Toast.makeText(FacebookPostActivity.this, "Message posted on " + provider, Toast.LENGTH_LONG).show();				
			}
			else
				Toast.makeText(FacebookPostActivity.this, "Message not posted on " + provider, Toast.LENGTH_LONG).show();
		}

		@Override
		public void onError(SocialAuthError e) {
		}
	}
}