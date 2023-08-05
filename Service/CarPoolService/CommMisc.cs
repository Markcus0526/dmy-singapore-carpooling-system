using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.IO;
using System.Configuration;
using System.Runtime.Serialization;
using CarPoolService.CarPoolDB;
using CarPoolService.DBManager;
using System.Threading;
using System.Security.Cryptography;
using System.Text;

namespace CarPoolService
{
    public class CommMisc
    {
        #region Field and Properties

        private static String strErrorFileName = "FSService.log";

        #endregion

        #region Public_Methods
        public static void LogErrors(String pMessage)
        {
            try
            {
                StreamWriter w = File.AppendText("C:\\" + strErrorFileName);
                w.WriteLine("{0}--{1}--{2}", DateTime.Now.ToShortDateString(), DateTime.Now.ToShortTimeString(), pMessage);
                w.Flush();
                w.Close();
            }
            catch (Exception ex)
            {
            }
        }

        /// <summary>
        /// Get Image Data From File
        /// </summary>
        /// <param name="ImgPath">Image Path</param>
        /// <returns>Represented String about Binary image data</returns>
        public static String GetImgData(String ImgPath)
        {
			String strImage = String.Empty;

            try
            {
                byte[] pImgBuf = null;
                FileStream imgStream = new FileStream(ImgPath, FileMode.Open);
                if (imgStream != null)
                {
                    pImgBuf = new byte[imgStream.Length];
                    imgStream.Read(pImgBuf, 0, (int)imgStream.Length);
                    imgStream.Close();

                    strImage = Convert.ToBase64String(pImgBuf);
                }
            }
            catch (System.Exception ex)
            {
                LogErrors(ex.ToString());
            }

            return strImage;
        }

        #endregion
    }

    [DataContract]
    public class StringContainer
    {
        long result = 0;
        [DataMember(Name = "Result")]
		public long Result
        {
            get { return result; }
            set { result = value; }
        }

		String message = String.Empty;
        [DataMember(Name = "Value")]
        public String Message
        {
            get { return message; }
            set { message = value; }
        }
    }

	[DataContract]
	public class STUserProfile
	{
		String username = String.Empty;
		[DataMember(Name = "UserName")]
		public String UserName
		{
			get { return username; }
			set { username = value; }
		}

		String phonenum = String.Empty;
		[DataMember(Name = "PhoneNum")]
		public String PhoneNum
		{
			get { return phonenum; }
			set { phonenum = value; }
		}

		String password = String.Empty;
		[DataMember(Name = "Password")]
		public String Password
		{
			get { return password; }
			set { password = value; }
		}

		int gender = 0;
		[DataMember(Name = "Gender")]
		public int Gender
		{
			get { return gender; }
			set { gender = value; }
		}

		int birth_year = 0;
		[DataMember(Name = "BirthYear")]
		public int BirthYear
		{
			get { return birth_year; }
			set { birth_year = value; }
		}

		String email = String.Empty;
		[DataMember(Name = "Email")]
		public String Email
		{
			get { return email; }
			set { email = value; }
		}

		int ind_gender = 0;
		[DataMember(Name = "IndGender")]
		public int IndGender
		{
			get { return ind_gender; }
			set { ind_gender = value; }
		}

		int grp_gender = 0;
		[DataMember(Name = "GrpGender")]
		public int GrpGender
		{
			get { return grp_gender; }
			set { grp_gender = value; }
		}

		int delay_time = 0;
		[DataMember(Name = "DelayTime")]
		public int DelayTime
		{
			get { return delay_time; }
			set { delay_time = value; }
		}

		String login_date = String.Empty;
		[DataMember(Name = "LoginDate")]
		public String LoginDate
		{
			get { return login_date; }
			set { login_date = value; }
		}

		int credit = 0;
		[DataMember(Name = "Credit")]
		public int Credit
		{
			get { return credit; }
			set { credit = value; }
		}

