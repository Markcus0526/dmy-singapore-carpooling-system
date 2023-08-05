package com.carpool;

import com.STData.STPairInfo;

import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.TextView;
import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;

public class CheckInActivity extends Activity {
		
	private Button btnConfirm;
	private Button btnAmend;
	private Button btnSetting;
	private TextView lblConfirmData;
	
	private STPairInfo m_stPairInfo = new STPairInfo();
		
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.checkin);
		
		m_stPairInfo.Uid = getIntent().getLongExtra("Uid", 0);
		m_stPairInfo.SrcLat = getIntent().getDoubleExtra("SrcLat", 0.0f);
		m_stPairInfo.SrcLon = getIntent().getDoubleExtra("SrcLon", 0.0f);
		m_stPairInfo.DstLat = getIntent().getDoubleExtra("DstLat", 0.0f);
		m_stPairInfo.DstLon = getIntent().getDoubleExtra("DstLon", 0.0f);
		m_stPairInfo.Destination = getIntent().getStringExtra("DstAddress");
		m_stPairInfo.Count = getIntent().getIntExtra("Pax", 1);
		m_stPairInfo.GrpGender = getIntent().getIntExtra("GrpGender", 2);
		m_stPairInfo.Color = getIntent().getStringExtra("ColorOfTop");
		m_stPairInfo.OtherFeature = getIntent().getStringExtra("OtherFeature");
						
		btnConfirm = (Button) findViewById(R.id.btnCheckIn_Confirm);
		btnConfirm.setOnClickListener( new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
				SharedPreferences.Editor editor = pref.edit();
				editor.putFloat(GlobalData.g_SharedPreferencesSrcLatitude, (float)m_stPairInfo.SrcLat);
				editor.putFloat(GlobalData.g_SharedPreferencesSrcLongitude, (float)m_stPairInfo.SrcLon);
				editor.putFloat(GlobalData.g_SharedPreferencesDstLatitude, (float)m_stPairInfo.DstLat);
				editor.putFloat(GlobalData.g_SharedPreferencesDstLongitude, (float)m_stPairInfo.DstLon);
				editor.putString(GlobalData.g_SharedPreferences_MyInfoDestination, m_stPairInfo.Destination);
				editor.putString(GlobalData.g_SharedPreferences_MyInfoColor, m_stPairInfo.Color);
				editor.putInt(GlobalData.g_SharedPreferences_MyInfoCount, m_stPairInfo.Count);
				editor.putInt(GlobalData.g_SharedPreferences_MyInfoGrpGender, m_stPairInfo.GrpGender);
				editor.putString(GlobalData.g_SharedPreferences_MyInfoOtherFeature, m_stPairInfo.OtherFeature);
				editor.commit();
				
				Intent intent = new Intent(CheckInActivity.this, MatchingActivity.class);
				intent.putExtra("PairInfo", m_stPairInfo);
				intent.putExtra("ReRequest", false);
				startActivity(intent);
			}
		});
		
		btnAmend = (Button) findViewById(R.id.btnCheckIn_Amend);
		btnAmend.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				Intent intent = new Intent(CheckInActivity.this, SelectPositionActivity.class);
				intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
				startActivity(intent);
				return;
			}
		});
		
		btnSetting = (Button) findViewById(R.id.btnCheckIn_Setting);
		btnSetting.setOnClickListener(new OnClickListener(){
			@Override
			public void onClick(View v)
			{
				Intent intent = new Intent(CheckInActivity.this, SettingActivity.class);
				intent.setFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
				startActivity(intent);
			}
		});
		
		lblConfirmData = (TextView) findViewById(R.id.lblCheckIn_ConfirmData);
		String strData = "Your destination : " + System.getProperty("line.separator") + "   " + m_stPairInfo.Destination + System.getProperty ("line.separator") + System.getProperty ("line.separator");
		if (m_stPairInfo.Count == 1)
			strData = strData + "You are " + Integer.toString(m_stPairInfo.Count) + " person." + System.getProperty("line.separator") + System.getProperty ("line.separator");
		else
			strData = strData + "You are " + Integer.toString(m_stPairInfo.Count) + " persons." + System.getProperty("line.separator") + System.getProperty ("line.separator");
		
		strData = strData + "Colour of your top is " + m_stPairInfo.Color + System.getProperty ("line.separator") + System.getProperty ("line.separator");
		if ( m_stPairInfo.OtherFeature.length() > 0 )
			strData += "Your other feature is " + m_stPairInfo.OtherFeature;
		lblConfirmData.setText(strData);
						
		ResolutionSet._instance.iterateChild(findViewById(R.id.llCheckInLayout));		
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