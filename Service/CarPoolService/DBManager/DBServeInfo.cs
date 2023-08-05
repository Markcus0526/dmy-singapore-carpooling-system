using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Runtime.Serialization;
using CarPoolService.CarPoolDB;

namespace CarPoolService.DBManager
{
    #region DATA_CONTRACT_STServeInfo
    [DataContract]
    public class STServeInfo
    {
        int id = 0;
        [DataMember(Name = "Id")]
        public int Id
        {
            get { return id; }
            set { id = value; }
        }
        
        int userid = 0;
        [DataMember(Name = "UserId")]
        public int UserId
        {
            get { return userid; }
            set { userid = value; }
        }
        
        String servedate = "";
        [DataMember(Name = "ServeDate")]
        public String ServeDate
        {
            get { return servedate; }
            set { servedate = value; }
        }

        String startpos = "";
        [DataMember(Name = "StartPos")]
        public String StartPos
        {
            get { return startpos; }
            set { startpos = value; }
        }
        
        String endpos = "";
        [DataMember(Name = "EndPos")]
        public String EndPos
        {
            get { return endpos; }
            set { endpos = value; }
        }

        float savingmoney = 0;
        [DataMember(Name = "SavingMoney")]
        public float SavingMoney
        {
            get { return savingmoney; }
            set { savingmoney = value; }
        }

        int score = 0;
        [DataMember(Name = "Score")]
        public int Score
        {
            get { return score; }
            set { score = value; }
        }
    }
    #endregion

    public class DBServeInfo
    {
        #region Field and Properties
        #endregion

        #region Constructor

        public DBServeInfo()
        {
        }

        #endregion

        #region Public_Methods
        


        #endregion

        #region Private_Methods


        #endregion
    }
}