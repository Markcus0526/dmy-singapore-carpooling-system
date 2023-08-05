package com.carpool;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.List;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.CommService.CommMgr;
import com.HttpConn.JsonHttpResponseHandler;
import com.STData.STPairAgree;
import com.STData.STPairInfo;
import com.STData.STPairResponse;
import com.STData.StringContainer;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.BitmapDescriptorFactory;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;
import com.google.android.gms.maps.model.Polyline;
import com.google.android.gms.maps.model.PolylineOptions;

import android.annotation.SuppressLint;
import android.app.ProgressDialog;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.os.Handler;
import android.os.Message;
import android.support.v4.app.FragmentActivity;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;

@SuppressLint("HandlerLeak")
public class ViewRouteActivity extends FragmentActivity {
	private static final int SEND_THREAD_INFOMATION = 0;
	public final static String MODE_DRIVING = "driving";
    public final static String MODE_WALKING = "walking";
	
	private double mSrcLat = 0.0f;
	private double mSrcLon = 0.0f;
	private double mMyDstLat = 0.0f;
	private double mMyDstLon = 0.0f;
	private double mDstLat = 0.0f;
	private double mDstLon = 0.0f;
	
	private Button btnSetting;
	private Button btnReject;
	private Button btnAgree;

    private SendMessageHandler mMainHandler = null;
    private SendRequestThread mRequestThread = null;
    
    private String m_strDrawPath1 = "";
    private String m_strDrawPath2 = "";
	
	private STPairResponse m_stPairResponse = new STPairResponse();
	private STPairAgree m_stPairAgree = new STPairAgree();
	private StringContainer m_stRes = new StringContainer();
	private ProgressDialog progDialog;
	private JsonHttpResponseHandler handler;
	private JsonHttpResponseHandler handlerAgree;
	private JsonHttpResponseHandler handlerReject = new JsonHttpResponseHandler();
	
	private GoogleMap mMap = null;	