		String message = String.Empty;
		[DataMember(Name = "Message")]
		public String Message
		{
			get { return message; }
			set { message = value; }
		}

		int err_code = 0;
		[DataMember(Name = "ErrCode")]
		public int ErrCode
		{
			get { return err_code; }
			set { err_code = value; }
		}

		String image_data = String.Empty;
		[DataMember(Name = "ImageData")]
		public String ImageData
		{
			get { return image_data; }
			set { image_data = value; }
		}

		double star_count = 0;
		[DataMember(Name = "StarCount")]
		public double StarCount
		{
			get { return star_count; }
			set { star_count = value; }
		}

		long uid = 0;
		[DataMember(Name = "Uid")]
		public long Uid
		{
			get { return uid; }
			set { uid = value; }
		}

		double total_saving = 0;
		[DataMember(Name = "TotalSaving")]
		public double TotalSaving
		{
			get { return total_saving; }
			set { total_saving = value; }
		}

		int isGroup = 0;
		[DataMember(Name = "IsGroup")]
		public int IsGroup
		{
			get { return isGroup; }
			set { isGroup = value; }
		}
	}

	[DataContract]
	public class STAuthUser
	{
		String email = String.Empty;
		[DataMember(Name = "Email")]
		public String Email
		{
			get { return email; }
			set { email = value; }
		}

// 		String phonenum = String.Empty;
// 		[DataMember(Name = "PhoneNum")]
// 		public String PhoneNum
// 		{
// 			get { return phonenum; }
// 			set { phonenum = value; }
// 		}

		String password = String.Empty;
		[DataMember(Name = "Password")]
		public String Password
		{
			get { return password; }
			set { password = value; }
		}
	}

	[DataContract]
	public class STPairInfo
	{
		int uid = 0;
		[DataMember(Name = "Uid")]
		public int Uid
		{
			get { return uid; }
			set { uid = value; }
		}

		double srclat = 0;
		[DataMember(Name = "SrcLat")]
		public double SrcLat
		{
			get { return srclat; }
			set { srclat = value; }
		}

		double srclon = 0;
		[DataMember(Name = "SrcLon")]
		public double SrcLon
		{
			get { return srclon; }
			set { srclon = value; }
		}

		double dstlat = 0;
		[DataMember(Name = "DstLat")]
		public double DstLat
		{
			get { return dstlat; }
			set { dstlat = value; }
		}

		double dstlon = 0;
		[DataMember(Name = "DstLon")]
		public double DstLon
		{
			get { return dstlon; }
			set { dstlon = value; }
		}

		String destination = String.Empty;
		[DataMember(Name = "Destination")]
		public String Destination
		{
			get { return destination; }
			set { destination = value; }
		}

		int count = 0;
		[DataMember(Name = "Count")]
		public int Count
		{
			get { return count; }
			set { count = value; }
		}

		int grp_gender = 0;
		[DataMember(Name = "GrpGender")]
		public int GrpGender
		{
			get { return grp_gender; }
			set { grp_gender = value; }
		}

		String color = String.Empty;
		[DataMember(Name = "Color")]
		public String Color
		{
			get { return color; }
			set { color = value; }
		}

		String otherfeature = String.Empty;
		[DataMember(Name = "OtherFeature")]
		public String OtherFeature
		{
			get { return otherfeature; }
			set { otherfeature = value; }
		}
	}

	[DataContract]
	public class STPairAgree
	{
		long uid = 0;
		[DataMember(Name = "Uid")]
		public long Uid
		{
			get { return uid; }
			set { uid = value; }
		}

		bool is_agree = true;
		[DataMember(Name = "IsAgree")]
		public bool IsAgree
		{
			get { return is_agree; }
			set { is_agree = value; }
		}
	}

	[DataContract]
	public class STPairResponse
	{
		long oppo_id = 0;
		[DataMember(Name = "OppoID")]
		public long OppoID
		{
			get { return oppo_id; }
			set { oppo_id = value; }
		}

