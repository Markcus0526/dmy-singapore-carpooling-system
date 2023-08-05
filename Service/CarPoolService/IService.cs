using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.ServiceModel.Web;
using System.Text;
using CarPoolService.DBManager;

namespace CarPoolService
{
    // NOTE: You can use the "Rename" command on the "Refactor" menu to change the interface name "IService1" in both code and config file together.
    [ServiceContract]
    public interface IService
    {
        [OperationContract]
        [WebGet(UriTemplate = "GetData/{strData}",
            BodyStyle = WebMessageBodyStyle.WrappedRequest,
            ResponseFormat = WebMessageFormat.Json,
            RequestFormat = WebMessageFormat.Json)]
        string GetData(string strData);

		[OperationContract]
		[WebInvoke(UriTemplate = "RequestRegister",
            Method = "POST", 
            BodyStyle = WebMessageBodyStyle.WrappedRequest,
            RequestFormat = WebMessageFormat.Json, 
            ResponseFormat = WebMessageFormat.Json)]
		StringContainer RequestRegister(STUserReg NewUser);

        [OperationContract]
        [WebInvoke(UriTemplate = "RequestIsRegistedUser",
            Method = "POST",
            BodyStyle = WebMessageBodyStyle.WrappedRequest,
            RequestFormat = WebMessageFormat.Json,
            ResponseFormat = WebMessageFormat.Json)]
        STLoginResult RequestIsRegistedUser(String Email);

		[OperationContract]
        [WebInvoke(UriTemplate = "IsValidUser",
            Method = "POST",
            BodyStyle = WebMessageBodyStyle.WrappedRequest,
            RequestFormat = WebMessageFormat.Json,
            ResponseFormat = WebMessageFormat.Json)]
        StringContainer IsValidUser(STAuthUser LoginInfo);

		[OperationContract]
		[WebInvoke(UriTemplate = "RequestLogin",
			Method = "POST",
			BodyStyle = WebMessageBodyStyle.WrappedRequest,
			RequestFormat = WebMessageFormat.Json,
			ResponseFormat = WebMessageFormat.Json)]
		STLoginResult RequestLogin(STAuthUser UserAuth);

		[OperationContract]
		[WebInvoke(UriTemplate = "RequestFLLogin",
			Method = "POST",
			BodyStyle = WebMessageBodyStyle.WrappedRequest,
			RequestFormat = WebMessageFormat.Json,
			ResponseFormat = WebMessageFormat.Json)]
		STLoginResult RequestFLLogin(STFLAuthInfo AuthInfo);

		[OperationContract]
		[WebInvoke(UriTemplate = "RequestPair",
			Method = "POST",
			BodyStyle = WebMessageBodyStyle.WrappedRequest,
			RequestFormat = WebMessageFormat.Json,
			ResponseFormat = WebMessageFormat.Json)]
		StringContainer RequestPair(STPairInfo PairInfo);

		[OperationContract]
		[WebGet(UriTemplate = "RequestIsPaired/{Uid}",
			BodyStyle = WebMessageBodyStyle.WrappedRequest,
			RequestFormat = WebMessageFormat.Json,
			ResponseFormat = WebMessageFormat.Json)]
		STPairResponse RequestIsPaired(String Uid);

		[OperationContract]
		[WebInvoke(UriTemplate = "RequestPairingHistoryList",
			Method = "POST",
			BodyStyle = WebMessageBodyStyle.WrappedRequest,
			RequestFormat = WebMessageFormat.Json,
			ResponseFormat = WebMessageFormat.Json)]
		STPairHistory[] RequestPairingHistoryList(STReqPairHistory ReqHistory);

		[OperationContract]
		[WebGet(UriTemplate = "GetPairingHistoryList/{Uid}/{PageNo}",
			BodyStyle = WebMessageBodyStyle.WrappedRequest,
			RequestFormat = WebMessageFormat.Json,
			ResponseFormat = WebMessageFormat.Json)]
		STPairHistory[] GetPairingHistoryList(String Uid, String PageNo);

		[OperationContract]
		[WebGet(UriTemplate = "RequestPairingHistoryCount/{Uid}",
			BodyStyle = WebMessageBodyStyle.WrappedRequest,
			RequestFormat = WebMessageFormat.Json,
			ResponseFormat = WebMessageFormat.Json)]
		STPairHistoryCount RequestPairingHistoryCount(String Uid);

		[OperationContract]
		[WebInvoke(UriTemplate = "RequestEvaluate",
			Method = "POST",
			BodyStyle = WebMessageBodyStyle.WrappedRequest,
			RequestFormat = WebMessageFormat.Json,
			ResponseFormat = WebMessageFormat.Json)]
		StringContainer RequestEvaluate(STEvaluate Evaluate);

		[OperationContract]
		[WebInvoke(UriTemplate = "RequestTaxiStand",
			Method = "POST",
			BodyStyle = WebMessageBodyStyle.WrappedRequest,
			RequestFormat = WebMessageFormat.Json,
			ResponseFormat = WebMessageFormat.Json)]
		STTaxiStandResp RequestTaxiStand(STReqTaxiStand ReqTaxiStand);

		[OperationContract]
		[WebInvoke(UriTemplate = "RequestTaxiStandList",
			Method = "POST",
			BodyStyle = WebMessageBodyStyle.WrappedRequest,
			RequestFormat = WebMessageFormat.Json,
			ResponseFormat = WebMessageFormat.Json)]
		STTaxiStand[] RequestTaxiStandList(STReqTaxiStand ReqTaxiStand);

        [OperationContract]
        [WebGet(UriTemplate = "GetDestList/{DestName}/{PageNo}",
            BodyStyle = WebMessageBodyStyle.WrappedRequest,
            RequestFormat = WebMessageFormat.Json,
            ResponseFormat = WebMessageFormat.Json)]
        STTaxiStand[] GetDestList(String DestName, String PageNo);

