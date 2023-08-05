package com.carpool;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import org.brickred.socialauth.Profile;
import org.brickred.socialauth.android.DialogListener;
import org.brickred.socialauth.android.SocialAuthAdapter;
import org.brickred.socialauth.android.SocialAuthAdapter.Provider;
import org.brickred.socialauth.android.SocialAuthError;
import org.brickred.socialauth.android.SocialAuthListener;
import org.json.JSONObject;
import com.CommService.CommMgr;
import com.HttpConn.JsonHttpResponseHandler;
import com.STData.STLoginResult;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.View.OnClickListener;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

public class LoginActivity extends Activity {

	private Button btnFacebookLogin = null;
	private Button btnLinkedInLogin = null;
	private Button btnSignIn = null;
	private Button btnRegister= null;
	
	private SocialAuthAdapter adapter;
	private ProgressDialog mDialog;
	
	private STLoginResult m_stLoginResult = new STLoginResult();
	private JsonHttpResponseHandler handler = null;
	
	private Profile m_profileMap = null;
	
	private int m_nYear = 0;
		
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.login);
		
		SimpleDateFormat format = new SimpleDateFormat("yyyy", Locale.CHINA);
		Date currentTime = new Date();
		String time = format.format(currentTime);
		m_nYear = Integer.parseInt(time);
				
		adapter = new SocialAuthAdapter(new ResponseListener());
				
		btnFacebookLogin = (Button) findViewById(R.id.btnLogin_FacebookLogin);
		btnFacebookLogin.setOnClickListener( new OnClickListener () {
			@Override
			public void onClick(View v)
			{
				GlobalData.g_nFLLogin= 1; 
				adapter.authorize(LoginActivity.this, Provider.FACEBOOK);
			}
		});
		
		btnLinkedInLogin = (Button) findViewById(R.id.btnLogin_LinkedInLogin);
		btnLinkedInLogin.setOnClickListener( new OnClickListener() {
			@Override
			public void onClick(View v)
			{
			    GlobalData.g_nFLLogin= 2;
				adapter.authorize(LoginActivity.this, Provider.LINKEDIN);
			}
		});
		
		btnSignIn = (Button) findViewById(R.id.btnLogin_SignIn);
		btnSignIn.setOnClickListener( new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				Intent intent = new Intent(LoginActivity.this, SignInActivity.class);
				startActivity(intent);
				finish();
			}
		});
		
		btnRegister = (Button) findViewById(R.id.btnLogin_Register);
		btnRegister.setOnClickListener( new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				Intent intent = new Intent(LoginActivity.this, UserRegisterActivity.class);
				startActivity(intent);
			}
		});	
		
		ResolutionSet._instance.iterateChild(findViewById(R.id.llLoginLayout));
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
	
	private final class ResponseListener implements DialogListener {
		@Override
		public void onComplete(Bundle values) {
			mDialog = new ProgressDialog(LoginActivity.this);
			mDialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
			mDialog.setMessage("Loading...");
			
			Events();
		}

		@Override
		public void onError(SocialAuthError error) {
			Log.d("Custom-UI", "Error");
			error.printStackTrace();
		}

		@Override
		public void onCancel() {
			Log.d("Custom-UI", "Cancelled");
		}

		@Override
		public void onBack() {
			Log.d("Custom-UI", "Dialog Closed by pressing Back Key");
		}		
	}
	
	public void Events() {
		mDialog.show();
		adapter.getUserProfileAsync(new ProfileDataListener());
	}
	
	private final class ProfileDataListener implements SocialAuthListener<Profile> {
		@Override
		public void onError(SocialAuthError e) {
		}

		@Override
		public void onExecute(String arg0, Profile profile) {
			//mDialog.dismiss();
			m_profileMap = profile;			
			
			handler = new JsonHttpResponseHandler()
			{
				int result = 0;
				
				@Override
				public void onSuccess(JSONObject jsonData)
				{
					result = 1;
					m_stLoginResult = CommMgr.commService.GetFLLoginFromJsonData(jsonData);
					if ( m_stLoginResult.ResultCode > 0 )
					{	
						mDialog.dismiss();
						if (GlobalData.g_nFLLogin == 1){
							adapter.signOut(Provider.FACEBOOK.toString());
						}
						
						SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
						SharedPreferences.Editor editor = pref.edit();
						editor.putLong(GlobalData.g_SharedPreferencesUserID, m_stLoginResult.ResultCode);
						editor.putString(GlobalData.g_SharedPreferencesUserName, m_stLoginResult.Name);
						editor.putString(GlobalData.g_SharedPreferencesEmailAddress, m_profileMap.getEmail());
						editor.putString(GlobalData.g_SharedPreferencesUserPassword, "");
						editor.putInt(GlobalData.g_SharedPreferences_LoginKind, GlobalData.g_nFLLogin);
						
						int nYear = 0;
						String strEmail = "";
						try {
							nYear = m_profileMap.getDob().getYear();
						} catch (Exception e) {
							nYear = m_nYear;
						}
						try {
							strEmail = m_profileMap.getEmail();
						} catch(Exception e) {
							strEmail = "";
						}
						
						if (GlobalData.g_nFLLogin == 1)
						{
							editor.putInt(GlobalData.g_SharedPreferences_FGender, 0);
							editor.putInt(GlobalData.g_SharedPreferences_FBirthYear, nYear);
							editor.putString(GlobalData.g_SharedPreferences_FEmail, strEmail);
							editor.putString(GlobalData.g_SharedPreferences_FPhoneNumber, "");
						}
						else if (GlobalData.g_nFLLogin == 2)
						{
							editor.putInt(GlobalData.g_SharedPreferences_LGender, 0);
							editor.putInt(GlobalData.g_SharedPreferences_LBirthYear, nYear);
							editor.putString(GlobalData.g_SharedPreferences_LEmail, strEmail);
							editor.putString(GlobalData.g_SharedPreferences_LPhoneNumber, "");
						}
						editor.commit();
						
						Intent intent = new Intent(LoginActivity.this, SelectPositionActivity.class);
						startActivity(intent);
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
					mDialog.dismiss();
					if (result == 0)
					{
						GlobalData.showToast(LoginActivity.this, getString(R.string.server_connection_error));
					}
					
					if (result == 2)
					{
						Intent intent = new Intent(LoginActivity.this, UserProfileActivity.class);
						intent.putExtra("profile", m_profileMap);
						startActivity(intent);
					}				
					result = 0;
				}			
			};
			
			String strEmail = m_profileMap.getEmail();
			CommMgr.commService.RequestIsRegistedUser(strEmail, handler);
		}
	}
	
	public class DialogAdapter extends BaseAdapter {
		private final LayoutInflater mInflater;
		private final Context ctx;
		private Drawable mIcon;
		String[] drawables;
		String[] options;

		public DialogAdapter(Context context, int textViewResourceId, String[] providers) {
			ctx = context;
			mInflater = LayoutInflater.from(ctx);
			options = providers;
		}
		
		@Override
		public int getCount() {
			return options.length;
		}

		@Override
		public Object getItem(int position) {
			return position;
		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		@Override
		public View getView(final int position, View convertView, ViewGroup parent) {
			ViewHolder holder;
			if (convertView == null) {
				convertView = mInflater.inflate(R.layout.provider_options, null);
				holder = new ViewHolder();
				holder.text = (TextView) convertView.findViewById(R.id.providerText);
				holder.icon = (ImageView) convertView.findViewById(R.id.provider);

				convertView.setTag(holder);
			} 
			else {
				holder = (ViewHolder) convertView.getTag();
			}

			String drawables[] = ctx.getResources().getStringArray(R.array.drawable_array);

			mIcon = ctx.getResources().getDrawable(
					ctx.getResources().getIdentifier(drawables[position], "drawable", ctx.getPackageName()));
			
			holder.text.setText(options[position]);
			holder.icon.setImageDrawable(mIcon);

			return convertView;
		}

		class ViewHolder {
			TextView text;
			ImageView icon;
		}
	}
	
	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) 
	{
	    if (keyCode == KeyEvent.KEYCODE_BACK) 
	    {
	    	finish();
	    }
	    return super.onKeyDown(keyCode, event);
	}	
}