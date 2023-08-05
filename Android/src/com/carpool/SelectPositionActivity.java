package com.carpool;

import java.util.List;
import java.util.Locale;

import org.json.JSONObject;

import com.CommService.CommMgr;
import com.HttpConn.AsyncHttpResponseHandler;
import com.HttpConn.JsonHttpResponseHandler;
import com.STData.STReqTaxiStand;
import com.STData.STTaxiStandResp;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GooglePlayServicesUtil;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.location.Address;
import android.location.Geocoder;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.v4.app.FragmentActivity;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.TextView;

public class SelectPositionActivity extends FragmentActivity {
	
	private final int REQUEST_SUCCESS = 1;
	private final int REQUEST_SERVER = 2;

	private boolean isAvailableTaxiStand = false;
	private boolean isRequestServer = false;
	private SendMessageHandler mMainHandler = null;
    private FindRequestThread mRequestThread = null;
		
	private Button btnStart;
	private Button btnModify;
	private Button btnSetting;
	private TextView lblMyAddress;

	private String mTaxiStandNo;
	private String mTaxiStandAddress;
	private String mMyPosAddress;
	private double curMyLon = 0.0f, curMyLat = 0.0f;
	private double curTaxiStandLon = 0.0f, curTaxiStandLat = 0.0f;
	
	private GoogleMap mMap;
	private Marker marker;
	private LocationManager mLocationManager;
	private String provider;
	
	private STReqTaxiStand reqTaxiStand = new STReqTaxiStand();
	private STTaxiStandResp respTaxiStand = new STTaxiStandResp();
	private JsonHttpResponseHandler handlerRequestServer = null;
	private AsyncHttpResponseHandler handlerUserCredits = null;
	private ProgressDialog progDialog = null;
		
