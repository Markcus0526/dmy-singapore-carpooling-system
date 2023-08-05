using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Runtime.Serialization;
using CarPoolService.CarPoolDB;

namespace CarPoolService.DBManager
{
    #region DATA_CONTRACT_STQueue
    [DataContract]
    public class STQueue
    {
        int id = 0;
        [DataMember(Name = "Id")]
        public int Id
        {
            get { return id; }
            set { id = value; }
        }

        String entertime = "";
        [DataMember(Name = "EnterTime")]
        public String EnterTime
        {
            get { return entertime; }
            set { entertime = value; }
        }

        int userid = 0;
        [DataMember(Name = "UserId")]
        public int UserId
        {
            get { return userid; }
            set { userid = value; }
        }

        int peoplenum = 0;
        [DataMember(Name = "PeopleNum")]
        public int PeopleNum
        {
            get { return peoplenum; }
            set { peoplenum = value; }
        }

        int samegender = 0;
        [DataMember(Name = "SameGender")]
        public int SameGender
        {
            get { return samegender; }
            set { samegender = value; }
        }

        String topcolor = "";
        [DataMember(Name = "TopColor")]
        public String TopColor
        {
            get { return topcolor; }
            set { topcolor = value; }
        }

        String otherfeature = "";
        [DataMember(Name = "OtherFeature")]
        public String OtherFeature
        {
            get { return otherfeature; }
            set { otherfeature = value; }
        }

        int taxistandid = 0;
        [DataMember(Name = "TaxiStandId")]
        public int TaxiStandId
        {
            get { return taxistandid; }
            set { taxistandid = value; }
        }

        String destinaton = "";
        [DataMember(Name = "Destination")]
        public String Destination
        {
            get { return destinaton; }
            set { destinaton = value; }
        }

        int groupno = 0;
        [DataMember(Name = "GroupNo")]
        public int GroupNo
        {
            get { return groupno; }
            set { groupno = value; }
        }
    }
    #endregion

    public class DBQueue
    {
        #region Field and Properties
        #endregion

        #region Constructor

        public DBQueue()
        {
        }

        #endregion

        #region Public_Methods

		public STAgreeResponse RequestOppoAgree(long uid)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			STAgreeResponse szRes = new STAgreeResponse();
			StringContainer szTemp = null;
			String szQuery = String.Empty;
			long queue_id = 0;

			try
			{
				szTemp = Global.getQueueIDFromUserID(uid);
				if (szTemp.Result <= 0)
				{
#if true
					szRes.ErrCode = (int)AgreeState.OPPO_DISAGREE;
					szRes.Message = szTemp.Message;
#else
					szRes.ErrCode = (int)szTemp.Result;
					szRes.Message = szTemp.Message;
#endif
				}
				else
				{
					queue_id = szTemp.Result;
					szTemp = Global.updateLastReqTime(queue_id, DateTime.Now);
					if (szTemp.Result != ErrManager.ERR_NONE)
					{
						szRes.ErrCode = (int)szTemp.Result;
						szRes.Message = szTemp.Message;
					}
					else
						szRes = Global.getOppoAgreeState(queue_id);
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

        #endregion

        #region Private_Methods


        #endregion
    }
}