		int err_code = 0;
		[DataMember(Name = "ErrCode")]
		public int ErrCode
		{
			get { return err_code; }
			set { err_code = value; }
		}

		String message = String.Empty;
		[DataMember(Name = "Message")]
		public String Message
		{
			get { return message; }
			set { message = value; }
		}

		String name = String.Empty;
		[DataMember(Name = "Name")]
		public String Name
		{
			get { return name; }
			set { name = value; }
		}

		String destination = String.Empty;
		[DataMember(Name = "Destination")]
		public String Destination
		{
			get { return destination; }
			set { destination = value; }
		}

		double dst_lat = 0;
		[DataMember(Name = "DstLat")]
		public double DstLat
		{
			get { return dst_lat; }
			set { dst_lat = value; }
		}

		double dst_lon = 0;
		[DataMember(Name = "DstLon")]
		public double DstLon
		{
			get { return dst_lon; }
			set { dst_lon = value; }
		}

		int count = 0;
		[DataMember(Name = "Count")]
		public int Count
		{
			get { return count; }
			set { count = value; }
		}

		String color = String.Empty;
		[DataMember(Name = "Color")]
		public String Color
		{
			get { return color; }
			set { color = value; }
		}

		String otherfeature = String.Empty;
		[DataMember(Name = "OtherFeature")]
		public String OtherFeature
		{
			get { return otherfeature; }
			set { otherfeature = value; }
		}

		int grp_gender = 2;
		[DataMember(Name = "GrpGender")]
		public int GrpGender
		{
			get { return grp_gender; }
			set { grp_gender = value; }
		}

		double savemoney = 0;
		[DataMember(Name = "SaveMoney")]
		public double SaveMoney
		{
			get { return savemoney; }
			set { savemoney = value; }
		}

		double lost_time = 0;
		[DataMember(Name = "LostTime")]
		public double LostTime
		{
			get { return lost_time; }
			set { lost_time = value; }
		}

		int off_order = 0;
		[DataMember(Name = "OffOrder")]
		public int OffOrder
		{
			get { return off_order; }
			set { off_order = value; }
		}

		int queue_order = 0;
		[DataMember(Name = "QueueOrder")]
		public int QueueOrder
		{
			get { return queue_order; }
			set { queue_order = value; }
		}
	}

	[DataContract]
	public class STUserReg
	{
		String username = String.Empty;
		[DataMember(Name = "UserName")]
		public String UserName
		{
			get { return username; }
			set { username = value; }
		}

		String phonenum = String.Empty;
		[DataMember(Name = "PhoneNum")]
		public String PhoneNum
		{
			get { return phonenum; }
			set { phonenum = value; }
		}

		String password = String.Empty;
		[DataMember(Name = "Password")]
		public String Password
		{
			get { return password; }
			set { password = value; }
		}

		int gender = 0;
		[DataMember(Name = "Gender")]
		public int Gender
		{
			get { return gender; }
			set { gender = value; }
		}

		int birth_year = 0;
		[DataMember(Name = "BirthYear")]
		public int BirthYear
		{
			get { return birth_year; }
			set { birth_year = value; }
		}

		String email = String.Empty;
		[DataMember(Name = "Email")]
		public String Email
		{
			get { return email; }
			set { email = value; }
		}

		int ind_gender = 0;
		[DataMember(Name = "IndGender")]
		public int IndGender
		{
			get { return ind_gender; }
			set { ind_gender = value; }
		}

		int grp_gender = 0;
		[DataMember(Name = "GrpGender")]
		public int GrpGender
		{
			get { return grp_gender; }
			set { grp_gender = value; }
		}

		int delaytime = 0;
		[DataMember(Name = "DelayTime")]
		public int DelayTime
		{
			get { return delaytime; }
			set { delaytime = value; }
		}

