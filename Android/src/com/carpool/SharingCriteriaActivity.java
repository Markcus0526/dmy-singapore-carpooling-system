package com.carpool;

import java.util.ArrayList;

import org.json.JSONObject;

import com.CommService.CommMgr;
import com.HttpConn.JsonHttpResponseHandler;
import com.STData.STUserProfile;
import com.STData.StringContainer;

import android.os.Bundle;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemSelectedListener;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.Spinner;
import android.widget.TextView;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;

public class SharingCriteriaActivity extends Activity {
	
	private Button btnSetting;
	private Button btnOk;
	private Spinner spinCarPool;
	private Spinner spinIndGender;
	private Spinner spinGrpGender;
	private Spinner spinDelayTime;
	
	private STUserProfile m_stUserProfile = new STUserProfile();
	private ProgressDialog progDialog;
	private JsonHttpResponseHandler handler;
	private JsonHttpResponseHandler handlerUpload;
	
	private ArrayList<String> m_arrCarPool = null;
	private CarPoolAdapter adapterCarPool = null;
	
	private ArrayList<String> m_arrIndGender = null;
	private IndGenderAdapter adapterIndGender = null;	

	private ArrayList<String> m_arrGrpGender = null;
	private GrpGenderAdapter adapterGrpGender = null;
	
