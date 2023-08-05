package com.carpool;

import java.util.ArrayList;

import org.apache.http.client.HttpClient;
import org.apache.http.client.ResponseHandler;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.BasicResponseHandler;
import org.apache.http.impl.client.DefaultHttpClient;
import org.json.JSONArray;
import org.json.JSONObject;

import com.CommService.CommMgr;
import com.HttpConn.JsonHttpResponseHandler;
import com.STData.STPairHistory;
import com.STData.STPairHistoryCount;
import com.STData.STReqPairHistory;
import com.STData.STServiceData;
import com.Utils.PullRefreshListView.PullToRefreshBase;
import com.Utils.PullRefreshListView.PullToRefreshBase.Mode;
import com.Utils.PullRefreshListView.PullToRefreshBase.OnLastItemVisibleListener;
import com.Utils.PullRefreshListView.PullToRefreshBase.OnRefreshListener;
import com.Utils.PullRefreshListView.PullToRefreshListView;

import android.os.AsyncTask;
import android.os.Bundle;
import android.text.format.DateUtils;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.ListView;
import android.widget.TextView;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;

public class HistoryActivity extends Activity {
	
	private final static int HISTORY_LIST_ONESHOW_COUNT = 15;
	
	private int nRequestPageNo = 1;
	boolean bExistNext = true;
	
	private Button btnSetting;
	private TextView lblTotalSaving;
	
	private PullToRefreshListView mPullRefreshListView;
	private ListView mRealListView;
	private MyAdapter mAdapter;
	
