package com.carpool;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;

import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.webkit.WebView;
import android.widget.Button;

public class OnBoardActivity extends Activity {
	private WebView webData;
	private String strContent = ", Welcome to the club of smart riders! According to Land & Transport Authority's statistics, the average taxi travel distance is 9.7Km per person per trip, which translates to a minimum taxi fare (2 people, excluding any location & midnight surcharges and waiting time) of c.S$14. By sharing a taxi using Ride2Gather, you split the fare by two and effectively save S$7 on average. However, only 1 credit is deducted upon each successful sharing, which costs only S$1.28 or less. There will be absolutely NO credit deduction if you simply check in to a Taxi Stand but do not manage to get a match to share with in the end. Being an early bird, you have been rewarded with 5 FREE Credits(worth S$6.40). Hurry up, let your friends know about this promotion and start saving as well. Let's save more money, more time, and save our lobely earth together!";
	
	private Button btnStart;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.onboard);
		
		webData = (WebView) findViewById(R.id.webOnBoard_Data);
		webData.setBackgroundColor(0);
		
		String content = 
			       "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"+
			       "<html><head>"+
			       "<meta http-equiv=\"content-type\" content=\"text/html; charset=utf-8\" />"+
			       "</head><body><p align=\"justify\">";

		SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
		String strUserName = pref.getString(GlobalData.g_SharedPreferencesUserName, "");
		content = content + strUserName + strContent + "</p></body></html>";

		try 
		{
			webData.loadData(URLEncoder.encode(content,"utf-8").replaceAll("\\+"," "), "text/html; charset=UTF-8", "utf-8");
		}
		catch (UnsupportedEncodingException e) 
		{
		}

		btnStart = (Button) findViewById(R.id.btnOnBoard_Start);
		btnStart.setOnClickListener(new OnClickListener(){
			@Override
			public void onClick(View v)
			{
				SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
				boolean bFirst = pref.getBoolean(GlobalData.g_SharedPreferencesIntro, true);
				
				if (bFirst == true)
				{
					Intent intent = new Intent(OnBoardActivity.this, LogoActivity.class);
					startActivity(intent);
					OnBoardActivity.this.finish();
				}
				else
				{
					Intent intent = new Intent(OnBoardActivity.this, SelectPositionActivity.class);
					startActivity(intent);
					OnBoardActivity.this.finish();
				}				
			}
		});
		
		ResolutionSet._instance.iterateChild(findViewById(R.id.llOnBoardLayout));		
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
	    	Intent intent = new Intent(OnBoardActivity.this, NoticeActivity.class);
	    	startActivity(intent);
	    	finish();
	    }
	    return super.onKeyDown(keyCode, event);
	}
}