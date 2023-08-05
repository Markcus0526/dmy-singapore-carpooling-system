package com.carpool;

import org.json.JSONObject;

import com.CommService.CommMgr;
import com.HttpConn.JsonHttpResponseHandler;
import com.STData.STUserProfile;

import android.os.Bundle;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.TextView;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Color;

public class CreditBalanceActivity extends Activity {
	
	private Button btnSetting;
	private Button btnBuyCredit;
	private TextView lblCredit;
	private TextView lblCreditTitle;
	private TextView lblTotal;
	
	private STUserProfile m_stUserProfile = new STUserProfile();
	private ProgressDialog progDialog;
	private JsonHttpResponseHandler handler;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.creditbalance);
		
		lblCredit = (TextView) findViewById(R.id.lblCreditBalance_Credits);
		lblCreditTitle = (TextView) findViewById(R.id.lblCreditBalance_CreditsRemain);
		lblTotal = (TextView) findViewById(R.id.lblCreditBalance_TotalSavingValue);
		
		btnSetting = (Button) findViewById(R.id.btnCreditBalance_Setting);
		btnSetting.setOnClickListener( new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				Intent intent = new Intent(CreditBalanceActivity.this, SettingActivity.class);
				startActivity(intent);
				CreditBalanceActivity.this.finish();
			}
		});
		
		btnBuyCredit = (Button) findViewById(R.id.btnCreditBalance_RequestBalance);
		btnBuyCredit.setOnClickListener( new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				Intent intent = new Intent(CreditBalanceActivity.this, BuyCreditsRequestActivity.class);				
				startActivity(intent);
			}
		});

		ResolutionSet._instance.iterateChild(findViewById(R.id.llCreditBalanceLayout));		
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
		RunBackgroundHandler();
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
			
			@Override
			public void onSuccess(JSONObject jsonData)
			{
				result = 1;
				m_stUserProfile = CommMgr.commService.GetUserProfileFromJsonData(jsonData);
				if ( m_stUserProfile.ErrCode == 1 )
				{	
					progDialog.dismiss();
					
					UpdateUI();
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
				progDialog.dismiss();
				if (result == 0)
				{
					GlobalData.showToast(CreditBalanceActivity.this, getString(R.string.server_connection_error));
					finish();
				}
				
				if (result == 2)
				{
					GlobalData.showToast(CreditBalanceActivity.this, getString(R.string.service_error));
					finish();
				}
				
				result = 0;
			}			
		};		
		
		progDialog = ProgressDialog.show(
				CreditBalanceActivity.this,
				"", 
				getString(R.string.waiting),
				true,
				true,
				null);
		
		long Uid = 0;		
		SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
		Uid = pref.getLong(GlobalData.g_SharedPreferencesUserID, 0);
		
		CommMgr.commService.RequestUserProfile(Long.toString(Uid), handler);
		
		return;
	}
	
	private void UpdateUI()
	{
		if ( m_stUserProfile.Credit == 0 )
		{
			lblCredit.setTextColor(Color.RED);
			lblCreditTitle.setTextColor(Color.RED);
			lblCredit.setText(Integer.toString(m_stUserProfile.Credit));
		}
		else
		{
			lblCredit.setTextColor(getResources().getColor(R.color.dark_gray));
			lblCreditTitle.setTextColor(getResources().getColor(R.color.dark_gray));
			lblCredit.setText(Integer.toString(m_stUserProfile.Credit));
		}
		
		lblTotal.setText("SGD " + Double.toString(m_stUserProfile.TotalSaving));
		
		return;
	}
	
	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) 
	{
	    if (keyCode == KeyEvent.KEYCODE_BACK) 
	    {
	    	Intent intent = new Intent(CreditBalanceActivity.this, SettingActivity.class);
	    	intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
	    	startActivity(intent);
			CreditBalanceActivity.this.finish();
	    }
	    return super.onKeyDown(keyCode, event);
	}
}