package com.carpool;

import java.io.ByteArrayOutputStream;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Locale;
import java.util.Map;

import org.brickred.socialauth.Profile;
import org.json.JSONObject;

import com.CommService.CommMgr;
import com.HttpConn.JsonHttpResponseHandler;
import com.STData.STFLAuthInfo;
import com.STData.STLoginResult;
import com.Utils.ImageLoader;

import android.os.Bundle;
import android.util.Base64;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.Spinner;
import android.widget.TextView;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.graphics.Bitmap.CompressFormat;
import android.graphics.drawable.BitmapDrawable;

public class UserProfileActivity extends Activity {

	private final int COUNT = 100;	
		
	private Profile profileMap = null;
	private ImageLoader imageLoader;
	
	private ImageView imgPhoto;
	private Spinner spinGender;
	private Spinner spinYear;
	private TextView lblEmail;
	private EditText txtPhoneNumber;
	private Button btnNext;

	private STFLAuthInfo m_stFLAuthInfo = new STFLAuthInfo();
	private STLoginResult m_stLoginResult = new STLoginResult();
	private JsonHttpResponseHandler handlerUserProfile = null;
	
	private ProgressDialog progDialog = null;
	
	private int nYear = 0;
		
	private ArrayList<String> m_arrGender = null;
	private GenderAdapter adapterGender = null;
	
