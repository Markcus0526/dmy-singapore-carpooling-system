package com.carpool;

import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.util.ArrayList;

import com.CommService.CommMgr;
import com.HttpConn.JsonHttpResponseHandler;
import com.STData.STSendSMS;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.provider.ContactsContract;
import android.telephony.SmsManager;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.database.Cursor;

public class TellFriendActivity extends Activity {
	
	private Button btnSetting;
	private Button btnSend;	
	private TextView lblPhoneNumber;
	private EditText txtContent;
	
	private STSendSMS m_stSendSMS = new STSendSMS();
	private JsonHttpResponseHandler handler;
	
	private int m_nMessageDividedCount = 0;
	private int m_nSentMessageCount = 0;
	
	private AlertDialog alert = null;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.tellfriend);
				
		lblPhoneNumber = (TextView) findViewById(R.id.lblTellFriend_Phone);
		lblPhoneNumber.setOnClickListener( new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
	            intent.setType(ContactsContract.CommonDataKinds.Phone.CONTENT_ITEM_TYPE);
	            startActivityForResult(intent, 0); 
			}
		});
		
		txtContent = (EditText) findViewById(R.id.txtTellFriend_Message);
		txtContent.setText(getString(R.string.TellFriend_SMSTemplate) + System.getProperty("line.separator") + System.getProperty("line.separator") + System.getProperty("line.separator")
						 + getString(R.string.TellFriend_DownloadTitle) + System.getProperty("line.separator") + System.getProperty("line.separator")
						 + getString(R.string.TellFriend_DownloadAndroid) + System.getProperty("line.separator")
						 + getString(R.string.TellFriend_DownloadiPhone) );
		
		btnSetting = (Button) findViewById(R.id.btnTellFriend_Setting);
		btnSetting.setOnClickListener( new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				Intent intent = new Intent(TellFriendActivity.this, SettingActivity.class);
				startActivity(intent);
		    	TellFriendActivity.this.finish();
			}
		});
		
		btnSend = (Button) findViewById(R.id.btnTellFriend_Send);
		btnSend.setOnClickListener( new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				if ( isAvailableUserRegisteredData() == false )
					return;
				
				m_nSentMessageCount = 0;
				m_nMessageDividedCount = 0;
				
				handler = new JsonHttpResponseHandler();				
				SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
				m_stSendSMS.Uid = pref.getLong(GlobalData.g_SharedPreferencesUserID, 0);
				m_stSendSMS.PhoneNum = lblPhoneNumber.getText().toString();
				CommMgr.commService.RequestSendSMS(m_stSendSMS, handler);
				
				try {
					String SENT = "SMS_SENT";
			        String DELIVERED = "SMS_DELIVERED";
			        
					ArrayList<PendingIntent> sentPendingIntents = new ArrayList<PendingIntent>();
				    ArrayList<PendingIntent> deliveredPendingIntents = new ArrayList<PendingIntent>();
				    
				    PendingIntent sentPI = PendingIntent.getBroadcast(TellFriendActivity.this, 0, new Intent(SENT), 0);
			        PendingIntent deliveredPI = PendingIntent.getBroadcast(TellFriendActivity.this, 0, new Intent(DELIVERED), 0);
			        
			        registerReceiver(new BroadcastReceiver(){
			            @Override
			            public void onReceive(Context arg0, Intent arg1) {
			                switch (getResultCode())
			                {
			                    case Activity.RESULT_OK:
			                    	m_nSentMessageCount++;
			                    	if (m_nSentMessageCount == m_nMessageDividedCount)
			                    	{
			                    		GlobalData.showToast(TellFriendActivity.this, "SMS successfully sent");
			                    	}
			                        break;
			                    case SmsManager.RESULT_ERROR_GENERIC_FAILURE:
			                    	GlobalData.showToast(TellFriendActivity.this, "Generic failure");
			                        break;
			                    case SmsManager.RESULT_ERROR_NO_SERVICE:
			                    	GlobalData.showToast(TellFriendActivity.this, "No service");
			                        break;
			                    case SmsManager.RESULT_ERROR_NULL_PDU:
			                    	GlobalData.showToast(TellFriendActivity.this, "Null PDU");
			                        break;
			                    case SmsManager.RESULT_ERROR_RADIO_OFF:
			                    	GlobalData.showToast(TellFriendActivity.this, "Radio OFF");
			                        break;
			                }
			            }
			        }, new IntentFilter(SENT));

			        registerReceiver(new BroadcastReceiver(){
			            @Override
			            public void onReceive(Context arg0, Intent arg1) {
			                switch (getResultCode())
			                {
			                    case Activity.RESULT_OK:
			                    	//GlobalData.showToast(TellFriendActivity.this, "SMS delivered");
			                        break;
			                    case Activity.RESULT_CANCELED:
			                    	//GlobalData.showToast(TellFriendActivity.this, "SMS not delivered");
			                        break;                        
			                }
			            }
			        }, new IntentFilter(DELIVERED));
			        
			        SmsManager sms = SmsManager.getDefault();
			        ArrayList<String> mSMSMessage = sms.divideMessage(txtContent.getText().toString());
			        m_nMessageDividedCount = mSMSMessage.size();
			        for (int i = 0; i < mSMSMessage.size(); i++) {
			            sentPendingIntents.add(i, sentPI);
			            deliveredPendingIntents.add(i, deliveredPI);
			        }
			        sms.sendMultipartTextMessage(lblPhoneNumber.getText().toString(), null, mSMSMessage, sentPendingIntents, deliveredPendingIntents);
				        
				}catch (Exception e){}

				return;
			}
		});

		ResolutionSet._instance.iterateChild(findViewById(R.id.llTellFriendLayout));

		AlertDialog.Builder builder = new AlertDialog.Builder(TellFriendActivity.this);
		builder.setMessage(getString(R.string.TellFriend_DialogContent)).setIcon(android.R.drawable.ic_dialog_alert).setTitle(getString(R.string.app_name))
				.setCancelable(false)
				.setPositiveButton(getString(R.string.SharingCriteria_Ok), new DialogInterface.OnClickListener() {
					public void onClick(DialogInterface dialog, int id) {
						alert.dismiss();
					}
				});
		alert = builder.create();
		alert.show();
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
		strData = lblPhoneNumber.getText().toString();
		if (strData.length() == 0)
		{
			GlobalData.showToast(TellFriendActivity.this, getString(R.string.phonenumber_insert_error));
			return false;
		}
		
		strData = txtContent.getText().toString();
		if (strData.length() == 0)
		{
			GlobalData.showToast(TellFriendActivity.this, getString(R.string.message_insert_error));
			return false;
		}
		
		return true;
	}
	
	public void onActivityResult(int request_code, int result_code, Intent data)
	{
		super.onActivityResult(request_code, result_code, data);
		
		if ( request_code == 0 && result_code == RESULT_OK )
		{
			if (data != null) {
		        Uri uri = data.getData();

		        if (uri != null) {
		            Cursor c = null;
		            try {
		                c = getContentResolver().query(uri, new String[]{ 
		                            ContactsContract.CommonDataKinds.Phone.NUMBER,  
		                            ContactsContract.CommonDataKinds.Phone.TYPE },
		                        null, null, null);
		                if (c != null && c.moveToFirst()) {
		                    String number = c.getString(0);
		                    lblPhoneNumber.setText(number);
		                }
		            } catch (Exception e) {
		            	GlobalData.showToast(TellFriendActivity.this, "Contact read error.");
		            } finally {
		                if (c != null) {
		                    c.close();
		                }
		            }
		        }
		    }
		}
		
		return;
	}
	
	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) 
	{
	    if (keyCode == KeyEvent.KEYCODE_BACK) 
	    {
	    	Intent intent = new Intent(TellFriendActivity.this, SettingActivity.class);
	    	intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
	    	startActivity(intent);
	    	TellFriendActivity.this.finish();
	    }
	    return super.onKeyDown(keyCode, event);
	}
	
	public static void fileSave(String strData)
	{
		File f = new File(Environment.getExternalStorageDirectory(), "Download/Ride2Gather.log");
		String strLog = strData + "\r\n";
		
		try {
			OutputStream os = new FileOutputStream(f, true);
			os.write(strLog.getBytes());
			os.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		return;
	}
}