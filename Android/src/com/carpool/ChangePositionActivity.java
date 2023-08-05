package com.carpool;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.Arrays;

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
import com.STData.STReqTaxiStand;
import com.STData.STTaxiStand;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.inputmethod.EditorInfo;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.TextView.OnEditorActionListener;

public class ChangePositionActivity extends Activity {
	
	private final int REQUEST_FAIL = 0;
	private final int REQUEST_SUCCESS = 1;
	
	private final int RADIUS = 1000;
	
	private SendMessageHandler mMainHandler = null;
    private FindRequestThread mRequestThread = null;
	
	private ImageView imgCancelMark;
	private EditText txtFind;
	private Button btnCannotFind;
	private ListView listAddressList;
	
	private double fSrcLat = 0.0f;
	private double fSrcLon = 0.0f;
	private String strAddress = "";
	private String strFindName = "";
	
	private int nSelectedItemNo = 0;
	
	private FindedAddressNode []m_Address;
	private MyAdapter adapter;
	private ProgressDialog progDialog = null;
	
	private JsonHttpResponseHandler handler;
	private ArrayList<STTaxiStand> m_arrTaxiStand = null;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.changeposition);
		
		fSrcLat = getIntent().getDoubleExtra("SrcLat", 0.0f);
		fSrcLon = getIntent().getDoubleExtra("SrcLon", 0.0f);
		strAddress = getIntent().getStringExtra("AddressName");
		
		Log.d("TAG", "latitude = " + fSrcLat + ", Longitude =" + fSrcLon + ", Address = " + strAddress );
		
		txtFind = (EditText) findViewById(R.id.txtChangePosition_Find);
		txtFind.setOnEditorActionListener( new OnEditorActionListener() {
			@Override
			public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
				if (actionId == EditorInfo.IME_ACTION_SEARCH)
				{
					btnCannotFind.setEnabled(false);
					strFindName = txtFind.getText().toString();
					if ( (fSrcLat != 0.0f) && (fSrcLon != 0.0f) )
					{						
						RunBackgroundHandler();
					}
					return true;
				}
				return false;
			}			
		});
		
		listAddressList = (ListView) findViewById(R.id.listChangePosition_AddressList);
		listAddressList.setDividerHeight(0);
		listAddressList.setOnItemClickListener( new OnItemClickListener() {
			@Override
			public void onItemClick(AdapterView<?> arg0, View arg1, int arg2, long arg3) {
				if (m_Address != null && m_Address.length > 0)
				{
					if ( m_Address.length >= arg2 )
					{	
						Intent intent = new Intent(ChangePositionActivity.this, SelectPositionActivity.class);
						intent.putExtra("SrcLat", m_Address[arg2].Latitude);
						intent.putExtra("SrcLon", m_Address[arg2].Longitude);
						intent.putExtra("Address", m_Address[arg2].Name);
						intent.putExtra("StandNo", m_Address[arg2].StandNo);
						intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
						startActivity(intent);
					}
				}
			}
		});
				
		imgCancelMark = (ImageView) findViewById(R.id.imgChangePosition_CancelMark);
		imgCancelMark.setOnClickListener( new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				if (txtFind != null)
					txtFind.setText("");
			}
		});
		
		btnCannotFind = (Button) findViewById(R.id.btnChangePosition_CannotFind);
		btnCannotFind.setOnClickListener( new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				Intent intent = new Intent(ChangePositionActivity.this, DestSubmitActivity.class);
				intent.putExtra("SrcLat", fSrcLat);
				intent.putExtra("SrcLon", fSrcLon);
				intent.putExtra("Address", strAddress);
				intent.putExtra("Name", "");
				startActivity(intent);
			}
		});
		
		mMainHandler = new SendMessageHandler();		
		ResolutionSet._instance.iterateChild(findViewById(R.id.llChangePositionLayout));		
	}
	
	private void RunBackgroundHandler()
	{
		handler = new JsonHttpResponseHandler()
		{
			int result = 0;
			
			@Override
			public void onSuccess(JSONArray jsonDataArr)
			{
				result = 1;
				m_arrTaxiStand = CommMgr.commService.getTaxiStandListFromJsonData(jsonDataArr);
				if ( m_arrTaxiStand != null && m_arrTaxiStand.size() > 0 )
				{
					progDialog.dismiss();
					
					m_Address = new FindedAddressNode[m_arrTaxiStand.size()];
					for ( int i = 0; i < m_arrTaxiStand.size(); i++ )
					{
						m_Address[i] = new FindedAddressNode();
						m_Address[i].StandNo = m_arrTaxiStand.get(i).StandNo;
						m_Address[i].Name = m_arrTaxiStand.get(i).StandName;
						m_Address[i].Vicinity = m_arrTaxiStand.get(i).GpsAddress;
		                m_Address[i].Latitude = m_arrTaxiStand.get(i).Latitude;
		                m_Address[i].Longitude = m_arrTaxiStand.get(i).Longitude;
					}
					
					updateAddressList();
				}
				else
				{
					progDialog.dismiss();
					progDialog = ProgressDialog.show(
							ChangePositionActivity.this,
							"", 
							getString(R.string.waiting),
							true,
							true,
							null);
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
					};
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
					GlobalData.showToast(ChangePositionActivity.this, getString(R.string.server_connection_error));
					ChangePositionActivity.this.finish();
				}
				
				result = 0;
			}			
		};
		
		progDialog = ProgressDialog.show(
				ChangePositionActivity.this,
				"", 
				getString(R.string.waiting),
				true,
				true,
				null);
		
		STReqTaxiStand reqTaxiStand = new STReqTaxiStand();
		SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
		reqTaxiStand.Uid = pref.getLong(GlobalData.g_SharedPreferencesUserID, 0);
		reqTaxiStand.Latitude = fSrcLat;
		reqTaxiStand.Longitude = fSrcLon;
		reqTaxiStand.Keyword = txtFind.getText().toString();
		CommMgr.commService.RequestTaxiStandList(reqTaxiStand, handler);
		
		return;
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
	
	public String makeURL ( String strFind ){
        StringBuilder urlString = new StringBuilder();
        urlString.append("https://maps.googleapis.com/maps/api/place/nearbysearch/json");
        urlString.append("?location=");
        urlString.append(Double.toString(fSrcLat));
        urlString.append(",");
        urlString.append(Double.toString( fSrcLon ));
        urlString.append("&radius=");
        urlString.append(Integer.toString( RADIUS ));
        urlString.append("&types=taxi_stand");
        if (strFind.length() != 0)
        {
	        urlString.append("&name=");
	        urlString.append(strFind);
        }
        urlString.append("&sensor=false&key=AIzaSyDA7rjm1Il4Q8jxjR1lb6pOdjZ3I3F2g68");
        return urlString.toString();
	}
	
	/*
	public String makeURL (double sourcelat, double sourcelog ){
        StringBuilder urlString = new StringBuilder();
        urlString.append("https://maps.googleapis.com/maps/api/place/nearbysearch/json");
        urlString.append("?location=");
        //urlString.append(Double.toString(sourcelat));
        urlString.append(Double.toString(-33.8670522));
        urlString.append(",");
        //urlString.append(Double.toString( sourcelog));
        urlString.append(Double.toString( 151.1957362 ));
        urlString.append("&radius=");
        urlString.append(Double.toString( 500.0f ));
        urlString.append("&types=taxi_stand&name=harbour&sensor=false&key=AIzaSyDA7rjm1Il4Q8jxjR1lb6pOdjZ3I3F2g68");
        return urlString.toString();        
	}
	*/
	
	private void updateAddressList()
	{
		if (m_Address != null)
		{
			adapter = new MyAdapter(ChangePositionActivity.this, 0, new ArrayList<FindedAddressNode>(Arrays.asList(m_Address)));
			listAddressList.setAdapter(adapter);						
		}
		
		if (m_Address == null || m_Address.length == 0)
			btnCannotFind.setEnabled(true);
	}
	
	class MyAdapter extends ArrayAdapter<FindedAddressNode> {
		ArrayList<FindedAddressNode> list;
		Context ctx;
		
		public MyAdapter(Context ctx, int resourceId, ArrayList<FindedAddressNode> list) {
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
				v = inflater.inflate(R.layout.finditems, null);
				ResolutionSet._instance.iterateChild(v.findViewById(R.id.llFindItemsLayout));
			}
			
			TextView txtName = (TextView)v.findViewById(R.id.txtBuildingName);
			txtName.setText(list.get(position).Name);
			TextView txtVicinity = (TextView)v.findViewById(R.id.txtBuildingVicinity);
			txtVicinity.setText(list.get(position).Vicinity);
			v.setTag(position);
			if (position == nSelectedItemNo)
				v.setBackgroundColor(Color.BLUE);
			else
				v.setBackgroundColor(Color.WHITE);				
			
			return v;
		}
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
            	updateAddressList();
                break;
                 
            case REQUEST_FAIL:
				GlobalData.showToast(ChangePositionActivity.this, getString(R.string.reqeust_timeout));
				btnCannotFind.setEnabled(true);
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
			String jsonRes = jParser.getJSONFromUrl(makeURL( strFindName ));
			
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
				
				m_Address = new FindedAddressNode[arrResult.length()];
				for ( int i = 0; i < arrResult.length(); i++ )
				{
					m_Address[i] = new FindedAddressNode();
					JSONObject jsonName = arrResult.getJSONObject(i);
					m_Address[i].Name = jsonName.getString("name");
					m_Address[i].Vicinity = jsonName.getString("vicinity");
	                JSONObject jsonGeometry = jsonName.getJSONObject("geometry");
	                JSONObject jsonLocation = jsonGeometry.getJSONObject("location");
	                m_Address[i].Latitude = jsonLocation.getDouble("lat");
	                m_Address[i].Longitude = jsonLocation.getDouble("lng");
				}
			} catch (JSONException e) {
				mMainHandler.sendEmptyMessage(REQUEST_FAIL);
				e.printStackTrace();
				return;
			}
			
			mMainHandler.sendEmptyMessage(REQUEST_SUCCESS);
			return;
        }
    }
		
	private class FindedAddressNode
	{
		double Latitude;
		double Longitude;
		String StandNo;
		String Name;		
		String Vicinity;
		
		public FindedAddressNode()
		{
			Latitude = 0.0f;
			Longitude = 0.0f;
			StandNo = "";
			Name = "";
			Vicinity = "";
		}
	}
}