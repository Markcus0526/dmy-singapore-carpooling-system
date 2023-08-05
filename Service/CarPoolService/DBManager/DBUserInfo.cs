using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Runtime.Serialization;
using CarPoolService.CarPoolDB;
using System.ServiceModel;
using System.Net;
using System.Xml.Linq;
using System.Diagnostics;

namespace CarPoolService.DBManager
{
	public class DBUserInfo
	{
		#region Field and Properties
		#endregion

		#region Constructor
		public DBUserInfo()
		{

		}
		#endregion

		public const int PASSLEN = 6;

		#region Public_Methods
		/// <summary>
		/// Get all announcement record data
		/// </summary>
		/// <param name="context">Database context</param>
		/// <param name="annRecordData">Result list of announcement record datas</param>
		/// <returns>Result state</returns>
		public StringContainer RegisterUser(STUserReg userInfo)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			StringContainer szRes = new StringContainer();

			try
			{
				if (userInfo == null)
				{
					szRes.Result = ErrManager.ERR_PARAM_NAME;
					szRes.Message = ErrManager.code2Msg(szRes.Result);
				}
				else
				{
					String strPhoneNumber = userInfo.PhoneNum;
					String szQuery = String.Empty, szPath = String.Empty;
					STAuthUser authUser = new STAuthUser();
					StringContainer exist = null;
					int resultCnt = 0;

					authUser.Email = userInfo.Email;

					exist = IsValidUser(authUser.Email, true);

					if (exist.Result > 0)
					{
						szRes.Result = ErrManager.ERR_USER_EXIST;
						szRes.Message = ErrManager.code2Msg(ErrManager.ERR_USER_EXIST);
					}
					else
					{
						if (DateTime.Now.Year - userInfo.BirthYear < 0 ||
							DateTime.Now.Year - userInfo.BirthYear > 100)
						{
							szRes.Result = ErrManager.ERR_PARAM;
							szRes.Message = ErrManager.code2Msg(szRes.Result);
						}
						else
						{
							if (userInfo.ImageData != String.Empty)
								szPath = Global.SaveImage(String.Empty, userInfo.ImageData);

							szQuery = "INSERT INTO tbl_user (name, password, gender, birthyear, phone_number, email_address, credits, total_savings, regist_date, is_grouping, ind_gender, grp_gender, delay_time, image_path, deleted) values(N'"
								+ userInfo.UserName + "', '"
								+ userInfo.Password + "', '"
								+ userInfo.Gender + "', '"
								+ userInfo.BirthYear + "', '"
								+ userInfo.PhoneNum + "', '"
								+ userInfo.Email + "',"
								+ "'5', '0', '"
								+ Global.DateTime2String(DateTime.Now, true, true, false, false) + "'"
								+ ",1,"
								+ userInfo.IndGender + ", "
								+ userInfo.GrpGender + ", "
								+ userInfo.DelayTime + ", '"
								+ szPath + "', 0)";

							resultCnt = dbContext.ExecuteCommand(szQuery);
							if (resultCnt == 1)
							{
								StringContainer szTemp = Global.IsReservedUser(userInfo.PhoneNum);
								if (szTemp.Result > 0)
								{
									Global.changeUserCredits(szTemp.Result, 2);
									Global.updateSMSLogValidState(szTemp.Result);
								}

								szRes.Result = ErrManager.ERR_NONE;
								szRes.Message = ErrManager.code2Msg(szRes.Result);
							}
							else
							{
								szRes.Result = ErrManager.ERR_REG_FAILED;
								szRes.Message = "Query = " + szQuery + "   :   " + ErrManager.code2Msg(ErrManager.ERR_REG_FAILED);
							}
						}
					}
				}
			}
			catch (System.Exception ex)
			{
				CommMisc.LogErrors(ex.ToString());

				szRes.Result = ErrManager.ERR_FAILURE;
				szRes.Message = "Exception : " + ex.Message;
			}

			return szRes;
		}

        public STLoginResult RequestIsRegistedUser(String Email)
        {
            CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
            STLoginResult szResult = new STLoginResult();
            String szQuery = String.Empty;
            long nUid = 0;

            szResult.Name = String.Empty;

            try
            {
                if (Email == null || Email.Length < 1)
                {
                    szResult.ResultCode = ErrManager.ERR_PARAM_NAME;
                    szResult.Message = ErrManager.code2Msg(ErrManager.ERR_PARAM_NAME);
                }
                else
                {
                    nUid = IsValidUser(Email, true).Result;

                    if (nUid <= 0)
                    {
                        szResult.ResultCode = ErrManager.ERR_INVALID_USER;
                        szResult.Message = ErrManager.code2Msg(ErrManager.ERR_INVALID_USER);
                    }
                    else
                    {
                        if (!isValidFLUser(nUid))
                        {
                            szResult.ResultCode = ErrManager.ERR_INVALID_USER;
                            szResult.Name = String.Empty;
                            szResult.Message = ErrManager.code2Msg(szResult.ResultCode);
                        }
                        else
                        {
                            Global.updateLoginTime(nUid, DateTime.Now);
                            szResult.ResultCode = nUid;
                            szResult.Name = Global.getUserNameFromUid(nUid);
                            szResult.Message = ErrManager.code2Msg(ErrManager.ERR_NONE);
                            szResult.FirstLogin = 0;
                        }
                    }
                }
            }
            catch (System.Exception ex)
            {
                CommMisc.LogErrors(ex.Message);

                szResult.ResultCode = ErrManager.ERR_FAILURE;
                szResult.Message = ex.Message;
            }

            return szResult;
        }

		public STLoginResult LoginUser(STAuthUser userInfo)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			STLoginResult szResult = new STLoginResult();

			szResult.Name = String.Empty;

