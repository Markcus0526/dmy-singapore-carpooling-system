using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data.SqlClient;
using CarPoolService.DBManager;
using CarPoolService.CarPoolDB;

namespace CarPoolService.CarPoolDB
{
	public class CarPoolDBMgr
	{
		#region Fields and Properties

		/*public CarPoolDBDataContext _dbcontext = new CarPoolDBDataContext();*/

		DBUserInfo _dbUserInfo = new DBUserInfo();
		DBTaxiStand _dbTaxiStand = new DBTaxiStand();
		DBQueue _dbQueue = new DBQueue();
		DBServeInfo _dbServeInfo = new DBServeInfo();

		#endregion

		#region Constructors
		public CarPoolDBMgr() {}
		#endregion

		#region Public Methods

		/// <summary>
		/// Check if the CarNo is already registered or not
		/// </summary>
		/// <param name="carNo">CarNo</param>
		/// <returns>Success Result</returns>

		public STLoginResult LoginUser(STAuthUser authUser)
		{
			return _dbUserInfo.LoginUser(authUser);
		}

		public STLoginResult FLLoginUser(STFLAuthInfo authInfo)
		{
			return _dbUserInfo.FLLoginUser(authInfo);
		}

		public StringContainer RegisterUser( STUserReg userInfo )
		{
			return _dbUserInfo.RegisterUser(userInfo );
		}

        public STLoginResult RequestIsRegistedUser(String Email)
        {
            return _dbUserInfo.RequestIsRegistedUser(Email);
        }

		public StringContainer RequestPair(STPairInfo PairInfo)
		{
			return _dbUserInfo.RequestPair(PairInfo);
		}

		public STPairResponse RequestIsPaired(long nUid)
		{
			return _dbUserInfo.RequestIsPaired(nUid);
		}

		public StringContainer RequestPairOff(long Uid)
		{
			return _dbUserInfo.RequestPairOff(Uid);
		}

		public StringContainer RequestPairAgree(STPairAgree agreeInfo)
		{
			return _dbUserInfo.RequestPairAgree(agreeInfo);
		}

		public int RequestUserCredits(long uid)
		{
			return _dbUserInfo.RequestUserCredits(uid);
		}

		public STUserProfile RequestUserProfile(long uid)
		{
			return _dbUserInfo.RequestUserProfile(uid);
		}

		public StringContainer RequestUserProfileUpdate(STUserProfile userProfile)
		{
			return _dbUserInfo.RequestUserProfileUpdate(userProfile);
		}

		public StringContainer RequestAddTaxiStand(STTaxiStand taxiStand)
		{
			return _dbTaxiStand.RequestAddTaxiStand(taxiStand);
		}

		public STAgreeResponse RequestOppoAgree(long uid)
		{
			return _dbQueue.RequestOppoAgree(uid);
		}

		public StringContainer IsValidUser(STAuthUser logInfo)
		{
			return _dbUserInfo.IsValidUser(logInfo.Email, true);
		}

		public STPairHistory[] PairingHistory(STReqPairHistory history_req)
		{
			return _dbUserInfo.PairingHistory(history_req);
		}

		public STPairHistoryCount PairingCount(String uid)
		{
			return _dbUserInfo.PairingHistoryCount(uid);
		}

		public StringContainer Evaluate(STEvaluate evaluate)
		{
			return _dbUserInfo.Evaluate(evaluate);
		}

		public STTaxiStandResp GetTaxiStand(STReqTaxiStand userPosInfo)
		{
			return _dbUserInfo.GetTaxiStand(userPosInfo);
		}

		public STTaxiStand[] GetTaxiStandList(STReqTaxiStand userPosInfo)
		{
			return _dbUserInfo.GetTaxiStandList(userPosInfo);
		}

        public STTaxiStand[] GetDestList(String DestName, int pageNo)
        {
            return _dbTaxiStand.GetDestList(DestName, pageNo);
        }

		public StringContainer RequestSendSMS(STSendSMS sendInfo)
		{
			return _dbUserInfo.RequestSendSMS(sendInfo);
		}

		public StringContainer ResetPassword(String email)
		{
			return _dbUserInfo.ResetPassword(email);
		}

		public void RequestShareLog(STShareLog ShareLog)
		{
			_dbUserInfo.RequestShareLog(ShareLog);
		}

		public StringContainer PairIsNext(String Uid)
		{
			return _dbUserInfo.PairIsNext(Uid);
		}

		public StringContainer SetNextTurn(String Uid)
		{
            try
			{
                return _dbUserInfo.SetNextTurn(Uid);
            }
            catch (Exception ex)
            {
                StringContainer szRes = new StringContainer();
                szRes.Message = "CarPoolDBMgr.cs";
                return szRes;
            }
		}

		public StringContainer PayResult(String Uid, String Price)
		{
			return _dbUserInfo.PayResult(Uid, Price);
		}

		public int GetSharable(long uid)
		{
			return _dbUserInfo.GetSharable(uid);
		}

		public void SendAlive()
		{
			_dbUserInfo.SendAlive();
		}

		#endregion



		#region Private Methods
		#endregion
	}
}