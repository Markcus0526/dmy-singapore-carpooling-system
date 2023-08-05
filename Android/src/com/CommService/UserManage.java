package com.CommService;

import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import org.apache.http.entity.StringEntity;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONStringer;
import com.HttpConn.AsyncHttpClient;
import com.HttpConn.AsyncHttpResponseHandler;
import com.HttpConn.JsonHttpResponseHandler;
import com.STData.STAuthUser;
import com.STData.STEvaluate;
import com.STData.STFLAuthInfo;
import com.STData.STLoginResult;
import com.STData.STPairHistory;
import com.STData.STPairHistoryCount;
import com.STData.STReqPairHistory;
import com.STData.STResetPassword;
import com.STData.STSendSMS;
import com.STData.STServiceData;
import com.STData.STShareLog;
import com.STData.STTaxiStand;
import com.STData.STUserProfile;
import com.STData.STUserReg;
import com.STData.StringContainer;

public class UserManage {
	
	public UserManage()
	{
	}
	
	public void RequestUserRegister( STUserReg userReg, JsonHttpResponseHandler handler )
	{
		JSONStringer data = null;
		try {
			data = new JSONStringer()
			.object()
        	.key("NewUser")
            	.object()
                	.key("UserName").value(userReg.UserName)
                	.key("PhoneNum").value(userReg.PhoneNum)
                	.key("Password").value(userReg.Password)
                	.key("Gender").value(userReg.Gender)
                	.key("BirthYear").value(userReg.BirthYear)
                	.key("Email").value(userReg.Email)
                	.key("IndGender").value(userReg.IndGender)
                	.key("GrpGender").value(userReg.GrpGender)
	            	.key("DelayTime").value(userReg.DelayTime)
	            	.key("ImageData").value(userReg.ImageData)
                .endObject()
           .endObject();

			StringEntity entity = new StringEntity(data.toString(), "UTF-8");
			AsyncHttpClient client = new AsyncHttpClient();
			client.setTimeout(STServiceData.connectTimeout);
			client.post(null, STServiceData.serviceAddr + STServiceData.strRequestRegister, 
					entity, "application/json; charset=UTF-8", handler);
		} catch (JSONException e) {
			e.printStackTrace();
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		
		return;
	}
	
	public StringContainer GetUserRegisterFromJsonData(JSONObject jsonData)
	{
		StringContainer data = new StringContainer();
		
		try {			
            data.Result = jsonData.getInt("Result");
            data.Value = jsonData.getString("Value");
        } 
		catch(Exception e){}
		
		return data;
	}
	
	public void RequestIsRegistedUser( String Email, JsonHttpResponseHandler handler )
	{
		JSONStringer data = null;
		try {
			data = new JSONStringer()
			.object()
        		.key("Email").value(Email)
           .endObject();

			StringEntity entity = new StringEntity(data.toString(), "UTF-8");
			AsyncHttpClient client = new AsyncHttpClient();
			client.setTimeout(STServiceData.connectTimeout);
			client.post(null, STServiceData.serviceAddr + STServiceData.strRequestIsRegistedUser, 
					entity, "application/json; charset=UTF-8", handler);
		} catch (JSONException e) {
			e.printStackTrace();
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		
		return;
	}
	
	public STLoginResult GetIsRegistedUserFromJsonData(JSONObject jsonData)
	{
		STLoginResult data = new STLoginResult();
		
		try {			
            data.ResultCode = jsonData.getInt("ResultCode");
            data.Message = jsonData.getString("Message");
            data.Name = jsonData.getString("Name");
            data.FirstLogin = jsonData.getInt("FirstLogin");
        } 
		catch(Exception e){}
		
		return data;
	}
	
	public void RequestUserLogin( STAuthUser userAuth, JsonHttpResponseHandler handler )
	{
		JSONStringer data = null;
		try {
			data = new JSONStringer()
			.object()
        	.key("UserAuth")
            	.object()
            		.key("Email").value(userAuth.Email)
                	.key("Password").value(userAuth.Password)
                .endObject()
           .endObject();

			StringEntity entity = new StringEntity(data.toString(), "UTF-8");
			AsyncHttpClient client = new AsyncHttpClient();
			client.setTimeout(STServiceData.connectTimeout);
			client.post(null, STServiceData.serviceAddr + STServiceData.strRequestLogin, 
					entity, "application/json; charset=UTF-8", handler);
		} catch (JSONException e) {
			e.printStackTrace();
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		
		return;
	}
	
	public STLoginResult GetUserLoginFromJsonData(JSONObject jsonData)
	{
		STLoginResult data = new STLoginResult();
		
		try {			
            data.ResultCode = jsonData.getInt("ResultCode");
            data.Message = jsonData.getString("Message");
            data.Name = jsonData.getString("Name");
            data.FirstLogin = jsonData.getInt("FirstLogin");
        } 
		catch(Exception e){}
		
		return data;
	}
	
	public void RequestFLLogin( STFLAuthInfo userAuth, JsonHttpResponseHandler handler )
	{
		JSONStringer data = null;
		try {
			data = new JSONStringer()
			.object()
        	.key("AuthInfo")
            	.object()
            		.key("Name").value(userAuth.Name)
                	.key("Email").value(userAuth.Email)
                	.key("Gender").value(userAuth.Gender)
                	.key("BirthYear").value(userAuth.BirthYear)
                	.key("PhoneNum").value(userAuth.PhoneNum)
                	.key("ImageData").value(userAuth.ImageData)
                .endObject()
           .endObject();

			StringEntity entity = new StringEntity(data.toString(), "UTF-8");
			AsyncHttpClient client = new AsyncHttpClient();
			client.setTimeout(STServiceData.connectTimeout);
			client.post(null, STServiceData.serviceAddr + STServiceData.strRequestFLLogin, 
					entity, "application/json; charset=UTF-8", handler);
		} catch (JSONException e) {
			e.printStackTrace();
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		
		return;
	}
	
	public STLoginResult GetFLLoginFromJsonData(JSONObject jsonData)
	{
		STLoginResult data = new STLoginResult();
		
		try {			
            data.ResultCode = jsonData.getInt("ResultCode");
            data.Message = jsonData.getString("Message");
            data.Name = jsonData.getString("Name");
            data.FirstLogin = jsonData.getInt("FirstLogin");
        } 
		catch(Exception e){}
		
		return data;
	}
	
	public void RequestUserCredits(String Uid, AsyncHttpResponseHandler handler)
	{
		AsyncHttpClient client = new AsyncHttpClient();
		client.setTimeout(STServiceData.connectTimeout);
		client.get(STServiceData.serviceAddr + STServiceData.strRequestUserCredits + "/" + Uid, handler);
	}
	
	public int GetUserCreditsFromJsonData(String strData)
	{
		int nCredits = -1;
		
		try
		{
			nCredits = Integer.parseInt(strData);
		}
		catch (Exception e) {
			nCredits = 0;
		}
		
		return nCredits;
	}
	
	public void GetSharable(String Uid, AsyncHttpResponseHandler handler)
	{
		AsyncHttpClient client = new AsyncHttpClient();
		client.setTimeout(STServiceData.connectTimeout);
		client.get(STServiceData.serviceAddr + STServiceData.strGetSharable + "/" + Uid, handler);
	}
	
	public int GetSharableFromJsonData(String strData)
	{
		int nSharable = -1;
		
		try
		{
			nSharable = Integer.parseInt(strData);
		}
		catch (Exception e) {
			nSharable = 0;
		}
		
		return nSharable;
	}
	
	public void RequestShareLog( STShareLog shareLog, JsonHttpResponseHandler handler )
	{
		JSONStringer data = null;
		try {
			data = new JSONStringer()
			.object()
        	.key("ShareLog")
            	.object()
                	.key("Uid").value(shareLog.Uid)
                	.key("Content").value(shareLog.Content)
                .endObject()
           .endObject();

			StringEntity entity = new StringEntity(data.toString(), "UTF-8");
			AsyncHttpClient client = new AsyncHttpClient();
			client.setTimeout(STServiceData.emailTimeout);
			client.post(null, STServiceData.serviceAddr + STServiceData.strRequestShareLog, 
					entity, "application/json; charset=UTF-8", handler);
		} catch (JSONException e) {
			e.printStackTrace();
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		
		return;
	}
	
	public void GetDestList(String DestName, int PageNo, AsyncHttpResponseHandler handler)
	{
		AsyncHttpClient client = new AsyncHttpClient();
		client.setTimeout(STServiceData.connectTimeout);
		
		DestName = DestName.replace(" ", "%20");
		String strGet = STServiceData.serviceAddr + STServiceData.strGetDestList + "/" + DestName + "/" + Integer.toString(PageNo);
		/*
		try {
            strGet = URLEncoder.encode( strGet, "utf-8" );
        } catch (UnsupportedEncodingException e) {
            strGet = "";
        }
        */
		client.get(strGet, handler);
	}
	
	public ArrayList<STTaxiStand> GetDestListFromJsonData(JSONArray jsonDataArr)
	{
		ArrayList<STTaxiStand> vdDataArr = new ArrayList<STTaxiStand>();

		try {
			for ( int i = 0; i < jsonDataArr.length(); i++ )
			{
				JSONObject jsonData = jsonDataArr.getJSONObject(i);
				
				STTaxiStand taxiStand = new STTaxiStand();
				taxiStand.Uid = jsonData.getLong("Uid");
				taxiStand.GpsAddress = jsonData.getString("GpsAddress");
				taxiStand.Latitude = jsonData.getDouble("Latitude");
				taxiStand.Longitude = jsonData.getDouble("Longitude");
				taxiStand.PostCode = jsonData.getString("PostCode");
				taxiStand.StandName = jsonData.getString("StandName");
				taxiStand.StandNo = jsonData.getString("StandNo");
				taxiStand.StandType = jsonData.getString("StandType");
				
				vdDataArr.add(taxiStand);
			}
		} catch (Exception e) {}
		
		return vdDataArr;
	}
	
	public void RequestUserProfile(String Uid, AsyncHttpResponseHandler handler)
	{
		AsyncHttpClient client = new AsyncHttpClient();
		client.setTimeout(STServiceData.connectTimeout);
		client.get(STServiceData.serviceAddr + STServiceData.strRequestUserProfile + "/" + Uid, handler);
	}
	
	public STUserProfile GetUserProfileFromJsonData(JSONObject jsonData)
	{
		STUserProfile data = new STUserProfile();
		
		try {			
            data.ErrCode = jsonData.getInt("ErrCode");
            data.Message = jsonData.getString("Message");
            data.Uid = jsonData.getLong("Uid");
            data.UserName = jsonData.getString("UserName");
            data.PhoneNum = jsonData.getString("PhoneNum");
            data.Password = jsonData.getString("Password");
            data.Gender = jsonData.getInt("Gender");
            data.BirthYear = jsonData.getInt("BirthYear");
            data.Email = jsonData.getString("Email");
            data.IndGender = jsonData.getInt("IndGender");
            data.GrpGender = jsonData.getInt("GrpGender");
            data.DelayTime = jsonData.getInt("DelayTime");
            data.LoginDate = jsonData.getString("LoginDate");
            data.Credit = jsonData.getInt("Credit");
            data.StarCount = jsonData.getDouble("StarCount");
            data.ImageData = jsonData.getString("ImageData");
            data.TotalSaving = jsonData.getDouble("TotalSaving");
            data.IsGroup = jsonData.getInt("IsGroup");
        } 
		catch(Exception e){}
		
		return data;
	}
	
	public void RequestResetPassword( STResetPassword resetPassword, JsonHttpResponseHandler handler )
	{
		JSONStringer data = null;
		try {
			data = new JSONStringer()
			.object()
        	.key("ResetPassword")
            	.object()
                	.key("Email").value(resetPassword.Email)
                .endObject()
           .endObject();

			StringEntity entity = new StringEntity(data.toString(), "UTF-8");
			AsyncHttpClient client = new AsyncHttpClient();
			client.setTimeout(STServiceData.emailTimeout);
			client.post(null, STServiceData.serviceAddr + STServiceData.strRequestResetPassword, 
					entity, "application/json; charset=UTF-8", handler);
		} catch (JSONException e) {
			e.printStackTrace();
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		
		return;
	}
	
	public StringContainer GetResetPasswordFromJsonData(JSONObject jsonData)
	{
		StringContainer data = new StringContainer();
		
		try {			
            data.Result = jsonData.getInt("Result");
            data.Value = jsonData.getString("Value");
        } 
		catch(Exception e){}
		
		return data;
	}
	
	public void RequestUserProfileUpdate( STUserProfile userProfile, JsonHttpResponseHandler handler )
	{
		JSONStringer data = null;
		try {
			data = new JSONStringer()
			.object()
        	.key("UserProfile")
            	.object()
                	.key("ErrCode").value(userProfile.ErrCode)
                	.key("Message").value(userProfile.Message)
                	.key("Uid").value(userProfile.Uid)
                	.key("UserName").value(userProfile.UserName)
                	.key("PhoneNum").value(userProfile.PhoneNum)
                	.key("Password").value(userProfile.Password)
                	.key("Gender").value(userProfile.Gender)
                	.key("BirthYear").value(userProfile.BirthYear)
                	.key("Email").value(userProfile.Email)
                	.key("IndGender").value(userProfile.IndGender)
                	.key("GrpGender").value(userProfile.GrpGender)
                	.key("DelayTime").value(userProfile.DelayTime)
                	.key("LoginDate").value(userProfile.LoginDate)
                	.key("Credit").value(userProfile.Credit)
                	.key("StarCount").value(userProfile.StarCount)
                	.key("ImageData").value(userProfile.ImageData)
                	.key("TotalSaving").value(userProfile.TotalSaving)
                	.key("IsGroup").value(userProfile.IsGroup)
                .endObject()
           .endObject();

			StringEntity entity = new StringEntity(data.toString(), "UTF-8");
			AsyncHttpClient client = new AsyncHttpClient();
			client.setTimeout(STServiceData.connectTimeout);
			client.post(null, STServiceData.serviceAddr + STServiceData.strRequestUserProfileUpdate, 
					entity, "application/json; charset=UTF-8", handler);
		} catch (JSONException e) {
			e.printStackTrace();
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		
		return;
	}
	
	public StringContainer GetUserProfileUpdateFromJsonData(JSONObject jsonData)
	{
		StringContainer data = new StringContainer();
		
		try {			
            data.Result = jsonData.getInt("Result");
            data.Value = jsonData.getString("Value");
        } 
		catch(Exception e){}
		
		return data;
	}
		
	public void RequestPairingHistoryCount( long nID, JsonHttpResponseHandler handler )
	{
		AsyncHttpClient client = new AsyncHttpClient();
		client.setTimeout(STServiceData.connectTimeout);
		client.get(STServiceData.serviceAddr + STServiceData.strRequestPairingHistoryCount + "/" + Long.toString(nID), handler);
		
		return;
	}
	
	public STPairHistoryCount GetPairingHistoryCountFromJsonData(JSONObject jsonData)
	{
		STPairHistoryCount data = new STPairHistoryCount();
		
		try {			
            data.ErrCode = jsonData.getLong("ErrCode");
            data.Message = jsonData.getString("Message");
            data.TotalCount = jsonData.getLong("TotalCount");
            data.TotalSaving = jsonData.getDouble("TotalSaving");
        } 
		catch(Exception e){
			e.printStackTrace();
		}
		
		return data;
	}
	
	public void RequestPairingHistoryList( STReqPairHistory reqPair, JsonHttpResponseHandler handler )
	{
		JSONStringer data = null;
		try {
			data = new JSONStringer()
			.object()
        	.key("ReqHistory")
            	.object()
                	.key("Uid").value(reqPair.Uid)
                	.key("PageNo").value(reqPair.PageNo)
                .endObject()
           .endObject();

			StringEntity entity = new StringEntity(data.toString(), "UTF-8");
			AsyncHttpClient client = new AsyncHttpClient();
			client.setTimeout(STServiceData.connectTimeout);
			client.post(null, STServiceData.serviceAddr + STServiceData.strRequestPairingHistoryList, 
					entity, "application/json; charset=UTF-8", handler);
		} catch (JSONException e) {
			e.printStackTrace();
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		
		return;
	}
	
	public ArrayList<STPairHistory> GetPairingHistoryListFromJsonData(JSONArray jsonDataArr)
	{
		ArrayList<STPairHistory> vdDataArr = new ArrayList<STPairHistory>();

		try {
			for ( int i = 0; i < jsonDataArr.length(); i++ )
			{
				JSONObject jsonData = jsonDataArr.getJSONObject(i);
				
				STPairHistory pairHistory = new STPairHistory();
				pairHistory.PairingTime = jsonData.getString("PairingTime");
				pairHistory.Uid1 = jsonData.getLong("Uid1");
				pairHistory.Uid2 = jsonData.getLong("Uid2");
				pairHistory.Name1 = jsonData.getString("Name1");
				pairHistory.Name2 = jsonData.getString("Name2");
				pairHistory.SrcAddr = jsonData.getString("SrcAddr");
				pairHistory.DstAddr1 = jsonData.getString("DstAddr1");
				pairHistory.DstAddr2 = jsonData.getString("DstAddr2");
				pairHistory.SavePrice = jsonData.getDouble("SavePrice");
				pairHistory.WasteTime = jsonData.getDouble("WasteTime");
				pairHistory.OffOrder = jsonData.getInt("OffOrder");
				pairHistory.Score1 = jsonData.getDouble("Score1");
				pairHistory.Score2 = jsonData.getDouble("Score2");
				pairHistory.Gender1 = jsonData.getInt("Gender1");
				pairHistory.Gender2 = jsonData.getInt("Gender2");
				
				vdDataArr.add(pairHistory);
			}
		} catch (Exception e) {}
		
		return vdDataArr;
	}
	
	public void RequestEvaluate( STEvaluate evaluate, JsonHttpResponseHandler handler )
	{
		JSONStringer data = null;
		try {
			data = new JSONStringer()
			.object()
        	.key("Evaluate")
            	.object()
                	.key("Uid").value(evaluate.Uid)
                	.key("OppoID").value(evaluate.OppoID)
                	.key("Score").value(evaluate.Score)
                	.key("ServeTime").value(evaluate.ServeTime)
                .endObject()
           .endObject();

			StringEntity entity = new StringEntity(data.toString(), "UTF-8");
			AsyncHttpClient client = new AsyncHttpClient();
			client.setTimeout(STServiceData.connectTimeout);
			client.post(null, STServiceData.serviceAddr + STServiceData.strRequestEvaluate, 
					entity, "application/json; charset=UTF-8", handler);
		} catch (JSONException e) {
			e.printStackTrace();
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		
		return;
	}
	
	public StringContainer GetEvaluateFromJsonData(JSONObject jsonData)
	{
		StringContainer data = new StringContainer();
		
		try {			
            data.Result = jsonData.getInt("Result");
            data.Value = jsonData.getString("Value");
        } 
		catch(Exception e){
			e.printStackTrace();
		}
		
		return data;
	}
	
	public void RequestSendSMS( STSendSMS sendSMS, JsonHttpResponseHandler handler )
	{
		JSONStringer data = null;
		try {
			data = new JSONStringer()
			.object()
        	.key("SendInfo")
            	.object()
            		.key("Uid").value(sendSMS.Uid)
                	.key("PhoneNum").value(sendSMS.PhoneNum)
                .endObject()
           .endObject();

			StringEntity entity = new StringEntity(data.toString(), "UTF-8");
			AsyncHttpClient client = new AsyncHttpClient();
			client.setTimeout(STServiceData.connectTimeout);
			client.post(null, STServiceData.serviceAddr + STServiceData.strRequestSendSMS, 
					entity, "application/json; charset=UTF-8", handler);
		} catch (JSONException e) {
			e.printStackTrace();
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		
		return;
	}	
}