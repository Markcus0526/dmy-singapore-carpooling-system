package com.CommService;

import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONObject;

import com.HttpConn.AsyncHttpResponseHandler;
import com.HttpConn.JsonHttpResponseHandler;
import com.STData.STAgreeResponse;
import com.STData.STAuthUser;
import com.STData.STEvaluate;
import com.STData.STFLAuthInfo;
import com.STData.STLoginResult;
import com.STData.STPairAgree;
import com.STData.STPairHistory;
import com.STData.STPairHistoryCount;
import com.STData.STPairInfo;
import com.STData.STPairResponse;
import com.STData.STReqPairHistory;
import com.STData.STReqTaxiStand;
import com.STData.STResetPassword;
import com.STData.STSendSMS;
import com.STData.STShareLog;
import com.STData.STTaxiStand;
import com.STData.STTaxiStandResp;
import com.STData.STUserProfile;
import com.STData.StringContainer;
import com.STData.STUserReg;

public class CommMgr {
	
	public static CommMgr commService = new CommMgr();

	UserManage userManage = new UserManage();
	PairManage pairManage = new PairManage();
	
	public CommMgr()
	{		
	}
	
	public void RequestUserRegister( STUserReg userReg, JsonHttpResponseHandler handler )
	{
		userManage.RequestUserRegister( userReg, handler );
	}
	
	public StringContainer GetUserRegisterFromJsonData(JSONObject jsonData)
	{
		return userManage.GetUserRegisterFromJsonData(jsonData);
	}
	
	public void RequestIsRegistedUser( String Email, JsonHttpResponseHandler handler )
	{
		userManage.RequestIsRegistedUser( Email, handler );
	}
	
	public STLoginResult GetIsRegistedUserFromJsonData(JSONObject jsonData)
	{
		return userManage.GetIsRegistedUserFromJsonData(jsonData);
	}
	
	public void RequestUserLogin( STAuthUser userAuth, JsonHttpResponseHandler handler )
	{
		userManage.RequestUserLogin(userAuth, handler);
	}
	
	public STLoginResult GetUserLoginFromJsonData(JSONObject jsonData)
	{
		return userManage.GetUserLoginFromJsonData(jsonData);
	}
	
	public void RequestFLLogin( STFLAuthInfo userAuth, JsonHttpResponseHandler handler )
	{
		userManage.RequestFLLogin(userAuth, handler);
	}
	
	public STLoginResult GetFLLoginFromJsonData(JSONObject jsonData)
	{
		return userManage.GetFLLoginFromJsonData(jsonData);
	}
	
	public void RequestUserCredits(String Uid, AsyncHttpResponseHandler handler)
	{
		userManage.RequestUserCredits(Uid, handler);
	}
	
	public int GetUserCreditsFromJsonData(String strData)
	{
		return userManage.GetUserCreditsFromJsonData(strData);
	}
	
	public void GetSharable(String Uid, AsyncHttpResponseHandler handler)
	{
		userManage.GetSharable(Uid, handler);
	}
	
	public int GetSharableFromJsonData(String strData)
	{
		return userManage.GetSharableFromJsonData(strData);
	}
	
	public void RequestShareLog(STShareLog shareLog, JsonHttpResponseHandler handler)
	{
		userManage.RequestShareLog(shareLog, handler);
	}
	
	public void RequestUserProfile(String Uid, JsonHttpResponseHandler handler)
	{
		userManage.RequestUserProfile(Uid, handler);
	}
	
	public STUserProfile GetUserProfileFromJsonData(JSONObject jsonData)
	{
		return userManage.GetUserProfileFromJsonData(jsonData);
	}
	
	public void RequestUserProfileUpdate( STUserProfile userProfile, JsonHttpResponseHandler handler )
	{
		userManage.RequestUserProfileUpdate(userProfile, handler);
	}
	
	public StringContainer GetUserProfileUpdateFromJsonData(JSONObject jsonData)
	{
		return userManage.GetUserProfileUpdateFromJsonData(jsonData);
	}
	
	public void RequestResetPassword( STResetPassword resetPassword, JsonHttpResponseHandler handler )
	{
		userManage.RequestResetPassword(resetPassword, handler);
	}
	
	public StringContainer GetResetPasswordFromJsonData(JSONObject jsonData)
	{
		return userManage.GetResetPasswordFromJsonData(jsonData);
	}
	
	public void RequestSendSMS( STSendSMS sendSMS, JsonHttpResponseHandler handler )
	{
		userManage.RequestSendSMS(sendSMS, handler);
	}
	
	public void RequestPairingHistoryCount( long nID, JsonHttpResponseHandler handler )
	{
		userManage.RequestPairingHistoryCount(nID, handler);
	}
	
