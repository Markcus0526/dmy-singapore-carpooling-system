package com.carpool;

import org.json.JSONObject;

import com.CommService.CommMgr;
import com.HttpConn.JsonHttpResponseHandler;
import com.STData.STResetPassword;
import com.STData.StringContainer;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;

public class ForgotPasswordActivity extends Activity {
	
	private STResetPassword m_stResetPassword = new STResetPassword();
	private JsonHttpResponseHandler handlerResetPassword = null;
	private ProgressDialog progDialog = null;
	
	private EditText txtEmail = null;
	private Button btnResetPassword = null;
			
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.forgotpassword);
		
		txtEmail = (EditText) findViewById(R.id.txtForgotPassword_Email);
		
		btnResetPassword = (Button) findViewById(R.id.btnForgotPassword_ResetPassword);
		btnResetPassword.setOnClickListener( new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				if ( isAvailableUserInputedData() == false )
					return;
				RunBackgroundHandler();
			}
		});
		
		ResolutionSet._instance.iterateChild(findViewById(R.id.llForgotPasswordLayout));		
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
		
	private boolean isAvailableUserInputedData()
	{
		String strData = "";
		strData = txtEmail.getText().toString();
		if (strData.length() == 0)
		{
			GlobalData.showToast(ForgotPasswordActivity.this, getString(R.string.email_insert_error));
			return false;
		}
		
		if ( GlobalData.isValidEmail(strData) == false )
		{
			GlobalData.showToast(ForgotPasswordActivity.this, getString(R.string.email_format_error));
			return false;
		}
						
		return true;
	}
	
	private void RunBackgroundHandler()
	{
		handlerResetPassword = new JsonHttpResponseHandler()
		{
			int result = 0;
			
			@Override
			public void onSuccess(JSONObject jsonData)
			{
				result = 1;
				StringContainer res = new StringContainer();
				res = CommMgr.commService.GetResetPasswordFromJsonData(jsonData);
				if ( res.Result == 1 )
				{	
					progDialog.dismiss();
					
					Intent intent = new Intent(ForgotPasswordActivity.this, SignInActivity.class);
					startActivity(intent);
					ForgotPasswordActivity.this.finish();
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
					GlobalData.showToast(ForgotPasswordActivity.this, getString(R.string.server_connection_error));
				}
				
				if (result == 2)
				{
					GlobalData.showToast(ForgotPasswordActivity.this, getString(R.string.service_error));
				}				
				result = 0;
			}			
		};
		
		progDialog = ProgressDialog.show(
				ForgotPasswordActivity.this,
				"", 
				getString(R.string.waiting),
				true,
				true,
				null);
		
		m_stResetPassword.Email = txtEmail.getText().toString();
		CommMgr.commService.RequestResetPassword(m_stResetPassword, handlerResetPassword);
		
		return;
	}
	
	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) 
	{
	    if (keyCode == KeyEvent.KEYCODE_BACK) 
	    {
	    	Intent intent = new Intent(ForgotPasswordActivity.this, SignInActivity.class);
	    	startActivity(intent);
	    	finish();
	    }
	    return super.onKeyDown(keyCode, event);
	}
}