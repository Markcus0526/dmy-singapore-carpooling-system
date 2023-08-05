package com.carpool;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.webkit.WebView;
import android.widget.Button;

public class NoticeActivity extends Activity {
	private WebView webData;
	private Button btnNext;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.notice);
		
		webData = (WebView) findViewById(R.id.webNotice_Data);
		webData.setBackgroundColor(0);
		
		String content = 
			       "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"+
			       "<html><head>"+
			       "<meta http-equiv=\"content-type\" content=\"text/html; charset=utf-8\" />"+
			       "</head><body><p align=\"justify\">";

		content += getResources().getString(R.string.Notice_Data) + "</p></body></html>";

		try 
		{
			webData.loadData(URLEncoder.encode(content,"utf-8").replaceAll("\\+"," "), "text/html; charset=UTF-8", "utf-8");
		}
		catch (UnsupportedEncodingException e) 
		{
		}
		
		btnNext = (Button) findViewById(R.id.btnNotice_Next);
		btnNext.setOnClickListener( new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				Intent intent = new Intent(NoticeActivity.this, OnBoardActivity.class);
				startActivity(intent);
				NoticeActivity.this.finish();
			}
		});
		
		ResolutionSet._instance.iterateChild(findViewById(R.id.llNoticeLayout));		
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
	    	Intent intent = new Intent(NoticeActivity.this, SignInActivity.class);
	    	startActivity(intent);
	    	finish();
	    }
	    return super.onKeyDown(keyCode, event);
	}
}