		String image_data = String.Empty;
		[DataMember(Name = "ImageData")]
		public String ImageData
		{
			get { return image_data; }
			set { image_data = value; }
		}
	}

	[DataContract]
	public class STUpdateProfile
	{
		int uid = 0;
		[DataMember(Name = "Uid")]
		public int Uid
		{
			get { return uid; }
			set { uid = value; }
		}

		bool is_carpool = true;
		[DataMember(Name = "IsCarPool")]
		public bool IsCarPool
		{
			get { return is_carpool; }
			set { is_carpool = value; }
		}

		int ind_gender = 0;
		[DataMember(Name = "IndGender")]
		public int IndGender
		{
			get { return ind_gender; }
			set { ind_gender = value; }
		}

		int grp_gender = 0;
		[DataMember(Name = "GrpGender")]
		public int GrpGender
		{
			get { return grp_gender; }
			set { grp_gender = value; }
		}

		int delay_time = 0;
		[DataMember(Name = "DelayTime")]
		public int DelayTime
		{
			get { return delay_time; }
			set { delay_time = value; }
		}
	}

	[DataContract]
	public class STTaxiStand
	{
		long uid = 0;
		[DataMember(Name = "Uid")]
		public long Uid
		{
			get { return uid; }
			set { uid = value; }
		}

		String stand_name = String.Empty;
		[DataMember(Name = "StandName")]
		public String StandName
		{
			get { return stand_name; }
			set { stand_name = value; }
		}

		String gps_addr = String.Empty;
		[DataMember(Name = "GpsAddress")]
		public String GpsAddress
		{
			get { return gps_addr; }
			set { gps_addr = value; }
		}

		double longitude = 0;
		[DataMember(Name = "Longitude")]
		public double Longitude
		{
			get { return longitude; }
			set { longitude = value; }
		}

		double latitude = 0;
		[DataMember(Name = "Latitude")]
		public double Latitude
		{
			get { return latitude; }
			set { latitude = value; }
		}

		String stand_type = String.Empty;
		[DataMember(Name = "StandType")]
		public String StandType
		{
			get { return stand_type; }
			set { stand_type = value; }
		}

		String stand_no = String.Empty;
		[DataMember(Name = "StandNo")]
		public String StandNo
		{
			get { return stand_no; }
			set { stand_no = value; }
		}

		String postcode = String.Empty;
		[DataMember(Name = "PostCode")]
		public String PostCode
		{
			get { return postcode; }
			set { postcode = value; }
		}
	}

	[DataContract]
	public class STResetPassword
	{
		int uid = 0;
		[DataMember(Name = "Uid")]
		public int Uid
		{
			get { return uid; }
			set { uid = value; }
		}

		String email = String.Empty;
		[DataMember(Name = "Email")]
		public String NewPassword
		{
			get { return email; }
			set { email = value; }
		}
	}

	[DataContract]
	public class STLoginResult
	{
		long res_code = 0;
		[DataMember(Name = "ResultCode")]
		public long ResultCode
		{
			get { return res_code; }
			set { res_code = value; }
		}

		String name = String.Empty;
		[DataMember(Name = "Name")]
		public String Name
		{
			get { return name; }
			set { name = value; }
		}

		String message = String.Empty;
		[DataMember(Name = "Message")]
		public String Message
		{
			get { return message; }
			set { message = value; }
		}

		int firstlogin = 0;
		[DataMember(Name = "FirstLogin")]
		public int FirstLogin
		{
			get { return firstlogin; }
			set { firstlogin = value; }
		}
	}

	[DataContract]
	public class STFLAuthInfo
	{
		String name = String.Empty;
		[DataMember(Name = "Name")]
		public String Name
		{
			get { return name; }
			set { name = value; }
		}

		String email = String.Empty;
		[DataMember(Name = "Email")]
		public String Email
		{
			get { return email; }
			set { email = value; }
		}

