using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Linq;
using System.Web;
using System.IO;
using System.Web.Hosting;
using System.Web.Mvc;
using System.Configuration;

namespace CarPool.Models
{
    #region Model
    public class TLQueueType
    {
        public long u_id { get; set; }
        public string TLName { get; set; }
        public long? taxistand_id { get; set; }
        public string GroupMode { get; set; }
        public DateTime EnterTime{ get; set; }
        public DateTime EnterTimeto { get; set; }
        public string UserName { get; set; }
        public long? user_id;
        public short? People_Num { get; set; }
        public string Destination { get; set; }
        public string GenderType { get; set; }
        public string TopColor { get; set; }
        public string Otherfeatrue { get; set; }
        public DateTime? checkoutTime { get; set; }
    }
    public class UserData
    {
        public string name { get; set; }
    }
    public class TaxiLocationData
    {
        public string name { get; set; }
    }
    #endregion
    public class QueueInfoModel
    {
        public static IEnumerable<TLQueueType> GetQueueList()
        {
            CarPoolDataContext db = CommonModel.GetDBContext();
            List<TLQueueType> retList = new List<TLQueueType>();
            string sql = "SELECT a.uid, a.enter_time, a.user_id, a.people_num, a.same_gender, a.top_color, a.other_features, a.pairedtime a.taxistand_id, a.destination, a.dst_longitude, a.dst_latitude, a.group_no, b.uid AS Expr1, b.name, c.uid AS Expr2, c.stand_name FROM tbl_queue AS a INNER JOIN tbl_user AS b ON a.user_id = b.uid INNER JOIN tbl_taxistand AS c ON a.taxistand_id = c.uid";
            IEnumerable<tbl_queue> queryList = db.ExecuteQuery<tbl_queue>(sql);
            IList<tbl_queue> tblList = queryList.ToList();
            TLQueueType temp;
            foreach (var item in tblList)
            {
                temp = new TLQueueType();
                temp.u_id = item.uid;
                temp.UserName = item.tbl_user.name;
                temp.GroupMode = item.group_no.ToString();
                temp.TopColor = item.top_color;
                temp.TLName = item.tbl_taxistand.stand_name;
                temp.Destination = item.destination;
                temp.EnterTime = item.enter_time;
                temp.checkoutTime = item.pairedtime;
                switch (item.same_gender.ToString())
                {
                    case "0":
                        temp.GenderType = "Male";
                        break;
                    case "1":
                        temp.GenderType = "Female";
                        break;
                    case "2":
                        temp.GenderType = "Both";
                        break;
                }
                temp.People_Num = item.people_num;
                temp.Otherfeatrue = item.other_features;
                retList.Add(temp);
            }
            return retList;
        }

        public static IEnumerable<TLQueueType> GetSearchList(string UserName, string TLName, string Destination, Nullable<short> PeoPleNum, string GenderType, DateTime Entertime, DateTime Entertimeto)
        {
            CarPoolDataContext db = new CarPoolDataContext(ConfigurationManager.ConnectionStrings["carpoolConnectionString"].ConnectionString);
            List<TLQueueType> retList = new List<TLQueueType>();
            string UserNameTemp;
            string TLNameTemp;
            string DestinationTemp;

            if (UserName == null)
                UserNameTemp = "";
            else
                UserNameTemp = UserName;

            if (TLName == null)
                TLNameTemp = "";
            else
                TLNameTemp = TLName;

            if (Destination == null)
                DestinationTemp = "";
            else
                DestinationTemp = Destination;

            int index=0;
            switch (GenderType)
            {
                case "Male":
                    index = 0;
                    break;
                case "Female":
                    index = 1;
                    break;
                case "Both":
                    index = 2;
                    break;
            }
            string sql = "SELECT a.uid, a.enter_time, a.user_id, a.people_num, a.same_gender, a.top_color, a.other_features, a.pairedtime, a.taxistand_id, a.destination, a.dst_longitude, a.dst_latitude, a.group_no, b.uid AS Expr1, b.name, c.uid AS Expr2, c.stand_name FROM tbl_queue AS a INNER JOIN tbl_user AS b ON a.user_id = b.uid INNER JOIN tbl_taxistand AS c ON a.taxistand_id = c.uid WHERE (a.deleted = 0 AND a.destination LIKE '%" + DestinationTemp + "%')";
            if(UserName!=null)
            {
                sql = sql + "and (b.name LIKE '%" + UserNameTemp + "%')";
            }
            if(TLName != null)
            {
                sql = sql + "and (c.stand_name LIKE '%" + TLNameTemp + "%')";
            }
            if (PeoPleNum != null)
            {
                sql = sql + "and (people_num = " + PeoPleNum.ToString() + ")";
            }

            if (index != 2)
            {
                sql = sql + "and (same_gender = " + index.ToString() + ")";
            }

            if (Entertime != null)
            {
                sql = sql + "and (enter_time >= '" + String.Format("{0:yyyy-MM-dd HH:mm:ss}", Entertime) + "')";
            }
            if (Entertimeto != null)
            {
                sql = sql + "and (enter_time <= '" + String.Format("{0:yyyy-MM-dd HH:mm:ss}", Entertimeto) + "')";
            }
            IEnumerable<tbl_queue> queryList = db.ExecuteQuery<tbl_queue>(sql);
            IList<tbl_queue> tblList = queryList.ToList();
            TLQueueType temp;
            foreach (var item in tblList)
            {
                temp = new TLQueueType();
                temp.u_id = item.uid;
                temp.UserName = item.tbl_user.name;
                temp.GroupMode = item.group_no.ToString();
                temp.TopColor = item.top_color;
                temp.TLName = item.tbl_taxistand.stand_name;
                temp.Destination = item.destination;
                temp.EnterTime = item.enter_time;
                temp.checkoutTime = item.pairedtime;
                switch (item.same_gender.ToString())
                {
                    case "0":
                        temp.GenderType = "Male";
                        break;
                    case "1":
                        temp.GenderType = "Female";
                        break;
                    case "2":
                        temp.GenderType = "Both";
                        break;
                }
                temp.People_Num = item.people_num;
                temp.Otherfeatrue = item.other_features;
                retList.Add(temp);
            }
            return retList;
        }
        public static bool DeleteSelectedItems(long[] items)
        {
            string delSql = "UPDATE tbl_queue SET deleted = 1 WHERE ";
            string whereSql = "";
            foreach (long uid in items)
            {
                if (whereSql != "") whereSql += " OR";
                whereSql += " uid = " + uid;
            }

            delSql += whereSql;

            CarPoolDataContext db = new CarPoolDataContext(ConfigurationManager.ConnectionStrings["carpoolConnectionString"].ConnectionString);
            db.ExecuteCommand(delSql);
            //"select table1.a,table2.b from table1,table2,table3 where table1.uid=table2.uid && table1.name=table3.name
            return true;
        }
    }
}