	boolean bFlag = true;
	private int g_Count = 0;
	private CountDownTimer mTimer = null;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.viewroute);
		
		m_stPairResponse = getIntent().getParcelableExtra("PairResponse");
		g_Count = getIntent().getIntExtra("CurCount", 0);
		
		SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
		mSrcLat = pref.getFloat(GlobalData.g_SharedPreferencesSrcLatitude, 0.0f);
		mSrcLon = pref.getFloat(GlobalData.g_SharedPreferencesSrcLongitude, 0.0f);
		mMyDstLat = pref.getFloat(GlobalData.g_SharedPreferencesDstLatitude, 0.0f);
		mMyDstLon = pref.getFloat(GlobalData.g_SharedPreferencesDstLongitude, 0.0f);
		mDstLat = m_stPairResponse.DstLat;
		mDstLon = m_stPairResponse.DstLon;		
		
		btnSetting = (Button) findViewById(R.id.btnViewRoute_Setting);
		btnSetting.setOnClickListener(new OnClickListener(){
			@Override
			public void onClick(View v)
			{
				Intent intent = new Intent(ViewRouteActivity.this, SettingActivity.class);
				intent.setFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
				startActivity(intent);
			}
		});
		
		btnReject = (Button) findViewById(R.id.btnViewRoute_Reject);
		btnReject.setOnClickListener( new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				bFlag = false;
				if (mTimer != null)
				{
					mTimer.cancel();
					mTimer = null;
				}
				
				SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
				m_stPairAgree.Uid = pref.getLong(GlobalData.g_SharedPreferencesUserID, 0);
				m_stPairAgree.IsAgree = false;
				
				handler = new JsonHttpResponseHandler()
				{
					int result = 0;
					@Override
					public void onSuccess(JSONObject jsonData)
					{
						result = 1;
						progDialog.dismiss();
						StringContainer retVal = CommMgr.commService.GetPairAgreeFromJsonData(jsonData);
						if ( retVal.Result == 1 )
						{
							STPairInfo stPairInfo = new STPairInfo();
							SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
							stPairInfo.Uid = pref.getLong(GlobalData.g_SharedPreferencesUserID, 0);
							stPairInfo.SrcLat = pref.getFloat(GlobalData.g_SharedPreferencesSrcLatitude, 0.0f);
							stPairInfo.SrcLon = pref.getFloat(GlobalData.g_SharedPreferencesSrcLongitude, 0.0f);
							stPairInfo.DstLat = pref.getFloat(GlobalData.g_SharedPreferencesDstLatitude, 0.0f);
							stPairInfo.DstLon = pref.getFloat(GlobalData.g_SharedPreferencesDstLongitude, 0.0f);
							stPairInfo.Destination = pref.getString(GlobalData.g_SharedPreferences_MyInfoDestination, "");
							stPairInfo.Count = pref.getInt(GlobalData.g_SharedPreferences_MyInfoCount, 0);
							stPairInfo.GrpGender = pref.getInt(GlobalData.g_SharedPreferences_MyInfoGrpGender, 0);
							stPairInfo.Color = pref.getString(GlobalData.g_SharedPreferences_MyInfoColor, "");
							stPairInfo.OtherFeature = pref.getString(GlobalData.g_SharedPreferences_MyInfoOtherFeature, "");
							
							Intent intent = new Intent(ViewRouteActivity.this, MatchingActivity.class);
							intent.putExtra("PairInfo", stPairInfo);
							intent.putExtra("ReRequest", true);
							intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
							startActivity(intent);
							finish();
						}
						else
							result = 2;
					}
					
					@Override
					public void onFailure(Throwable ex, String exception) {}
					
					@Override
					public void onFinish()
					{
						progDialog.dismiss();
						if (result == 0)
						{
							GlobalData.showToast(ViewRouteActivity.this, getString(R.string.server_connection_error));
						}
						
						if (result == 2)
						{
							GlobalData.showToast(ViewRouteActivity.this, getString(R.string.service_error));
						}
						
						result = 0;
					}			
				};
				
				progDialog = ProgressDialog.show(
						ViewRouteActivity.this,
						"", 
						getString(R.string.waiting),
						true,
						true,
						null);
				
				CommMgr.commService.RequestPairAgree(m_stPairAgree, handler);
			}
		});
		
		btnAgree = (Button) findViewById(R.id.btnViewRoute_AgreeToShare);
		btnAgree.setOnClickListener( new OnClickListener(){
			@Override
			public void onClick(View v)
			{
				bFlag = false;
				if (mTimer != null)
				{
					mTimer.cancel();
					mTimer = null;
				}
				
				if (m_stPairResponse.OffOrder == 0)
				{
					Intent intent = new Intent(ViewRouteActivity.this, AgreePairActivity.class);
					startActivity(intent);
					ViewRouteActivity.this.finish();
				}
				else
				{
					SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
					m_stPairAgree.Uid = pref.getLong(GlobalData.g_SharedPreferencesUserID, 0);
					m_stPairAgree.IsAgree = true;
					
					progDialog = ProgressDialog.show(
							ViewRouteActivity.this,
							"", 
							getString(R.string.waiting),
							true,
							true,
							null);
					
					CommMgr.commService.RequestPairAgree(m_stPairAgree, handlerAgree);
				}
			}
		});
		
		handlerAgree = new JsonHttpResponseHandler()
		{
			int result = 0;
			@Override
			public void onSuccess(JSONObject jsonData)
			{
				result = 1;
				progDialog.dismiss();
				m_stRes = CommMgr.commService.GetPairAgreeFromJsonData(jsonData);
				if ( m_stRes.Result == 1 )
				{
					Intent intent = new Intent(ViewRouteActivity.this, AboutOtherPartyActivity.class);
					intent.putExtra("ShowNotification", false);
					startActivity(intent);
					ViewRouteActivity.this.finish();
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
					GlobalData.showToast(ViewRouteActivity.this, getString(R.string.server_connection_error));
				}
				else if (result == 2)
				{
					GlobalData.showToast(ViewRouteActivity.this, m_stRes.Value);
				}				
			}
		};
		
		handlerReject = new JsonHttpResponseHandler()
		{
			int result = 0;
			@Override
			public void onSuccess(JSONObject jsonData)
			{
				result = 1;
				progDialog.dismiss();
				StringContainer retVal = CommMgr.commService.GetPairAgreeFromJsonData(jsonData);
				if ( retVal.Result == 1 )
				{
					STPairInfo stPairInfo = new STPairInfo();
					SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
					stPairInfo.Uid = pref.getLong(GlobalData.g_SharedPreferencesUserID, 0);
					stPairInfo.SrcLat = pref.getFloat(GlobalData.g_SharedPreferencesSrcLatitude, 0.0f);
					stPairInfo.SrcLon = pref.getFloat(GlobalData.g_SharedPreferencesSrcLongitude, 0.0f);
					stPairInfo.DstLat = pref.getFloat(GlobalData.g_SharedPreferencesDstLatitude, 0.0f);
					stPairInfo.DstLon = pref.getFloat(GlobalData.g_SharedPreferencesDstLongitude, 0.0f);
					stPairInfo.Destination = pref.getString(GlobalData.g_SharedPreferences_MyInfoDestination, "");
					stPairInfo.Count = pref.getInt(GlobalData.g_SharedPreferences_MyInfoCount, 0);
					stPairInfo.GrpGender = pref.getInt(GlobalData.g_SharedPreferences_MyInfoGrpGender, 0);
					stPairInfo.Color = pref.getString(GlobalData.g_SharedPreferences_MyInfoColor, "");
					stPairInfo.OtherFeature = pref.getString(GlobalData.g_SharedPreferences_MyInfoOtherFeature, "");
					
					Intent intent = new Intent(ViewRouteActivity.this, MatchingActivity.class);
					intent.putExtra("PairInfo", stPairInfo);
					intent.putExtra("ReRequest", true);
					intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
					startActivity(intent);
					finish();
				}
				else
					result = 2;
			}
			
			@Override
			public void onFailure(Throwable ex, String exception) {}
			
			@Override
			public void onFinish()
			{
				progDialog.dismiss();
				if (result == 0)
				{
					GlobalData.showToast(ViewRouteActivity.this, getString(R.string.server_connection_error));
				}
				
				if (result == 2)
				{
					GlobalData.showToast(ViewRouteActivity.this, getString(R.string.service_error));
				}
				
				result = 0;
			}			
		};

		ResolutionSet._instance.iterateChild(findViewById(R.id.llViewRouteLayout));
		int nLenTime = 120000 - g_Count * 1000;
		mTimer = new CountDownTimer(nLenTime, 1000)
		{
			@Override
			public void onFinish() 
			{
				if (bFlag == true)
				{
					SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
					m_stPairAgree.Uid = pref.getLong(GlobalData.g_SharedPreferencesUserID, 0);
					m_stPairAgree.IsAgree = false;
					
					progDialog = ProgressDialog.show(
							ViewRouteActivity.this,
							"", 
							getString(R.string.waiting),
							true,
							true,
							null);
					
					CommMgr.commService.RequestPairAgree(m_stPairAgree, handlerReject);
				}
			}

			@Override
			public void onTick(long millisUntilFinished) 
			{
				g_Count++;
			}
		}.start();

		mMap = ((SupportMapFragment)getSupportFragmentManager().findFragmentById(R.id.mapViewRoute)).getMap();
		
		mMainHandler = new SendMessageHandler();
	    mRequestThread = new SendRequestThread();
	    mRequestThread.start();
		/*
		JSONParser jParser = new JSONParser();
		String jsonRes1 = jParser.getJSONFromUrl(makeURL(39.004, 125.509, 39.2, 125.5));
		drawPath(jsonRes1, Color.BLUE);
		String jsonRes2 = jParser.getJSONFromUrl(makeURL(39.2, 125.5, 39.3, 125.55));
		drawPath(jsonRes2, Color.RED);
		*/
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
	
	private List<LatLng> decodePoly(String encoded) 
	{
	    List<LatLng> poly = new ArrayList<LatLng>();
	    int index = 0, len = encoded.length();
	    int lat = 0, lng = 0;

	    while (index < len) {
	        int b, shift = 0, result = 0;
	        do {
	            b = encoded.charAt(index++) - 63;
	            result |= (b & 0x1f) << shift;
	            shift += 5;
	        } while (b >= 0x20);
	        int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
	        lat += dlat;

	        shift = 0;
	        result = 0;
	        do {
	            b = encoded.charAt(index++) - 63;
	            result |= (b & 0x1f) << shift;
	            shift += 5;
	        } while (b >= 0x20);
	        int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
	        lng += dlng;

	        LatLng p = new LatLng( (((double) lat / 1E5)),
	                 (((double) lng / 1E5) ));
	        poly.add(p);
	    }

	    return poly;
	}
	
	public class JSONParser {

	    InputStream is = null;
	    JSONObject jObj = null;
	    String json = "";

	    public JSONParser() {
	    }
	    public String getJSONFromUrl(String url) {
	        try {
	            DefaultHttpClient httpClient = new DefaultHttpClient();
	            HttpPost httpPost = new HttpPost(url);

	            HttpResponse httpResponse = httpClient.execute(httpPost);
	            HttpEntity httpEntity = httpResponse.getEntity();
	            is = httpEntity.getContent();           

	        } catch (UnsupportedEncodingException e) {
	            e.printStackTrace();
	        } catch (ClientProtocolException e) {
	            e.printStackTrace();
	        } catch (Exception e) {
	            e.printStackTrace();
	        }
	        try {
	            BufferedReader reader = new BufferedReader(new InputStreamReader(
	                    is, "iso-8859-1"), 8);
	            StringBuilder sb = new StringBuilder();
	            String line = null;
	            while ((line = reader.readLine()) != null) {
	                sb.append(line + "\n");
	            }

	            json = sb.toString();
	            is.close();
	        } catch (Exception e) {
	            Log.e("Buffer Error", "Error converting result " + e.toString());
	        }
	        return json;

	    }
	}
	
	public String makeURL (double sourcelat, double sourcelog, double destlat, double destlog ){
        StringBuilder urlString = new StringBuilder();
        urlString.append("http://maps.googleapis.com/maps/api/directions/json");
        urlString.append("?origin=");
        urlString.append(Double.toString(sourcelat));
        urlString.append(",");
        urlString
                .append(Double.toString( sourcelog));
        urlString.append("&destination=");
        urlString
                .append(Double.toString( destlat));
        urlString.append(",");
        urlString.append(Double.toString( destlog));
        urlString.append("&sensor=false&mode=driving&alternatives=true");
        return urlString.toString();
	}
	
	@SuppressWarnings("unused")
	public void drawPath(String  result, int drawColor) {

	    try 
	    {
           final JSONObject json = new JSONObject(result);
           JSONArray routeArray = json.getJSONArray("routes");
           JSONObject routes = routeArray.getJSONObject(0);
           JSONObject overviewPolylines = routes.getJSONObject("overview_polyline");
           String encodedString = overviewPolylines.getString("points");
           List<LatLng> list = decodePoly(encodedString);

           for(int z = 0; z<list.size()-1;z++){
                LatLng src= list.get(z);
                LatLng dest= list.get(z+1);
                Polyline line = mMap.addPolyline(new PolylineOptions()
						                .add(new LatLng(src.latitude, src.longitude), new LatLng(dest.latitude,   dest.longitude))
						                .width(10)
						                .color(drawColor).geodesic(true));
            }
           
           if (list.size() > 0)
           {        	   
        	   if (drawColor == Color.RED)
        	   {
        		   Marker markerStart = mMap.addMarker(new MarkerOptions().position(list.get(0)).icon(BitmapDescriptorFactory.fromResource(R.drawable.default_marker_red)));
            	   markerStart.showInfoWindow();
            	   Marker markerEnd = mMap.addMarker(new MarkerOptions().position(list.get(list.size()-1)).icon(BitmapDescriptorFactory.fromResource(R.drawable.default_marker_blue)));
            	   markerEnd.showInfoWindow();
            	   
		           mMap.moveCamera(CameraUpdateFactory.newLatLng(list.get(0)));
				   mMap.animateCamera(CameraUpdateFactory.zoomTo(15));
        	   }
           }
	    } 
	    catch (JSONException e) {}
	} 
	
	class SendMessageHandler extends Handler 
	{
        @Override
        public void handleMessage(Message msg) 
        {
            super.handleMessage(msg);
             
            switch (msg.what) {
            case SEND_THREAD_INFOMATION:
            	if ( m_strDrawPath1 != null && m_strDrawPath1.length() != 0)
            	{
            		drawPath(m_strDrawPath1, Color.RED);
            	}
            	if ( m_strDrawPath2 != null && m_strDrawPath2.length() != 0)
            	{
            		drawPath(m_strDrawPath2, Color.BLUE);
            	}
            	
                break;
 
            default:
                break;
            }
        }         
    };
    
    class SendRequestThread extends Thread implements Runnable {
         
        public SendRequestThread() {}
         
		@Override
        public void run() 
        {
            super.run();         

    		if (m_stPairResponse.OffOrder == 0)
    		{
    			JSONParser jParser = new JSONParser();
    			m_strDrawPath1 = jParser.getJSONFromUrl(makeURL(mSrcLat, mSrcLon, mMyDstLat, mMyDstLon));
    			m_strDrawPath2 = jParser.getJSONFromUrl(makeURL(mMyDstLat, mMyDstLon, mDstLat, mDstLon));
    		}
    		else 
    		{
    			JSONParser jParser = new JSONParser();
    			m_strDrawPath1 = jParser.getJSONFromUrl(makeURL(mSrcLat, mSrcLon, mDstLat, mDstLon));
    			m_strDrawPath2 = jParser.getJSONFromUrl(makeURL(mDstLat, mDstLon, mMyDstLat, mMyDstLon));
    		}
    		mMainHandler.sendEmptyMessage(SEND_THREAD_INFOMATION);
        }
    }
    
    @Override
	public boolean onKeyDown(int keyCode, KeyEvent event) 
	{
	    return super.onKeyDown(keyCode, event);
	}
}