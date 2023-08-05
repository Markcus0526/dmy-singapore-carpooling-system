package com.carpool;

import com.InApp.IabHelper;
import com.InApp.IabResult;
import com.InApp.Inventory;
import com.InApp.Purchase;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.RelativeLayout;

public class BuyCreditsRequestActivity extends Activity {	
	static final String TAG = "Ride2Gather";
	static final String ITEM_SKU = "android.test.purchased";
	
	private RelativeLayout rl5Credits;
	private RelativeLayout rl10Credits;
	private RelativeLayout rl20Credits;
	private RelativeLayout rlPostFacebook;
	private RelativeLayout rlInviteFriend;
	
	private Button btnSetting;
	
    private IabHelper mHelper;	
    
    IabHelper.OnIabPurchaseFinishedListener mPurchaseFinishedListener = new IabHelper.OnIabPurchaseFinishedListener() {
		public void onIabPurchaseFinished(IabResult result, Purchase purchase) 
		{
		   if (result.isFailure()) 
		   {
		      return;
		   }      
		   else if (purchase.getSku().equals(ITEM_SKU)) {
			   consumeItem();
			   rl5Credits.setEnabled(false);
		   }  
	   }
    };
    
    IabHelper.QueryInventoryFinishedListener mReceivedInventoryListener = new IabHelper.QueryInventoryFinishedListener() {
    	public void onQueryInventoryFinished(IabResult result, Inventory inventory) 
    	{ 		   		   
    		if (result.isFailure()) {}
    		else 
    			mHelper.consumeAsync(inventory.getPurchase(ITEM_SKU), mConsumeFinishedListener);
    	}
    };
    
    IabHelper.OnConsumeFinishedListener mConsumeFinishedListener = new IabHelper.OnConsumeFinishedListener() 
    {
    	public void onConsumeFinished(Purchase purchase, IabResult result) 
    	{
    		if (result.isSuccess())
    			 rl5Credits.setEnabled(true);
    		else {}
    	}
	};
	/*
	private void InitBiling()
	{
    	String base64EncodedPublicKey = GlobalData.g_PublicKey;
        
    	mHelper = new IabHelper(this, base64EncodedPublicKey);    
    	mHelper.startSetup( new IabHelper.OnIabSetupFinishedListener() 
    	{
    		public void onIabSetupFinished(IabResult result) 
    		{
    	    	if (!result.isSuccess()) 
    	    	{
    	        	Log.d(TAG, "In-app Billing setup failed: " + result);
    	    	}
    	    	else 
    	    	{             
    	      	    Log.d(TAG, "In-app Billing is set up OK");
    	    	}
    	   }
    	});
	}
	*/
	public void consumeItem() 
	{
		mHelper.queryInventoryAsync(mReceivedInventoryListener);
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.buycreditsrequest);
		
		btnSetting = (Button) findViewById(R.id.btnBuyCreditsRequest_Setting);
		btnSetting.setOnClickListener( new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				Intent intent = new Intent(BuyCreditsRequestActivity.this, SettingActivity.class);
				intent.setFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
				startActivity(intent);;
			}
		});
						
		rl5Credits = (RelativeLayout) findViewById(R.id.rlBuyCreditsRequest_5Credits);
		rl5Credits.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				//mHelper.launchPurchaseFlow(BuyCreditsRequestActivity.this, ITEM_SKU, 10001, mPurchaseFinishedListener, "");
			}
		});
		
		rl10Credits = (RelativeLayout) findViewById(R.id.rlBuyCreditsRequest_10Credits);
		rl10Credits.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v)
			{
			}
		});
		
		rl20Credits = (RelativeLayout) findViewById(R.id.rlBuyCreditsRequest_20Credits);
		rl20Credits.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v)
			{
			}
		});
		
		rlPostFacebook = (RelativeLayout) findViewById(R.id.rlBuyCreditsRequest_PostFacebook);
		rlPostFacebook.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				Intent intent = new Intent(BuyCreditsRequestActivity.this, FacebookPostActivity.class);
				startActivity(intent);
			}
		});
		
		rlInviteFriend = (RelativeLayout) findViewById(R.id.rlBuyCreditsRequest_InviteFriend);
		rlInviteFriend.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v)
			{
				Intent intent = new Intent(BuyCreditsRequestActivity.this,TellFriendActivity.class);
				startActivity(intent);
			}
		});
		
		//InitBiling();		
		
		ResolutionSet._instance.iterateChild(findViewById(R.id.llBuyCreditsRequestLayout));		
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
	public void onStop()
	{
		super.onStop();
		return;
	}
	
	@Override
	public void onRestart()
	{
		super.onRestart();
		return;
	}
	
	@Override
    public void onDestroy() {
		super.onDestroy();
		if (mHelper != null) 
			mHelper.dispose();
		mHelper = null;
    }
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) 
	{
		if (!mHelper.handleActivityResult(requestCode, resultCode, data)) 
			super.onActivityResult(requestCode, resultCode, data);
	}
}