			try
			{
				if (userInfo == null)
				{
					szResult.ResultCode = ErrManager.ERR_PARAM_NAME;
					szResult.Message = ErrManager.code2Msg(ErrManager.ERR_PARAM_NAME);
				}
				else
				{
					String szQuery = String.Empty;

					szQuery = "SELECT * FROM tbl_user WHERE password = '" + userInfo.Password +
							"' AND email_address = '" + userInfo.Email +
							"' AND deleted = 0";

					IEnumerable<tbl_user> resultEnums = dbContext.ExecuteQuery<tbl_user>(szQuery);
					IList<tbl_user> resultList = resultEnums.ToList();

					if (resultList.Count != 1)
					{
						szResult.ResultCode = ErrManager.ERR_LOGIN_FAILED;
						szResult.Message = ErrManager.code2Msg(szResult.ResultCode);
					}
					else
					{
						bool bFirst = (resultList[0].last_login_date == null);
						Global.updateLoginTime(resultList[0].uid, DateTime.Now);

						szResult.ResultCode = resultList[0].uid;
						szResult.Message = ErrManager.code2Msg(ErrManager.ERR_NONE);
						szResult.Name = resultList[0].name;
						szResult.FirstLogin = bFirst ? 1 : 0;
					}
				}
			}
			catch (System.Exception ex)
			{
				CommMisc.LogErrors(ex.Message);

				szResult.ResultCode = ErrManager.ERR_FAILURE;
				szResult.Message = ex.Message;
			}

