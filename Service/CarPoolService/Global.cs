using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using CarPoolService.CarPoolDB;
using System.IO;
using System.Text;
using System.Diagnostics;
// using System.Web.Mail;
using System.Net.Mail;
using System.Net;

namespace CarPoolService
{
	public class Global
	{
		private static String gmailAccount = "test.ride2gather@gmail.com";
		private static String gmailPwd = "1695506955";

		public static double MAX_TAXISTAND_DIST = 1;				// 500 meter
		public static double COORD_OFFSET_LIMIT = 0.0001;
		public static int HISTORY_PAGE_VOLUMN = 15;

		public static double MAX_POS_RANGE = 0.005;

		/// <summary>
		/// Function to get absolute value
		/// </summary>
		/// <param name="fValue"></param>
		/// <returns></returns>
		public static double abs(double fValue)
		{
			if (fValue < 0)
				return -fValue;
			else
				return fValue;
		}

		/// <summary>
		/// Function to convert datetime to string
		/// </summary>
		/// <param name="inDateTime"></param>
		/// <param name="inIsAttachTime"></param>
		/// <param name="inIsLowerBound"></param>
		/// <param name="inIsUpperBound"></param>
		/// <returns></returns>
		public static String DateTime2String(DateTime inDateTime,
											bool inIsAttachTime,
											bool inIsAttachSecond,
											bool inIsLowerBound,
											bool inIsUpperBound)
		{
			String szRet = String.Empty, szFormat = String.Empty;

			DateTime dateTime = new DateTime(inDateTime.Year, inDateTime.Month, inDateTime.Day,
				inDateTime.Hour, inDateTime.Minute, inDateTime.Second);

			if (!inIsAttachTime)
			{
				szFormat = "yyyy-MM-dd";
				szRet = inDateTime.ToString(szFormat);
			}
			else
			{
				if (inIsAttachSecond)
				{
					if (inIsLowerBound)
						dateTime = new DateTime(inDateTime.Year, inDateTime.Month, inDateTime.Day, 0, 0, 0);
					else if (inIsUpperBound)
						dateTime = new DateTime(inDateTime.Year, inDateTime.Month, inDateTime.Day, 23, 59, 59);
				}
				else
				{
					if (inIsLowerBound)
						dateTime = new DateTime(inDateTime.Year, inDateTime.Month, inDateTime.Day, 0, 0, 0);
					else if (inIsUpperBound)
						dateTime = new DateTime(inDateTime.Year, inDateTime.Month, inDateTime.Day, 23, 59, 00);
					else
						dateTime = new DateTime(inDateTime.Year, inDateTime.Month, inDateTime.Day, inDateTime.Hour, inDateTime.Minute, 0);
				}

				szFormat = "yyyy-MM-dd HH:mm:ss";
				szRet = dateTime.ToString(szFormat);
			}

			return szRet;
		}

		/// <summary>
		/// Get current date time information
		/// </summary>
		/// <returns></returns>
		public static String GetCurTime(bool bIsAttachSec)
		{
			return DateTime2String(DateTime.Now, true, bIsAttachSec, false, false);
		}

		#region user management internal functions

		/// <summary>
		/// Function to get current valid user list
		/// </summary>
		/// <param name="dbContext">database context</param>
		/// <returns></returns>
		public static IList<tbl_user> getUserList()
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			if (dbContext == null)
				return null;

			String szQuery = "SELECT * FROM tbl_user WHERE deleted = 0";

			IEnumerable<tbl_user> arrEnums = dbContext.ExecuteQuery<tbl_user>(szQuery);
			if (arrEnums == null)
				return null;

			return arrEnums.ToList();
		}

		/// <summary>
		/// Function to insert a user info into queue
		/// </summary>
		/// <param name="context">database context</param>
		/// <param name="pairInfo">user required pairing info</param>
		/// <returns></returns>
		public static StringContainer insertIntoQueue(STPairInfo pairInfo)
		{
			CarPoolDBDataContext context = new CarPoolDBDataContext();
			StringContainer szRes = new StringContainer();
			String szQuery = String.Empty;
			long nTaxiStand = 0;

			try
			{
				if (pairInfo != null)
				{
					nTaxiStand = getTaxiStandIdFromCoord(pairInfo.SrcLat, pairInfo.SrcLon);
					if (nTaxiStand < 0)						// Not found taxi stand
					{
						szRes.Result = ErrManager.ERR_NOTFOUND_TAXISTAND;
						szRes.Message = ErrManager.code2Msg(szRes.Result);
					}
					else									// Found taxi stand
					{
						szQuery = "INSERT INTO tbl_queue (enter_time, user_id, people_num, same_gender, top_color, other_features, taxistand_id, destination, dst_longitude, dst_latitude, group_no, state, resp_time, queue_time, agree_state, off_order, savingmoney, wastetime, lastreqtime, deleted) values (N'"
										+ Global.DateTime2String(DateTime.Now, true, true, false, false) + "','"
										+ pairInfo.Uid + "','"
										+ pairInfo.Count + "','"
										+ pairInfo.GrpGender + "',N'"
										+ pairInfo.Color + "',N'"
										+ pairInfo.OtherFeature + "','"
										+ nTaxiStand + "',N'"
										+ pairInfo.Destination + "','"
										+ pairInfo.DstLon + "','"
										+ pairInfo.DstLat + "','0', '0', '"
										+ Global.GetCurTime(true) + "', '"
										+ Global.GetCurTime(true) + "', '0', '0', '0', '0', '"
										+ Global.GetCurTime(true) + "', '0')";

						if (context.ExecuteCommand(szQuery) != 1)
							szRes.Result = ErrManager.ERR_SQLQUERY;
						else
							szRes.Result = ErrManager.ERR_NONE;

						szRes.Message = ErrManager.code2Msg(szRes.Result);
					}
				}
				else
				{
					szRes.Result = ErrManager.ERR_PARAM;
					szRes.Message = ErrManager.code2Msg(szRes.Result);
				}

			}
			catch (System.Exception ex)
			{
				szRes.Result = ErrManager.ERR_UNKNOWN;
				szRes.Message = ex.Message;
			}

			return szRes;
		}

		/// <summary>
		/// Function to get taxi stand id from coordinates
		/// </summary>
		/// <param name="dbContext">database context</param>
		/// <param name="lat">latitude of taxi stand</param>
		/// <param name="lon">longitude of taxi stand</param>
		/// <returns></returns>
		public static long getTaxiStandIdFromCoord(double lat, double lon)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			String szQuery = "SELECT * FROM tbl_taxistand";
			long nRetVal = -1;