		int gender = 0;
		[DataMember(Name = "Gender")]
		public int Gender
		{
			get { return gender; }
			set { gender = value; }
		}

		int birth_year = 0;
		[DataMember(Name = "BirthYear")]
		public int BirthYear
		{
			get { return birth_year; }
			set { birth_year = value; }
		}

		String phone_num = String.Empty;
		[DataMember(Name = "PhoneNum")]
		public String PhoneNum
		{
			get { return phone_num; }
			set { phone_num = value; }
		}

		String image_data = String.Empty;
		[DataMember(Name = "ImageData")]
		public String ImageData
		{
			get { return image_data; }
			set { image_data = value; }
		}
	}

	[DataContract]
	public class STPairHistory
	{
		String pair_time = String.Empty;
		[DataMember(Name = "PairingTime")]
		public String PairingTime
		{
			get { return pair_time; }
			set { pair_time = value; }
		}

		long uid1 = 0;
		[DataMember(Name = "Uid1")]
		public long Uid1
		{
			get { return uid1; }
			set { uid1 = value; }
		}

		long uid2 = 0;
		[DataMember(Name = "Uid2")]
		public long Uid2
		{
			get { return uid2; }
			set { uid2 = value; }
		}

		String name1 = String.Empty;
		[DataMember(Name = "Name1")]
		public String Name1
		{
			get { return name1; }
			set { name1 = value; }
		}

		String name2 = String.Empty;
		[DataMember(Name = "Name2")]
		public String Name2
		{
			get { return name2; }
			set { name2 = value; }
		}

		String src_addr = String.Empty;
		[DataMember(Name = "SrcAddr")]
		public String SrcAddr
		{
			get { return src_addr; }
			set { src_addr = value; }
		}

		String dst_addr1 = String.Empty;
		[DataMember(Name = "DstAddr1")]
		public String DstAddr1
		{
			get { return dst_addr1; }
			set { dst_addr1 = value; }
		}

		String dst_addr2 = String.Empty;
		[DataMember(Name = "DstAddr2")]
		public String DstAddr2
		{
			get { return dst_addr2; }
			set { dst_addr2 = value; }
		}

		double waste_time = 0;
		[DataMember(Name = "WasteTime")]
		public double WasteTime
		{
			get { return waste_time; }
			set { waste_time = value; }
		}

		int off_order = 0;
		[DataMember(Name = "OffOrder")]
		public int OffOrder
		{
			get { return off_order; }
			set { off_order = value; }
		}

		double save_price = 0;
		[DataMember(Name = "SavePrice")]
		public double SavePrice
		{
			get { return save_price; }
			set { save_price = value; }
		}

		double score1 = 0;
		[DataMember(Name = "Score1")]
		public double Score1
		{
			get { return score1; }
			set { score1 = value; }
		}

		double score2 = 0;
		[DataMember(Name = "Score2")]
		public double Score2
		{
			get { return score2; }
			set { score2 = value; }
		}

		int gender1 = 0;
		[DataMember(Name = "Gender1")]
		public int Gender1
		{
			get { return gender1; }
			set { gender1 = value; }
		}

		int gender2 = 0;
		[DataMember(Name = "Gender2")]
		public int Gender2
		{
			get { return gender2; }
			set { gender2 = value; }
		}
	}

	[DataContract]
	public class STPairHistoryCount
	{
		long errcode = 0;
		[DataMember(Name = "ErrCode")]
		public long ErrCode
		{
			get { return errcode; }
			set { errcode = value; }
		}

		String message = String.Empty;
		[DataMember(Name = "Message")]
		public String Message
		{
			get { return message; }
			set { message = value; }
		}

		long total_count = 0;
		[DataMember(Name = "TotalCount")]
		public long TotalCount
		{
			get { return total_count; }
			set { total_count = value; }
		}

		double total_saving = 0;
		[DataMember(Name = "TotalSaving")]
		public double TotalSaving
		{
			get { return total_saving; }
			set { total_saving = value; }
		}
	}

