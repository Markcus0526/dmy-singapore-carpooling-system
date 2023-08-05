using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.ServiceModel.Web;
using System.Text;
using CarPoolService.CarPoolDB;
using CarPoolService.DBManager;

namespace CarPoolService
{
	// NOTE: You can use the "Rename" command on the "Reactor" menu to change the class name "Service1" in code, svc and config file together.

	public class Service : IService
	{
		CarPoolDBMgr _carpooldbMgr = new CarPoolDBMgr();

		public Service()
		{
			ErrManager.initErrInfos();
		}

		public string GetData(string strData)
		{
			return string.Format("<B>You entered: {0}</B>", strData);
		}

		#region interface functions
		public StringContainer RequestRegister(STUserReg NewUser)
		{
			return _carpooldbMgr.RegisterUser(NewUser);
		}

        public STLoginResult RequestIsRegistedUser(String Email)
        {
            return _carpooldbMgr.RequestIsRegistedUser(Email);
        }

		public STLoginResult RequestLogin(STAuthUser UserAuth)
		{
			return _carpooldbMgr.LoginUser(UserAuth);
		}

		public STLoginResult RequestFLLogin(STFLAuthInfo AuthInfo)
		{
			return _carpooldbMgr.FLLoginUser(AuthInfo);
		}

		public StringContainer RequestPair(STPairInfo PairInfo)
		{
			StringContainer res = null;
			try
			{
				res = _carpooldbMgr.RequestPair(PairInfo);
			}
			catch (System.Exception ex)
			{
				res = new StringContainer();
				res.Result = ErrManager.ERR_UNKNOWN;
				res.Message = ex.Message;
			}

			return res;
		}

		public STPairResponse RequestIsPaired(String Uid)
		{
			STPairResponse res = null;
			long nUid;

			try
			{
				nUid = long.Parse(Uid);
				res = _carpooldbMgr.RequestIsPaired(nUid);
			}
			catch (System.Exception ex)
			{
				res = new STPairResponse();
				res.ErrCode = ErrManager.ERR_PARAM;
				res.Message = ex.Message;
			}

			return res;
		}

		public STLoginResult TestMethod()
		{
#if false
			STFLAuthInfo flInfo = new STFLAuthInfo();

			flInfo.Name = "MingYuanDe";
			flInfo.Email = "cmspsa@gmail.com";
			flInfo.Gender = 1;
			flInfo.BirthYear = 1965;
			flInfo.PhoneNum = @"18640217389";
			flInfo.ImageData = "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";
			STLoginResult szRes = RequestFLLogin(flInfo);
#else
            String Email = "a@a.com";
			return RequestIsRegistedUser(Email);
#endif
		}

		public StringContainer RequestPairOff(String Uid)
		{
			StringContainer szRes = new StringContainer();

			try
			{
				szRes = _carpooldbMgr.RequestPairOff(long.Parse(Uid));
			}
			catch (System.Exception ex)
			{
				szRes.Result = ErrManager.ERR_UNKNOWN;
				szRes.Message = ex.Message;
			}

			return szRes;
		}

		public STUserProfile RequestUserProfile(String Uid)
		{
			STUserProfile userProfile = new STUserProfile();
			long uid = 0;

			try
			{
				uid = long.Parse(Uid);
				userProfile = _carpooldbMgr.RequestUserProfile(uid);
			}
			catch (Exception ex)
			{
				userProfile.ErrCode = ErrManager.ERR_UNKNOWN;
				userProfile.Message = ex.Message;
				CommMisc.LogErrors(ex.Message);
			}

			return userProfile;
		}

		public StringContainer RequestUserProfileUpdate(STUserProfile UserProfile)
		{
			return _carpooldbMgr.RequestUserProfileUpdate(UserProfile);
		}

		public StringContainer RequestAddTaxiStand(STTaxiStand TaxiStand)
		{
			return _carpooldbMgr.RequestAddTaxiStand(TaxiStand);
		}