	public STPairHistoryCount GetPairingHistoryCountFromJsonData(JSONObject jsonData)
	{
		return userManage.GetPairingHistoryCountFromJsonData(jsonData);
	}
	
	public void RequestPairingHistoryList( STReqPairHistory reqPair, JsonHttpResponseHandler handler )
	{
		userManage.RequestPairingHistoryList(reqPair, handler);
	}
	
	public ArrayList<STPairHistory> GetPairingHistoryListFromJsonData(JSONArray jsonDataArr)
	{
		return userManage.GetPairingHistoryListFromJsonData(jsonDataArr);
	}
	
	public void RequestEvaluate( STEvaluate evaluate, JsonHttpResponseHandler handler )
	{
		userManage.RequestEvaluate(evaluate, handler);
	}
	
	public StringContainer GetEvaluateFromJsonData(JSONObject jsonData)
	{
		return userManage.GetEvaluateFromJsonData(jsonData);
	}
	
	public void GetDestList(String DestName, int PageNo, JsonHttpResponseHandler handler)
	{
		userManage.GetDestList(DestName, PageNo, handler);
	}
	
	public ArrayList<STTaxiStand> GetDestListFromJsonData(JSONArray jsonArr)
	{
		return userManage.GetDestListFromJsonData(jsonArr);
	}
	
	public void RequestPair( STPairInfo PairInfo, JsonHttpResponseHandler handler )
	{
		pairManage.RequestPair(PairInfo, handler);
	}
	
	public StringContainer GetRequestPairFromJsonData(JSONObject jsonData)
	{
		return pairManage.GetRequestPairFromJsonData(jsonData);
	}
	
	public void RequestPairAgree( STPairAgree AgreeInfo, JsonHttpResponseHandler handler )
	{
		pairManage.RequestPairAgree(AgreeInfo, handler);
	}
	
	public StringContainer GetPairAgreeFromJsonData(JSONObject jsonData)
	{
		return pairManage.GetPairAgreeFromJsonData(jsonData);
	}
	
	public void RequestAddTaxiStand( STTaxiStand TaxiStand, JsonHttpResponseHandler handler )
	{
		pairManage.RequestAddTaxiStand(TaxiStand, handler);
	}
	
	public StringContainer GetAddTaxiStandFromJsonData(JSONObject jsonData)
	{
		return pairManage.GetAddTaxiStandFromJsonData(jsonData);
	}
	
	public void RequestTaxiStand( STReqTaxiStand reqTaxiStand, JsonHttpResponseHandler handler )
	{
		pairManage.RequestTaxiStand(reqTaxiStand, handler);
	}
	
	public STTaxiStandResp GetTaxiStandFromJsonData(JSONObject jsonData)
	{
		return pairManage.GetTaxiStandFromJsonData(jsonData);
	}
	
	public void RequestTaxiStandList(STReqTaxiStand reqTaxiStand, JsonHttpResponseHandler handler )
	{
		pairManage.RequestTaxiStandList(reqTaxiStand, handler);
	}
	
	public ArrayList<STTaxiStand> getTaxiStandListFromJsonData(JSONArray jsonArr)
	{
		return pairManage.GetTaxiStandListFromJsonData(jsonArr);
	}
	
	public void RequestIsPaired(long Uid, JsonHttpResponseHandler handler)
	{
		pairManage.RequestIsPaired(Uid, handler);
	}
	
	public STPairResponse GetIsPairedFromJsonData(JSONObject jsonData)
	{
		return pairManage.GetIsPairedFromJsonData(jsonData);
	}
	
	public void RequestPairOff(long Uid, JsonHttpResponseHandler handler)
	{
		pairManage.RequestPairOff(Uid, handler);
	}
	
	public StringContainer GetPairOffFromJsonData(JSONObject jsonData)
	{
		return pairManage.GetPairOffFromJsonData(jsonData);
	}
	
	public void RequestOppoAgree(long Uid, JsonHttpResponseHandler handler)
	{
		pairManage.RequestOppoAgree(Uid, handler);
	}
	
	public STAgreeResponse GetOppoAgreeFromJsonData(JSONObject jsonData)
	{
		return pairManage.GetOppoAgreeFromJsonData(jsonData);
	}
	
	public void RequestPairIsNext(String Uid, JsonHttpResponseHandler handler)
	{
		pairManage.RequestPairIsNext(Uid, handler);
	}
	
	public StringContainer GetPairIsNextFromJsonData(JSONObject jsonData)
	{
		return pairManage.GetPairIsNextFromJsonData(jsonData);
	}
	
	public void RequestSetNextTurn(String Uid, JsonHttpResponseHandler handler)
	{
		pairManage.RequestSetNextTurn(Uid, handler);
	}
	
	public StringContainer GetSetNextTurnFromJsonData(JSONObject jsonData)
	{
		return pairManage.GetSetNextTurnFromJsonData(jsonData);
	}
}
