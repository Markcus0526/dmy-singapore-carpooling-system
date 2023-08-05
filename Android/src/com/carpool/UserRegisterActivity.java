package com.carpool;

import java.io.ByteArrayOutputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Locale;
import org.json.JSONObject;
import com.CommService.CommMgr;
import com.HttpConn.JsonHttpResponseHandler;
import com.STData.STAuthUser;
import com.STData.STLoginResult;
import com.STData.StringContainer;
import com.STData.STUserReg;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore.Images;
import android.util.Base64;
import android.view.KeyEvent;
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
import android.graphics.Color;
import android.graphics.Bitmap.CompressFormat;

public class UserRegisterActivity extends Activity {
	
	private final int COUNT = 100;	
		
	private Spinner spinGender;
	private Spinner spinYearOfBirth;
	
	private Uri mSelectedImage = null;
	
	public Button btnRegister;
	public Button btnBack;
	public EditText txtUserName;
	public EditText txtEmail;
	public EditText txtPhoneNumber;
	public EditText txtPassword;
	public EditText txtRePassword;
	public ImageView imgPhoto;
	
	public STUserReg m_stUserReg = new STUserReg();
	public StringContainer m_stRegResult = new StringContainer();
	
	public STAuthUser m_stAuthUser = new STAuthUser();
	public STLoginResult m_stLoginResult = new STLoginResult();
	
	private JsonHttpResponseHandler handlerRegister = null;
	private JsonHttpResponseHandler handlerLogin = null;
	private ProgressDialog progDialog = null;
	
	private ArrayList<String> m_arrGender = null;
	private GenderAdapter adapterGender = null;
	