		public STAgreeResponse RequestOppoAgree(String Uid)
		{
			STAgreeResponse szRes = new STAgreeResponse();
			long uid = 0;

			try
			{
				uid = long.Parse(Uid);
				szRes = _carpooldbMgr.RequestOppoAgree(uid);
			}
			catch (Exception ex)
			{
				szRes.ErrCode = ErrManager.ERR_UNKNOWN;
				szRes.Message = ex.Message;

				CommMisc.LogErrors(ex.Message);
			}

			return szRes;
		}

		public StringContainer RequestPairAgree(STPairAgree AgreeInfo)
		{
			return _carpooldbMgr.RequestPairAgree(AgreeInfo);
		}

		public int RequestUserCredits(String Uid)
		{
			int nRes = 0;
			long uid = 0;

			try
			{
				uid = long.Parse(Uid);
				nRes = _carpooldbMgr.RequestUserCredits(uid);
			}
			catch (Exception ex)
			{
				nRes = -1;
				CommMisc.LogErrors(ex.Message);
			}

			return nRes;
		}

		public StringContainer RequestSendSMS(STSendSMS SendInfo)
		{
			return _carpooldbMgr.RequestSendSMS(SendInfo);
		}

		public STPairHistory[] RequestPairingHistoryList(STReqPairHistory ReqHistory)
		{
			return _carpooldbMgr.PairingHistory(ReqHistory);
		}

		public STPairHistory[] GetPairingHistoryList(String Uid, String PageNo)
		{
			STReqPairHistory reqHistory = new STReqPairHistory();

			try
			{
				reqHistory.Uid = long.Parse(Uid);
				reqHistory.PageNo = long.Parse(PageNo);

				return _carpooldbMgr.PairingHistory(reqHistory);
			}
			catch (Exception ex)
			{
				CommMisc.LogErrors(ex.Message);
				return null;
			}
		}

		public STPairHistoryCount RequestPairingHistoryCount(String Uid)
		{
			return _carpooldbMgr.PairingCount(Uid);
		}

		public StringContainer RequestEvaluate(STEvaluate Evaluate)
		{
			return _carpooldbMgr.Evaluate(Evaluate);
		}

		public STTaxiStandResp RequestTaxiStand(STReqTaxiStand ReqTaxiStand)
		{
			return _carpooldbMgr.GetTaxiStand(ReqTaxiStand);
		}

		public STTaxiStand[] RequestTaxiStandList(STReqTaxiStand ReqTaxiStand)
		{
			return _carpooldbMgr.GetTaxiStandList(ReqTaxiStand);
		}
		
		public STTaxiStand[] GetDestList(String DestName, String PageNo)
        {
			try
			{
				int nPageNo = int.Parse(PageNo);
				return _carpooldbMgr.GetDestList(DestName, nPageNo);
			}
			catch (System.Exception ex)
			{
				return null;
			}
        }
		
		public StringContainer RequestResetPassword(STReqResetPassword ResetPassword)
		{
			return _carpooldbMgr.ResetPassword(ResetPassword.Email);
		}

		public int GetSharable(String Uid)
		{
			try
			{
				long uid = long.Parse(Uid);
				return _carpooldbMgr.GetSharable(uid);
			}
			catch (System.Exception ex)
			{
				CommMisc.LogErrors(ex.Message);
				return -1;
			}
		}

		public void RequestShareLog(STShareLog ShareLog)
		{
			_carpooldbMgr.RequestShareLog(ShareLog);
		}

		public StringContainer PairIsNext(String Uid)
		{
			return _carpooldbMgr.PairIsNext(Uid);
		}

		public StringContainer SetNextTurn(String Uid)
		{
            try
            {
                return _carpooldbMgr.SetNextTurn(Uid);
            }
            catch (Exception ex)
            {
                StringContainer szRes = new StringContainer();
                szRes.Message = "Service.svc.cs";
                return szRes;
            }
		}

		#endregion


		public StringContainer PayResult(String Uid, String Price)
		{
			return _carpooldbMgr.PayResult(Uid, Price);
		}

		public StringContainer IsValidUser(STAuthUser LoginInfo)
		{
			return _carpooldbMgr.IsValidUser(LoginInfo);
		}


		public void SendAlive()
		{
			_carpooldbMgr.SendAlive();
		}
	}
}
