package com.carpool;

import java.io.ByteArrayOutputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

import org.brickred.socialauth.android.SocialAuthAdapter.Provider;
import org.json.JSONObject;
import com.CommService.CommMgr;
import com.HttpConn.JsonHttpResponseHandler;
import com.STData.STUserProfile;
import com.STData.StringContainer;
import com.Utils.AutoSizeRatingBar;

import android.net.Uri;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.provider.MediaStore.Images;
import android.util.Base64;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.graphics.Bitmap.CompressFormat;
import android.graphics.BitmapFactory;
import android.graphics.drawable.BitmapDrawable;

public class ProfileInfoActivity extends Activity {
	
	private ImageView imgPhoto;
	private Button btnSetting;
	private Button btnEdit;
	private Button btnLogout;
	private EditText txtEmail;
	private EditText txtPhoneNumber;
	private EditText txtYearOfBirth;
	private AutoSizeRatingBar m_starMark;
	
	private Uri mSelectedImage = null;

	private STUserProfile m_stUserProfile = new STUserProfile();
	private ProgressDialog progDialog;
	private JsonHttpResponseHandler handler;
	private JsonHttpResponseHandler handlerUpload;
	
	private int m_nCurYear = 0;
	private boolean m_bIsChanaged = false;	
	private boolean m_bPhotoChanged = false;	
	private boolean m_bInvalidUser = false;
	
