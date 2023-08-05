package com.carpool;

import android.app.Activity;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.TextView;

public class NotificationActivity extends Activity {
	private TextView lblContent;
	private Button btnNext;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.notification);
		
		String strData = getIntent().getStringExtra("Content");
		
		lblContent = (TextView) findViewById(R.id.lblNotifiation_Content);
		lblContent.setText(strData);

		btnNext = (Button) findViewById(R.id.btnNotification_Next);
		btnNext.setOnClickListener( new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				NotificationActivity.this.finish();
			}
		});
		
		ResolutionSet._instance.iterateChild(findViewById(R.id.llNotificationLayout));		
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
	
	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) 
	{
	    if (keyCode == KeyEvent.KEYCODE_BACK) 
	    {
	    	finish();
	    }
	    return super.onKeyDown(keyCode, event);
	}
}