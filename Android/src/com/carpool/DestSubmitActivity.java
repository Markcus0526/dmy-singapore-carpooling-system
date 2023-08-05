package com.carpool;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.conn.ConnectTimeoutException;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.params.BasicHttpParams;
import org.apache.http.params.HttpConnectionParams;
import org.apache.http.params.HttpParams;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.CommService.CommMgr;
import com.HttpConn.JsonHttpResponseHandler;
import com.STData.STTaxiStand;
import com.STData.StringContainer;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.webkit.WebView;
import android.widget.Button;

public class DestSubmitActivity extends Activity {
	private final int REQUEST_FAIL = 0;
	private final int REQUEST_SUCCESS = 1;
	
	private String m_strPostCode = "";
	private String m_strStandNo = "";
	
	private WebView webData;	
	private Button btnSubmit;
	private Button btnCancel;
	
	private STTaxiStand m_stTaxiStand = new STTaxiStand();
	private ProgressDialog progDialog = null;
	private JsonHttpResponseHandler handlerAddTaxiStand = null;
	
	private SendMessageHandler mMainHandler = null;
    private FindRequestThread mRequestThread = null;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.destsubmit);
		
		m_stTaxiStand.Latitude = getIntent().getDoubleExtra("SrcLat", 0.0f);
		m_stTaxiStand.Longitude = getIntent().getDoubleExtra("SrcLon", 0.0f);
		m_stTaxiStand.StandName = getIntent().getStringExtra("Address");
		m_stTaxiStand.GpsAddress = getIntent().getStringExtra("Name");	
		
		webData = (WebView) findViewById(R.id.webDestSubmit_Data);
		webData.setBackgroundColor(0);
		
		String content = 
			       "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"+
			       "<html><head>"+
			       "<meta http-equiv=\"content-type\" content=\"text/html; charset=utf-8\" />"+
			       "</head><body><p align=\"justify\">";

		content += getResources().getString(R.string.DestSubmit_Content) + "</p></body></html>";

		try 
		{
			webData.loadData(URLEncoder.encode(content,"utf-8").replaceAll("\\+"," "), "text/html; charset=UTF-8", "utf-8");
		}
		catch (UnsupportedEncodingException e) 
		{
		}

		btnSubmit = (Button) findViewById(R.id.btnDestSubmit_Submit);
		btnSubmit.setOnClickListener(new OnClickListener(){
			@Override
			public void onClick(View v)
			{
				RunBackgroundHandler();
			}
		});
		
		btnCancel = (Button) findViewById(R.id.btnDestSubmit_Cancel);
		btnCancel.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				DestSubmitActivity.this.finish();
			}
		});
		
		ResolutionSet._instance.iterateChild(findViewById(R.id.llDestSubmitLayout));
		
		progDialog = ProgressDialog.show(
				DestSubmitActivity.this,
				"", 
				getString(R.string.waiting),
				true,
				true,
				null);
		
		if (m_stTaxiStand.Latitude != 0 && m_stTaxiStand.Longitude != 0)
		{
			mMainHandler = new SendMessageHandler();
			mRequestThread = new FindRequestThread();
			mRequestThread.start();
		}
		
		return;
	}
	
	@SuppressLint("HandlerLeak")
	class SendMessageHandler extends Handler 
	{
        @Override
        public void handleMessage(Message msg) 
        {
            super.handleMessage(msg);

            if (progDialog != null && progDialog.isShowing() == true)
            	progDialog.dismiss();
            switch (msg.what) {
            case REQUEST_SUCCESS:
                break;
                 
            case REQUEST_FAIL:
            	m_stTaxiStand.StandNo = "";
            	m_stTaxiStand.PostCode = "";
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
            
            JSONParser jParser = new JSONParser();				
			String jsonRes = jParser.getJSONFromUrl(makeURL( m_stTaxiStand.Latitude, m_stTaxiStand.Longitude ));
            //String jsonRes = jParser.getJSONFromUrl(makeURL( 40.714224, -73.961452 ));
			
			if (jsonRes.length() == 0)
			{
				mMainHandler.sendEmptyMessage(REQUEST_FAIL);
				return;
			}
			
			JSONObject mainObject = null;
			try {
				mainObject = new JSONObject(jsonRes);
			} catch (JSONException e) {
				mMainHandler.sendEmptyMessage(REQUEST_FAIL);
				e.printStackTrace();
				return;
			}

			try {
				JSONArray arrResult = mainObject.getJSONArray("results");
				if ( (arrResult == null) || (arrResult.length() == 0) )
				{
					mMainHandler.sendEmptyMessage(REQUEST_FAIL);
					return;
				}
				
				JSONArray arrAddress = arrResult.getJSONObject(0).getJSONArray("address_components");
				String strStandNo ="";
				String strPostCode = "";
				for ( int i = 0; i < arrAddress.length(); i++ )
				{
					JSONObject obj = arrAddress.getJSONObject(i);
					JSONArray arr = obj.getJSONArray("types");
					String str = "";
					if ( arr.length() > 0 )
						str = arr.getString(0);
					else
						continue;
					if (str.contains("street_number"))
						strStandNo = obj.getString("long_name");
					if (str.contains("postal_code"))
						strPostCode = obj.getString("long_name");
				}
				
				m_strStandNo = strStandNo;
				m_strPostCode = strPostCode;
				
			} catch (JSONException e) {
				mMainHandler.sendEmptyMessage(REQUEST_FAIL);
				m_strStandNo = "";
				m_strPostCode = "";
				e.printStackTrace();
				return;
			}
			
			mMainHandler.sendEmptyMessage(REQUEST_SUCCESS);
			return;
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
	
	private void RunBackgroundHandler()
	{
		handlerAddTaxiStand = new JsonHttpResponseHandler()
		{
			int result = 0;
			StringContainer stData = new StringContainer();
			
			@Override
			public void onSuccess(JSONObject jsonData)
			{
				result = 1;
				stData = CommMgr.commService.GetAddTaxiStandFromJsonData(jsonData);
				if ( (stData.Result == -105) || stData.Result > 0 )
				{	
					progDialog.dismiss();

					Intent intent = new Intent(DestSubmitActivity.this, SelectPositionActivity.class);
					intent.putExtra("SrcLat", m_stTaxiStand.Latitude);
					intent.putExtra("SrcLon", m_stTaxiStand.Longitude);
					intent.putExtra("Address", m_stTaxiStand.StandName);
					intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
					startActivity(intent);
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
					GlobalData.showToast(DestSubmitActivity.this, getString(R.string.server_connection_error));
				}
				
				if (result == 2)
				{
					GlobalData.showToast(DestSubmitActivity.this, stData.Value);
				}
				
				result = 0;
			}
			
		};

		SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
		m_stTaxiStand.Uid = pref.getLong(GlobalData.g_SharedPreferencesUserID, 0);
		m_stTaxiStand.StandType = "Taxi Stand";
		if (m_stTaxiStand.Latitude == 0 || m_stTaxiStand.Longitude == 0)
		{
			m_stTaxiStand.StandNo = "";
			m_stTaxiStand.PostCode = "";
		}
		else
		{
			m_stTaxiStand.StandNo = m_strStandNo;
			m_stTaxiStand.PostCode = m_strPostCode;
		}
		
		progDialog = ProgressDialog.show(
				DestSubmitActivity.this,
				"", 
				getString(R.string.waiting),
				true,
				true,
				null);
		
		CommMgr.commService.RequestAddTaxiStand(m_stTaxiStand, handlerAddTaxiStand);
		
		return;
	}
	
	public class JSONParser {

	    InputStream is = null;
	    JSONObject jObj = null;
	    String json = "";

	    public JSONParser() {
	    }
	    public String getJSONFromUrl(String url) {
	        try {
	        	HttpParams httpParameters = new BasicHttpParams(); 
	        	int timeoutConnection = 5000;
	        	HttpConnectionParams.setConnectionTimeout(httpParameters, timeoutConnection);
	        	HttpConnectionParams.setSoTimeout(httpParameters, timeoutConnection);
	            DefaultHttpClient httpClient = new DefaultHttpClient(httpParameters);
	            HttpPost httpPost = new HttpPost(url);
	            HttpResponse httpResponse = httpClient.execute(httpPost);
	            HttpEntity httpEntity = httpResponse.getEntity();
	            is = httpEntity.getContent();           

	        } catch (UnsupportedEncodingException e) {
	        	return "";
	        } catch (ClientProtocolException e) {
	        	return "";
	        } catch (ConnectTimeoutException e) {
	        	return "";
	        } catch (IOException e) {
	        	return "";
	        }
	    
	        try {
	            BufferedReader reader = new BufferedReader(new InputStreamReader(is, "iso-8859-1"), 8);
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
	
	public String makeURL ( double fLat, double fLon ){
        StringBuilder urlString = new StringBuilder();
        urlString.append("http://maps.googleapis.com/maps/api/geocode/json?latlng=");
        urlString.append(Double.toString(fLat));
        urlString.append(",");
        urlString.append(Double.toString( fLon ));
        urlString.append("&sensor=false");
        return urlString.toString();
	}
}