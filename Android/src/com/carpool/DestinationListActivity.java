package com.carpool;

import java.util.ArrayList;
import org.apache.http.client.HttpClient;
import org.apache.http.client.ResponseHandler;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.BasicResponseHandler;
import org.apache.http.impl.client.DefaultHttpClient;
import org.json.JSONArray;
import com.CommService.CommMgr;
import com.HttpConn.JsonHttpResponseHandler;
import com.STData.STServiceData;
import com.STData.STTaxiStand;
import com.Utils.PullRefreshListView.PullToRefreshBase;
import com.Utils.PullRefreshListView.PullToRefreshListView;
import com.Utils.PullRefreshListView.PullToRefreshBase.Mode;
import com.Utils.PullRefreshListView.PullToRefreshBase.OnLastItemVisibleListener;
import com.Utils.PullRefreshListView.PullToRefreshBase.OnRefreshListener;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.AsyncTask;
import android.os.Bundle;
import android.text.format.DateUtils;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.inputmethod.EditorInfo;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ArrayAdapter;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.TextView.OnEditorActionListener;

public class DestinationListActivity extends Activity {

	private final static int TAXISTAND_LIST_ONESHOW_COUNT = 20;
	
	private int nRequestPageNo = 0;
	boolean bExistNext = true;
	private PullToRefreshListView mPullRefreshListView;
	private ListView listRealAddressList = null;
    
    private Bundle mExtra;
    private Intent mIntent;
	
	private ImageView imgCancelMark;
	private EditText txtFind;
		
	private int nSelectedItemNo = 0;
	private double fDestLat = 0.0f;
	private double fDestLon = 0.0f;
	private String strFindAddress = "";
	
	private String m_strFindText = "";
	
	private MyAdapter adapter;
	private ProgressDialog progDialog = null;
	