	private int m_nLoginKind = 0;
			
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.profileinfo);
		
		SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
		m_nLoginKind = pref.getInt(GlobalData.g_SharedPreferences_LoginKind, 0);
		
		SimpleDateFormat format = new SimpleDateFormat("yyyy", Locale.CHINA);
		Date currentTime = new Date();
		String time = format.format(currentTime);
		m_nCurYear = Integer.parseInt(time);
		
		imgPhoto = (ImageView) findViewById(R.id.imgProfileInfo_Photo);
		imgPhoto.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				if (m_bInvalidUser)
					return;
				String strAction = Intent.ACTION_PICK;
				Uri uri = android.provider.MediaStore.Images.Media.INTERNAL_CONTENT_URI;
				Intent intent = new Intent(strAction, uri);
				startActivityForResult(intent, 0);
			}
		});
		
		txtEmail = (EditText) findViewById(R.id.txtProfileInfo_Email);
		txtPhoneNumber = (EditText) findViewById(R.id.txtProfileInfo_PhoneNumber);
		txtYearOfBirth = (EditText) findViewById(R.id.txtProfileInfo_YearOfBirth);
		
		txtEmail.setEnabled(false);
		txtPhoneNumber.setEnabled(false);
		txtYearOfBirth.setEnabled(false);
		
		m_starMark = (AutoSizeRatingBar) findViewById(R.id.starProfileInfo_Mark);
		m_starMark.ConvertToScaledSize( m_starMark.getLayoutParams().width, m_starMark.getLayoutParams().height);
		
		btnSetting = (Button) findViewById(R.id.btnProfileInfo_Setting);
		btnSetting.setOnClickListener( new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				Intent intent = new Intent(ProfileInfoActivity.this, SettingActivity.class);
				startActivity(intent);
				ProfileInfoActivity.this.finish();
			}
		});
		
		btnEdit = (Button) findViewById(R.id.btnProfileInfo_Edit);
		if ( m_nLoginKind == 1 || m_nLoginKind == 2 )
			btnEdit.setVisibility(View.GONE);
		btnEdit.setOnClickListener( new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				if (m_bInvalidUser)
					return;
				
				if (m_nLoginKind == 1 || m_nLoginKind == 2)
					return;
				
				m_bIsChanaged = true;
				//txtEmail.setEnabled(true);
				txtPhoneNumber.setEnabled(true);
				txtYearOfBirth.setEnabled(true);
			}
		});
		
		btnLogout = (Button) findViewById(R.id.btnProfileInfo_Logout);
		btnLogout.setOnClickListener( new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				if ( m_bIsChanaged == true ) 
				{
					if (m_nLoginKind == 0)
					{
						if ( isValidUserInputedInfo() == false )
							return;
					}
					
					new AlertDialog.Builder(ProfileInfoActivity.this).setIcon(android.R.drawable.ic_dialog_alert).setTitle(getString(R.string.app_name)).setMessage(getString(R.string.profile_save)).setPositiveButton(getString(R.string.dialog_ok), 
							new DialogInterface.OnClickListener()
							{
								@Override
							    public void onClick( DialogInterface dialog, int which )
							    {
									boolean bFlag = true;
									Bitmap bmp = null;
									if (m_bPhotoChanged)
									{
										try {
											if (mSelectedImage != null)
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
											ByteArrayOutputStream bytes = new ByteArrayOutputStream();
											bmp.compress(CompressFormat.JPEG, 50, bytes);
											m_stUserProfile.ImageData = Base64.encodeToString(bytes.toByteArray(), Base64.NO_WRAP);
										}
										else
											m_stUserProfile.ImageData = "";
									}
									
									SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
									m_stUserProfile.Uid = pref.getLong(GlobalData.g_SharedPreferencesUserID, 0);
									m_stUserProfile.Email = txtEmail.getText().toString();
									m_stUserProfile.PhoneNum = txtPhoneNumber.getText().toString();
									m_stUserProfile.BirthYear = Integer.parseInt(txtYearOfBirth.getText().toString());
									
									progDialog = ProgressDialog.show(
										ProfileInfoActivity.this,
										"", 
										getString(R.string.waiting),
										true,
										true,
										null);
									CommMgr.commService.RequestUserProfileUpdate(m_stUserProfile, handlerUpload);
							    }
							}
					).setNegativeButton( getString(R.string.dialog_cancel), new DialogInterface.OnClickListener()
					{
						@Override
					    public void onClick( DialogInterface dialog, int which )
					    {
							removeUserLoginInfo();
							SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
							SharedPreferences.Editor editor = pref.edit();
							editor.commit();
							Intent intent = new Intent(ProfileInfoActivity.this, LoginActivity.class);
							intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
							startActivity(intent);
							ProfileInfoActivity.this.finish();
					    }
					} ).show();
				}
				else
				{
					removeUserLoginInfo();
					SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
					SharedPreferences.Editor editor = pref.edit();
					editor.commit();
					Intent intent = new Intent(ProfileInfoActivity.this, LoginActivity.class);
					intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
					startActivity(intent);
					ProfileInfoActivity.this.finish();
				}
			}
		});

		RunBackgroundHandler();
		
		ResolutionSet._instance.iterateChild(findViewById(R.id.llProfileInfoLayout));		
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
	
	@SuppressWarnings({ "rawtypes", "unchecked" })
	private void removeUserLoginInfo()
	{
		SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
		SharedPreferences.Editor editor = pref.edit();
				
		if (m_nLoginKind == 0)
		{			
			editor.putString(GlobalData.g_SharedPreferencesUserName, "");
			editor.putString(GlobalData.g_SharedPreferencesEmailAddress, "");
		}
		else if (m_nLoginKind == 1)
		{
			editor.putString(GlobalData.g_SharedPreferencesUserName, "");
			editor.putString(GlobalData.g_SharedPreferences_FEmail, "");
			
			Map<String, Object> tokenMap;
			
			SharedPreferences defPref = PreferenceManager.getDefaultSharedPreferences(ProfileInfoActivity.this);

		    if (defPref.contains(Provider.FACEBOOK.toString() + " key")) 
		    {
			      tokenMap = new HashMap();
	
			      for (Map.Entry entry : defPref.getAll().entrySet()) {
			        tokenMap.put(entry.getKey().toString(), entry.getValue());
			      }
	
			      try
			      {
			        SharedPreferences.Editor defEditor = PreferenceManager.getDefaultSharedPreferences(ProfileInfoActivity.this).edit();
			        String key = (String)tokenMap.get(Provider.FACEBOOK.toString() + " key");
			        if (key != null && key.length() > 0)
			        {
			        	defEditor.remove(Provider.FACEBOOK + " key");
			        }
	
			        String providerid = (String)tokenMap.get(Provider.FACEBOOK.toString() + " providerid");
			        if (providerid != null && providerid.length() > 0)
			        {
			        	defEditor.remove(Provider.FACEBOOK + " providerid");
			        }
	
			        String secret = (String)tokenMap.get(Provider.FACEBOOK.toString() + " secret");
			        if (secret != null && secret.length() > 0)
			        {
			        	defEditor.remove(Provider.FACEBOOK + " secret");
			        }
			        
			        defEditor.commit();
			      }catch (Exception e){}
		    }
		} 
		else if (m_nLoginKind == 2)
		{
			editor.putString(GlobalData.g_SharedPreferencesUserName, "");
			editor.putString(GlobalData.g_SharedPreferences_LEmail, "");
			
			Map<String, Object> tokenMap;
			
			SharedPreferences defPref = PreferenceManager.getDefaultSharedPreferences(ProfileInfoActivity.this);

		    if (defPref.contains(Provider.LINKEDIN.toString() + " key")) {
		      tokenMap = new HashMap();

		      for (Map.Entry entry : defPref.getAll().entrySet()) {
		        tokenMap.put(entry.getKey().toString(), entry.getValue());
		      }

		      try
		      {
		        SharedPreferences.Editor defEditor = PreferenceManager.getDefaultSharedPreferences(ProfileInfoActivity.this).edit();
		        String key = (String)tokenMap.get(Provider.LINKEDIN.toString() + " key");
		        if (key != null && key.length() > 0)
		        {
		        	defEditor.remove(Provider.LINKEDIN + " key");
		        }

		        String secret = (String)tokenMap.get(Provider.LINKEDIN.toString() + " secret");
		        if (secret != null && secret.length() > 0)
		        {
		        	defEditor.remove(Provider.LINKEDIN + " secret");
		        }

		        String providerid = (String)tokenMap.get(Provider.LINKEDIN.toString() + " providerid");
		        if (providerid != null && providerid.length() > 0)
		        {
		        	defEditor.remove(Provider.LINKEDIN + " providerid");
		        }
		        defEditor.commit();
		      }catch (Exception e){}
		    }
		}
			
		editor.commit();
		return;
	}
	
	private boolean isValidUserInputedInfo()
	{
		String strData = "";
				
		strData = txtEmail.getText().toString();
		if (strData.length() == 0)
		{
			GlobalData.showToast(ProfileInfoActivity.this, getString(R.string.email_insert_error));
			return false;
		}
		
		if ( GlobalData.isValidEmail(strData) == false )
		{
			GlobalData.showToast(ProfileInfoActivity.this, getString(R.string.email_format_error));
			return false;
		}
		
		strData = txtPhoneNumber.getText().toString();
		if ( strData == null || strData.length() == 0 )
		{
			GlobalData.showToast(ProfileInfoActivity.this, getString(R.string.phonenumber_insert_error));
			return false;
		}
		
		strData = txtYearOfBirth.getText().toString();
		if (strData.length() == 0)
		{
			GlobalData.showToast(ProfileInfoActivity.this, getString(R.string.yearofbirth_insert_error));
			return false;
		}
		
		int nYear = 0;
		try {
			nYear = Integer.parseInt(strData.toString());
		} catch (Exception e) {
			GlobalData.showToast(ProfileInfoActivity.this, getString(R.string.yearofbirth_insert_error));
			return false;
		}
		
		if ( (nYear > m_nCurYear) || nYear < (m_nCurYear-100))
		{
			String strText = String.format(getString(R.string.yearofbirth_format_error), m_nCurYear-100, m_nCurYear);
			GlobalData.showToast(ProfileInfoActivity.this, strText);
			return false;
		}
				
		return true;
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
					m_bInvalidUser = true;
					GlobalData.showToast(ProfileInfoActivity.this, getString(R.string.server_connection_error));
					finish();
				}
				
				if (result == 2)
				{
					m_bInvalidUser = true;
					if (m_stUserProfile.ErrCode == -103)
						GlobalData.showToast(ProfileInfoActivity.this, "This user is not valid.");
					else
						GlobalData.showToast(ProfileInfoActivity.this, getString(R.string.service_error));
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
					removeUserLoginInfo();
					Intent intent = new Intent(ProfileInfoActivity.this, LoginActivity.class);
					intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
					startActivity(intent);
					ProfileInfoActivity.this.finish();
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
					GlobalData.showToast(ProfileInfoActivity.this, getString(R.string.server_connection_error));
				}
				
				if (result == 2)
				{
					GlobalData.showToast(ProfileInfoActivity.this, getString(R.string.service_error));
				}
				
				result = 0;
			}			
		};
		
		progDialog = ProgressDialog.show(
				ProfileInfoActivity.this,
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
	
	@SuppressWarnings("deprecation")
	private void UpdateUI()
	{
		txtEmail.setText(m_stUserProfile.Email);
		txtPhoneNumber.setText(m_stUserProfile.PhoneNum);
		txtYearOfBirth.setText(Integer.toString(m_stUserProfile.BirthYear));
		m_starMark.setRate((float)m_stUserProfile.StarCount);
		m_starMark.invalidate();
		
		try {
			if ( (m_stUserProfile.ImageData != null) && (m_stUserProfile.ImageData.length() > 0) ) {
				byte[] decodedString = Base64.decode(m_stUserProfile.ImageData, Base64.NO_WRAP);
				Bitmap decodedByte = BitmapFactory.decodeByteArray(decodedString, 0, decodedString.length);
				BitmapDrawable ob = new BitmapDrawable(decodedByte);
				imgPhoto.setScaleType(ImageView.ScaleType.FIT_XY);
				imgPhoto.setBackgroundDrawable(ob);
			}
		}
		catch (Exception e) {
		}
		
		return;
	}
	
	@SuppressWarnings("deprecation")
	public void onActivityResult(int request_code, int result_code, Intent data)
	{
		if ( request_code == 0 && result_code == RESULT_OK )
		{
			m_bIsChanaged = true;
			m_bPhotoChanged = true;
			mSelectedImage = data.getData();
			imgPhoto.setBackgroundDrawable( new BitmapDrawable());
			imgPhoto.setImageURI(mSelectedImage);
			imgPhoto.setScaleType(ImageView.ScaleType.FIT_XY);
		}
		
		return;
	}
	
	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) 
	{
	    if (keyCode == KeyEvent.KEYCODE_BACK) 
	    {
	    	Intent intent = new Intent(ProfileInfoActivity.this, SettingActivity.class);
	    	startActivity(intent);
	    	ProfileInfoActivity.this.finish();
	    }
	    return super.onKeyDown(keyCode, event);
	}
}