	private STReqPairHistory m_stReqPairHistory = new STReqPairHistory();
	private STPairHistoryCount m_stPairHistoryCount = new STPairHistoryCount();
	private ArrayList<STPairHistory> m_arrPairHistoryList = new ArrayList<STPairHistory>();
	private JsonHttpResponseHandler handlerRequestCount;
	private JsonHttpResponseHandler handlerRequestList;
	private ProgressDialog progDialog;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.history);
		
		lblTotalSaving = (TextView) findViewById(R.id.lblHistory_TotalSavingValue);
		
		mPullRefreshListView = (PullToRefreshListView) findViewById(R.id.listHistory_Histories);
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
		
		mRealListView = mPullRefreshListView.getRefreshableView();
		
		btnSetting = (Button) findViewById(R.id.btnHistory_Setting);
		btnSetting.setOnClickListener( new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				Intent intent = new Intent(HistoryActivity.this, SettingActivity.class);
				startActivity(intent);
				HistoryActivity.this.finish();
			}
		});
		
		ResolutionSet._instance.iterateChild(findViewById(R.id.llHistoryLayout));
		
		handlerRequestCount = new JsonHttpResponseHandler()
		{
			int result = 0;
			
			@Override
			public void onSuccess(JSONObject jsonData)
			{
				result = 1;
				m_stPairHistoryCount = CommMgr.commService.GetPairingHistoryCountFromJsonData(jsonData);
				if ( m_stPairHistoryCount.ErrCode > 0 )
				{	
					updateUI();
					
					SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
					m_stReqPairHistory.Uid = pref.getLong(GlobalData.g_SharedPreferencesUserID, 0);
					m_stReqPairHistory.PageNo = 1;
					CommMgr.commService.RequestPairingHistoryList(m_stReqPairHistory, handlerRequestList);
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
				if (result == 0)
				{
					progDialog.dismiss();
					GlobalData.showToast(HistoryActivity.this, getString(R.string.server_connection_error));
					HistoryActivity.this.finish();
				}
				
				if (result == 2)
				{
					progDialog.dismiss();
					GlobalData.showToast(HistoryActivity.this, getString(R.string.service_error));
					HistoryActivity.this.finish();
				}
				
				result = 0;
			}			
		};
		
		handlerRequestList = new JsonHttpResponseHandler()
		{
			int result = 0;
			
			@Override
			public void onSuccess(JSONArray jsonDataArr)
			{
				result = 1;
				m_arrPairHistoryList = CommMgr.commService.GetPairingHistoryListFromJsonData(jsonDataArr);
            	nRequestPageNo = 1;
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
					GlobalData.showToast(HistoryActivity.this, getString(R.string.server_connection_error));
					HistoryActivity.this.finish();
				}
				
				result = 0;
			}			
		};
	}
	
	private void initContents()
	{
		if (mRealListView != null)
	    {
	    	getShowListFromData();
	    }
	}
	
	private void getShowListFromData()
    {
    	if (m_arrPairHistoryList == null)
    		return;
    	
    	if (m_arrPairHistoryList.size() == HISTORY_LIST_ONESHOW_COUNT)
    	{
    		bExistNext = true;
   			mPullRefreshListView.setMode(Mode.PULL_FROM_END);
    	}
    	else
    	{
    		bExistNext = false;
   			mPullRefreshListView.setMode(Mode.DISABLED);
    	}
    	
    	if (mRealListView != null)
    	{
    		mRealListView.setCacheColorHint(Color.parseColor("#FFF1F1F1"));
    		mRealListView.setDivider(new ColorDrawable(Color.parseColor("#FFCCCCCC")));
    		mRealListView.setDividerHeight(2);
    		
    		mAdapter = new MyAdapter(HistoryActivity.this, 0, m_arrPairHistoryList);
    		mRealListView.setAdapter(mAdapter);
    	}
    }
	
	@Override
	public void onStart()
	{
		super.onStart();
		
		RunBackgroundHandler();
		
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
	
	private void RunBackgroundHandler()
	{
		SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
	    long Uid = pref.getLong(GlobalData.g_SharedPreferencesUserID, 0);
		
		progDialog = ProgressDialog.show(
				HistoryActivity.this,
				"", 
				getString(R.string.waiting),
				true,
				true,
				null);
		
		CommMgr.commService.RequestPairingHistoryCount(Uid, handlerRequestCount);
		
		return;
	}
	
	private void updateUI()
	{
		lblTotalSaving.setText( "S$" + Double.toString( m_stPairHistoryCount.TotalSaving ));		
		return;
	}
	
	class MyAdapter extends ArrayAdapter<STPairHistory> {
		ArrayList<STPairHistory> list;
		Context ctx;
		
		public MyAdapter(Context ctx, int resourceId, ArrayList<STPairHistory> list) {
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
				v = inflater.inflate(R.layout.historyitem, null);
				ResolutionSet._instance.iterateChild(v.findViewById(R.id.llHistoryItemLayout));
			}
			
			SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
			long nID = pref.getLong(GlobalData.g_SharedPreferencesUserID, 0);
			
			if ( nID == list.get(position).Uid1 )
			{
				TextView lblPairingTime = (TextView)v.findViewById(R.id.lblHistoryItem_Time);
				lblPairingTime.setText(list.get(position).PairingTime);
				TextView lblName = (TextView)v.findViewById(R.id.lblHistoryItem_Name);
				lblName.setText( "With " + list.get(position).Name2 + " @" + list.get(position).SrcAddr);
				Button btnRating = (Button)v.findViewById(R.id.btnHistoryItem_Rating);
				TextView lblRating = (TextView)v.findViewById(R.id.lblHistoryItem_Rating);
				if (list.get(position).Score2 >= 0)
				{
					lblRating.setText( Double.toString(list.get(position).Score2) );
					if ( list.get(position).Gender2 == 0 ) 	// if male
						btnRating.setText(getString(R.string.History_RatingHim));
					else									// if female
						btnRating.setText(getString(R.string.History_RatingHer));
					btnRating.setEnabled(false);
				}
				else 
				{
					lblRating.setText("-");
					if ( list.get(position).Gender2 == 0 ) 	// if male
						btnRating.setText(getString(R.string.History_RatingHim));
					else									// if female
						btnRating.setText(getString(R.string.History_RatingHer));
					btnRating.setEnabled(true);
				}
			
				btnRating.setTag(position);
				btnRating.setOnClickListener( new OnClickListener() {
					@Override
					public void onClick(View v)
					{
						int nVal = (Integer)v.getTag();
						if (nVal >= list.size())
							return;
						
						SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
						long nID = pref.getLong(GlobalData.g_SharedPreferencesUserID, 0);
						if (list.get(nVal) != null)
						{
							if (nID == list.get(nVal).Uid1)
							{
								Intent intent = new Intent(HistoryActivity.this, RatingActivity.class);
								intent.putExtra("MyID", list.get(nVal).Uid1);
								intent.putExtra("YourID", list.get(nVal).Uid2);
								intent.putExtra("Name", list.get(nVal).Name2);
								intent.putExtra("SrcAddress", list.get(nVal).SrcAddr);
								intent.putExtra("DstAddress", list.get(nVal).DstAddr2);
								intent.putExtra("PairTime", list.get(nVal).PairingTime);
								
								intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
								
								startActivity(intent);
							}
							else
							{
								Intent intent = new Intent(HistoryActivity.this, RatingActivity.class);
								intent.putExtra("MyID", list.get(nVal).Uid2);
								intent.putExtra("YourID", list.get(nVal).Uid1);
								intent.putExtra("Name", list.get(nVal).Name1);
								intent.putExtra("SrcAddress", list.get(nVal).SrcAddr);
								intent.putExtra("DstAddress", list.get(nVal).DstAddr1);
								intent.putExtra("PairTime", list.get(nVal).PairingTime);
								
								intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
								
								startActivity(intent);
							}
						}
					}
				});
			}
			else if ( nID == list.get(position).Uid2 )
			{
				TextView lblPairingTime = (TextView)v.findViewById(R.id.lblHistoryItem_Time);
				lblPairingTime.setText(list.get(position).PairingTime);
				TextView lblName = (TextView)v.findViewById(R.id.lblHistoryItem_Name);
				lblName.setText( "With " + list.get(position).Name1 + " @" + list.get(position).SrcAddr);
				Button btnRating = (Button)v.findViewById(R.id.btnHistoryItem_Rating);
				TextView lblRating = (TextView)v.findViewById(R.id.lblHistoryItem_Rating);
				if (list.get(position).Score1 >= 0)
				{
					lblRating.setText( Double.toString(list.get(position).Score1) );
					if ( list.get(position).Gender1 == 0 ) 	// if male
						btnRating.setText(getString(R.string.History_RatingHim));
					else									// if female
						btnRating.setText(getString(R.string.History_RatingHer));
					btnRating.setEnabled(false);
				}
				else 
				{
					lblRating.setText("-");
					if ( list.get(position).Gender1 == 0 ) 	// if male
						btnRating.setText(getString(R.string.History_RatingHim));
					else									// if female
						btnRating.setText(getString(R.string.History_RatingHer));
					btnRating.setEnabled(true);
				}
			
				btnRating.setTag(position);
				btnRating.setOnClickListener( new OnClickListener() {
					@Override
					public void onClick(View v)
					{
						int nVal = (Integer)v.getTag();
						if (nVal >= list.size())
							return;
						
						SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
						long nID = pref.getLong(GlobalData.g_SharedPreferencesUserID, 0);
						if (list.get(nVal) != null)
						{
							if (nID == list.get(nVal).Uid1)
							{
								Intent intent = new Intent(HistoryActivity.this, RatingActivity.class);
								intent.putExtra("MyID", list.get(nVal).Uid1);
								intent.putExtra("YourID", list.get(nVal).Uid2);
								intent.putExtra("Name", list.get(nVal).Name2);
								intent.putExtra("SrcAddress", list.get(nVal).SrcAddr);
								intent.putExtra("DstAddress", list.get(nVal).DstAddr2);
								intent.putExtra("PairTime", list.get(nVal).PairingTime);
								
								intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
								
								startActivity(intent);
							}
							else
							{
								Intent intent = new Intent(HistoryActivity.this, RatingActivity.class);
								intent.putExtra("MyID", list.get(nVal).Uid2);
								intent.putExtra("YourID", list.get(nVal).Uid1);
								intent.putExtra("Name", list.get(nVal).Name1);
								intent.putExtra("SrcAddress", list.get(nVal).SrcAddr);
								intent.putExtra("DstAddress", list.get(nVal).DstAddr1);
								intent.putExtra("PairTime", list.get(nVal).PairingTime);
								
								intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
								
								startActivity(intent);
							}
						}						
					}
				});
			}
			
			return v;
		}
	}
	
	private class GetDataTask extends AsyncTask<Void, Void, ArrayList<STPairHistory>> {

		@Override
		protected ArrayList<STPairHistory> doInBackground(Void... params) 
		{
			try {
				nRequestPageNo = nRequestPageNo + 1;
				SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
				m_stReqPairHistory.Uid = pref.getLong(GlobalData.g_SharedPreferencesUserID, 0);
				m_stReqPairHistory.PageNo = nRequestPageNo;
				String responseBody = RequestPairHistoryListWithParamNoDelay(m_stReqPairHistory);
				
				JSONArray jsonData = new JSONArray(responseBody);
				ArrayList<STPairHistory> extraInfoList = CommMgr.commService.GetPairingHistoryListFromJsonData(jsonData);
				
				return extraInfoList;
			} catch (Exception e) {
			}
			
			return null;
		}

		@Override
		protected void onPostExecute(ArrayList<STPairHistory> result) {
			if (result != null)
			{
				int nBufSize = result.size();
				if (nBufSize == HISTORY_LIST_ONESHOW_COUNT)
					bExistNext = true;
				else
					bExistNext = false;
				
				for (int i = 0; i < nBufSize; i++)
					m_arrPairHistoryList.add(result.get(i));
				
				mAdapter.notifyDataSetChanged();
				mPullRefreshListView.onRefreshComplete();
			}
			
			super.onPostExecute(result);
		}
	}
	
	@SuppressWarnings("unchecked")
	public String RequestPairHistoryListWithParamNoDelay(STReqPairHistory condition)
	{
		String connectUrl = STServiceData.serviceAddr + STServiceData.strGetPairingHistoryList + "/" + Long.toString(condition.Uid)+ "/" + Long.toString(condition.PageNo);

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
	
	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) 
	{
	    if (keyCode == KeyEvent.KEYCODE_BACK) 
	    {
	    	Intent intent = new Intent(HistoryActivity.this, SettingActivity.class);
	    	intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
	    	startActivity(intent);
	    	HistoryActivity.this.finish();
	    }
	    return super.onKeyDown(keyCode, event);
	}
}