package com.carpool;

import org.json.JSONObject;

import com.CommService.CommMgr;
import com.HttpConn.JsonHttpResponseHandler;
import com.STData.STAuthUser;
import com.STData.STLoginResult;

import android.os.Bundle;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.content.SharedPreferences;

public class SignInActivity extends Activity {

	private	TextView lblForgotPassword;
	private EditText txtEmail;
	private EditText txtPassword;
	private Button btnSignIn;
	private Button btnBack;

	private STAuthUser m_stAuthUser = new STAuthUser();
	private STLoginResult m_stLoginResult = new STLoginResult();
	private JsonHttpResponseHandler handlerLogin = null;
	private ProgressDialog progDialog = null;
			
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.signin);		
		
		lblForgotPassword = (TextView) findViewById(R.id.lblSignIn_ForgotPassword);
		lblForgotPassword.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				Intent intent = new Intent(SignInActivity.this, ForgotPasswordActivity.class);
				startActivity(intent);
				finish();
			}
		});
		
		txtEmail = (EditText) findViewById(R.id.txtSignIn_Email);
		txtPassword = (EditText) findViewById(R.id.txtSignIn_Password);
		
		btnBack = (Button) findViewById(R.id.btnSignIn_Back);
		btnBack.setOnClickListener( new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				Intent intent = new Intent(SignInActivity.this, LoginActivity.class);
				startActivity(intent);
				SignInActivity.this.finish();
				return;
			}
		});
		
		btnSignIn = (Button) findViewById(R.id.btnSignIn_SignIn);
		btnSignIn.setOnClickListener( new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				if ( isValidUserInputedInfo() == false )
					return;
				
				RunBackgroundHandler();
			}
		});
		
		ResolutionSet._instance.iterateChild(findViewById(R.id.llSignInLayout));		
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
	public void onResume()
	{
		super.onResume();
		
		txtPassword.setText(getString(R.string.Null_String));
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
		strData = txtEmail.getText().toString();
		if (strData.length() == 0)
		{
			GlobalData.showToast(SignInActivity.this, getString(R.string.email_insert_error));
			return false;
		}
		
		if ( GlobalData.isValidEmail(strData) == false )
		{
			GlobalData.showToast(SignInActivity.this, getString(R.string.email_format_error));
			return false;
		}
		
		strData = txtPassword.getText().toString();
		if (strData.length() == 0)
		{
			GlobalData.showToast(SignInActivity.this, getString(R.string.password_insert_error));
			return false;
		}
				
		return true;
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
						Intent intent = new Intent(SignInActivity.this, NoticeActivity.class);
						startActivity(intent);
						SignInActivity.this.finish();
					}
					else
					{
						Intent intent = new Intent(SignInActivity.this, SelectPositionActivity.class);
						startActivity(intent);
						SignInActivity.this.finish();
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
					GlobalData.showToast(SignInActivity.this, getString(R.string.server_connection_error));
				}
				
				if (result == 2)
				{
					GlobalData.showToast(SignInActivity.this, m_stLoginResult.Message);
				}
				
				result = 0;
			}
			
		};

		m_stAuthUser.Email = txtEmail.getText().toString();		
		m_stAuthUser.Password = txtPassword.getText().toString();
		
		progDialog = ProgressDialog.show(
				SignInActivity.this,
				"", 
				getString(R.string.waiting),
				true,
				true,
				null);
		
		CommMgr.commService.RequestUserLogin(m_stAuthUser, handlerLogin);
		
		return;
	}
	
	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) 
	{
	    if (keyCode == KeyEvent.KEYCODE_BACK) 
	    {
	    	Intent intent = new Intent(SignInActivity.this, LoginActivity.class);
	    	startActivity(intent);
	    	finish();
	    }
	    return super.onKeyDown(keyCode, event);
	}
}