	@SuppressWarnings({ "static-access" })
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.selectposition);
		
		curTaxiStandLat = getIntent().getDoubleExtra("SrcLat", 0.0f);
		curTaxiStandLon = getIntent().getDoubleExtra("SrcLon", 0.0f);
		mTaxiStandAddress = getIntent().getStringExtra("Address");
		mTaxiStandNo = getIntent().getStringExtra("StandNo");				
		
		if ( curTaxiStandLat != 0.0f && curTaxiStandLon != 0.0f )
			isAvailableTaxiStand = true;

		btnStart = (Button) findViewById(R.id.btnSelectPosition_Start);
		if ( curTaxiStandLat == 0.0f || curTaxiStandLon == 0.0f )
			btnStart.setEnabled(false);
		else
			btnStart.setEnabled(true);
		btnStart.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				RunBackgroundHandler();
			}
		});
		
		btnModify = (Button) findViewById(R.id.btnSelectPosition_Modify);
		btnModify.setOnClickListener(new OnClickListener(){
			@Override
			public void onClick(View v)
			{
				if ( (curTaxiStandLat == 0.0f) && (curTaxiStandLon == 0.0f) && (curMyLat == 0.0f) && (curMyLon == 0.0f) )
					return;
				
				if (mRequestThread != null) {
					if ( mRequestThread.isAlive() )
						mRequestThread.interrupt();
					mRequestThread = null;
				}
				
				Intent intent = new Intent(SelectPositionActivity.this, ChangePositionActivity.class);				
				if ( (curTaxiStandLat != 0.0f) && ( curTaxiStandLon != 0.0f ) )
				{
					intent.putExtra("SrcLat", curTaxiStandLat);
					intent.putExtra("SrcLon", curTaxiStandLon);
					intent.putExtra("AddressName", mTaxiStandAddress);
				}
				else
				{
					intent.putExtra("SrcLat", curMyLat);
					intent.putExtra("SrcLon", curMyLon);
					intent.putExtra("AddressName", mMyPosAddress);
				}
				startActivity(intent);
			}
		});
		
		btnSetting = (Button) findViewById(R.id.btnSelectPosition_Setting);
		btnSetting.setOnClickListener( new OnClickListener(){
			@Override
			public void onClick(View v)
			{
				SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
				SharedPreferences.Editor editor = pref.edit();
				editor.putInt(GlobalData.g_SharedPreferences_SettingFlag, 0);
				editor.commit();
				
				Intent intent = new Intent(SelectPositionActivity.this, SettingActivity.class);
				startActivity(intent);
			}
		});
		
		lblMyAddress = (TextView) findViewById(R.id.lblSelectPosition_MyPos);
		
		getGpsService();
		
		mMainHandler = new SendMessageHandler();		
		ResolutionSet._instance.iterateChild(findViewById(R.id.llSelectPositionLayout));
		
		int status = GooglePlayServicesUtil.isGooglePlayServicesAvailable(SelectPositionActivity.this);
		if ( status != ConnectionResult.SUCCESS )			
		{
			GlobalData.showToast(SelectPositionActivity.this, "This equipment not support Google Play Services");
			SelectPositionActivity.this.finish();
		}
		else
		{
			mMap = ((SupportMapFragment) getSupportFragmentManager().findFragmentById(R.id.mapSelectPosition)).getMap();
			if (mMap != null)
				mMap.setMyLocationEnabled(true);
			
			mLocationManager = (LocationManager) getSystemService(Context.LOCATION_SERVICE);
		    provider = mLocationManager.NETWORK_PROVIDER;
		    if(!mLocationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER)) {
		        provider = mLocationManager.GPS_PROVIDER;
		    }

		    if (provider == null) {
		        provider = mLocationManager.getBestProvider(null, true);
		    }
		    
		    Location location= mLocationManager.getLastKnownLocation(provider);
		    if (location != null)
		    	locationListener.onLocationChanged(location);
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

		mLocationManager.requestLocationUpdates(provider, 1000, 0, locationListener);
		if ( mTaxiStandAddress != null && mTaxiStandAddress.length() > 0 )
		{
			if (mTaxiStandNo != null && mTaxiStandNo.length() > 0)
				lblMyAddress.setText(mTaxiStandNo + "-" + mTaxiStandAddress);
			else
				lblMyAddress.setText(mTaxiStandAddress);
		}
		else
			lblMyAddress.setText("");

		return;
	}
		
	@Override
	public void onPause()
	{
		super.onPause();
		
		mLocationManager.removeUpdates(locationListener);
		
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
	
	private LocationListener locationListener = new LocationListener() {
        
        public void onLocationChanged(Location location) {
        	curMyLat = location.getLatitude();
    		curMyLon = location.getLongitude();

    		if (curMyLat != 0.0f && curMyLon != 0.0f) 
    		{
    		    if(marker != null)
    		        marker.remove();
    		    
    			LatLng curMyPos = new LatLng(curMyLat, curMyLon);
    		    marker = mMap.addMarker(new MarkerOptions().position(curMyPos));
    		    mMap.moveCamera(CameraUpdateFactory.newLatLng(curMyPos));
    		    mMap.animateCamera(CameraUpdateFactory.zoomTo(15));
    		    
    		    mMainHandler.sendEmptyMessage(REQUEST_SERVER);
    		    
    		    if ( isAvailableTaxiStand == false )
    		    {
    			    if (mRequestThread != null) {
    					if ( mRequestThread.isAlive() )
    						mRequestThread.interrupt();
    					mRequestThread = null;
    					mRequestThread = new FindRequestThread();
    					mRequestThread.start();
    				}
    				else {
    					mRequestThread = new FindRequestThread();
    					mRequestThread.start();
    				}
    		    }
    		}
        }
        
        public void onStatusChanged(String provider, int status, Bundle extras) {}
    
        public void onProviderEnabled(String provider) {}
    
        public void onProviderDisabled(String provider) {}

    
    };
	
	public String getAddress(double latitude, double longitude) 
	{
		String strAddress = "";
		
        try 
        {
            Geocoder geocoder;
            List<Address> addresses;
            geocoder = new Geocoder(SelectPositionActivity.this, Locale.CHINA);
            if (latitude != 0 || longitude != 0) 
            {
                addresses = geocoder.getFromLocation(latitude, longitude, 1);
                String address = addresses.get(0).getAddressLine(0);
                String city = addresses.get(0).getAddressLine(1);
                String country = addresses.get(0).getAddressLine(2);
                Log.d("TAG", "address = "+address+", city ="+city+", country = "+country );
                
                if (city != null && city.length() > 0)
                	strAddress = address + " " + city;
                
                if (country != null && country.length() > 0)
                	strAddress += " " + country;
                
                return strAddress;
            }
        }
        catch (Exception e) 
        {
            e.printStackTrace();
        }
        
		return "";
    }
	

	private boolean getGpsService() {
		String gs = android.provider.Settings.Secure.getString(getContentResolver(),
		android.provider.Settings.Secure.LOCATION_PROVIDERS_ALLOWED);
		if (gs.indexOf("gps", 0) < 0) {
			AlertDialog.Builder gsDialog = new AlertDialog.Builder(this);
			gsDialog.setTitle(getString(R.string.alert));
			gsDialog.setMessage(getString(R.string.gpsalert));
			gsDialog.setPositiveButton(getString(R.string.SharingCriteria_Ok), new DialogInterface.OnClickListener() {
				public void onClick(DialogInterface dialog, int which) {
					Intent intent = new Intent(android.provider.Settings.ACTION_LOCATION_SOURCE_SETTINGS);
					intent.addCategory(Intent.CATEGORY_DEFAULT);
					startActivity(intent);
				}
			}).create().show();
			return false;
		} else {
			return true;
		}
	}
	
	@SuppressLint("HandlerLeak")
	class SendMessageHandler extends Handler 
	{
        @Override
        public void handleMessage(Message msg) 
        {
            super.handleMessage(msg);

            switch (msg.what) {
            case REQUEST_SUCCESS:
                break;
                
            case REQUEST_SERVER:
            	if (isRequestServer == false)
            	{
            		handlerRequestServer = new JsonHttpResponseHandler()
            		{            			
            			@Override
            			public void onSuccess(JSONObject objData)
            			{
            				respTaxiStand = CommMgr.commService.GetTaxiStandFromJsonData(objData);            				
            				if (respTaxiStand.Result < 0)
            				{
            					return;
            				}

            				if (isAvailableTaxiStand == false)
            				{
	            				mTaxiStandAddress = respTaxiStand.TaxiStand.StandName;
	            				mTaxiStandNo = respTaxiStand.TaxiStand.StandNo;
	            				curTaxiStandLat = respTaxiStand.TaxiStand.Latitude;
	            				curTaxiStandLon = respTaxiStand.TaxiStand.Longitude;
	            				if (mTaxiStandNo != null && mTaxiStandNo.length() > 0)
	            					lblMyAddress.setText(mTaxiStandNo + "-" + mTaxiStandAddress);
	            				else
	            					lblMyAddress.setText(mTaxiStandAddress);
            				}
            				btnStart.setEnabled(true);
            			}
            			
            			@Override
            			public void onFailure(Throwable ex, String exception) {}
            			
            			@Override
            			public void onFinish()
            			{
            				/*
            				if ( result != 1 )
            				{
            					SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
                        		reqTaxiStand.Uid = pref.getLong(GlobalData.g_SharedPreferencesUserID, 0);
                        		reqTaxiStand.Latitude = curTaxiStandLat;
                        		reqTaxiStand.Longitude = curTaxiStandLon;
                        		CommMgr.commService.RequestTaxiStand(reqTaxiStand, handlerRequestServer);
            				}
            				*/
            			};
            		};
            		
            		if ( curMyLon == 0.0f || curMyLat == 0.0f )
            			return;
            			
            		isRequestServer = true;
            		
            		SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
            		reqTaxiStand.Uid = pref.getLong(GlobalData.g_SharedPreferencesUserID, 0);
            		reqTaxiStand.Latitude = curMyLat;
            		reqTaxiStand.Longitude = curMyLon;
            		CommMgr.commService.RequestTaxiStand(reqTaxiStand, handlerRequestServer);
            	}
            	break;
                 
            default:
                break;
            }
        }         
    };
	    
    class FindRequestThread extends Thread implements Runnable {
         
        public FindRequestThread() {}         
         
		@Override
        public void run() 
        {
            super.run();
            
            mMyPosAddress = getAddress(curMyLat, curMyLon);
	    	mMainHandler.sendEmptyMessage(REQUEST_SUCCESS);
            
			return;
        }
    }
	
	private void RunBackgroundHandler()
	{
		handlerUserCredits = new AsyncHttpResponseHandler()
		{
			int result = 0;
			
			@Override
			public void onSuccess(String strData)
			{
				result = 1;

				progDialog.dismiss();
				
				int nCredits = CommMgr.commService.GetUserCreditsFromJsonData(strData);
				
				if (nCredits < 0)
				{
					result = 2;
					return;
				}
				
				if ( nCredits == 0 )
				{
					Intent intent = new Intent(SelectPositionActivity.this, BuyCreditsActivity.class);
					intent.putExtra("Credits", nCredits);
					startActivity(intent);
				}				
				
				if (nCredits > 0)
				{					
					SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
					SharedPreferences.Editor editor = pref.edit();
					editor.putFloat(GlobalData.g_SharedPreferencesSrcLatitude, (float)curTaxiStandLat);
					editor.putFloat(GlobalData.g_SharedPreferencesSrcLongitude, (float)curTaxiStandLon);
					editor.putString(GlobalData.g_SharedPreferencesSrcAddress, mTaxiStandAddress);
					editor.commit();
					
					Intent intent = new Intent(SelectPositionActivity.this, MyInfoActivity.class);
					startActivity(intent);
				}				
			}
			
			@Override
			public void onFailure(Throwable ex, String exception) {}
			
			@Override
			public void onFinish()
			{
				progDialog.dismiss();
				if (result == 0)
					GlobalData.showToast(SelectPositionActivity.this, getString(R.string.server_connection_error));
				
				if (result == 2)
					GlobalData.showToast(SelectPositionActivity.this, getString(R.string.service_error));
				
				result = 0;
			}
			
		};
		
		progDialog = ProgressDialog.show(
				SelectPositionActivity.this,
				"", 
				getString(R.string.waiting),
				true,
				true,
				null);
		
		SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
		long Uid = pref.getLong(GlobalData.g_SharedPreferencesUserID, 0);
		
		CommMgr.commService.RequestUserCredits(Long.toString(Uid), handlerUserCredits);
		
		return;
	}
	
	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) 
	{
	    if (keyCode == KeyEvent.KEYCODE_BACK) 
	    {
	    	Intent intent = new Intent(SelectPositionActivity.this, SignInActivity.class);
	    	startActivity(intent);
	    	finish();
	    }
	    return super.onKeyDown(keyCode, event);
	}
}