	private JsonHttpResponseHandler handler = null;
	private ArrayList<STTaxiStand> m_arrDest = null;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.destinationlist);
						
		mPullRefreshListView = (PullToRefreshListView) findViewById(R.id.listDestinationList_AddressList);
		mPullRefreshListView.setMode(Mode.PULL_FROM_END);
		
		mPullRefreshListView.setOnRefreshListener(new OnRefreshListener<ListView>() {
			@Override
			public void onRefresh(PullToRefreshBase<ListView> refreshView) {
				String label = DateUtils.formatDateTime(getApplicationContext(), System.currentTimeMillis(),
						DateUtils.FORMAT_SHOW_TIME | DateUtils.FORMAT_SHOW_DATE | DateUtils.FORMAT_ABBREV_ALL);

				refreshView.getLoadingLayoutProxy().setLastUpdatedLabel(label);

				new GetDataTask().execute();
			}
		});
		
		mPullRefreshListView.setOnLastItemVisibleListener( new OnLastItemVisibleListener() {
			@Override
			public void onLastItemVisible() {}
		});
		
		mPullRefreshListView.setOnItemClickListener( new OnItemClickListener() {
			@Override
			public void onItemClick(AdapterView<?> arg0, View arg1, int arg2, long arg3) {
				if (m_arrDest != null && m_arrDest.size() > 0)
				{
					if ( m_arrDest.size() >= arg2 )
					{	
						fDestLat = m_arrDest.get(arg2-1).Latitude;
						fDestLon = m_arrDest.get(arg2-1).Longitude;
						if (m_arrDest.get(arg2-1).GpsAddress != null && m_arrDest.get(arg2-1).GpsAddress.length() > 0)
							strFindAddress = m_arrDest.get(arg2-1).GpsAddress;
						else
						{
							strFindAddress = m_arrDest.get(arg2-1).StandName + ", (S)" + m_arrDest.get(arg2-1).PostCode;
						}
						
						mExtra = new Bundle();						
						mIntent = new Intent();
						mExtra.putDouble("DstLat", fDestLat);
						mExtra.putDouble("DstLon", fDestLon);
						mExtra.putString("DstAddress", strFindAddress);
						mIntent.putExtras(mExtra);
						DestinationListActivity.this.setResult(RESULT_OK, mIntent);
						DestinationListActivity.this.finish();
					}
				}
			}
		});
		
		listRealAddressList = mPullRefreshListView.getRefreshableView();

		txtFind = (EditText) findViewById(R.id.txtDestinationList_Find);
		txtFind.setOnEditorActionListener( new OnEditorActionListener() {
			@Override
			public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
				if (actionId == EditorInfo.IME_ACTION_SEARCH)
				{
					/*
					 * FixMe 2013-11-14
					fDestLat = 41.66475400000000000000;
					fDestLon = 123.34406000000000000000;
					strFindAddress = "Sujiatun";
					mExtra = new Bundle();						
					mIntent = new Intent();
					mExtra.putDouble("DstLat", fDestLat);
					mExtra.putDouble("DstLon", fDestLon);
					mExtra.putString("DstAddress", strFindAddress);
					mIntent.putExtras(mExtra);
					DestinationListActivity.this.setResult(RESULT_OK, mIntent);
					DestinationListActivity.this.finish();
					*/
					
					m_strFindText = txtFind.getText().toString();
					if ( m_strFindText == null || m_strFindText.length() == 0 )
					{
						GlobalData.showToast(DestinationListActivity.this, getString(R.string.destination_insert_error));
						return false;
					}
					try {
						listRealAddressList.setAdapter(null);
					} catch(Exception ex){
					};
					RunBackgroundHandler();
					
					return true;
				}
				
				return false;
			}
		});
		
		imgCancelMark = (ImageView) findViewById(R.id.imgDestinationList_CancelMark);
		imgCancelMark.setOnClickListener( new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				if (txtFind != null)
					txtFind.setText("");
			}
		});
						
		ResolutionSet._instance.iterateChild(findViewById(R.id.llDestinationListLayout));		
	}
	
	private void initContents()
	{
		if (listRealAddressList != null)
	    {
	    	getShowListFromData();
	    }
	}
	
	private void getShowListFromData()
    {
    	if (m_arrDest == null || m_arrDest.size() < 1)
    		return;

    	if (m_arrDest.size() == TAXISTAND_LIST_ONESHOW_COUNT)
    	{
    		bExistNext = true;
   			mPullRefreshListView.setMode(Mode.PULL_FROM_END);
    	}
    	else
    	{
    		bExistNext = false;
   			mPullRefreshListView.setMode(Mode.DISABLED);
    	}
    	
    	if (listRealAddressList != null)
    	{
    		listRealAddressList.setCacheColorHint(Color.parseColor("#FFF1F1F1"));
    		listRealAddressList.setDivider(new ColorDrawable(Color.parseColor("#FFCCCCCC")));
    		listRealAddressList.setDividerHeight(2);
    		adapter = new MyAdapter(DestinationListActivity.this, 0, m_arrDest);
    		listRealAddressList.setAdapter(adapter);
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
		
		SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
		fDestLat = pref.getFloat(GlobalData.g_SharedPreferencesSrcLatitude, 0.0f);
		fDestLon = pref.getFloat(GlobalData.g_SharedPreferencesSrcLongitude, 0.0f);
		
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
		handler = new JsonHttpResponseHandler()
		{
			int result = 0;
			
			@Override
			public void onSuccess(JSONArray jsonDataArr)
			{
				result = 1;
				progDialog.dismiss();
				m_arrDest = CommMgr.commService.GetDestListFromJsonData(jsonDataArr);
				initContents();
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
					GlobalData.showToast(DestinationListActivity.this, getString(R.string.server_connection_error));
				}
				
				result = 0;
			}			
		};
		
		progDialog = ProgressDialog.show(
				DestinationListActivity.this,
				"", 
				getString(R.string.waiting),
				true,
				true,
				null);
		
		nSelectedItemNo = 0;
		CommMgr.commService.GetDestList(m_strFindText, nSelectedItemNo, handler);
		
		return;
	}

	class MyAdapter extends ArrayAdapter<STTaxiStand> {
		ArrayList<STTaxiStand> list;
		Context ctx;
		
		public MyAdapter(Context ctx, int resourceId, ArrayList<STTaxiStand> list) {
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
			TextView txtVicinity = (TextView)v.findViewById(R.id.txtBuildingVicinity);
			/*
			 * Fixme 2013-12-10
			 * GpsAddress <= Area2
			 * StandName <= Area1
			 */
			if (list.get(position).GpsAddress != null)
			{
				if (list.get(position).GpsAddress.length() != 0)
				{
					txtName.setText(list.get(position).GpsAddress);
					txtVicinity.setText(list.get(position).StandName + ",(S)" + list.get(position).PostCode);
				}
				else
				{
					txtName.setText(list.get(position).StandName);
					txtVicinity.setText(list.get(position).StandName + ",(S)" + list.get(position).PostCode);
				}
			}
			v.setTag(position);
			if (position == nSelectedItemNo)
				v.setBackgroundColor(Color.BLUE);
			else
				v.setBackgroundColor(Color.WHITE);				
			
			return v;
		}
	}
	
	private class GetDataTask extends AsyncTask<Void, Void, ArrayList<STTaxiStand>> {

		@Override
		protected ArrayList<STTaxiStand> doInBackground(Void... params) 
		{
			try {
				nRequestPageNo = nRequestPageNo + 1;
				String responseBody = RequestPairHistoryListWithParamNoDelay(m_strFindText, nRequestPageNo);
				
				JSONArray jsonData = new JSONArray(responseBody);
				ArrayList<STTaxiStand> extraInfoList = CommMgr.commService.GetDestListFromJsonData(jsonData);
				
				return extraInfoList;
			} catch (Exception e) {
			}
			
			return null;
		}

		@Override
		protected void onPostExecute(ArrayList<STTaxiStand> result) {
			if (result != null)
			{
				int nBufSize = result.size();
				if (nBufSize == TAXISTAND_LIST_ONESHOW_COUNT)
					bExistNext = true;
				else
					bExistNext = false;
				
				for (int i = 0; i < nBufSize; i++)
					m_arrDest.add(result.get(i));
				
				adapter.notifyDataSetChanged();
				mPullRefreshListView.onRefreshComplete();
			}
			
			super.onPostExecute(result);
		}
	}
	
	@SuppressWarnings("unchecked")
	public String RequestPairHistoryListWithParamNoDelay(String strFindText, int nPageNo)
	{
		String connectUrl = STServiceData.serviceAddr + STServiceData.strGetDestList + "/" + strFindText + "/" + Long.toString(nPageNo);

		HttpClient client = new DefaultHttpClient();
		HttpGet get = new HttpGet(connectUrl);

		@SuppressWarnings("rawtypes")
		ResponseHandler responseHandler = new BasicResponseHandler();

		String responseBody = "";
		try {
			responseBody = client.execute(get, responseHandler);
		} catch(Exception ex) {
			ex.printStackTrace();
		}
		
		return responseBody;
	}
}