		[OperationContract]
		[WebInvoke(UriTemplate = "RequestResetPassword",
			Method = "POST",
			BodyStyle = WebMessageBodyStyle.WrappedRequest,
			RequestFormat = WebMessageFormat.Json,
			ResponseFormat = WebMessageFormat.Json)]
		StringContainer RequestResetPassword(STReqResetPassword ResetPassword);

#if true
		[OperationContract]
		[WebGet(UriTemplate = "TestMethod",
			BodyStyle = WebMessageBodyStyle.WrappedRequest,
			RequestFormat = WebMessageFormat.Json,
			ResponseFormat = WebMessageFormat.Json)]
		STLoginResult TestMethod();
#endif


		[OperationContract]
		[WebGet(UriTemplate = "RequestPairOff/{Uid}",
			BodyStyle = WebMessageBodyStyle.WrappedRequest,
			RequestFormat = WebMessageFormat.Json,
			ResponseFormat = WebMessageFormat.Json)]
		StringContainer RequestPairOff(String Uid);

		[OperationContract]
		[WebGet(UriTemplate = "RequestUserProfile/{Uid}",
			BodyStyle = WebMessageBodyStyle.WrappedRequest,
			RequestFormat = WebMessageFormat.Json,
			ResponseFormat = WebMessageFormat.Json)]
		STUserProfile RequestUserProfile(String Uid);

		[OperationContract]
		[WebInvoke(UriTemplate = "RequestUserProfileUpdate",
			Method = "POST",
			BodyStyle = WebMessageBodyStyle.WrappedRequest,
			RequestFormat = WebMessageFormat.Json,
			ResponseFormat = WebMessageFormat.Json)]
		StringContainer RequestUserProfileUpdate(STUserProfile UserProfile);

		[OperationContract]
		[WebInvoke(UriTemplate = "RequestAddTaxiStand",
			Method = "POST",
			BodyStyle = WebMessageBodyStyle.WrappedRequest,
			RequestFormat = WebMessageFormat.Json,
			ResponseFormat = WebMessageFormat.Json)]
		StringContainer RequestAddTaxiStand(STTaxiStand TaxiStand);

		[OperationContract]
		[WebGet(UriTemplate = "RequestOppoAgree/{Uid}",
			BodyStyle = WebMessageBodyStyle.WrappedRequest,
			RequestFormat = WebMessageFormat.Json,
			ResponseFormat = WebMessageFormat.Json)]
		STAgreeResponse RequestOppoAgree(String Uid);

		[OperationContract]
		[WebInvoke(UriTemplate = "RequestPairAgree",
			Method = "POST",
			BodyStyle = WebMessageBodyStyle.WrappedRequest,
			RequestFormat = WebMessageFormat.Json,
			ResponseFormat = WebMessageFormat.Json)]
		StringContainer RequestPairAgree(STPairAgree AgreeInfo);

		[OperationContract]
		[WebGet(UriTemplate = "RequestUserCredits/{Uid}",
			BodyStyle = WebMessageBodyStyle.WrappedRequest,
			RequestFormat = WebMessageFormat.Json,
			ResponseFormat = WebMessageFormat.Json)]
		int RequestUserCredits(String Uid);

		[OperationContract]
		[WebInvoke(UriTemplate = "RequestSendSMS",
			Method = "POST",
			BodyStyle = WebMessageBodyStyle.WrappedRequest,
			RequestFormat = WebMessageFormat.Json,
			ResponseFormat = WebMessageFormat.Json)]
		StringContainer RequestSendSMS(STSendSMS SendInfo);

		[OperationContract]
		[WebGet(UriTemplate = "GetSharable/{Uid}",
			BodyStyle = WebMessageBodyStyle.WrappedRequest,
			RequestFormat = WebMessageFormat.Json,
			ResponseFormat = WebMessageFormat.Json)]
		int GetSharable(String Uid);

		[OperationContract]
		[WebInvoke(UriTemplate = "RequestShareLog",
			Method = "POST",
			BodyStyle = WebMessageBodyStyle.WrappedRequest,
			RequestFormat = WebMessageFormat.Json,
			ResponseFormat = WebMessageFormat.Json)]
		void RequestShareLog(STShareLog ShareLog);

		[OperationContract]
		[WebGet(UriTemplate = "PairIsNext/{Uid}",
			BodyStyle = WebMessageBodyStyle.WrappedRequest,
			RequestFormat = WebMessageFormat.Json,
			ResponseFormat = WebMessageFormat.Json)]
		StringContainer PairIsNext(String Uid);

		[OperationContract]
		[WebGet(UriTemplate = "SetNextTurn/{Uid}",
			BodyStyle = WebMessageBodyStyle.WrappedRequest,
			RequestFormat = WebMessageFormat.Json,
			ResponseFormat = WebMessageFormat.Json)]
		StringContainer SetNextTurn(String Uid);

		[OperationContract]
		[WebGet(UriTemplate = "PayResult/{Uid}/{Price}",
			BodyStyle = WebMessageBodyStyle.WrappedRequest,
			RequestFormat = WebMessageFormat.Json,
			ResponseFormat = WebMessageFormat.Json)]
		StringContainer PayResult(String Uid, String Price);

		#region API_COMMON
        [OperationContract]
        [WebGet(UriTemplate = "SendAlive",
            BodyStyle = WebMessageBodyStyle.WrappedRequest,
            ResponseFormat = WebMessageFormat.Json,
            RequestFormat = WebMessageFormat.Json)]
        void SendAlive();
        #endregion
    }
}
    