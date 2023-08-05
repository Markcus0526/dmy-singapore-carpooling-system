package com.STData;

public class STServiceData {
	// Service Addr	
	//public static String serviceAddr = "http://192.168.1.46:5000/Service.svc/";
	//public static String serviceAddr = "http://218.25.54.28:5041/Service.svc/";
	public static String serviceAddr = "http://218.25.54.28:10011/Service.svc/";
	
	// User Manage Command	
	public final static String strRequestRegister = "RequestRegister";
	public final static String strRequestIsRegistedUser = "RequestIsRegistedUser";
	public final static String strRequestLogin = "RequestLogin";
	public final static String strRequestFLLogin = "RequestFLLogin";
	public final static String strRequestUserCredits = "RequestUserCredits";
	public final static String strGetSharable = "GetSharable";
	public final static String strRequestShareLog = "RequestShareLog";
	public final static String strRequestUserProfile = "RequestUserProfile";
	public final static String strRequestUserProfileUpdate = "RequestUserProfileUpdate";
	public final static String strRequestResetPassword = "RequestResetPassword";
	public final static String strRequestPairingHistoryCount = "RequestPairingHistoryCount";
	public final static String strRequestPairingHistoryList = "RequestPairingHistoryList";
	public final static String strGetPairingHistoryList = "GetPairingHistoryList";
	public final static String strRequestEvaluate = "RequestEvaluate";
	public final static String strRequestSendSMS = "RequestSendSMS";
	public final static String strGetDestList = "GetDestList";
	
	
	// Pair Information Command
	public final static String strRequestPair = "RequestPair";
	public final static String strRequestIsPaired = "RequestIsPaired";
	public final static String strRequestPairAgree ="RequestPairAgree";
	public final static String strRequestAddTaxiStand = "RequestAddTaxiStand";
	public final static String strRequestTaxiStand = "RequestTaxiStand";
	public final static String strRequestTaxiStandList = "RequestTaxiStandList";
	public final static String strRequestPairOff = "RequestPairOff";
	public final static String strRequestOppoAgree = "RequestOppoAgree";
	public final static String strRequestPairIsNext = "PairIsNext";
	public final static String strRequestSetNextTurn = "SetNextTurn";
	
	// Connection Info
	public static int connectTimeout = 4 * 1000; // 5 Seconds
	public static int emailTimeout = 19 * 1000; // 20 Seconds
}
