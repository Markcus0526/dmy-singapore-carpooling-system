using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace CarPoolService
{
	public class ErrInfo
	{
		int _errcode = 0;
		public int errCode
		{
			get { return _errcode; }
			set { _errcode = value; }
		}

		String _errmsg = "Success";
		public String errMsg
		{
			get { return _errmsg; }
			set { _errmsg = value; }
		}

		public ErrInfo(int err_code, String err_msg)
		{
			errCode = err_code;
			errMsg = err_msg;
		}

		public ErrInfo()
		{
			errCode = 0;
			errMsg = "Success";
		}
	}

	public class ErrManager
	{
#region Error Codes
		public static int ERR_NONE = 1;
		public static int ERR_FAILURE = -1;

		public static int ERR_PARAM = -2;
		public static int ERR_PARAM_NAME = -3;
		public static int ERR_CONN = -4;

		public static int ERR_USER_EXIST = -100;
		public static int ERR_REG_FAILED = -101;
		public static int ERR_LOGIN_FAILED = -102;
		public static int ERR_INVALID_USER = -103;
		public static int ERR_NO_PAIR = -104;
		public static int ERR_TAXISTAND_EXIST = -105;
		public static int ERR_ALREADY_RATED = -106;
		public static int ERR_SERVE_ISNOTFORUSER = -107;
		public static int ERR_RATE_UPDATE_FAILED = -108;
		public static int ERR_TAXISTAND_NOT_FOUND = -109;
		public static int ERR_LOG_SERVE_ERROR = -110;
		public static int ERR_ALREADY_SET_AGREESTATE = -111;
		public static int ERR_SQLQUERY = -112;
		public static int ERR_ALREADY_INQUEUE = -113;
		public static int ERR_INVALID_EMAIL = -114;
		public static int ERR_NOT_INQUEUE = -115;
		public static int ERR_INVALID_QUEUEID = -116;
		public static int ERR_NOTFOUND_TAXISTAND = -117;
		public static int ERR_OPPO_ALREADY_REMOVED = -118;
		public static int ERR_UPDATE_USERAGREE_FAILED = -119;
		public static int ERR_UPDATE_LASTREQTIME = -120;
		public static int ERR_TAXISTAND_UPDATE_SUCCESS = -121;
		public static int ERR_TAXISTAND_UPDATE_FAIL = -122;

		public static int ERR_UNKNOWN = -9999;
#endregion

		public static List<ErrInfo> m_arrErrInfos = new List<ErrInfo>();

		public static void initErrInfos()
		{
			m_arrErrInfos.Add(new ErrInfo(ERR_UNKNOWN,					"Unknown Error"));

			m_arrErrInfos.Add(new ErrInfo(ERR_NONE,						"Success"));
			m_arrErrInfos.Add(new ErrInfo(ERR_FAILURE,					"Failure"));
			m_arrErrInfos.Add(new ErrInfo(ERR_PARAM,					"Parameter error"));
			m_arrErrInfos.Add(new ErrInfo(ERR_PARAM_NAME,				"Input parameter name error"));
			m_arrErrInfos.Add(new ErrInfo(ERR_CONN,						"Connection error"));
			m_arrErrInfos.Add(new ErrInfo(ERR_USER_EXIST,				"User already exists"));
			m_arrErrInfos.Add(new ErrInfo(ERR_REG_FAILED,				"User register failed"));
			m_arrErrInfos.Add(new ErrInfo(ERR_LOGIN_FAILED,				"Wrong parameters"));
			m_arrErrInfos.Add(new ErrInfo(ERR_INVALID_USER,				"Invalid user"));
			m_arrErrInfos.Add(new ErrInfo(ERR_NO_PAIR,					"Still not found pair"));
			m_arrErrInfos.Add(new ErrInfo(ERR_TAXISTAND_EXIST,			"Taxi stand already exist"));
			m_arrErrInfos.Add(new ErrInfo(ERR_ALREADY_RATED,			"This user already rated for this serve"));
			m_arrErrInfos.Add(new ErrInfo(ERR_SERVE_ISNOTFORUSER,		"This serve is not for this user"));
			m_arrErrInfos.Add(new ErrInfo(ERR_RATE_UPDATE_FAILED,		"Rating failed"));
			m_arrErrInfos.Add(new ErrInfo(ERR_TAXISTAND_NOT_FOUND,		"Taxi stand not found"));
			m_arrErrInfos.Add(new ErrInfo(ERR_LOG_SERVE_ERROR,			"Logging serve info failed"));
			m_arrErrInfos.Add(new ErrInfo(ERR_ALREADY_SET_AGREESTATE,	"Already set agree state"));
			m_arrErrInfos.Add(new ErrInfo(ERR_SQLQUERY,					"Error while execute sql query"));
			m_arrErrInfos.Add(new ErrInfo(ERR_ALREADY_INQUEUE,			"User already exist in queue"));
			m_arrErrInfos.Add(new ErrInfo(ERR_INVALID_EMAIL,			"Not authenticated email"));
			m_arrErrInfos.Add(new ErrInfo(ERR_NOT_INQUEUE,				"User is not in the queue"));
			m_arrErrInfos.Add(new ErrInfo(ERR_INVALID_QUEUEID,			"Not valid queue id"));
			m_arrErrInfos.Add(new ErrInfo(ERR_NOTFOUND_TAXISTAND,		"Taxi stand not found"));
			m_arrErrInfos.Add(new ErrInfo(ERR_OPPO_ALREADY_REMOVED,		"Oppo already deleted"));
			m_arrErrInfos.Add(new ErrInfo(ERR_UPDATE_USERAGREE_FAILED,	"Updating user agree state on DB failed"));
			m_arrErrInfos.Add(new ErrInfo(ERR_UPDATE_LASTREQTIME,		"Updating user last request time on DB failed"));
			m_arrErrInfos.Add(new ErrInfo(ERR_TAXISTAND_UPDATE_SUCCESS, "Taxi stand information updated"));
			m_arrErrInfos.Add(new ErrInfo(ERR_TAXISTAND_UPDATE_FAIL,	"Taxi stand information update failed"));
		}

		public static String code2Msg(long err_code)
		{
			String szMsg = String.Empty;

			for (int i = 0; i < m_arrErrInfos.Count; i++)
			{
				if (m_arrErrInfos[i].errCode == err_code)
				{
					szMsg = m_arrErrInfos[i].errMsg;
					break;
				}
			}

			return szMsg;
		}
	}
}