			IEnumerable<tbl_taxistand> arrTaxiStands = dbContext.ExecuteQuery<tbl_taxistand>(szQuery);
			IList<tbl_taxistand> arrListTaskStands = arrTaxiStands.ToList();

			for (int i = 0; i < arrListTaskStands.Count; i++)
			{
				tbl_taxistand taxiStand = arrListTaskStands[i];
				if (Global.abs((double)taxiStand.latitude - lat) < Global.COORD_OFFSET_LIMIT &&
					Global.abs((double)taxiStand.longitude - lon) < Global.COORD_OFFSET_LIMIT)
				{
					nRetVal = taxiStand.uid;
					break;
				}
			}

			return nRetVal;
		}

		/// <summary>
		/// Function to get queue id from user id
		/// </summary>
		/// <param name="dbContext">database context</param>
		/// <param name="uid">user id</param>
		/// <returns></returns>
		public static StringContainer getQueueIDFromUserID(long uid)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			StringContainer szRes = new StringContainer();
			String szQuery = String.Empty;
			IEnumerable<long> arrEnums = null;
			IList<long> arrList = null;

			try
			{
				if (dbContext != null)
				{
					szQuery = "SELECT uid FROM tbl_queue WHERE user_id = " + uid + " AND deleted = 0";

					arrEnums = dbContext.ExecuteQuery<long>(szQuery);
					arrList = arrEnums.ToList();

					if (arrList.Count != 0)
					{
						szRes.Result = arrList[0];
						szRes.Message = ErrManager.code2Msg(ErrManager.ERR_NONE);
					}
					else
					{
						szRes.Result = ErrManager.ERR_NOT_INQUEUE;
						szRes.Message = ErrManager.code2Msg(szRes.Result);
					}
				}
				else
				{
					szRes.Result = ErrManager.ERR_PARAM;
					szRes.Message = ErrManager.code2Msg(szRes.Result);
				}
			}
			catch (Exception ex)
			{
				CommMisc.LogErrors(ex.Message);

				szRes.Result = ErrManager.ERR_UNKNOWN;
				szRes.Message = ex.Message;
			}

			return szRes;
		}

		/// <summary>
		/// Function to get user id from queue id
		/// </summary>
		/// <param name="dbContext"></param>
		/// <param name="queue_id"></param>
		/// <returns></returns>
		public static long getUserIDFromQueueID(long queue_id)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			long uid = 0;
			String szQuery = String.Empty;
			IEnumerable<tbl_queue> arrEnums = null;
			IList<tbl_queue> arrList = null;

			if (dbContext == null)
			{
				uid = 0;
			}
			else
			{
				szQuery = "SELECT * FROM tbl_queue WHERE uid = '" + queue_id + "'";

				arrEnums = dbContext.ExecuteQuery<tbl_queue>(szQuery);
				arrList = arrEnums.ToList();

				if (arrList.Count == 0)
					uid = 0;
				else
					uid = arrList.FirstOrDefault().user_id;
			}

			return uid;
		}

		public static String getDstNameFromQueueID(long queue_id)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			String szDest = null;
			String szQuery = String.Empty;
			IEnumerable<tbl_queue> arrEnums = null;
			IList<tbl_queue> arrList = null;

			try
			{
				szQuery = "SELECT * FROM tbl_queue WHERE uid = '" + queue_id + "'";

				arrEnums = dbContext.ExecuteQuery<tbl_queue>(szQuery);
				arrList = arrEnums.ToList();

				if (arrList.Count == 0)
					szDest = String.Empty;
				else
					szDest = arrList.FirstOrDefault().destination;
			}
			catch (Exception ex)
			{
				CommMisc.LogErrors(ex.Message);
				szDest = null;
			}

			return szDest;
		}


		/// <summary>
		/// Function to get user authentication info from user id
		/// </summary>
		/// <param name="dbContext">database context</param>
		/// <param name="uid">user id</param>
		/// <returns></returns>
		public static STAuthUser getUserAuth(long uid)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			STAuthUser userAuth = new STAuthUser();
			String szQuery = String.Empty;
			IEnumerable<tbl_user> arrEnums = null;
			IList<tbl_user> arrList = null;

			try
			{
				szQuery = "SELECT * FROM tbl_user WHERE uid = '" + uid + "' AND deleted = 0";

				arrEnums = dbContext.ExecuteQuery<tbl_user>(szQuery);
				arrList = arrEnums.ToList();

				if (arrList.Count == 0)
					userAuth = null;
				else
				{
					userAuth.Email = arrList[0].email_address;
					userAuth.Password = arrList[0].password;
				}
			}
			catch (Exception ex)
			{
				CommMisc.LogErrors(ex.Message);
				userAuth = null;
			}

			return userAuth;
		}

		/// <summary>
		/// Function to get agree state of pairing opposite
		/// </summary>
		/// <param name="dbContext"></param>
		/// <param name="queue_id"></param>
		/// <returns></returns>
		public static STAgreeResponse getOppoAgreeState(long queue_id)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			String szQuery = String.Empty;
			long nOppo_QueueID = 0;
			STAgreeResponse szRes = new STAgreeResponse();
			StringContainer szTemp = null;

			try
			{
				szTemp = getOppoQueueID(queue_id);
				if (szTemp.Result <= 0)			// Opposite already removed
				{
					szRes.ErrCode = (int)AgreeState.OPPO_DISAGREE;
					szRes.Message = ErrManager.code2Msg(ErrManager.ERR_NONE);

					Global.resetUserState(queue_id);
				}
				else
				{
					nOppo_QueueID = szTemp.Result;
					szRes = getAgreeState(nOppo_QueueID);
				}
			}
			catch (System.Exception ex)
			{
				CommMisc.LogErrors(ex.Message);

				szRes.ErrCode = ErrManager.ERR_UNKNOWN;
				szRes.Message = ex.Message;
			}

			return szRes;
		}

		/// <summary>
		/// Function to get user 'agree state' field from queue id
		/// </summary>
		/// <param name="queue_id">Queue Uid</param>
		/// <returns></returns>
		public static STAgreeResponse getAgreeState(long queue_id)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			STAgreeResponse szRes = new STAgreeResponse();
			String szQuery = String.Empty;
			IEnumerable<tbl_queue> arrEnums = null;
			IList<tbl_queue> arrList = null;

			try
			{
				szQuery = "SELECT * FROM tbl_queue WHERE uid = " + queue_id
					+ " AND deleted = 0";

				arrEnums = dbContext.ExecuteQuery<tbl_queue>(szQuery);
				arrList = arrEnums.ToList();

				if (arrList.Count == 0)
				{
					szRes.ErrCode = ErrManager.ERR_NOT_INQUEUE;
					szRes.Message = ErrManager.code2Msg(szRes.ErrCode);
				}
				else
				{
					if (arrList[0].agree_state == null)
						szRes.ErrCode = 0;
					else
					{
						szRes.ErrCode = (int)arrList[0].agree_state;
						if (szRes.ErrCode == (int)AgreeState.OPPO_AGREE)
						{
							if (arrList[0].pairedtime == null)
								szRes.PairTime = String.Empty;
							else
								szRes.PairTime = DateTime2String((DateTime)arrList[0].pairedtime, true, true, false, false);
						}
					}

					szRes.Message = ErrManager.code2Msg(ErrManager.ERR_NONE);
				}
			}
			catch (System.Exception ex)
			{
				CommMisc.LogErrors(ex.Message);

				szRes.ErrCode = ErrManager.ERR_UNKNOWN;
				szRes.Message = ex.Message;
			}

			return szRes;
		}


		/// <summary>
		/// Function to get resp_time field from tbl_queue table
		/// </summary>
		/// <param name="dbContext"></param>
		/// <param name="queue_id"></param>
		/// <returns></returns>
		public static DateTime? getLastUpdateTime(long queue_id)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			DateTime? lastUpdateTime = null;
			String szQuery = String.Empty;
			IEnumerable<tbl_queue> arrEnums = null;
			IList<tbl_queue> arrList = null;

			try
			{
				szQuery = "SELECT * FROM tbl_queue WHERE uid = '" + queue_id + "'";

				arrEnums = dbContext.ExecuteQuery<tbl_queue>(szQuery);
				arrList = arrEnums.ToList();

				if (arrList.Count == 0)
					lastUpdateTime = null;
				else
					lastUpdateTime = arrList[0].resp_time;
			}
			catch (System.Exception ex)
			{
				CommMisc.LogErrors(ex.Message);
				lastUpdateTime = null;
			}

			return lastUpdateTime;
		}

		/// <summary>
		/// Function to get user name from user id
		/// </summary>
		/// <param name="dbContext"></param>
		/// <param name="uid"></param>
		/// <returns></returns>
		public static String getUserNameFromUid(long uid)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			String szRes = String.Empty;
			String szQuery = String.Empty;
			IEnumerable<tbl_user> arrEnums = null;
			IList<tbl_user> arrList = null;

			try
			{
				szQuery = "SELECT * FROM tbl_user WHERE uid = '" + uid + "' AND deleted = 0";

				arrEnums = dbContext.ExecuteQuery<tbl_user>(szQuery);
				arrList = arrEnums.ToList();

				szRes = arrList[0].name;
			}
			catch (Exception ex)
			{
				CommMisc.LogErrors(ex.Message);
			}

			return szRes;
		}

		/// <summary>
		/// Function to get user gender from user id
		/// </summary>
		/// <param name="dbContext"></param>
		/// <param name="uid"></param>
		/// <returns></returns>
		public static int getUserGenderFromID(long uid)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			int nGender = -1;
			String szQuery = String.Empty;
			IEnumerable<tbl_user> arrEnums = null;
			IList<tbl_user> arrList = null;

			try
			{
				szQuery = "SELECT * FROM tbl_user WHERE uid = '" + uid + "' AND deleted = 0";

				arrEnums = dbContext.ExecuteQuery<tbl_user>(szQuery);
				arrList = arrEnums.ToList();

				nGender = (int)arrList[0].gender;
			}
			catch (Exception ex)
			{
				CommMisc.LogErrors(ex.Message);
				nGender = -1;
			}

			return nGender;
		}

		/// <summary>
		/// Function to get user total saving from user id
		/// </summary>
		/// <param name="dbContext"></param>
		/// <param name="uid"></param>
		/// <returns></returns>
		public static double getTotalSavingFromID(long uid)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			double fSaving = 0;
			String szQuery = String.Empty;
			IEnumerable<tbl_user> arrEnums = null;
			IList<tbl_user> arrList = null;

			try
			{
				szQuery = "SELECT * FROM tbl_user WHERE uid = '" + uid + "' AND deleted = 0";

				arrEnums = dbContext.ExecuteQuery<tbl_user>(szQuery);
				arrList = arrEnums.ToList();

				fSaving = arrList[0].total_savings == null ? 0 : (double)arrList[0].total_savings;
			}
			catch (Exception ex)
			{
				CommMisc.LogErrors(ex.Message);
				fSaving = 0;
			}

			return fSaving;
		}

		/// <summary>
		/// Function to get opposite info from queue id and group id
		/// </summary>
		/// <param name="dbContext"></param>
		/// <param name="queue_id"></param>
		/// <param name="group_no"></param>
		/// <returns></returns>
		public static STPairResponse getPairResponseInfo(long queue_id, int group_no)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			STPairResponse pairRes = new STPairResponse();
			String szQuery = String.Empty;
			IEnumerable<tbl_queue> arrEnums = null;
			IList<tbl_queue> arrList = null;
			tbl_queue main_info = null, oppo_info = null;

			try
			{
				if (dbContext == null)
				{
					pairRes.ErrCode = ErrManager.ERR_PARAM;
					pairRes.Message = ErrManager.code2Msg(ErrManager.ERR_PARAM);
				}
				else
				{
					szQuery = "SELECT * FROM tbl_queue WHERE uid = " + queue_id
						+ " AND group_no = '" + group_no
						+ "' AND state = '" + (int)UserState.USERSTATE_REQUEST
						+ "' AND deleted = 0";

					arrEnums = dbContext.ExecuteQuery<tbl_queue>(szQuery);
					arrList = arrEnums.ToList();

					if (arrList.Count == 0)
					{
						pairRes.ErrCode = ErrManager.ERR_NOT_INQUEUE;
						pairRes.Message = ErrManager.code2Msg(pairRes.ErrCode);
					}
					else
					{
						main_info = arrList[0];

						dbContext = new CarPoolDBDataContext();
						szQuery = "SELECT * FROM tbl_queue WHERE uid <> '" + queue_id
							+ "' AND group_no = '" + group_no
							+ "' AND deleted = 0";

						arrEnums = dbContext.ExecuteQuery<tbl_queue>(szQuery);
						arrList = arrEnums.ToList();

						if (arrList.Count == 0)
						{
							pairRes.ErrCode = ErrManager.ERR_NOT_INQUEUE;
							pairRes.Message = ErrManager.code2Msg(pairRes.ErrCode);
						}
						else
						{
							oppo_info = arrList[0];

							pairRes.ErrCode = ErrManager.ERR_NONE;
							pairRes.Message = ErrManager.code2Msg(ErrManager.ERR_NONE);
							pairRes.Name = getUserNameFromUid(oppo_info.user_id);
							pairRes.Destination = oppo_info.destination;
							pairRes.DstLat = (double)oppo_info.dst_latitude;
							pairRes.DstLon = (double)oppo_info.dst_longitude;
							pairRes.Count = oppo_info.people_num == null ? 1 : (int)oppo_info.people_num;
							pairRes.Color = oppo_info.top_color == null ? "NULL" : oppo_info.top_color;
							pairRes.GrpGender = (int)oppo_info.same_gender;
							pairRes.OtherFeature = oppo_info.other_features == null ? "NULL" : oppo_info.other_features;
							pairRes.SaveMoney = (double)main_info.savingmoney;
							pairRes.LostTime = (double)main_info.wastetime;
							pairRes.OffOrder = (int)main_info.off_order;
							pairRes.OppoID = oppo_info.user_id;

							if (((DateTime)oppo_info.queue_time).Ticks < ((DateTime)main_info.queue_time).Ticks)
								pairRes.QueueOrder = 1;
							else
								pairRes.QueueOrder = 0;

							pairRes.ErrCode = ErrManager.ERR_NONE;
							pairRes.Message = ErrManager.code2Msg(pairRes.ErrCode);
						}
					}
				}
			}
			catch (System.Exception ex)
			{
				CommMisc.LogErrors(ex.Message);

				pairRes.ErrCode = ErrManager.ERR_FAILURE;
				pairRes.Message = ex.Message;
			}

			return pairRes;
		}

		public static StringContainer changeUserCredits(long userID, int nVal)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			StringContainer szRes = new StringContainer();
			String szQuery = String.Empty;
			IEnumerable<tbl_user> arrEnums = null;
			IList<tbl_user> arrList = null;
			tbl_user userInfo = null;

			try
			{
				szQuery = "SELECT * FROM tbl_user WHERE uid = " + userID;

				arrEnums = dbContext.ExecuteQuery<tbl_user>(szQuery);
				arrList = arrEnums.ToList();
				userInfo = arrList[0];

				userInfo.credits += nVal;

				szQuery = "UPDATE tbl_user SET credits = " + userInfo.credits + " WHERE uid = " + userID;

				if (dbContext.ExecuteCommand(szQuery) == 1)
					szRes.Result = ErrManager.ERR_NONE;
				else
					szRes.Result = ErrManager.ERR_SQLQUERY;

				szRes.Message = ErrManager.code2Msg(szRes.Result);
			}
			catch (System.Exception ex)
			{
				CommMisc.LogErrors(ex.Message);

				szRes.Result = ErrManager.ERR_UNKNOWN;
				szRes.Message = ex.Message;
			}

			return szRes;
		}

		public static StringContainer IsReservedUser(String phone_num)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			StringContainer szRes = new StringContainer();
			String szQuery = String.Empty;
			IEnumerable<tbl_smslog> arrEnums = null;
			IList<tbl_smslog> arrList = null;
			tbl_smslog log_item = null;

			try
			{
				szQuery = "SELECT * FROM tbl_smslog WHERE valid = 1";

				arrEnums = dbContext.ExecuteQuery<tbl_smslog>(szQuery);
				arrList = arrEnums.ToList();

				for (int i = 0; i < arrList.Count; i++)
				{
					if (isSamePhoneNum(arrList[i].receiver, phone_num))
					{
						log_item = arrList[i];
						break;
					}
				}

				if (log_item == null)
					szRes.Result = ErrManager.ERR_FAILURE;
				else
					szRes.Result = log_item.user_id;

				szRes.Message = ErrManager.code2Msg(szRes.Result);
			}
			catch (System.Exception ex)
			{
				CommMisc.LogErrors(ex.Message);

				szRes.Result = ErrManager.ERR_UNKNOWN;
				szRes.Message = ex.Message;
			}

			return szRes;
		}

		public static bool isSamePhoneNum(String str1, String str2)
		{
			String str_temp1 = removeNonNumeric(str1);
			String str_temp2 = removeNonNumeric(str2);

			return str_temp1.Equals(str_temp2);
		}

		public static String removeNonNumeric(String szValue)
		{
			List<char> arrChars = szValue.ToList<char>();
			for (int i = arrChars.Count - 1; i >= 0; i--)
			{
				if ('0' > arrChars[i] || arrChars[i] > '9')
					arrChars.RemoveAt(i);
			}

			return new String(arrChars.ToArray());
		}

		public static StringContainer updateSMSLogValidState(long nUid)
		{
			StringContainer szRes = new StringContainer();

			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			String szQuery = String.Empty;

			try
			{
				szQuery = "UPDATE tbl_smslog SET valid = 0 WHERE user_id = '" + nUid + "'";

				dbContext.ExecuteCommand(szQuery);

				szRes.Result = ErrManager.ERR_NONE;
				szRes.Message = ErrManager.code2Msg(szRes.Result);
			}
			catch (System.Exception ex)
			{
				CommMisc.LogErrors(ex.Message);

				szRes.Result = ErrManager.ERR_UNKNOWN;
				szRes.Message = ex.Message;
			}

			return szRes;
		}

		public static StringContainer resetUserState(long queue_id)
		{
			StringContainer szRes = null;
			szRes = Global.updateUserState(queue_id, (int)UserState.USERSTATE_REQUEST);
			if (szRes.Result != ErrManager.ERR_NONE)
				return szRes;

			szRes = Global.updateUserAgreeState(queue_id, (int)AgreeState.OPPO_NOREPLY);
			if (szRes.Result != ErrManager.ERR_NONE)
				return szRes;

			szRes = Global.updateGroupNo(queue_id, 0);
			if (szRes.Result != ErrManager.ERR_NONE)
				return szRes;

			szRes = Global.updateOffOrder(queue_id, 0);
			if (szRes.Result != ErrManager.ERR_NONE)
				return szRes;

			szRes = Global.updateSavingMoney(queue_id, 0);
			if (szRes.Result != ErrManager.ERR_NONE)
				return szRes;

			szRes = Global.updateWasteTime(queue_id, 0);

			return szRes;
		}

		/// <summary>
		/// Update user state in tbl_queue
		/// </summary>
		/// <param name="dbContext"></param>
		/// <param name="uid"></param>
		/// <param name="nState"></param>
		/// <returns></returns>
		public static StringContainer updateUserState(long queue_id, int nState)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			StringContainer szRes = new StringContainer();
			String szQuery = String.Empty;

			try
			{
				szQuery = "UPDATE tbl_queue SET state = '" + nState
					+ "' WHERE uid = '" + queue_id
					+ "' AND deleted = 0";

				if (dbContext.ExecuteCommand(szQuery) != 1)
					szRes.Result = ErrManager.ERR_NOT_INQUEUE;
				else
					szRes.Result = ErrManager.ERR_NONE;

				szRes.Message = ErrManager.code2Msg((int)szRes.Result);
			}
			catch (System.Exception ex)
			{
				CommMisc.LogErrors(ex.Message);

				szRes.Result = ErrManager.ERR_UNKNOWN;
				szRes.Message = ex.Message;
			}

			return szRes;
		}

		public static StringContainer updatePairedTimeFromQueueID(long queue_id, DateTime pairedTime)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			StringContainer szRes = new StringContainer();
			String szQuery = String.Empty;
			String szTime = DateTime2String(pairedTime, true, true, false, false);

			try
			{
				szQuery = "UPDATE tbl_queue SET pairedtime = '" + szTime + "' WHERE uid = " + queue_id;

				if (dbContext.ExecuteCommand(szQuery) != 1)
					szRes.Result = ErrManager.ERR_UNKNOWN;
				else
					szRes.Result = ErrManager.ERR_NONE;

				szRes.Message = ErrManager.code2Msg(szRes.Result);
			}
			catch (System.Exception ex)
			{
				CommMisc.LogErrors(ex.Message);

				szRes.Result = ErrManager.ERR_UNKNOWN;
				szRes.Message = ex.Message;
			}

			return szRes;
		}

		public static StringContainer updateLoginTime(long uid, DateTime time)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			StringContainer szRes = new StringContainer();
			String szQuery = String.Empty;
			String szTime = DateTime2String(time, true, true, false, false);

			try
			{
				szQuery = "UPDATE tbl_user SET last_login_date = '" + szTime + "' WHERE uid = '" + uid + "'";

				if (dbContext.ExecuteCommand(szQuery) != 1)
					szRes.Result = ErrManager.ERR_UNKNOWN;
				else
					szRes.Result = ErrManager.ERR_NONE;

				szRes.Message = ErrManager.code2Msg(szRes.Result);
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
		/// Function to update service response time of the user in queue
		/// </summary>
		/// <param name="dbContext"></param>
		/// <param name="queue_id"></param>
		/// <param name="time"></param>
		/// <returns></returns>
		public static StringContainer updateRespTime(long queue_id, DateTime time)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			StringContainer szRes = new StringContainer();
			String szQuery = String.Empty, szTime = DateTime2String(time, true, true, false, false);

			try
			{
				szQuery = "UPDATE tbl_queue SET resp_time = '" + szTime
					+ "' WHERE uid = '" + queue_id
					+ "' AND deleted = 0";

				if (dbContext.ExecuteCommand(szQuery) != 1)
					szRes.Result = ErrManager.ERR_FAILURE;
				else
					szRes.Result = ErrManager.ERR_NONE;

				szRes.Message = ErrManager.code2Msg((int)szRes.Result);
			}
			catch (System.Exception ex)
			{
				CommMisc.LogErrors(ex.Message);

				szRes.Result = ErrManager.ERR_UNKNOWN;
				szRes.Message = ex.Message;
			}


			return szRes;
		}

		public static StringContainer updateLastReqTime(long queue_id, DateTime time)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			StringContainer szRes = new StringContainer();
			String szQuery = String.Empty;
			String szTime = DateTime2String(time, true, true, false, false);
			int nRes = 0;

			try
			{
				szQuery = "UPDATE tbl_queue SET lastreqtime = '" + szTime + "' WHERE uid = " + queue_id + " AND deleted = 0";

				nRes = dbContext.ExecuteCommand(szQuery);
				if (nRes == 1)
					szRes.Result = ErrManager.ERR_NONE;
				else
					szRes.Result = ErrManager.ERR_UPDATE_LASTREQTIME;

				szRes.Message = ErrManager.code2Msg(szRes.Result);
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
		/// Function to get 
		/// </summary>
		/// <param name="?"></param>
		/// <param name="agree"></param>
		/// <returns></returns>
		public static StringContainer updateUserAgreeState(long queue_id, int agree)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			StringContainer szRes = new StringContainer();
			String szQuery = String.Empty;

			try
			{
				szQuery = "UPDATE tbl_queue SET agree_state = " + agree.ToString()
					+ " WHERE uid = " + queue_id
					+ " AND deleted = 0";

				if (dbContext.ExecuteCommand(szQuery) != 1)
					szRes.Result = ErrManager.ERR_UPDATE_USERAGREE_FAILED;
				else
					szRes.Result = ErrManager.ERR_NONE;

				szRes.Message = ErrManager.code2Msg((int)szRes.Result);
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
		/// Function to update group_no field of data base
		/// </summary>
		/// <param name="dbContext"></param>
		/// <param name="queue_id"></param>
		/// <param name="agree"></param>
		/// <returns></returns>
		public static StringContainer updateGroupNo(long queue_id, int nGroupNo)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			StringContainer szRes = new StringContainer();
			String szQuery = String.Empty;
			int nRes = 0;

			try
			{
				szQuery = "UPDATE tbl_queue SET group_no = " + nGroupNo + " WHERE uid = " + queue_id;

				nRes = dbContext.ExecuteCommand(szQuery);

				if (nRes != 1)
					szRes.Result = ErrManager.ERR_INVALID_USER;
				else
					szRes.Result = ErrManager.ERR_NONE;

				szRes.Message = ErrManager.code2Msg(szRes.Result);

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
		/// Function to update off_order field of tbl_queue
		/// </summary>
		/// <param name="dbContext"></param>
		/// <param name="queue_id"></param>
		/// <param name="off_order"></param>
		/// <returns></returns>
		public static StringContainer updateOffOrder(long queue_id, int off_order)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			StringContainer szRes = new StringContainer();
			String szQuery = String.Empty;
			int nRes = 0;

			try
			{
				szQuery = "UPDATE tbl_queue SET off_order = " + off_order + " WHERE uid = " + queue_id;

				nRes = dbContext.ExecuteCommand(szQuery);

				if (nRes != 1)
					szRes.Result = ErrManager.ERR_INVALID_USER;
				else
					szRes.Result = ErrManager.ERR_NONE;

				szRes.Message = ErrManager.code2Msg(szRes.Result);

			}
			catch (System.Exception ex)
			{
				CommMisc.LogErrors(ex.Message);

				szRes.Result = ErrManager.ERR_UNKNOWN;
				szRes.Message = ErrManager.code2Msg(szRes.Result);

			}

			return szRes;
		}

		/// <summary>
		/// Function to update savingmoney field of tbl_queue
		/// </summary>
		/// <param name="dbContext"></param>
		/// <param name="queue_id"></param>
		/// <param name="off_order"></param>
		/// <returns></returns>
		public static StringContainer updateSavingMoney(long queue_id, double savingmoney)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			StringContainer szRes = new StringContainer();
			String szQuery = String.Empty;
			int nRes = 0;

			try
			{
				szQuery = "UPDATE tbl_queue SET savingmoney = " + savingmoney + " WHERE uid = " + queue_id;

				nRes = dbContext.ExecuteCommand(szQuery);

				if (nRes != 1)
					szRes.Result = ErrManager.ERR_INVALID_USER;
				else
					szRes.Result = ErrManager.ERR_NONE;

				szRes.Message = ErrManager.code2Msg(szRes.Result);

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
		/// Function to update wastetime field of tbl_queue
		/// </summary>
		/// <param name="dbContext"></param>
		/// <param name="queue_id"></param>
		/// <param name="off_order"></param>
		/// <returns></returns>
		public static StringContainer updateWasteTime(long queue_id, double wastetime)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			StringContainer szRes = new StringContainer();
			String szQuery = String.Empty;
			int nRes = 0;

			try
			{
				szQuery = "UPDATE tbl_queue SET wastetime = " + wastetime + " WHERE uid = " + queue_id;

				nRes = dbContext.ExecuteCommand(szQuery);

				if (nRes != 1)
					szRes.Result = ErrManager.ERR_INVALID_USER;
				else
					szRes.Result = ErrManager.ERR_NONE;

				szRes.Message = ErrManager.code2Msg(szRes.Result);

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
		/// Function to get paired state of a user
		/// </summary>
		/// <param name="dbContext"></param>
		/// <param name="queue_id"></param>
		/// <returns></returns>
		public static int getPairedState(long queue_id)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			int nRes = 0;
			String szQuery = String.Empty;
			IEnumerable<tbl_queue> arrEnums = null;
			IList<tbl_queue> arrList = null;

			try
			{
				szQuery = "SELECT * FROM tbl_queue WHERE uid = '" + queue_id + "'";

				arrEnums = dbContext.ExecuteQuery<tbl_queue>(szQuery);
				arrList = arrEnums.ToList();

				if (arrList.Count == 0)
					nRes = 0;
				else
					nRes = arrList[0].state == null ? 0 : (int)arrList[0].state;
			}
			catch (Exception ex)
			{
				CommMisc.LogErrors(ex.Message);
				nRes = 0;
			}

			return nRes;
		}

		/// <summary>
		/// Get group no from queue id
		/// </summary>
		/// <param name="dbContext"></param>
		/// <param name="queue_id"></param>
		/// <returns></returns>
		public static int getGroupNo(long queue_id)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			int nRes = 0;
			String szQuery = String.Empty;
			IEnumerable<int> arrEnums = null;
			IList<int> arrList = null;

			try
			{
				szQuery = "SELECT group_no FROM tbl_queue WHERE uid = " + queue_id + " AND deleted = 0";

				arrEnums = dbContext.ExecuteQuery<int>(szQuery);
				arrList = arrEnums.ToList();
				if (arrList.Count() != 0)
					nRes = arrList[0];
			}
			catch (Exception ex)
			{
				CommMisc.LogErrors(ex.Message);
				nRes = 0;
			}

			return nRes;
		}

		/// <summary>
		/// Get user id from user auth info
		/// </summary>
		/// <param name="dbContext"></param>
		/// <param name="userAuth"></param>
		/// <returns></returns>
		public static StringContainer getUserIDFromAuth(STAuthUser userAuth)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			StringContainer szRes = new StringContainer();
			String szQuery = String.Empty;
			IEnumerable<tbl_user> arrEnums = null;
			IList<tbl_user> arrList = null;

			try
			{
				szQuery = "SELECT * FROM tbl_user WHERE " +
					"email_address = '" + userAuth.Email + "' AND " +
					"password = '" + userAuth.Password + "' AND deleted = 0";

				arrEnums = dbContext.ExecuteQuery<tbl_user>(szQuery);
				arrList = arrEnums.ToList();

				if (arrList.Count == 0)
				{
					szRes.Result = ErrManager.ERR_FAILURE;
					szRes.Message = ErrManager.code2Msg((int)szRes.Result);
				}
				else
				{
					szRes.Result = arrList[0].uid;
					szRes.Message = ErrManager.code2Msg(ErrManager.ERR_NONE);
				}
			}
			catch (System.Exception ex)
			{
				CommMisc.LogErrors(ex.Message);
				szRes.Result = ErrManager.ERR_FAILURE;
				szRes.Message = ErrManager.code2Msg((int)szRes.Result);
			}

			return szRes;
		}

		/// <summary>
		/// If already found a pair, return the opposite queue id
		/// </summary>
		/// <param name="dbContext"></param>
		/// <param name="queue_id"></param>
		/// <returns></returns>
		public static StringContainer getOppoQueueID(long queue_id)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			StringContainer szRes = new StringContainer();
			String szQuery = String.Empty;
			int nGroupNo = 0;
			IEnumerable<tbl_queue> arrEnums = null;
			IList<tbl_queue> arrList = null;

			try
			{
				nGroupNo = getGroupNo(queue_id);

				if (nGroupNo <= 0)
				{
					szRes.Result = ErrManager.ERR_NO_PAIR;
					szRes.Message = ErrManager.code2Msg(szRes.Result);
				}
				else
				{
					szQuery = "SELECT * FROM tbl_queue WHERE uid <> '" + queue_id
						+ "' AND group_no = '" + nGroupNo + "'"
						+ " AND deleted = 0";

					arrEnums = dbContext.ExecuteQuery<tbl_queue>(szQuery);
					arrList = arrEnums.ToList();

					if (arrList.Count == 0)
					{
						szRes.Result = ErrManager.ERR_OPPO_ALREADY_REMOVED;
						szRes.Message = ErrManager.code2Msg(szRes.Result);
					}
					else
					{
						szRes.Result = arrList[0].uid;
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

		public static String getImagePathFromUID(long uid)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			String szPath = String.Empty;
			String szQuery = String.Empty;
			IEnumerable<String> arrEnums = null;
			IList<String> arrList = null;

			try
			{
				szQuery = "SELECT image_path FROM tbl_user WHERE uid = " + uid + " AND deleted = 0";

				arrEnums = dbContext.ExecuteQuery<String>(szQuery);
				arrList = arrEnums.ToList();
				szPath = arrList[0];
			}
			catch (System.Exception ex)
			{
				CommMisc.LogErrors(ex.Message);
				szPath = String.Empty;
			}

			return szPath;
		}

		public static String getImageDataFromFile(String szPath)
		{
			String szImageData = String.Empty;

			try
			{
				szImageData = File.ReadAllText(szPath);
			}
			catch (System.Exception ex)
			{
				CommMisc.LogErrors(ex.Message);
				szImageData = String.Empty;
			}

			return szImageData;
		}

		public static String generateRandomPassword(int size)
		{
			Random _rng = new Random();
			string _chars = "0123456789";
			char[] buffer = new char[size];

			for (int i = 0; i < size; i++)
				buffer[i] = _chars[_rng.Next(_chars.Length)];

			return new string(buffer);
		}

		public static StringContainer updateUserPassword(String email, String password)
		{
			StringContainer szRes = new StringContainer();
			String szQuery = String.Empty;
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			int nResCnt = 0;

			try
			{
				szQuery = "UPDATE tbl_user SET password = '" + password + "' WHERE email_address = '" + email + "' AND deleted = 0";
				nResCnt = dbContext.ExecuteCommand(szQuery);

				if (nResCnt == 1)
					szRes.Result = ErrManager.ERR_NONE;
				else
					szRes.Result = ErrManager.ERR_FAILURE;

				szRes.Message = ErrManager.code2Msg(szRes.Result);
			}
			catch (System.Exception ex)
			{
				CommMisc.LogErrors(ex.Message);

				szRes.Result = ErrManager.ERR_UNKNOWN;
				szRes.Message = ex.Message;
			}

			return szRes;
		}

		public static bool sendEmail(String email_addr, String title, String content)
		{
			MailMessage msg = new MailMessage();
			bool bSuc = true;

			try
			{
				msg.From = new MailAddress(gmailAccount);
				msg.To.Add(email_addr);
				msg.Subject = title;
				msg.Body = content;

				SmtpClient client = new SmtpClient();
				client.EnableSsl = true;
				client.UseDefaultCredentials = false;
				client.Credentials = new NetworkCredential(gmailAccount, gmailPwd);
				client.Host = "smtp.gmail.com";
				/*client.Port = 25;*/
				client.DeliveryMethod = SmtpDeliveryMethod.Network;

				client.Send(msg);
			}
			catch (Exception ex)
			{
				CommMisc.LogErrors(ex.Message);
				bSuc = false;
			}

			return bSuc;
		}

		public static double calcDist(double lat1, double lon1, double lat2, double lon2, char unit)
		{
			double theta = lon1 - lon2;
			double dist = Math.Sin(deg2rad(lat1)) * Math.Sin(deg2rad(lat2)) + Math.Cos(deg2rad(lat1)) * Math.Cos(deg2rad(lat2)) * Math.Cos(deg2rad(theta));
			dist = Math.Acos(dist);
			dist = rad2deg(dist);
			dist = dist * 60 * 1.1515;
			if (unit == 'K')
			{
				dist = dist * 1.609344;
			}
			else if (unit == 'N')
			{
				dist = dist * 0.8684;
			}

			return dist;
		}

		private static double deg2rad(double deg)
		{
			return (deg * Math.PI / 180.0);
		}

		private static double rad2deg(double rad)
		{
			return (rad / Math.PI * 180.0);
		}

		public static float GetRating(long Uid)
		{
			double fRating = 0;

			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			String szQuery = String.Empty;
			IEnumerable<tbl_serve> arrEnums = null;
			IList<tbl_serve> arrList = null;
			List<double> arrRatings = new List<double>();

			try
			{
				szQuery = "SELECT * FROM tbl_serve where user_id = " + Uid
					+ " OR user_id2 = " + Uid;

				arrEnums = dbContext.ExecuteQuery<tbl_serve>(szQuery);
				arrList = arrEnums.ToList();

				for (int i = 0; i < arrList.Count; i++)
				{
					if (arrList[i].user_id == Uid && arrList[i].score1 != null && arrList[i].score1 >= 0 && arrList[i].score1 <= 5)
						arrRatings.Add((double)arrList[i].score1);
					else if (arrList[i].user_id2 == Uid && arrList[i].score2 != null && arrList[i].score2 >= 0 && arrList[i].score2 <= 5)
						arrRatings.Add((double)arrList[i].score2);
				}

				for (int i = 0; i < arrRatings.Count; i++)
				{
					fRating += arrRatings[i];
				}

				if (arrRatings.Count != 0)
					fRating /= arrRatings.Count;

			}
			catch (System.Exception ex)
			{
				CommMisc.LogErrors(ex.Message);
				fRating = 0;
			}

			return (float)fRating;
		}

		public static void UpdateTotalSavingMoney(long uid, double fMoney)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			String szQuery = String.Empty;
			IEnumerable<tbl_user> arrEnums = null;
			IList<tbl_user> arrList = null;
			tbl_user userItem = null;
			double fTotalSaving = 0;

			try
			{
				szQuery = "SELECT * FROM tbl_user WHERE uid = " + uid + " AND deleted = 0";

				arrEnums = dbContext.ExecuteQuery<tbl_user>(szQuery);
				arrList = arrEnums.ToList();
				userItem = arrList[0];

				fTotalSaving = userItem.total_savings == null ? 0 : (double)userItem.total_savings;
				fTotalSaving += fMoney;

				szQuery = "UPDATE tbl_user SET total_savings = " + fTotalSaving + " WHERE uid = " + uid;
				dbContext.ExecuteCommand(szQuery);
			}
			catch (System.Exception ex)
			{
				CommMisc.LogErrors(ex.Message);
			}
		}

		public static String getTaxiStandNameFromID(long taxistand_id)
		{
			String szResult = null;
			String szQuery = String.Empty;
			IEnumerable<tbl_taxistand> arrEnums = null;
			IList<tbl_taxistand> arrList = null;
			tbl_taxistand taxistand = null;
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();

			try
			{
				szQuery = "SELECT * FROM tbl_taxistand WHERE uid = " + taxistand_id;

				arrEnums = dbContext.ExecuteQuery<tbl_taxistand>(szQuery);
				arrList = arrEnums.ToList();
				taxistand = arrList[0];

				szResult = taxistand.stand_name;
			}
			catch (System.Exception ex)
			{
				CommMisc.LogErrors(ex.Message);
			}

			return szResult;
		}

		public static StringContainer LogServe(long uid1,
			long uid2,
			String szStartPos,
			String szEndPos1,
			String szEndPos2,
			double savePrice1,
			double savePrice2,
			double wasteTime1,
			double wasteTime2,
			int offOrder1,
			int offOrder2,
			DateTime pairTime)
		{
			StringContainer szRes = new StringContainer();
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			String szQuery = String.Empty;

			try
			{
				szQuery = "INSERT INTO tbl_serve (user_id,user_id2,serve_date,start_pos,end_pos,end_pos2,saving_money,saving_money2,waste_time,waste_time2,off_order1,off_order2,score1,score2) values (" +
					"'" + uid1 + "'," +
					"'" + uid2 + "'," +
					"'" + DateTime2String(pairTime, true, true, false, false) + "'," +
					"'" + szStartPos + "'," +
					"'" + szEndPos1 + "'," +
					"'" + szEndPos2 + "'," +
					"'" + savePrice1 + "'," +
					"'" + savePrice2 + "'," +
					"'" + wasteTime1 + "'," +
					"'" + wasteTime2 + "'," +
					"'" + offOrder1 + "'," +
					"'" + offOrder1 + "'," +
					"'-1'," +
					"'-1')";

				if (dbContext.ExecuteCommand(szQuery) != 1)
					szRes.Result = ErrManager.ERR_LOG_SERVE_ERROR;
				else
					szRes.Result = ErrManager.ERR_NONE;

				szRes.Message = ErrManager.code2Msg(szRes.Result);
			}
			catch (Exception ex)
			{
				CommMisc.LogErrors(ex.Message);

				szRes.Result = ErrManager.ERR_UNKNOWN;
				szRes.Message = ex.Message;
			}

			return szRes;
		}

		public static long getTaxiStandIDFromQueueID(long nQueueID)
		{
			long nID = 0;

			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			String szQuery = String.Empty;
			IEnumerable<tbl_queue> arrEnums = null;
			IList<tbl_queue> arrList = null;
			tbl_queue queueItem = null;

			try
			{
				szQuery = "SELECT * FROM tbl_queue WHERE uid = " + nQueueID;
				arrEnums = dbContext.ExecuteQuery<tbl_queue>(szQuery);
				arrList = arrEnums.ToList();
				queueItem = arrList[0];

				nID = queueItem.taxistand_id;
			}
			catch (System.Exception ex)
			{
				CommMisc.LogErrors(ex.Message);
				nID = 0;
			}

			return nID;
		}

		public static double GetSavingFromQueueID(long nQueueID)
		{
			double fSaving = 0;

			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			String szQuery = String.Empty;
			IEnumerable<tbl_queue> arrEnums = null;
			IList<tbl_queue> arrList = null;
			tbl_queue queueItem = null;

			try
			{
				szQuery = "SELECT * FROM tbl_queue WHERE uid = " + nQueueID;
				arrEnums = dbContext.ExecuteQuery<tbl_queue>(szQuery);
				arrList = arrEnums.ToList();
				queueItem = arrList[0];

				fSaving = queueItem.savingmoney == null ? 0 : (double)queueItem.savingmoney;
			}
			catch (System.Exception ex)
			{
				CommMisc.LogErrors(ex.Message);
				fSaving = 0;
			}

			return fSaving;
		}

		public static double getWasteTimeFromQueueID(long nQueueID)
		{
			double fWasteTime = 0;

			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			String szQuery = String.Empty;
			IEnumerable<tbl_queue> arrEnums = null;
			IList<tbl_queue> arrList = null;
			tbl_queue queueItem = null;

			try
			{
				szQuery = "SELECT * FROM tbl_queue WHERE uid = " + nQueueID;
				arrEnums = dbContext.ExecuteQuery<tbl_queue>(szQuery);
				arrList = arrEnums.ToList();
				queueItem = arrList[0];

				fWasteTime = queueItem.wastetime == null ? 0 : (double)queueItem.wastetime;
			}
			catch (System.Exception ex)
			{
				CommMisc.LogErrors(ex.Message);
				fWasteTime = 0;
			}

			return fWasteTime;
		}

		public static int getOffOrderFromQueueID(long nQueueID)
		{
			int nOrder = 0;

			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			String szQuery = String.Empty;
			IEnumerable<tbl_queue> arrEnums = null;
			IList<tbl_queue> arrList = null;
			tbl_queue queueItem = null;

			try
			{
				szQuery = "SELECT * FROM tbl_queue WHERE uid = " + nQueueID;
				arrEnums = dbContext.ExecuteQuery<tbl_queue>(szQuery);
				arrList = arrEnums.ToList();
				queueItem = arrList[0];

				nOrder = queueItem.off_order == null ? 0 : (int)queueItem.off_order;
			}
			catch (System.Exception ex)
			{
				CommMisc.LogErrors(ex.Message);
				nOrder = 0;
			}

			return nOrder;
		}

        public static DateTime getQueueTimeFromQueueID(long nQueueID)
        {
            DateTime retTime = DateTime.MinValue;

            CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
            String szQuery = String.Empty;
            IEnumerable<tbl_queue> arrEnums = null;
            IList<tbl_queue> arrList = null;
            tbl_queue queueItem = null;

            try
            {
                szQuery = "SELECT * FROM tbl_queue WHERE uid = " + nQueueID;
                arrEnums = dbContext.ExecuteQuery<tbl_queue>(szQuery);
                arrList = arrEnums.ToList();
                queueItem = arrList[0];

                retTime = queueItem.queue_time == null ? DateTime.MinValue : (DateTime)queueItem.queue_time;
            }
            catch (System.Exception ex)
            {
                CommMisc.LogErrors(ex.Message);
            }

            return retTime;
        }



		public static String SaveImage(String szOrgPath, String szImageData)
		{
			if (szImageData == String.Empty || szImageData == null)
				return String.Empty;

			String newPath = szOrgPath;
			String szFileName = DateTime.Now.ToString("yyyyMMdd_HHmmss");

			if (newPath == null)
				newPath = "";

			if (newPath == String.Empty)
			{
#if true
				newPath = "D:\\Ride2Gather\\Site\\UploadPhotos\\" + szFileName;
#else
				newPath = "D:\\Work\\CarPool\\TempImage\\" + szFileName;
#endif
			}

			try
			{
				File.WriteAllText(newPath, szImageData);
			}
			catch (System.Exception ex)
			{
				CommMisc.LogErrors(ex.Message);
				newPath = String.Empty;
			}

			return newPath;
		}

		#endregion

	}
}