	[DataContract]
	public class STReqPairHistory
	{
		long uid = 0;
		[DataMember(Name = "Uid")]
		public long Uid
		{
			get { return uid; }
			set { uid = value; }
		}

		long pageno = 0;
		[DataMember(Name = "PageNo")]
		public long PageNo
		{
			get { return pageno; }
			set { pageno = value; }
		}
	}

	[DataContract]
	public class STEvaluate
	{
		long uid = 0;
		[DataMember(Name = "Uid")]
		public long Uid
		{
			get { return uid; }
			set { uid = value; }
		}

		long oppo_uid = 0;
		[DataMember(Name = "OppoID")]
		public long OppoID
		{
			get { return oppo_uid; }
			set { oppo_uid = value; }
		}

		double score = 0;
		[DataMember(Name = "Score")]
		public double Score
		{
			get { return score; }
			set { score = value; }
		}

		String servetime = String.Empty;
		[DataMember(Name = "ServeTime")]
		public String ServeTime
		{
			get { return servetime; }
			set { servetime = value; }
		}
	}

	[DataContract]
	public class STReqTaxiStand
	{
		long uid = 0;
		[DataMember(Name = "Uid")]
		public long Uid
		{
			get { return uid; }
			set { uid = value; }
		}

		double lon = 0;
		[DataMember(Name = "Longitude")]
		public double Longitude
		{
			get { return lon; }
			set { lon = value; }
		}

		double lat = 0;
		[DataMember(Name = "Latitude")]
		public double Latitude
		{
			get { return lat; }
			set { lat = value; }
		}

		String keyword = String.Empty;
		[DataMember(Name = "Keyword")]
		public String Keyword
		{
			get { return keyword; }
			set { keyword = value; }
		}
	}

	[DataContract]
	public class STReqResetPassword
	{
		String email = String.Empty;
		[DataMember(Name = "Email")]
		public String Email
		{
			get { return email; }
			set { email = value; }
		}
	}

	[DataContract]
	public class STTaxiStandResp
	{
		long err_code = 0;
		[DataMember(Name = "Result")]
		public long Result
		{
			get { return err_code; }
			set { err_code = value; }
		}

		String msg = String.Empty;
		[DataMember(Name = "Message")]
		public String Message
		{
			get { return msg; }
			set { msg = value; }
		}

		STTaxiStand taxistand = new STTaxiStand();
		[DataMember(Name = "TaxiStand")]
		public STTaxiStand TaxiStand
		{
			get { return taxistand; }
			set { taxistand = value; }
		}
	}

	[DataContract]
	public class STAgreeResponse
	{
		int err_code = 0;
		[DataMember(Name = "ErrCode")]
		public int ErrCode
		{
			get { return err_code; }
			set { err_code = value; }
		}

		String msg = String.Empty;
		[DataMember(Name = "Message")]
		public String Message
		{
			get { return msg; }
			set { msg = value; }
		}

		String time = String.Empty;
		[DataMember(Name = "PairTime")]
		public String PairTime
		{
			get { return time; }
			set { time = value; }
		}
	}

	[DataContract]
	public class STSendSMS
	{
		long uid = 0;
		[DataMember(Name = "Uid")]
		public long Uid
		{
			get { return uid; }
			set { uid = value; }
		}

		String phone_num = String.Empty;
		[DataMember(Name = "PhoneNum")]
		public String PhoneNum
		{
			get { return phone_num; }
			set { phone_num = value; }
		}
	}

	[DataContract]
	public class STShareLog
	{
		long user_id = 0;
		[DataMember(Name = "UserID")]
		public long UserID
		{
			get { return user_id; }
			set { user_id = value; }
		}

		String content = String.Empty;
		[DataMember(Name = "Content")]
		public String Content
		{
			get { return content; }
			set { content = value; }
		}
	}
}
