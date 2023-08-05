package com.carpool;

import org.json.JSONObject;

import com.CommService.CommMgr;
import com.HttpConn.JsonHttpResponseHandler;
import com.STData.STAgreeResponse;
import com.STData.STEvaluate;
import com.STData.StringContainer;

import android.os.Bundle;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.RatingBar;
import android.widget.TextView;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;

public class RatingActivity extends Activity {
	
	private Button btnSetting;
	private Button btnConfirm;
	private Button btnCancel;
	private TextView lblContent;
	private RatingBar starScore;
	
	private boolean bFlag = false;
	
	private long nMyID = 0;
	private long nYourID = 0;
	private String strName = "";
	private String strSrcAddress = "";
	private String strDstAddress = "";
	private String strPairTime = "";
	
	private STEvaluate m_stEvaluate = new STEvaluate();
	private ProgressDialog progDialog = null;
	private JsonHttpResponseHandler handlerEvaluate;
	
	private STAgreeResponse m_stAgree = new STAgreeResponse();
	private JsonHttpResponseHandler handlerAgree;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.rating);
		
		bFlag = getIntent().getBooleanExtra("Flag", false);
		nMyID = getIntent().getLongExtra("MyID", 0);
		nYourID = getIntent().getLongExtra("YourID", 0);
		strName = getIntent().getStringExtra("Name");
		strSrcAddress = getIntent().getStringExtra("SrcAddress");
		strDstAddress = getIntent().getStringExtra("DstAddress");
		strPairTime = getIntent().getStringExtra("PairTime");
		
		lblContent = (TextView) findViewById(R.id.lblRating_Content);		
		
		starScore = (RatingBar) findViewById(R.id.starRating_Star);
		
		btnSetting = (Button) findViewById(R.id.btnRating_Setting);
		btnSetting.setOnClickListener( new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				Intent intent = new Intent(RatingActivity.this, SettingActivity.class);
				intent.setFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
				startActivity(intent);
			}
		});
		
		btnConfirm = (Button) findViewById(R.id.btnRating_Confirm);
		btnConfirm.setOnClickListener( new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				RunBackgroundHandler();
				return;
			}
		});
		
		btnCancel = (Button) findViewById(R.id.btnRating_Cancel);
		btnCancel.setOnClickListener( new OnClickListener() {
			@SuppressLint("InlinedApi")
			@Override
			public void onClick(View v)
			{
				if (bFlag == true)
		    	{
		    		Intent intent = new Intent(RatingActivity.this, SelectPositionActivity.class);
		    		intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
		    		startActivity(intent);
		    		finish();
		    	}
		    	else
		    		finish();
				return;
			}
		});
		
		if (bFlag == true)
		{
			handlerAgree = new JsonHttpResponseHandler()
			{
				int result = 0;
				
				@Override
				public void onSuccess(JSONObject jsonData)
				{
					result = 1;
					m_stAgree = CommMgr.commService.GetOppoAgreeFromJsonData(jsonData);
					if (m_stAgree.ErrCode == 1)
					{
						strPairTime = m_stAgree.PairTime;
						lblContent.setText("Name : " + strName + System.getProperty ("line.separator")
								 + "Start Address : " + strSrcAddress + System.getProperty ("line.separator")
								 + "Dest Address : " + strDstAddress + System.getProperty ("line.separator")
								 + "Paired Time : " + strPairTime);
					}
					else 
						result = 2;
				}
				
				@Override
				public void onFailure(Throwable ex, String exception) {
				}
				
				@Override
				public void onFinish()
				{
					progDialog.dismiss();
					if (result == 0)
					{
						GlobalData.showToast(RatingActivity.this, getString(R.string.server_connection_error));
					}
					
					if (result == 2)
					{
						GlobalData.showToast(RatingActivity.this, getString(R.string.service_error));
					}
					
					result = 0;
				}
				
			};
			
			progDialog = ProgressDialog.show(
					RatingActivity.this,
					"", 
					getString(R.string.waiting),
					true,
					true,
					null);
			
			CommMgr.commService.RequestOppoAgree(nMyID, handlerAgree);
		}
		else
		{
			lblContent.setText("Name : " + strName + System.getProperty ("line.separator")
				 + "Start Address : " + strSrcAddress + System.getProperty ("line.separator")
				 + "Dest Address : " + strDstAddress + System.getProperty ("line.separator")
				 + "Paired Time : " + strPairTime);
		}

		ResolutionSet._instance.iterateChild(findViewById(R.id.llRatingLayout));		
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
	
	private void RunBackgroundHandler()
	{
		handlerEvaluate = new JsonHttpResponseHandler()
		{
			int result = 0;
			
			@Override
			public void onSuccess(JSONObject jsonData)
			{
				result = 1;
				StringContainer res = CommMgr.commService.GetEvaluateFromJsonData(jsonData);
				if ( res.Result > 0 )
				{	
					progDialog.dismiss();
					
					Intent intent = new Intent(RatingActivity.this, HistoryActivity.class);
					intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
					startActivity(intent);
				}
				else
				{
					if (res.Result == -106)
					{
						result = 3;
						GlobalData.showToast(RatingActivity.this, getString(R.string.Rating_AlreadyUpdated));
						Intent intent = new Intent(RatingActivity.this, HistoryActivity.class);
						intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
						startActivity(intent);
					}
					else
						result = 2;
				}
			}
			
			@Override
			public void onFailure(Throwable ex, String exception) {
			}
			
			@Override
			public void onFinish()
			{
				progDialog.dismiss();
				if (result == 0)
				{
					GlobalData.showToast(RatingActivity.this, getString(R.string.server_connection_error));
				}
				
				if (result == 2)
				{
					GlobalData.showToast(RatingActivity.this, getString(R.string.service_error));
				}
				
				result = 0;
			}
			
		};

		m_stEvaluate.Uid = nMyID;
		m_stEvaluate.OppoID = nYourID;
		m_stEvaluate.Score = starScore.getRating();
		m_stEvaluate.ServeTime = strPairTime;
		
		progDialog = ProgressDialog.show(
				RatingActivity.this,
				"", 
				getString(R.string.waiting),
				true,
				true,
				null);
		
		CommMgr.commService.RequestEvaluate(m_stEvaluate, handlerEvaluate);
		
		return;
	}
	
	@SuppressLint("InlinedApi")
	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) 
	{
	    if (keyCode == KeyEvent.KEYCODE_BACK) 
	    {
	    	if (bFlag == true)
	    	{
	    		Intent intent = new Intent(RatingActivity.this, SelectPositionActivity.class);
	    		intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK);
	    		startActivity(intent);
	    	}
	    	else
	    		finish();
	    }
	    return super.onKeyDown(keyCode, event);
	}
}