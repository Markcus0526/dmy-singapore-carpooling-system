package com.carpool;

import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.TextView;
import android.app.Activity;
import android.content.Intent;

public class BuyCreditsActivity extends Activity {
	
	private int mCredits = -1;
	
	private TextView lblContent = null;
	private Button btnReturn;
	private Button btnSetting;
	private Button btnBuyCredits;
		
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.buycredits);
		
		mCredits = getIntent().getIntExtra("Credits", 0);
		
		lblContent = (TextView) findViewById(R.id.lblBuyCredits_CreditsHint);
		String text = String.format( getResources().getString(R.string.BuyCredits_CreditsHint), mCredits);		
		lblContent.setText( text );
		
		btnReturn = (Button) findViewById(R.id.btnBuyCredits_Return);
		btnReturn.setOnClickListener( new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				finish();
			}
		});
		
		btnSetting = (Button) findViewById(R.id.btnBuyCredits_Setting);
		btnSetting.setOnClickListener( new OnClickListener() 
		{
			@Override
			public void onClick(View v)
			{
				Intent intent = new Intent(BuyCreditsActivity.this, SettingActivity.class);
				intent.setFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
				startActivity(intent);
			}
		});
		
		btnBuyCredits = (Button) findViewById(R.id.btnBuyCredits_BuyCredits);
		btnBuyCredits.setOnClickListener( new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				Intent intent = new Intent(BuyCreditsActivity.this, BuyCreditsRequestActivity.class);
				startActivity(intent);				
				return;
			}
		});
		
		ResolutionSet._instance.iterateChild(findViewById(R.id.llBuyCreditsLayout));		
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