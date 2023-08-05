package com.carpool;

import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.RelativeLayout;
import android.app.Activity;
import android.content.Intent;

public class SettingActivity extends Activity {
	
	private RelativeLayout rlHome;
	private RelativeLayout rlProfile;
	private RelativeLayout rlSharingCriteria;
	private RelativeLayout rlTellFriend;
	private RelativeLayout rlCreditBalance;
	private RelativeLayout rlHistory;
	private RelativeLayout rlHelp;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.setting);
		
		rlHome = (RelativeLayout) findViewById(R.id.rlSetting_Home);
		rlHome.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				Intent intent = new Intent(SettingActivity.this, SelectPositionActivity.class);
				intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_CLEAR_TASK | Intent.FLAG_ACTIVITY_NEW_TASK);
				startActivity(intent);
			}
		});

		rlProfile = (RelativeLayout) findViewById(R.id.rlSetting_Profile);
		rlProfile.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				Intent intent = new Intent(SettingActivity.this, ProfileInfoActivity.class);
				startActivity(intent);
				SettingActivity.this.finish();
			}
		});
		
		rlSharingCriteria = (RelativeLayout) findViewById(R.id.rlSetting_SharingCriteria);
		rlSharingCriteria.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				Intent intent = new Intent(SettingActivity.this, SharingCriteriaActivity.class);
				startActivity(intent);
				SettingActivity.this.finish();
			}
		});

		rlTellFriend = (RelativeLayout) findViewById(R.id.rlSetting_TellFriend);
		rlTellFriend.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				Intent intent = new Intent(SettingActivity.this, TellFriendActivity.class);
				startActivity(intent);
				SettingActivity.this.finish();
			}
		});
		
		rlHistory = (RelativeLayout) findViewById(R.id.rlSetting_HistoryAndRating);
		rlHistory.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				Intent intent = new Intent(SettingActivity.this, HistoryActivity.class);
				startActivity(intent);
				SettingActivity.this.finish();
			}
		});
		
		rlCreditBalance = (RelativeLayout) findViewById(R.id.rlSetting_CreditBalance);
		rlCreditBalance.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				Intent intent = new Intent(SettingActivity.this, CreditBalanceActivity.class);
				startActivity(intent);
				SettingActivity.this.finish();
			}
		});
		
		rlHelp = (RelativeLayout) findViewById(R.id.rlSetting_Help);
		rlHelp.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				Intent intent = new Intent(SettingActivity.this, HelpActivity.class);
				startActivity(intent);
				SettingActivity.this.finish();
			}
		});

		ResolutionSet._instance.iterateChild(findViewById(R.id.llSettingLayout));		
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
}