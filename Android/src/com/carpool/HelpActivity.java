package com.carpool;

import android.os.Bundle;
import android.text.Html;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.TextView;
import android.app.Activity;
import android.content.Intent;

public class HelpActivity extends Activity {
	
	private Button btnSetting;
	private TextView lblHelpContent;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.help);		
		
		btnSetting = (Button) findViewById(R.id.btnHelp_Setting);
		btnSetting.setOnClickListener( new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				Intent intent = new Intent(HelpActivity.this, SettingActivity.class);
				startActivity(intent);
				HelpActivity.this.finish();
			}
		});
		
		lblHelpContent = (TextView) findViewById(R.id.lblHelp_Content);
		String str1 = "If you have enquiries regarding the App, Please contact us at ";
		String str2 = "Ride2gather@gmail.com";
		lblHelpContent.setText(Html.fromHtml( str1 + "<br />" + "<br />" + "<b>" + str2 + "</b>"));

		ResolutionSet._instance.iterateChild(findViewById(R.id.llHelpLayout));		
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
	    	Intent intent = new Intent(HelpActivity.this, SettingActivity.class);
	    	intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
	    	startActivity(intent);
	    	HelpActivity.this.finish();
	    }
	    return super.onKeyDown(keyCode, event);
	}
}