	private ArrayList<String> m_arrBirthYear = null;
	private BirthYearAdapter adapterBirthYear = null;
			
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.userregister);
		
		SimpleDateFormat format = new SimpleDateFormat("yyyy", Locale.CHINA);
		Date currentTime = new Date();
		String time = format.format(currentTime);
		int nYear = Integer.parseInt(time);
		
		String[] arrGender = getResources().getStringArray(R.array.UserRegister_GroupGender);
		m_arrGender = new ArrayList<String>(arrGender.length);
		for (String strVal : arrGender)
			m_arrGender.add(strVal);
		
		m_arrBirthYear = new ArrayList<String>(COUNT);
		for ( int i = 0; i < COUNT; i++)
		{
			m_arrBirthYear.add(Integer.toString((nYear - COUNT) + i+1));
		}
		
		imgPhoto = (ImageView) findViewById(R.id.imgUserRegister_Photo);
		imgPhoto.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				String strAction = Intent.ACTION_PICK;
				Uri uri = android.provider.MediaStore.Images.Media.INTERNAL_CONTENT_URI;
				Intent intent = new Intent(strAction, uri);
				startActivityForResult(intent, 0);
			}
		});
		
		spinGender = (Spinner) findViewById(R.id.spinUserRegister_Gender);
		adapterGender = new GenderAdapter(UserRegisterActivity.this, 0, m_arrGender);
		adapterGender.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
		spinGender.setAdapter(adapterGender);
		
		spinYearOfBirth = (Spinner) findViewById(R.id.spinUserRegister_YearOfBirth);
		adapterBirthYear = new BirthYearAdapter(UserRegisterActivity.this, 0, m_arrBirthYear);
		adapterBirthYear.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
		spinYearOfBirth.setAdapter(adapterBirthYear);
		spinYearOfBirth.setSelection(COUNT-1);
		
		btnBack = (Button) findViewById(R.id.btnUserRegister_Back);
		btnBack.setOnClickListener( new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				Intent intent = new Intent(UserRegisterActivity.this, LoginActivity.class);
				startActivity(intent);
				UserRegisterActivity.this.finish();
				return;
			}
		});
		
		btnRegister = (Button) findViewById(R.id.btnUserRegister_Register);
		btnRegister.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				if ( isAvailableUserRegisteredData() == false )
					return;
				
				RunBackgroundHandler();
			}
		});
		
		txtUserName = (EditText) findViewById(R.id.txtUserRegister_Nickname);
		txtEmail = (EditText) findViewById(R.id.txtUserRegister_Email);
		txtPhoneNumber = (EditText) findViewById(R.id.txtUserRegister_PhoneNumber);
		txtPassword = (EditText) findViewById(R.id.txtUserRegister_Password);
		txtRePassword = (EditText) findViewById(R.id.txtUserRegister_RePassword);
		
		ResolutionSet._instance.iterateChild(findViewById(R.id.llUserRegisterLayout));		
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
	
	private boolean isAvailableUserRegisteredData()
	{		
		String strData = "";
		strData = txtUserName.getText().toString();
		if (strData.length() == 0)
		{
			GlobalData.showToast(UserRegisterActivity.this, getString(R.string.username_insert_error));
			return false;
		}
		
		strData = txtEmail.getText().toString();
		if (strData.length() == 0)
		{
			GlobalData.showToast(UserRegisterActivity.this, getString(R.string.email_insert_error));
			return false;
		}
		
		if ( GlobalData.isValidEmail(strData) == false )
		{
			GlobalData.showToast(UserRegisterActivity.this, getString(R.string.email_format_error));
			return false;
		}
		
		strData = txtPhoneNumber.getText().toString();
		if (strData.length() == 0)
		{
			GlobalData.showToast(UserRegisterActivity.this, getString(R.string.phonenumber_insert_error));
			return false;
		}
		
		strData = txtPassword.getText().toString();
		if (strData.length() == 0)
		{
			GlobalData.showToast(UserRegisterActivity.this, getString(R.string.password_insert_error));
			return false;
		}
		
		strData = txtRePassword.getText().toString();
		if (strData.length() == 0)
		{
			GlobalData.showToast(UserRegisterActivity.this, getString(R.string.repassword_insert_error));
			return false;
		}
		
		if ( !strData.equals( txtPassword.getText().toString()) )			
		{
			GlobalData.showToast(UserRegisterActivity.this, getString(R.string.password_match_error));
			return false;
		}
		
		return true;
	}
	
	private int getUserAge()
	{
		int nAge = 0;
		String strAge = "";
		
		try
		{
			strAge = spinYearOfBirth.getSelectedItem().toString();
			nAge = Integer.parseInt(strAge);
		}
		catch (Exception e)
		{
			nAge = 0;
		}
		
		return nAge;
	}
	
	private int getUserGender()
	{
		int nGender = 0;		
		try
		{
			nGender = (int)spinGender.getSelectedItemId();
		}
		catch (Exception e)
		{
			nGender = 0;
		}
		
		return nGender;
	}
	
	private void RunBackgroundHandler()
	{
		handlerLogin = new JsonHttpResponseHandler()
		{
			int result = 0;
			
			@Override
			public void onSuccess(JSONObject jsonData)
			{
				result = 1;
				m_stLoginResult = CommMgr.commService.GetUserLoginFromJsonData(jsonData);
				if ( m_stLoginResult.ResultCode > 0 )
				{	
					progDialog.dismiss();
					
					SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
					SharedPreferences.Editor editor = pref.edit();
					editor.putLong(GlobalData.g_SharedPreferencesUserID, m_stLoginResult.ResultCode);
					editor.putString(GlobalData.g_SharedPreferencesUserName, m_stLoginResult.Name);
					editor.putString(GlobalData.g_SharedPreferencesEmailAddress, txtEmail.getText().toString());
					editor.putString(GlobalData.g_SharedPreferencesUserPassword, txtPassword.getText().toString());
					editor.putInt(GlobalData.g_SharedPreferences_LoginKind, 0);
					editor.commit();

					if (m_stLoginResult.FirstLogin == 1)
					{
						Intent intent = new Intent(UserRegisterActivity.this, NoticeActivity.class);
						startActivity(intent);
						UserRegisterActivity.this.finish();
					}
					else
					{
						Intent intent = new Intent(UserRegisterActivity.this, SelectPositionActivity.class);
						startActivity(intent);
						UserRegisterActivity.this.finish();
					}
				}
				else
				{
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
					GlobalData.showToast(UserRegisterActivity.this, getString(R.string.server_connection_error));
				}
				
				if (result == 2)
				{
					GlobalData.showToast(UserRegisterActivity.this, m_stLoginResult.Message);
				}
				
				result = 0;
			}
			
		};
		
		handlerRegister = new JsonHttpResponseHandler()
		{
			int result = 0;
			
			@Override
			public void onSuccess(JSONObject jsonData)
			{
				result = 1;
				m_stRegResult = CommMgr.commService.GetUserRegisterFromJsonData(jsonData);
				if ( m_stRegResult.Result == 1 )
				{
					/*
					 * FixMe Start 
					 * 2013-12-18
					 */	
					//progDialog.dismiss();

					m_stAuthUser.Email = m_stUserReg.Email;
					m_stAuthUser.Password = m_stUserReg.Password;
					
					CommMgr.commService.RequestUserLogin(m_stAuthUser, handlerLogin);
					/*
					Intent intent = new Intent(UserRegisterActivity.this, SignInActivity.class);
					startActivity(intent);
					UserRegisterActivity.this.finish();
					*/
					/*
					 * FixMe End 
					 * 2013-12-18
					 */
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
					GlobalData.showToast(UserRegisterActivity.this, getString(R.string.server_connection_error));
				}
				
				if (result == 2)
				{
					GlobalData.showToast(UserRegisterActivity.this, m_stRegResult.Value);
				}
				
				result = 0;
			}			
		};
		
		boolean bFlag = true;
		Bitmap bmp = null;
		try {
			if (mSelectedImage == null)
				bFlag = false;
			else
				bmp = Images.Media.getBitmap(getContentResolver(), mSelectedImage);
		}catch (FileNotFoundException e) {
			e.printStackTrace();
			bFlag = false;
		}catch (IOException e){
			e.printStackTrace();
			bFlag = false;
		}
		
		if (bFlag)
		{
			try {
				ByteArrayOutputStream bytes = new ByteArrayOutputStream();
				bmp.compress(CompressFormat.JPEG, 50, bytes);
				m_stUserReg.ImageData = Base64.encodeToString(bytes.toByteArray(), Base64.DEFAULT);
			}catch (Exception e)
			{
				m_stUserReg.ImageData = "";
			}
		}
		else
			m_stUserReg.ImageData = "";
		
		m_stUserReg.UserName = txtUserName.getText().toString();
		m_stUserReg.PhoneNum= txtPhoneNumber.getText().toString();
		m_stUserReg.Password = txtPassword.getText().toString();
		m_stUserReg.Gender = getUserGender();
		m_stUserReg.BirthYear = getUserAge();
		m_stUserReg.Email = txtEmail.getText().toString();
		
		progDialog = ProgressDialog.show(
				UserRegisterActivity.this,
				"", 
				getString(R.string.waiting),
				true,
				true,
				null);
		
		CommMgr.commService.RequestUserRegister(m_stUserReg, handlerRegister);
	
		return;
	}	
	
	public void onActivityResult(int request_code, int result_code, Intent data)
	{
		if ( request_code == 0 && result_code == RESULT_OK )
		{
			mSelectedImage = data.getData();
			imgPhoto.setBackgroundColor(Color.parseColor("#000000"));
			imgPhoto.setImageURI(mSelectedImage);
			imgPhoto.setScaleType(ImageView.ScaleType.FIT_CENTER);
		}
		
		return;
	}
	
	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) 
	{
	    if (keyCode == KeyEvent.KEYCODE_BACK) 
	    {
	    	Intent intent = new Intent(UserRegisterActivity.this, LoginActivity.class);
	    	startActivity(intent);
	    	finish();
	    }
	    return super.onKeyDown(keyCode, event);
	}
}