			return szResult;
		}

		public STLoginResult FLLoginUser(STFLAuthInfo authInfo)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			STLoginResult szResult = new STLoginResult();
			String szQuery = String.Empty;
			STUserReg regInfo = new STUserReg();
			StringContainer szRes = new StringContainer(), szTemp = null;
			STAuthUser authUser = new STAuthUser();
			long nUid = 0;

			szResult.Name = String.Empty;

			try
			{
				if (authInfo == null)
				{
					szResult.ResultCode = ErrManager.ERR_PARAM_NAME;
					szResult.Message = ErrManager.code2Msg(ErrManager.ERR_PARAM_NAME);
				}
				else
				{
					nUid = IsValidUser(authInfo.Email, true).Result;

					if (nUid <= 0)
					{
						regInfo.UserName = authInfo.Name;
						regInfo.PhoneNum = authInfo.PhoneNum;
						regInfo.Password = String.Empty;
						regInfo.Gender = authInfo.Gender;
						regInfo.BirthYear = authInfo.BirthYear;
						regInfo.Email = authInfo.Email;
						regInfo.IndGender = 0;
						regInfo.GrpGender = 5;
						regInfo.DelayTime = 10;
						regInfo.ImageData = authInfo.ImageData;

						szRes = RegisterUser(regInfo);

						authUser.Email = regInfo.Email;
						authUser.Password = regInfo.Password;
						szTemp = Global.getUserIDFromAuth(authUser);

						szResult.ResultCode = szTemp.Result;
						szResult.Message = szRes.Message;
						szResult.Name = authInfo.Name;
						szResult.FirstLogin = 1;

						Global.updateLoginTime(szTemp.Result, DateTime.Now);
					}
					else
					{
						if (!isValidFLUser(nUid))
						{
							szResult.ResultCode = ErrManager.ERR_INVALID_USER;
							szResult.Name = String.Empty;
							szResult.Message = ErrManager.code2Msg(szResult.ResultCode);
						}
						else
						{
							if (authInfo.ImageData == "img")
							{
								szQuery = "UPDATE tbl_user SET gender = " + authInfo.Gender +
									", birthyear = " + authInfo.BirthYear +
									", phone_number = '" + authInfo.PhoneNum + "' WHERE uid = " + nUid;
							}
							else
							{
								String szOrgPath = Global.getImagePathFromUID(nUid);
								String szNewPath = Global.SaveImage(szOrgPath, authInfo.ImageData);

								szQuery = "UPDATE tbl_user SET gender = " + authInfo.Gender +
									", birthyear = " + authInfo.BirthYear +
									", phone_number = '" + authInfo.PhoneNum + "'" +
									", image_path = '" + szNewPath + "' WHERE uid = " + nUid;
							}

							dbContext.ExecuteCommand(szQuery);

							Global.updateLoginTime(nUid, DateTime.Now);
							szResult.ResultCode = nUid;
							szResult.Name = Global.getUserNameFromUid(nUid);
							szResult.Message = ErrManager.code2Msg(ErrManager.ERR_NONE);
							szResult.FirstLogin = 0;
						}
					}
				}
			}
			catch (System.Exception ex)
			{
				CommMisc.LogErrors(ex.Message);

				szResult.ResultCode = ErrManager.ERR_FAILURE;
				szResult.Message = ex.Message;
			}

			return szResult;
		}

		public StringContainer IsValidUser(String szVal, bool isEmail)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			StringContainer strRes = new StringContainer();
			String szQuery = String.Empty;

			try
			{
				if (szVal == String.Empty)
				{
					strRes.Result = ErrManager.ERR_PARAM;
					strRes.Message = ErrManager.code2Msg(strRes.Result);
				}
				else
				{
					if (isEmail)
					{
						szQuery = "SELECT * FROM tbl_user WHERE email_address = '" + szVal
							+ "' AND deleted = 0";
					}
					else
					{
						szQuery = "SELECT * FROM tbl_user WHERE phone_number = '" + szVal
							+ "' AND deleted = 0";
					}

					IEnumerable<tbl_user> queryEnums = dbContext.ExecuteQuery<tbl_user>(szQuery);
					IList<tbl_user> queryList = queryEnums.ToList();

					if (queryList.Count > 0)
					{
						strRes.Result = queryList.FirstOrDefault().uid;
						strRes.Message = queryList.FirstOrDefault().phone_number;
					}
					else
					{
						strRes.Result = ErrManager.ERR_FAILURE;
						strRes.Message = ErrManager.code2Msg(ErrManager.ERR_FAILURE);
					}
				}
			}
			catch (System.Exception ex)
			{
				CommMisc.LogErrors(ex.ToString());

				strRes.Result = ErrManager.ERR_FAILURE;
				strRes.Message = ex.Message;
			}

			return strRes;
		}

		public bool isValidFLUser(long Uid)
		{
			bool bSuccess = false;

			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			StringContainer strRes = new StringContainer();
			String szQuery = String.Empty;

			try
			{
				szQuery = "SELECT COUNT(*) FROM tbl_user WHERE (password = '' OR password IS NULL) AND deleted = 0 AND uid = " + Uid;

				IEnumerable<int> queryEnums = dbContext.ExecuteQuery<int>(szQuery);
				IList<int> queryList = queryEnums.ToList();

				if (queryList[0] == 1)
					bSuccess = true;
			}
			catch (System.Exception ex)
			{
				CommMisc.LogErrors(ex.ToString());
				bSuccess = false;
			}

			return bSuccess;
		}

		/// <summary>
		/// Put a user into taxi queue
		/// </summary>
		/// <param name="pairInfo">User information</param>
		/// <returns>Returns a "StringContainer" variable</returns>
		public StringContainer RequestPair(STPairInfo pairInfo)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();

			StringContainer result = new StringContainer(), szTemp = null;

			try
			{
				if (pairInfo == null || dbContext == null)
				{
					result.Result = ErrManager.ERR_PARAM;
					result.Message = ErrManager.code2Msg(result.Result);
				}
				else
				{
					szTemp = Global.getQueueIDFromUserID(pairInfo.Uid);
					if (szTemp.Result > 0)
					{
						result.Result = ErrManager.ERR_ALREADY_INQUEUE;
						result.Message = ErrManager.code2Msg(result.Result);
					}
					else
					{
						szTemp = Global.insertIntoQueue(pairInfo);

						result.Result = szTemp.Result;
						result.Message = szTemp.Message;
					}
				}
			}
			catch (Exception ex)
			{
				result.Result = ErrManager.ERR_UNKNOWN;
				result.Message = ex.Message;
			}

			return result;
		}

		public STPairResponse RequestIsPaired(long nUid)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			STPairResponse pairRes = new STPairResponse();

			long nQueueID = 0;
			int nGroupNo = 0;
			StringContainer szTemp = null;

			try
			{
				szTemp = Global.getQueueIDFromUserID(nUid);
				if (szTemp.Result <= 0)
				{
					pairRes.ErrCode = ErrManager.ERR_NOT_INQUEUE;
					pairRes.Message = ErrManager.code2Msg(pairRes.ErrCode);
				}
				else
				{
					nQueueID = szTemp.Result;

					szTemp = Global.updateLastReqTime(nQueueID, DateTime.Now);
					if (szTemp.Result != ErrManager.ERR_NONE)
					{
						pairRes.ErrCode = (int)szTemp.Result;
						pairRes.Message = szTemp.Message;
					}
					else
					{
						nGroupNo = Global.getGroupNo(nQueueID);

						if (nGroupNo <= 0)			// Not found pair yet
						{
							pairRes.ErrCode = ErrManager.ERR_NO_PAIR;
							pairRes.Message = ErrManager.code2Msg(pairRes.ErrCode);
						}
						else						// Found a pair
						{
							DateTime queue_time1 = Global.getQueueTimeFromQueueID(nQueueID);
                            DateTime queue_time2 = Global.getQueueTimeFromQueueID(Global.getOppoQueueID(nQueueID).Result);
							int nOppoAgreeState = Global.getOppoAgreeState(nQueueID).ErrCode;

                            if (queue_time1.Ticks >= queue_time2.Ticks && nOppoAgreeState == (int)AgreeState.OPPO_NOREPLY)
                            {
                                pairRes.ErrCode = ErrManager.ERR_NO_PAIR;
                                pairRes.Message = ErrManager.code2Msg(pairRes.ErrCode);
                            }
                            else if (queue_time1.Ticks >= queue_time2.Ticks && nOppoAgreeState == (int)AgreeState.OPPO_DISAGREE)
                            {
                                long nOppo_QuqueID = Global.getOppoQueueID(nQueueID).Result;
                                Global.resetUserState(nQueueID);
                                Global.resetUserState(nOppo_QuqueID);
                            }
							else
							{
								pairRes = Global.getPairResponseInfo(nQueueID, nGroupNo);

								if (pairRes.ErrCode == ErrManager.ERR_NONE)
								{
									szTemp = Global.updateUserState(nQueueID, (int)UserState.USERSTATE_RESPONSE);
									if (szTemp.Result == ErrManager.ERR_NONE)
										szTemp = Global.updateRespTime(nQueueID, DateTime.Now);

									pairRes.ErrCode = (int)szTemp.Result;
									pairRes.Message = szTemp.Message;
								}
								else
								{
									pairRes.ErrCode = ErrManager.ERR_NO_PAIR;
									pairRes.Message = ErrManager.code2Msg(pairRes.ErrCode);
								}
							}
						}
					}
				}
			}
			catch (Exception ex)
			{
				pairRes.ErrCode = ErrManager.ERR_UNKNOWN;
				pairRes.Message = ex.Message;
			}

			return pairRes;
		}

		public StringContainer RequestPairOff(long Uid)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			StringContainer szRes = new StringContainer();
			String szQuery = String.Empty;

			try
			{
				szQuery = "UPDATE tbl_queue set deleted = 1 WHERE user_id = " + Uid + " AND deleted = 0";

				if (dbContext.ExecuteCommand(szQuery) != 1)
					szRes.Result = ErrManager.ERR_SQLQUERY;
				else
					szRes.Result = ErrManager.ERR_NONE;
				szRes.Message = ErrManager.code2Msg(szRes.Result);
			}
			catch (System.Exception ex)
			{
				szRes.Result = ErrManager.ERR_UNKNOWN;
				szRes.Message = ex.Message;
			}

			return szRes;
		}

		public StringContainer RequestPairAgree(STPairAgree agreeInfo)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			StringContainer szTemp = null, szRes = new StringContainer();
			STAgreeResponse szOppoAgreeResp = null;
			String szQuery = String.Empty;
			DateTime serveTime = DateTime.Now;

			long nQueueID = 0, nOppo_QueueID = 0, uid1 = 0, uid2 = 0, nTaxiStandID = 0;
			double fSaveMoney1 = 0, fSaveMoney2 = 0;

			try
			{
				szTemp = Global.getQueueIDFromUserID(agreeInfo.Uid);

				if (szTemp.Result <= 0)
				{
					szRes.Result = (int)szTemp.Result;
					szRes.Message = szTemp.Message;
				}
				else
				{
					nQueueID = szTemp.Result;

					szTemp = Global.updateLastReqTime(nQueueID, DateTime.Now);
					if (szTemp.Result <= 0)
					{
						szRes.Result = (int)szTemp.Result;
						szRes.Message = szTemp.Message;
					}
					else
					{
						szTemp = Global.getOppoQueueID(nQueueID);
						if (szTemp.Result <= 0)
						{
							szRes.Result = (int)szTemp.Result;
							szRes.Message = szTemp.Message;

							Global.resetUserState(nQueueID);
						}
						else
						{
							nOppo_QueueID = szTemp.Result;

							szTemp = Global.updateUserAgreeState(nQueueID, agreeInfo.IsAgree ? 1 : 2);
							if (szTemp.Result <= 0)
							{
								szRes.Result = (int)szTemp.Result;
								szRes.Message = szTemp.Message;
							}
							else
							{
								szRes.Result = ErrManager.ERR_NONE;
								szRes.Message = ErrManager.code2Msg(szRes.Result);

								szOppoAgreeResp = Global.getAgreeState(nOppo_QueueID);
								if (szOppoAgreeResp.ErrCode < 0)
								{
									CommMisc.LogErrors(szOppoAgreeResp.Message);
								}
								else
								{
									if (szOppoAgreeResp.ErrCode != (long)AgreeState.OPPO_NOREPLY)
									{
										if (szOppoAgreeResp.ErrCode == (long)AgreeState.OPPO_AGREE &&
											agreeInfo.IsAgree)		// Both are agreed
										{
											Global.updateUserState(nQueueID, (int)UserState.USERSTATE_PAIR_SUCCESS);
											Global.updateUserState(nOppo_QueueID, (int)UserState.USERSTATE_PAIR_SUCCESS);

											uid1 = agreeInfo.Uid;
											uid2 = Global.getUserIDFromQueueID(nOppo_QueueID);

											fSaveMoney1 = Global.GetSavingFromQueueID(nQueueID);
											fSaveMoney2 = Global.GetSavingFromQueueID(nOppo_QueueID);

											Global.UpdateTotalSavingMoney(uid1, fSaveMoney1);
											Global.UpdateTotalSavingMoney(uid2, fSaveMoney2);

											nTaxiStandID = Global.getTaxiStandIDFromQueueID(nQueueID);

											serveTime = DateTime.Now;

											Global.updatePairedTimeFromQueueID(nQueueID, serveTime);
											Global.updatePairedTimeFromQueueID(nOppo_QueueID, serveTime);

											Global.LogServe(uid1,
												uid2,
												Global.getTaxiStandNameFromID(nTaxiStandID),
												Global.getDstNameFromQueueID(nQueueID),
												Global.getDstNameFromQueueID(nOppo_QueueID),
												Global.GetSavingFromQueueID(nQueueID),
												Global.GetSavingFromQueueID(nOppo_QueueID),
												Global.getWasteTimeFromQueueID(nQueueID),
												Global.getWasteTimeFromQueueID(nOppo_QueueID),
												Global.getOffOrderFromQueueID(nQueueID),
												Global.getOffOrderFromQueueID(nOppo_QueueID),
												serveTime);

											Global.changeUserCredits(uid1, -1);
											Global.changeUserCredits(uid2, -1);
										}
										else
										{
											Global.resetUserState(nQueueID);
											Global.resetUserState(nOppo_QueueID);
										}
									}
								}
							}
						}
					}
				}
			}
			catch (System.Exception ex)
			{
				CommMisc.LogErrors(ex.Message);

				szRes.Result = ErrManager.ERR_UNKNOWN;
				szRes.Message = ex.Message;
			}

			return szRes;
		}

		public int RequestUserCredits(long uid)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			int nRes = 0;
			String szQuery = String.Empty;
			IEnumerable<tbl_user> arrEnums = null;
			IList<tbl_user> arrList = null;

			try
			{
				szQuery = "SELECT * FROM tbl_user WHERE uid = " + uid
					+ " AND deleted = 0";

				arrEnums = dbContext.ExecuteQuery<tbl_user>(szQuery);
				arrList = arrEnums.ToList();

				nRes = arrList[0].credits == null ? 0 : (int)arrList[0].credits;
			}
			catch (System.Exception ex)
			{
				CommMisc.LogErrors(ex.Message);
			}

			return nRes;
		}

		public STUserProfile RequestUserProfile(long uid)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			STUserProfile profile = new STUserProfile();

			try
			{
				String szQuery = String.Empty;

				szQuery = "SELECT * FROM tbl_user WHERE uid = " + uid
					+ " AND deleted = 0";

				IEnumerable<tbl_user> infoEnums = dbContext.ExecuteQuery<tbl_user>(szQuery);
				IList<tbl_user> infoList = infoEnums.ToList();

				if (infoList.Count != 1)
				{
					profile.ErrCode = ErrManager.ERR_INVALID_USER;
					profile.Message = ErrManager.code2Msg(profile.ErrCode);
				}
				else
				{
					tbl_user userInfo = infoList[0];

					profile.Uid = userInfo.uid;
					profile.UserName = userInfo.name;
					profile.PhoneNum = userInfo.phone_number;
					profile.Gender = (int)userInfo.gender;
					profile.BirthYear = (int)userInfo.birthyear;
					profile.Email = userInfo.email_address;
					profile.IndGender = (int)userInfo.ind_gender;
					profile.GrpGender = (int)userInfo.grp_gender;
					profile.DelayTime = (int)userInfo.delay_time;
					profile.LoginDate = userInfo.last_login_date.ToString();
					profile.Credit = userInfo.credits == null ? 0 : (int)userInfo.credits;
					profile.StarCount = Global.GetRating(userInfo.uid);
					profile.ImageData = Global.getImageDataFromFile(userInfo.image_path);
					profile.TotalSaving = (double)userInfo.total_savings;
					profile.IsGroup = (int)userInfo.is_grouping;

					profile.ErrCode = ErrManager.ERR_NONE;
					profile.Message = ErrManager.code2Msg(ErrManager.ERR_NONE);
				}
			}
			catch (System.Exception ex)
			{
				CommMisc.LogErrors(ex.Message);

				profile.ErrCode = ErrManager.ERR_UNKNOWN;
				profile.Message = ex.Message;
			}

			return profile;
		}

		public StringContainer RequestUserProfileUpdate(STUserProfile userProfile)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			StringContainer szRes = new StringContainer();
			String szPath = String.Empty;

			if (userProfile == null)
			{
				szRes.Result = ErrManager.ERR_PARAM;
				szRes.Message = ErrManager.code2Msg(ErrManager.ERR_PARAM);
			}
			else
			{
				int nResult;
				String szQuery = String.Empty;

				try
				{
					if (userProfile.ImageData != String.Empty)
					{
						szPath = Global.getImagePathFromUID(userProfile.Uid);
						szPath = Global.SaveImage(szPath, userProfile.ImageData);
					}

					szQuery = "UPDATE tbl_user SET is_grouping = '" + userProfile.IsGroup + "', " +
						"name = '" + userProfile.UserName + "', " +
						"phone_number = '" + userProfile.PhoneNum + "', " +
						"email_address = '" + userProfile.Email + "', " +
						"ind_gender = '" + userProfile.IndGender + "', " +
						"grp_gender = '" + userProfile.GrpGender + "', " +
						"delay_time = '" + userProfile.DelayTime + "', " +
						"image_path = '" + szPath + "', " +
						"birthyear = '" + userProfile.BirthYear + "' " +
						"WHERE uid = '" + userProfile.Uid + "'";

					nResult = dbContext.ExecuteCommand(szQuery);

					if (nResult != 1)
					{
						szRes.Result = ErrManager.ERR_FAILURE;
						szRes.Message = ErrManager.code2Msg(ErrManager.ERR_FAILURE);
					}
					else
					{
						szRes.Result = ErrManager.ERR_NONE;
						szRes.Message = ErrManager.code2Msg(ErrManager.ERR_NONE);
					}
				}
				catch (System.Exception ex)
				{
					CommMisc.LogErrors(ex.Message);

					szRes.Result = ErrManager.ERR_FAILURE;
					szRes.Message = "Exception : " + ex.Message;
				}
			}

			return szRes;
		}

		public STPairHistoryCount PairingHistoryCount(String szUid)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();

			STPairHistoryCount result = new STPairHistoryCount();
			String szQuery = String.Empty;
			IEnumerable<int> arrAllEnums = null;
			IList<int> arrList = null;
			long nUid = 0;

			try
			{
				nUid = long.Parse(szUid);
				szQuery = "SELECT COUNT(*) FROM tbl_serve WHERE user_id = " + nUid + " OR user_id2 = " + nUid;

				arrAllEnums = dbContext.ExecuteQuery<int>(szQuery);

				result.ErrCode = ErrManager.ERR_NONE;
				result.Message = ErrManager.code2Msg(ErrManager.ERR_NONE);

				arrList = arrAllEnums.ToList();
				result.TotalCount = arrList[0];
				result.TotalSaving = Global.getTotalSavingFromID(nUid);
			}
			catch (Exception ex)
			{
				CommMisc.LogErrors(ex.Message);

				result.ErrCode = ErrManager.ERR_UNKNOWN;
				result.Message = ex.Message;
			}

			return result;
		}

		public STPairHistory[] PairingHistory(STReqPairHistory history_req)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			String szQuery = String.Empty;
			IEnumerable<tbl_serve> arrEnums = null, arrAllEnums = null;
			IList<tbl_serve> arrList = null;
			List<STPairHistory> arrResult = new List<STPairHistory>();

			try
			{
				if (history_req == null)
				{
					arrResult = null;
				}
				else if (history_req.PageNo < 1)
				{
					arrResult = null;
				}
				else
				{
					szQuery = "SELECT * FROM tbl_serve WHERE user_id = " + history_req.Uid + " OR user_id2 = " + history_req.Uid + " ORDER BY uid";

					arrAllEnums = dbContext.ExecuteQuery<tbl_serve>(szQuery);
					arrEnums = arrAllEnums.Skip(((int)history_req.PageNo - 1) * Global.HISTORY_PAGE_VOLUMN).Take(Global.HISTORY_PAGE_VOLUMN);
					arrList = arrEnums.ToList();

					for (int i = 0; i < arrList.Count; i++)
					{
						STPairHistory history = new STPairHistory();
						tbl_serve serve = arrList[i];

						history.PairingTime = Global.DateTime2String(serve.serve_date, true, true, false, false);

						history.Uid1 = serve.user_id;
						history.Uid2 = serve.user_id2;

						history.Name1 = Global.getUserNameFromUid(history.Uid1);
						history.Name2 = Global.getUserNameFromUid(history.Uid2);

						history.SrcAddr = serve.start_pos;
						history.DstAddr1 = serve.end_pos;
						history.DstAddr2 = serve.end_pos2;
						history.Score1 = (float)serve.score1;
						history.Score2 = (float)serve.score2;
						history.Gender1 = (int)Global.getUserGenderFromID(history.Uid1);
						history.Gender2 = (int)Global.getUserGenderFromID(history.Uid2);

						if (serve.user_id == history_req.Uid)
						{
							history.OffOrder = (int)serve.off_order1;
							history.SavePrice = (double)serve.saving_money;
							history.WasteTime = (double)serve.waste_time;
						}
						else
						{
							history.OffOrder = (int)serve.off_order2;
							history.SavePrice = (double)serve.saving_money2;
							history.WasteTime = (double)serve.waste_time2;
						}

						arrResult.Add(history);
					}
				}
			}
			catch (Exception ex)
			{
				CommMisc.LogErrors(ex.Message);

				arrResult = null;
			}

			return arrResult.ToArray();
		}

		public StringContainer Evaluate(STEvaluate evaluate)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			StringContainer szRes = new StringContainer();
			String szQuery = String.Empty;
			IEnumerable<tbl_serve> arrEnums = null;
			IList<tbl_serve> arrList = null;
			tbl_serve serveinfo = null;
			int nUserIndex = 0;

			try
			{
				szQuery = "SELECT * FROM tbl_serve WHERE (user_id = " + evaluate.Uid + 
					" AND user_id2 = " + evaluate.OppoID
					+ " AND serve_date = '" + evaluate.ServeTime + "') OR "
					+ "(user_id = " + evaluate.OppoID
					+ " AND user_id2 = " + evaluate.Uid
					+ " AND serve_date = '" + evaluate.ServeTime + "')";

				arrEnums = dbContext.ExecuteQuery<tbl_serve>(szQuery);
				arrList = arrEnums.ToList();

				for (int i = 0; i < arrList.Count; i++)
				{
					if (arrList[i].serve_date == DateTime.Parse(evaluate.ServeTime))
					{
						serveinfo = arrList[i];
						break;
					}
				}

				if (serveinfo == null)
				{
					szRes.Result = ErrManager.ERR_INVALID_USER;
					szRes.Message = ErrManager.code2Msg(szRes.Result);
				}
				else
				{
					if (evaluate.Uid == serveinfo.user_id)
						nUserIndex = 1;
					else if (evaluate.Uid == serveinfo.user_id2)
						nUserIndex = 2;

					if (nUserIndex == 0)
					{
						szRes.Result = ErrManager.ERR_SERVE_ISNOTFORUSER;
						szRes.Message = ErrManager.code2Msg(szRes.Result);
					}
					else
					{
						if (nUserIndex == 1)
						{
							if (serveinfo.score2 < 0)		// Not rated yet
							{
								szQuery = "UPDATE tbl_serve SET score2=" + evaluate.Score + " WHERE uid = " + serveinfo.uid;
								if (dbContext.ExecuteCommand(szQuery) != 1)
									szRes.Result = ErrManager.ERR_RATE_UPDATE_FAILED;
								else
									szRes.Result = ErrManager.ERR_NONE;
								szRes.Message = ErrManager.code2Msg(szRes.Result);
							}
							else
							{
								szRes.Result = ErrManager.ERR_ALREADY_RATED;
								szRes.Message = ErrManager.code2Msg(szRes.Result);
							}
						}
						else
						{
							if (serveinfo.score1 < 0)		// Not rated yet
							{
								szQuery = "UPDATE tbl_serve SET score1=" + evaluate.Score + " WHERE uid = " + serveinfo.uid;
								if (dbContext.ExecuteCommand(szQuery) != 1)
									szRes.Result = ErrManager.ERR_RATE_UPDATE_FAILED;
								else
									szRes.Result = ErrManager.ERR_NONE;
								szRes.Message = ErrManager.code2Msg(szRes.Result);
							}
							else
							{
								szRes.Result = ErrManager.ERR_ALREADY_RATED;
								szRes.Message = ErrManager.code2Msg(szRes.Result);
							}
						}
					}
				}
			}
			catch (System.Exception ex)
			{
				CommMisc.LogErrors(ex.Message);

				szRes.Result = ErrManager.ERR_UNKNOWN;
				szRes.Message = ex.Message;
			}

			return szRes;
		}

		public STTaxiStandResp GetTaxiStand(STReqTaxiStand userPosInfo)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			STTaxiStandResp taxiStandResp = new STTaxiStandResp();
			IEnumerable<tbl_taxistand> arrEnums = null;
			IList<tbl_taxistand> arrList = null;

			double distance = -1, temp = 0;
			int nIndex = 0;

			String szQuery = String.Empty;

			try
			{
				szQuery = "SELECT * FROM tbl_taxistand ORDER BY uid";
				arrEnums = dbContext.ExecuteQuery<tbl_taxistand>(szQuery);
				arrList = arrEnums.ToList();

				for (int i = 0; i < arrList.Count; i++)
				{
					temp = Global.calcDist(userPosInfo.Latitude, userPosInfo.Longitude, (double)arrList[i].latitude, (double)arrList[i].longitude, 'K');
					if (temp > Global.MAX_TAXISTAND_DIST)
						continue;

					if (distance < 0 || distance > temp)
					{
						nIndex = i;
						distance = temp;
					}
				}

				if (distance < 0)
				{
					taxiStandResp.Result = ErrManager.ERR_TAXISTAND_NOT_FOUND;
					taxiStandResp.Message = ErrManager.code2Msg(taxiStandResp.Result);
				}
				else
				{
					taxiStandResp.Result = ErrManager.ERR_NONE;
					taxiStandResp.Message = ErrManager.code2Msg(taxiStandResp.Result);

					taxiStandResp.TaxiStand.StandType = arrList[nIndex].taxi_stand_type;
					taxiStandResp.TaxiStand.StandName = arrList[nIndex].stand_name;
					taxiStandResp.TaxiStand.Latitude = (double)arrList[nIndex].latitude;
					taxiStandResp.TaxiStand.Longitude = (double)arrList[nIndex].longitude;
					taxiStandResp.TaxiStand.GpsAddress = arrList[nIndex].gps_address;
					taxiStandResp.TaxiStand.PostCode = arrList[nIndex].postcode == null ? String.Empty : arrList[nIndex].postcode;
					taxiStandResp.TaxiStand.StandNo = arrList[nIndex].stand_no == null ? String.Empty : arrList[nIndex].stand_no;
				}
			}
			catch (System.Exception ex)
			{
				CommMisc.LogErrors(ex.Message);

				taxiStandResp.Result = ErrManager.ERR_UNKNOWN;
				taxiStandResp.Message += ex.Message;
			}

			return taxiStandResp;
		}

		public STTaxiStand[] GetTaxiStandList(STReqTaxiStand userPosInfo)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			List<STTaxiStand> arrTaxiStands = new List<STTaxiStand>();
			IEnumerable<tbl_taxistand> arrEnums = null;
			IList<tbl_taxistand> arrList = null;

			double temp = 0;

			String szQuery = String.Empty;
			String szKeyword = userPosInfo.Keyword;
			if (szKeyword == null)
				szKeyword = String.Empty;

			try
			{
				szQuery = "SELECT * FROM tbl_taxistand WHERE stand_name LIKE '%" + szKeyword + "%' OR stand_no LIKE '%" + szKeyword + "%' ORDER BY uid";
				arrEnums = dbContext.ExecuteQuery<tbl_taxistand>(szQuery);
				arrList = arrEnums.ToList();

				for (int i = 0; i < arrList.Count; i++)
				{
					temp = Global.calcDist(userPosInfo.Latitude, userPosInfo.Longitude, (double)arrList[i].latitude, (double)arrList[i].longitude, 'K');
					if (temp > Global.MAX_TAXISTAND_DIST)
						continue;

					tbl_taxistand standinfo = arrList[i];
					STTaxiStand taxiStand = new STTaxiStand();

					taxiStand.StandType = standinfo.taxi_stand_type;
					taxiStand.StandName = standinfo.stand_name;
					taxiStand.Latitude = (double)standinfo.latitude;
					taxiStand.Longitude = (double)standinfo.longitude;
					taxiStand.GpsAddress = standinfo.gps_address;
					taxiStand.PostCode = standinfo.postcode == null ? String.Empty : standinfo.postcode;
					taxiStand.StandNo = standinfo.stand_no == null ? String.Empty : standinfo.stand_no;

					arrTaxiStands.Add(taxiStand);
				}
			}
			catch (System.Exception ex)
			{
				CommMisc.LogErrors(ex.Message);

				arrTaxiStands.Clear();
			}

			return arrTaxiStands.ToArray();
		}

		public StringContainer RequestSendSMS(STSendSMS sendInfo)
		{
			StringContainer szRes = new StringContainer();
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			String szQuery = String.Empty;
			StringContainer szTemp = IsValidUser(sendInfo.PhoneNum, false);

			try
			{
				if (szTemp.Result > 0)
				{
					szQuery = "INSERT INTO tbl_smslog (user_id, receiver, sendtime, valid, deleted) VALUES (" +
						sendInfo.Uid + ", '" +
						sendInfo.PhoneNum + "', '" +
						Global.DateTime2String(DateTime.Now, true, true, false, false) + "', 0, 0)";
				}
				else
				{
					szQuery = "INSERT INTO tbl_smslog (user_id, receiver, sendtime, valid, deleted) VALUES (" +
						sendInfo.Uid + ", '" +
						sendInfo.PhoneNum + "', '" +
						Global.DateTime2String(DateTime.Now, true, true, false, false) + "', 1, 0)";
				}

				if (dbContext.ExecuteCommand(szQuery) != 1)
				{
					szRes.Result = ErrManager.ERR_SQLQUERY;
					szRes.Message = ErrManager.code2Msg(szRes.Result);
				}
				else
				{
					szRes.Result = ErrManager.ERR_NONE;
					szRes.Message = ErrManager.code2Msg(szRes.Result);
				}
			}
			catch (System.Exception ex)
			{
				CommMisc.LogErrors(ex.Message);

				szRes.Result = ErrManager.ERR_UNKNOWN;
				szRes.Message = ex.Message;
			}

			return szRes;
		}

		public StringContainer ResetPassword(String email)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			StringContainer szRes = new StringContainer(), szTemp = null;
			String szQuery = String.Empty;
			IEnumerable<int> arrCounts = null;
			IList<int> arrList = null;
			int nCount = 0;
			String szNewPass = String.Empty;

			try
			{
				szQuery = "SELECT COUNT(*) FROM tbl_user WHERE email_address = '" + email + "'";
				arrCounts = dbContext.ExecuteQuery<int>(szQuery);
				arrList = arrCounts.ToList();
				nCount = arrList[0];

				if (nCount == 0)
				{
					szRes.Result = ErrManager.ERR_INVALID_EMAIL;
					szRes.Message = ErrManager.code2Msg(szRes.Result);
				}
				else
				{
					szNewPass = Global.generateRandomPassword(PASSLEN);
					if (szNewPass == null || szNewPass.Length != PASSLEN)
					{
						szRes.Result = ErrManager.ERR_FAILURE;
						szRes.Message = ErrManager.code2Msg(szRes.Result);
					}
					else
					{
						szTemp = Global.updateUserPassword(email, szNewPass);
						if (szTemp.Result == ErrManager.ERR_NONE)
						{
							Global.sendEmail(email, "Your new password!", szNewPass);
							szRes.Result = ErrManager.ERR_NONE;
						}
						else
							szRes.Result = szTemp.Result;

						szRes.Message = ErrManager.code2Msg(szRes.Result);
					}
				}
			}
			catch (System.Exception ex)
			{
				CommMisc.LogErrors(ex.Message);

				szRes.Result = ErrManager.ERR_UNKNOWN;
				szRes.Message = ex.Message;
			}

			return szRes;
		}

		public int GetSharable(long uid)
		{
			int nRet = 0, nLimitDays = 7;
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			String szQuery = String.Empty;
			STAuthUser authUser = null;
			IEnumerable<tbl_sharelog> arrEnums = null;
			IList<tbl_sharelog> arrList = null;
			tbl_sharelog logItem = null;

			try
			{
				authUser = Global.getUserAuth(uid);
				if (authUser == null)
					nRet = -1;
				else
				{
					szQuery = "SELECT * FROM tbl_sharelog WHERE user_id = " + uid + " AND deleted = 0 ORDER BY uid";

					arrEnums = dbContext.ExecuteQuery<tbl_sharelog>(szQuery);
					arrList = arrEnums.ToList();

					if (arrList.Count == 0)
						nRet = 1;
					else
					{
						logItem = arrList[arrList.Count - 1];
						double day_span = DateTime.Now.Subtract(logItem.sendtime).TotalDays;
						if (day_span < nLimitDays)
							nRet = 0;
						else
							nRet = 1;
					}
				}
			}
			catch (System.Exception ex)
			{
				CommMisc.LogErrors(ex.Message);
				nRet = -1;
			}

			return nRet;
		}

		public void RequestShareLog(STShareLog shareLog)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			String szQuery = String.Empty;

			try
			{
				szQuery = "INSERT INTO tbl_sharelog (user_id, sendtime, share_content, deleted) VALUES (" + shareLog.UserID
					+ ", '" + Global.DateTime2String(DateTime.Now, true, true, false, false)
					+ "', '" + shareLog.Content + "', 0)";

				if (dbContext.ExecuteCommand(szQuery) == 1)
				{
					Global.changeUserCredits(shareLog.UserID, 1);
				}
			}
			catch (System.Exception ex)
			{
				CommMisc.LogErrors(ex.Message);
			}
		}

		public StringContainer PairIsNext(String Uid)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			String szQuery = String.Empty;
			StringContainer szRes = new StringContainer(), szTemp = null;
			long uid = 0, queue_id = 0;
			IEnumerable<tbl_queue> arrEnums = null;
			IList<tbl_queue> arrList = null;

			try
			{
				uid = long.Parse(Uid);

				szTemp = Global.getQueueIDFromUserID(uid);

				if (szTemp == null || szTemp.Result <= 0)
				{
					szRes.Result = ErrManager.ERR_INVALID_QUEUEID;
					szRes.Message = ErrManager.code2Msg(szRes.Result);
				}
				else
				{
					queue_id = szTemp.Result;

                    szTemp = Global.getOppoQueueID(queue_id);
                    queue_id = szTemp.Result;

					szQuery = "SELECT * FROM tbl_queue WHERE uid = " + queue_id + " AND deleted = 0";
					arrEnums = dbContext.ExecuteQuery<tbl_queue>(szQuery);
					arrList = arrEnums.ToList();

					if (arrList.Count() == 0)
					{
						szRes.Result = ErrManager.ERR_INVALID_USER;
						szRes.Message = ErrManager.code2Msg(szRes.Result);
					}
					else
					{
						szRes.Result = arrList.FirstOrDefault().isnext == null ? 0 : 1;
						szRes.Message = ErrManager.code2Msg(ErrManager.ERR_NONE);
					}
				}
			}
			catch (System.Exception ex)
			{
				CommMisc.LogErrors(ex.Message);

				szRes.Result = ErrManager.ERR_UNKNOWN;
				szRes.Message = ex.Message;
			}

			return szRes;
		}

		public StringContainer SetNextTurn(String Uid)
		{
            StringContainer szRes = new StringContainer(), szTemp = null;
            String szMsg = "Start";

            try
			{
                szMsg = "dbContext";

                CarPoolDBDataContext dbContext = new CarPoolDBDataContext();

                szMsg = "szQuery";

                String szQuery = String.Empty;

                long uid = 0, queue_id = 0;
                
                uid = long.Parse(Uid);
				szTemp = Global.getQueueIDFromUserID(uid);

				if (szTemp == null || szTemp.Result <= 0)
				{
					szRes.Result = ErrManager.ERR_INVALID_QUEUEID;
					szRes.Message = ErrManager.code2Msg(szRes.Result);
				}
				else
				{
					queue_id = szTemp.Result;
					szQuery = "UPDATE tbl_queue SET isnext = 1 WHERE uid = " + queue_id + " AND deleted = 0";
					dbContext.ExecuteCommand(szQuery);

					szRes.Result = ErrManager.ERR_NONE;
					szRes.Message = ErrManager.code2Msg(szRes.Result);
				}
			}
			catch (System.Exception ex)
			{
				CommMisc.LogErrors(ex.Message);

				szRes.Result = ErrManager.ERR_UNKNOWN;
				szRes.Message = szMsg;
			}

			return szRes;
		}

		public StringContainer PayResult(String Uid, String Price)
		{
			StringContainer szRes = new StringContainer();

			try
			{
				CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
				String szQuery = String.Empty;

				long uid = long.Parse(Uid);
				int price = int.Parse(Price);
				tbl_user userinfo = (from m in dbContext.tbl_users
									 where m.deleted == 0 && m.uid == uid
									 select m).FirstOrDefault();

				if (userinfo == null)
				{
					szRes.Result = -1;
					szRes.Message = "User authentication failed!";
				}
				else
				{
					int nAddCredits = 0;
					if (price == 5)			// Add 5 credits
					{
						nAddCredits = 5;
					}
					else if (price == 9)	// Add 10 credits
					{
						nAddCredits = 10;
					}
					else if (price == 16)	// Add 20 credits
					{
						nAddCredits = 20;
					}

					if (userinfo.credits == null)
						userinfo.credits = nAddCredits;
					else
						userinfo.credits += nAddCredits;

					szRes.Result = 1;
					szRes.Message = String.Format("Success! You got {0} credits successfully!", nAddCredits);
				}
			}
			catch (System.Exception ex)
			{
				CommMisc.LogErrors(ex.Message);

				szRes.Result = ErrManager.ERR_UNKNOWN;
				szRes.Message = ex.Message;
			}

			return szRes;
		}


		/// <summary>
		/// Receive client's alive signal
		/// </summary>
		public void SendAlive()
		{

		}

		#endregion

		#region Private_Methods
		#endregion
	}
}