	private ArrayList<String> m_arrDelayTime = null;
	private DelayTimeAdapter adapterDelayTime = null;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.sharingcriteria);
		
		String[] arrCarPool = getResources().getStringArray(R.array.SharingCriteria_CarPool);
		m_arrCarPool = new ArrayList<String>(arrCarPool.length);
		for (String strVal : arrCarPool)
			m_arrCarPool.add(strVal);
		
		String[] arrIndGender = getResources().getStringArray(R.array.SharingCriteria_Gender);
		m_arrIndGender = new ArrayList<String>(arrIndGender.length);
		for (String strVal : arrIndGender)
			m_arrIndGender.add(strVal);
		
		String[] arrGrpGender = getResources().getStringArray(R.array.SharingCriteria_GrpGender);
		m_arrGrpGender = new ArrayList<String>(arrGrpGender.length);
		for (String strVal : arrGrpGender)
			m_arrGrpGender.add(strVal);
		
		String[] arrDelayTime = getResources().getStringArray(R.array.SharingCriteria_DelayTime);
		m_arrDelayTime = new ArrayList<String>(arrDelayTime.length);
		for (String strVal : arrDelayTime)
			m_arrDelayTime.add(strVal);
		
		spinCarPool = (Spinner) findViewById(R.id.spinSharingCriteria_CarPool);
		spinCarPool.setOnItemSelectedListener( new OnItemSelectedListener() {
			@Override
			public void onItemSelected(AdapterView<?> arg0, View arg1, int arg2, long arg3) {
				if (arg2 == 0)
				{
					spinGrpGender.setEnabled(false);
				}
				else
				{
					spinGrpGender.setEnabled(true);
				}
			}

			@Override
			public void onNothingSelected(AdapterView<?> arg0) {
			}
		});
		
		adapterCarPool = new CarPoolAdapter(SharingCriteriaActivity.this, 0, m_arrCarPool);
		adapterCarPool.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
		spinCarPool.setAdapter(adapterCarPool);
				
		spinIndGender = (Spinner) findViewById(R.id.spinSharingCriteria_IndGender);
		adapterIndGender = new IndGenderAdapter(SharingCriteriaActivity.this, 0, m_arrIndGender);
		adapterIndGender.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
		spinIndGender.setAdapter(adapterIndGender);
		
		spinGrpGender = (Spinner) findViewById(R.id.spinSharingCriteria_GrpGender);
		adapterGrpGender = new GrpGenderAdapter(SharingCriteriaActivity.this, 0, m_arrGrpGender);
		adapterGrpGender.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
		spinGrpGender.setAdapter(adapterGrpGender);
		
		spinDelayTime = (Spinner) findViewById(R.id.spinSharingCriteria_DelayTime);
		adapterDelayTime = new DelayTimeAdapter(SharingCriteriaActivity.this, 0, m_arrDelayTime);
		adapterDelayTime.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
		spinDelayTime.setAdapter(adapterDelayTime);
		
		btnSetting = (Button) findViewById(R.id.btnSharingCriteria_Setting);
		btnSetting.setOnClickListener( new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				Intent intent = new Intent(SharingCriteriaActivity.this, SettingActivity.class);
				startActivity(intent);
				SharingCriteriaActivity.this.finish();
			}
		});
		
		btnOk = (Button) findViewById(R.id.btnSharingCriteria_Ok);
		btnOk.setOnClickListener( new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
				m_stUserProfile.Uid = pref.getLong(GlobalData.g_SharedPreferencesUserID, 0);
				m_stUserProfile.IsGroup = spinCarPool.getSelectedItemPosition();
				m_stUserProfile.IndGender = spinIndGender.getSelectedItemPosition();
				m_stUserProfile.GrpGender = spinGrpGender.getSelectedItemPosition();
				switch(spinDelayTime.getSelectedItemPosition())
				{
				case 0:
					m_stUserProfile.DelayTime = 3;
					break;
				case 1:
					m_stUserProfile.DelayTime = 5;
					break;
				case 2:
					m_stUserProfile.DelayTime = 10;
					break;
				}
				
				progDialog = ProgressDialog.show(
					SharingCriteriaActivity.this,
					"", 
					getString(R.string.waiting),
					true,
					true,
					null);
				CommMgr.commService.RequestUserProfileUpdate(m_stUserProfile, handlerUpload);
				
				return;
			}
		});

		ResolutionSet._instance.iterateChild(findViewById(R.id.llSharingCriteriaLayout));		
	}
	
	class CarPoolAdapter extends ArrayAdapter<String> {
		ArrayList<String> list;
		Context ctx;
		
		public CarPoolAdapter(Context ctx, int resourceId, ArrayList<String> list) {
			super(ctx, resourceId, list);
			this.ctx = ctx;
			this.list = list;
		}

		@Override
		public int getCount() {
			return list.size();
		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			View v = convertView;
			if (v == null)
			{
				LayoutInflater inflater = (LayoutInflater)ctx.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
				v = inflater.inflate(R.layout.spinner_edit, null);
				ResolutionSet._instance.iterateChild(v.findViewById(R.id.llSpinnerEditBack));
			}
			
			TextView txtName = (TextView)v.findViewById(R.id.lblSpinnerText);
			txtName.setText(list.get(position));
			//txtName.setTextSize(TypedValue.COMPLEX_UNIT_PX, (float)(ResolutionSet.fPro * txtName.getTextSize()));
			
			return v;
		}
	}
	
	class IndGenderAdapter extends ArrayAdapter<String> {
		ArrayList<String> list;
		Context ctx;
		
		public IndGenderAdapter(Context ctx, int resourceId, ArrayList<String> list) {
			super(ctx, resourceId, list);
			this.ctx = ctx;
			this.list = list;
		}

		@Override
		public int getCount() {
			return list.size();
		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			View v = convertView;
			if (v == null)
			{
				LayoutInflater inflater = (LayoutInflater)ctx.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
				v = inflater.inflate(R.layout.spinner_edit, null);
				ResolutionSet._instance.iterateChild(v.findViewById(R.id.llSpinnerEditBack));
			}
			
			TextView txtName = (TextView)v.findViewById(R.id.lblSpinnerText);
			txtName.setText(list.get(position));
			//txtName.setTextSize(TypedValue.COMPLEX_UNIT_PX, (float)(ResolutionSet.fPro * txtName.getTextSize()));
			
			return v;
		}
	}
	
	class GrpGenderAdapter extends ArrayAdapter<String> {
		ArrayList<String> list;
		Context ctx;
		
		public GrpGenderAdapter(Context ctx, int resourceId, ArrayList<String> list) {
			super(ctx, resourceId, list);
			this.ctx = ctx;
			this.list = list;
		}

		@Override
		public int getCount() {
			return list.size();
		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			View v = convertView;
			if (v == null)
			{
				LayoutInflater inflater = (LayoutInflater)ctx.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
				v = inflater.inflate(R.layout.spinner_edit, null);
				ResolutionSet._instance.iterateChild(v.findViewById(R.id.llSpinnerEditBack));
			}
			
			TextView txtName = (TextView)v.findViewById(R.id.lblSpinnerText);
			txtName.setText(list.get(position));
			//txtName.setTextSize(TypedValue.COMPLEX_UNIT_PX, (float)(ResolutionSet.fPro * txtName.getTextSize()));
			
			return v;
		}
	}
	
	class DelayTimeAdapter extends ArrayAdapter<String> {
		ArrayList<String> list;
		Context ctx;
		
		public DelayTimeAdapter(Context ctx, int resourceId, ArrayList<String> list) {
			super(ctx, resourceId, list);
			this.ctx = ctx;
			this.list = list;
		}

		@Override
		public int getCount() {
			return list.size();
		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			View v = convertView;
			if (v == null)
			{
				LayoutInflater inflater = (LayoutInflater)ctx.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
				v = inflater.inflate(R.layout.spinner_edit, null);
				ResolutionSet._instance.iterateChild(v.findViewById(R.id.llSpinnerEditBack));
			}
			
			TextView txtName = (TextView)v.findViewById(R.id.lblSpinnerText);
			txtName.setText(list.get(position));
			//txtName.setTextSize(TypedValue.COMPLEX_UNIT_PX, (float)(ResolutionSet.fPro * txtName.getTextSize()));
			
			return v;
		}
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
					GlobalData.showToast(SharingCriteriaActivity.this, getString(R.string.server_connection_error));
					finish();
				}
				
				if (result == 2)
				{
					GlobalData.showToast(SharingCriteriaActivity.this, getString(R.string.service_error));
				}
				
				result = 0;
			}			
		};
		
		handlerUpload = new JsonHttpResponseHandler()
		{
			int result = 0;
			
			@Override
			public void onSuccess(JSONObject jsonData)
			{
				result = 1;
				StringContainer res = new StringContainer();
				res = CommMgr.commService.GetUserProfileUpdateFromJsonData(jsonData);
				if ( res.Result == 1 )
				{	
					progDialog.dismiss();
					GlobalData.showToast(SharingCriteriaActivity.this, getString(R.string.SharingCriteria_SaveSuccess));
					SharingCriteriaActivity.this.finish();
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
					GlobalData.showToast(SharingCriteriaActivity.this, getString(R.string.server_connection_error));
				}
				
				if (result == 2)
				{
					GlobalData.showToast(SharingCriteriaActivity.this, getString(R.string.service_error));
				}
				
				result = 0;
			}			
		};
		
		progDialog = ProgressDialog.show(
				SharingCriteriaActivity.this,
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
		spinCarPool.setSelection(m_stUserProfile.IsGroup);
		spinIndGender.setSelection(m_stUserProfile.IndGender);
		spinGrpGender.setSelection(m_stUserProfile.GrpGender);		
		switch(m_stUserProfile.DelayTime)
		{
		case 3:
			spinDelayTime.setSelection(0);
			break;
		case 5:
			spinDelayTime.setSelection(1);
			break;
		case 10:
			spinDelayTime.setSelection(2);
			break;
		default:
			spinDelayTime.setSelection(0);
		}
		
		return;
	}
	
	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) 
	{
	    if (keyCode == KeyEvent.KEYCODE_BACK) 
	    {
	    	Intent intent = new Intent(SharingCriteriaActivity.this, SettingActivity.class);
	    	intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
	    	startActivity(intent);
	    	SharingCriteriaActivity.this.finish();
	    }
	    return super.onKeyDown(keyCode, event);
	}
}