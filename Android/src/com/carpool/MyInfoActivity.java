package com.carpool;

import java.util.ArrayList;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.RelativeLayout;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.AdapterView.OnItemSelectedListener;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;

public class MyInfoActivity extends Activity {
	
	private static final int DESTINATIONLIST_REQUEST = 0;
	
	private double mSrcLatitude = 0.0f;
	private double mSrcLongitude = 0.0f;
	private double mDstLatitude = 0.0f;
	private double mDstLongitude = 0.0f;
	private String mDstAddress;
		
	private Spinner spinPax;
	private Spinner spinGroupGender;
	private Spinner spinColorOfTop;
	private TextView lblDestination;
	private EditText txtOtherFeature;
	private Button btnCheckIn;
	private Button btnBack;
	
	private ArrayList<String> m_arrPax = null;
	private PaxAdapter adapterPax = null;
	
	private ArrayList<String> m_arrGender = null;
	private GenderAdapter adapterGender = null;
	
	private ArrayList<String> m_arrColor = null;
	private ColorAdapter adapterColor = null;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.myinfo);
				
		String[] arrPax = getResources().getStringArray(R.array.MyInfo_Pax);
		m_arrPax = new ArrayList<String>(arrPax.length);
		for (String strVal : arrPax)
			m_arrPax.add(strVal);
		
		String[] arrGender = getResources().getStringArray(R.array.MyInfo_GroupGender);
		m_arrGender = new ArrayList<String>(arrGender.length);
		for (String strVal : arrGender)
			m_arrGender.add(strVal);
		
		String[] arrColor = getResources().getStringArray(R.array.ColorList);
		m_arrColor = new ArrayList<String>(arrColor.length);
		for (String strVal : arrColor)
			m_arrColor.add(strVal);
		
		mDstLatitude = getIntent().getDoubleExtra("DstLat", 0.0f);
		mDstLongitude = getIntent().getDoubleExtra("DstLon", 0.0f);
		mDstAddress = getIntent().getStringExtra("DstAddress");

		txtOtherFeature = (EditText) findViewById(R.id.txtMyInfo_OtherFeature);
		
		lblDestination = (TextView) findViewById(R.id.lblMyInfo_Destination);
		lblDestination.setOnClickListener( new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				Intent intent = new Intent(MyInfoActivity.this, DestinationListActivity.class);
				startActivityForResult(intent, DESTINATIONLIST_REQUEST);				
				return;
			}
		});
		
		btnCheckIn = (Button) findViewById(R.id.btnMyInfo_CheckIn);
		btnCheckIn.setOnClickListener( new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				if ( isValidUserInputedInfo() == false )
					return;
				
				/*
				 * index start from 0
				 * pair count  = pax + 1
				 */
				int nPax = (int)(spinPax.getSelectedItemId()+1);
				int nGroupGender = (int)(spinGroupGender.getSelectedItemId());
				String strColorOfTop = spinColorOfTop.getSelectedItem().toString();

				Intent intent = new Intent(MyInfoActivity.this, CheckInActivity.class);				
				SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
				intent.putExtra("Uid", pref.getLong("Uid", 0));				
				intent.putExtra("SrcLat", mSrcLatitude);
				intent.putExtra("SrcLon", mSrcLongitude);
				intent.putExtra("DstLat", mDstLatitude);
				intent.putExtra("DstLon", mDstLongitude);
				intent.putExtra("DstAddress", mDstAddress);
				intent.putExtra("Pax", nPax);
				intent.putExtra("GrpGender", nGroupGender);
				intent.putExtra("ColorOfTop", strColorOfTop);
				intent.putExtra("OtherFeature", txtOtherFeature.getText().toString());
				startActivity(intent);
			}
		});
		
		btnBack = (Button) findViewById(R.id.btnMyInfo_back);
		btnBack.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				finish();
			}
		});
		
		spinPax = (Spinner) findViewById(R.id.spinMyInfo_Pax);
		spinPax.setOnItemSelectedListener( new OnItemSelectedListener() {
			@Override
			public void onItemSelected(AdapterView<?> arg0, View arg1, int arg2, long arg3) {
				if (arg2 == 0)
				{
					spinGroupGender.setEnabled(false);
				}
				else
				{
					spinGroupGender.setEnabled(true);
				}
			}

			@Override
			public void onNothingSelected(AdapterView<?> arg0) {
			}
		});
		adapterPax = new PaxAdapter(MyInfoActivity.this, 0, m_arrPax);
		adapterPax.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
		spinPax.setAdapter(adapterPax);
		
		spinGroupGender = (Spinner) findViewById(R.id.spinMyInfo_GroupGender);
		adapterGender = new GenderAdapter(MyInfoActivity.this, 0, m_arrGender);
		adapterGender.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
		spinGroupGender.setAdapter(adapterGender);
		
		spinColorOfTop = (Spinner) findViewById(R.id.spinMyInfo_ColorOfTop);
		adapterColor = new ColorAdapter(MyInfoActivity.this, 0, m_arrColor);
		adapterColor.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
		spinColorOfTop.setAdapter(adapterColor);
				
		ResolutionSet._instance.iterateChild(findViewById(R.id.llMyInfoLayout));		
	}
	
	class PaxAdapter extends ArrayAdapter<String> {
		ArrayList<String> list;
		Context ctx;
		
		public PaxAdapter(Context ctx, int resourceId, ArrayList<String> list) {
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
				RelativeLayout rlLayout = (RelativeLayout)v.findViewById(R.id.llSpinnerEditBack);
				//if (position == 0)
					//rlLayout.setVisibility(View.GONE);
					//rlLayout.setLayoutParams( new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.FILL_PARENT, 1));
				ResolutionSet._instance.iterateChild(rlLayout);
			}
			
			TextView txtName = (TextView)v.findViewById(R.id.lblSpinnerText);
			txtName.setText(list.get(position));
			//txtName.setTextSize(TypedValue.COMPLEX_UNIT_PX, (float)(ResolutionSet.fPro * txtName.getTextSize()));
			
			return v;
		}
	}
	
	class GenderAdapter extends ArrayAdapter<String> {
		ArrayList<String> list;
		Context ctx;
		
		public GenderAdapter(Context ctx, int resourceId, ArrayList<String> list) {
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
	
	class ColorAdapter extends ArrayAdapter<String> {
		ArrayList<String> list;
		Context ctx;
		
		public ColorAdapter(Context ctx, int resourceId, ArrayList<String> list) {
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
		
		SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
		mSrcLatitude = pref.getFloat(GlobalData.g_SharedPreferencesSrcLatitude, 0.0f);
		mSrcLongitude = pref.getFloat(GlobalData.g_SharedPreferencesSrcLongitude, 0.0f);
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
	
	private boolean isValidUserInputedInfo()
	{
		String strData = "";
		strData = lblDestination.getText().toString();
		if (strData.length() == 0)
		{
			GlobalData.showToast(MyInfoActivity.this, getString(R.string.destination_insert_error));
			return false;
		}		
		
		return true;
	}
	
	@Override
	public void onActivityResult(int requestCode, int resultCode, Intent intent)
	{
		super.onActivityResult(requestCode, resultCode, intent);
		
		switch (requestCode)
		{
		case DESTINATIONLIST_REQUEST:
			if ( resultCode == RESULT_OK )
			{
				mDstLatitude = intent.getDoubleExtra("DstLat", 0.0f);
				mDstLongitude = intent.getDoubleExtra("DstLon", 0.0f);
				mDstAddress = intent.getStringExtra("DstAddress");
				lblDestination.setText(mDstAddress);
			}
			break;
		}
	}
}