	private ArrayList<String> m_arrBirthYear = null;
	private BirthYearAdapter adapterBirthYear = null;
		
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.userprofile);
		
		String[] arrGender = getResources().getStringArray(R.array.UserRegister_GroupGender);
		m_arrGender = new ArrayList<String>(arrGender.length);
		for (String strVal : arrGender)
			m_arrGender.add(strVal);
				
		SimpleDateFormat format = new SimpleDateFormat("yyyy", Locale.CHINA);
		Date currentTime = new Date();
		String time = format.format(currentTime);
		nYear = Integer.parseInt(time);
		
		m_arrBirthYear = new ArrayList<String>(COUNT);
		for ( int i = 0; i < COUNT; i++)
		{
			m_arrBirthYear.add(Integer.toString((nYear - COUNT) + i+1));
		}
		
		imgPhoto = (ImageView) findViewById(R.id.imgUserProfile_Photo);
		spinGender = (Spinner) findViewById(R.id.spinUserProfile_Gender);
		adapterGender = new GenderAdapter(UserProfileActivity.this, 0, m_arrGender);
		adapterGender.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
		spinGender.setAdapter(adapterGender);
		
		spinYear = (Spinner) findViewById(R.id.spinUserProfile_Year);
		adapterBirthYear = new BirthYearAdapter(UserProfileActivity.this, 0, m_arrBirthYear);
		adapterBirthYear.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
		spinYear.setAdapter(adapterBirthYear);
		
		
		lblEmail = (TextView) findViewById(R.id.lblUserProfile_Email);
		txtPhoneNumber = (EditText) findViewById(R.id.txtUserProfile_PhoneNumber);
		
		btnNext = (Button) findViewById(R.id.btnUserProfile_Next);
		btnNext.setOnClickListener( new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				if (isAvailableUserRegisteredData() == false)
					return;
				
				RunBackgroundHandler();
			}
		});
		
		profileMap = (Profile) getIntent().getSerializableExtra("profile");
				
		imageLoader = new ImageLoader(UserProfileActivity.this);
		imageLoader.DisplayImage(profileMap.getProfileImageURL(), imgPhoto);
		
		if (profileMap != null)
		{
			String strData = null;
			try
			{
				strData = profileMap.getGender();
			}
			catch(Exception e)
			{
				strData = null;
			}
			
			spinGender.setSelection(0);
			
			try
			{
				int year = profileMap.getDob().getYear();
				spinYear.setSelection(100 - (nYear - year) - 1);
				
			}
			catch(Exception e)
			{
				strData = null;
			}
			
			try
			{
				strData = profileMap.getEmail();
			}
			catch(Exception e)
			{
				strData = null;
			}
			if ((strData != null) && (strData != ""))
				lblEmail.setText(strData);
			
			try
			{
				strData = profileMap.getCountry();
			}
			catch(Exception e)
			{
				strData = null;
			}
			
			Map<String, String> mapData = profileMap.getContactInfo();
			if ( mapData != null )
			{
				try {
					strData = mapData.get("mobile");
				} catch (Exception e) {
					strData = "";
				}
				
				if (strData.length() > 0)
				{
					if ( Character.isLetter(strData.charAt(0)))
						strData = "";
				}
			}
			
			txtPhoneNumber.setText("");
		}
		
		ResolutionSet._instance.iterateChild(findViewById(R.id.llUserProfileLayout));		
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
				v = inflater.inflate(R.layout.register_spinner_edit, null);
				ResolutionSet._instance.iterateChild(v.findViewById(R.id.llRegisterSpinnerEditBack));
			}
			
			TextView txtName = (TextView)v.findViewById(R.id.lblSpinnerText);
			txtName.setText(list.get(position));
			//txtName.setTextSize(TypedValue.COMPLEX_UNIT_PX, (float)(ResolutionSet.fPro * txtName.getTextSize()));
			
			return v;
		}
	}
	
	class BirthYearAdapter extends ArrayAdapter<String> {
		ArrayList<String> list;
		Context ctx;
		
		public BirthYearAdapter(Context ctx, int resourceId, ArrayList<String> list) {
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
				v = inflater.inflate(R.layout.register_spinner_edit, null);
				ResolutionSet._instance.iterateChild(v.findViewById(R.id.llRegisterSpinnerEditBack));
			}
			
			TextView txtName = (TextView)v.findViewById(R.id.lblSpinnerText);
			txtName.setText(list.get(position));
			//txtName.setTextSize(TypedValue.COMPLEX_UNIT_PX, (float)(ResolutionSet.fPro * txtName.getTextSize()));
			
			return v;
		}
	}
	
	private boolean isAvailableUserRegisteredData()
	{	
		String strData = txtPhoneNumber.getText().toString();
		if (strData.length() == 0)
		{
			GlobalData.showToast(UserProfileActivity.this, getString(R.string.phonenumber_insert_error));
			return false;
		}		
		
		return true;
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
		handlerUserProfile = new JsonHttpResponseHandler()
		{
			int result = 0;
			
			@Override
			public void onSuccess(JSONObject jsonData)
			{
				result = 1;
				m_stLoginResult = CommMgr.commService.GetFLLoginFromJsonData(jsonData);
				if ( m_stLoginResult.ResultCode > 0 )
				{	
					progDialog.dismiss();
					
					SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
					SharedPreferences.Editor editor = pref.edit();
					editor.putLong(GlobalData.g_SharedPreferencesUserID, m_stLoginResult.ResultCode);
					editor.putString(GlobalData.g_SharedPreferencesUserName, m_stLoginResult.Name);
					editor.putString(GlobalData.g_SharedPreferencesEmailAddress, m_stFLAuthInfo.Email);
					editor.putString(GlobalData.g_SharedPreferencesUserPassword, "");
					editor.putInt(GlobalData.g_SharedPreferences_LoginKind, GlobalData.g_nFLLogin);
					if (GlobalData.g_nFLLogin == 1)
					{
						editor.putInt(GlobalData.g_SharedPreferences_FGender, spinGender.getSelectedItemPosition());
						editor.putInt(GlobalData.g_SharedPreferences_FBirthYear, Integer.parseInt(spinYear.getSelectedItem().toString()));
						editor.putString(GlobalData.g_SharedPreferences_FEmail, lblEmail.getText().toString());
						editor.putString(GlobalData.g_SharedPreferences_FPhoneNumber, txtPhoneNumber.getText().toString());
					}
					else if (GlobalData.g_nFLLogin == 2)
					{
						editor.putInt(GlobalData.g_SharedPreferences_LGender, spinGender.getSelectedItemPosition());
						editor.putInt(GlobalData.g_SharedPreferences_LBirthYear, Integer.parseInt(spinYear.getSelectedItem().toString()));
						editor.putString(GlobalData.g_SharedPreferences_LEmail, lblEmail.getText().toString());
						editor.putString(GlobalData.g_SharedPreferences_LPhoneNumber, txtPhoneNumber.getText().toString());
					}
					editor.commit();
					
					if (m_stLoginResult.FirstLogin == 1)
					{
						Intent intent = new Intent(UserProfileActivity.this, NoticeActivity.class);
						startActivity(intent);
					}
					else
					{
						Intent intent = new Intent(UserProfileActivity.this, SelectPositionActivity.class);
						startActivity(intent);
					}
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
					GlobalData.showToast(UserProfileActivity.this, getString(R.string.server_connection_error));
				}
				
				if (result == 2)
				{
					GlobalData.showToast(UserProfileActivity.this, m_stLoginResult.Message);
				}				
				result = 0;
			}			
		};

		try {
			m_stFLAuthInfo.Name = profileMap.getFirstName() + " " + profileMap.getLastName();
		}
		catch(Exception e)
		{
			m_stFLAuthInfo.Name = "";
		}
		m_stFLAuthInfo.Email = lblEmail.getText().toString();
		try {
			m_stFLAuthInfo.Gender = spinGender.getSelectedItemPosition();
		}
		catch (Exception e)
		{
			m_stFLAuthInfo.Gender = 0;
		}
		try {
			m_stFLAuthInfo.BirthYear = Integer.parseInt(spinYear.getSelectedItem().toString());
		}
		catch (Exception e)
		{
			m_stFLAuthInfo.BirthYear = 0;
		}
		m_stFLAuthInfo.PhoneNum = txtPhoneNumber.getText().toString();
		
		try {
			Bitmap bm=((BitmapDrawable)imgPhoto.getDrawable()).getBitmap();
			ByteArrayOutputStream bytes = new ByteArrayOutputStream();
			bm.compress(CompressFormat.JPEG, 50, bytes);
			m_stFLAuthInfo.ImageData = Base64.encodeToString(bytes.toByteArray(), Base64.NO_WRAP);
		} catch (Exception e) {
			m_stFLAuthInfo.ImageData = "";
		}
		
		progDialog = ProgressDialog.show(
				UserProfileActivity.this,
				"", 
				getString(R.string.waiting),
				true,
				true,
				null);
		
		CommMgr.commService.RequestFLLogin(m_stFLAuthInfo, handlerUserProfile);
		
		return;
	}
}