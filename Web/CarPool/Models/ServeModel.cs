using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Configuration;
namespace CarPool.Models
{
    #region Models
    public class ServeInfo
    {
        public long uid { get; set; }
        public DateTime serve_date { get; set; }
        public string user_name1 { get; set; }
        public string user_name2 { get; set; }
        public string start_point { get; set; }
        public string end_point1 { get; set; }
        public double? saved_money1 { get; set; }
        public double? waste1 { get; set; }
        public double? score1 { get; set; }
        public string end_point2 { get; set; }
        public double? saved_money2 { get; set; }
        public double? waste2 { get; set; }
        public double? score2 { get; set; }
        public long user_id1 { get; set; }
        public long user_id2 { get; set; }
        public DateTime from_date { get; set; }
        public DateTime to_date { get; set; }

        public string user_name { get; set; }
        public string end_point { get; set; }
    }
    public class User
    {
        public long uid { get; set; }
        public string name { get; set; }
    }
    #endregion
    public class ServeModel
    {
        static CarPoolDataContext dbContext = new CarPoolDataContext(ConfigurationManager.ConnectionStrings["carpoolConnectionString"].ConnectionString);
        public static IEnumerable<ServeInfo> getServeList(string userName, string start_pos, string end_pos, string fromDate, string toDate)
        {
            DateTime from_date;
            DateTime to_date;
            if(userName == null)
                userName = "";
            if (start_pos == null)
                start_pos = "";
            if (end_pos == null)
                end_pos = "";
            if (fromDate == null)
                from_date = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);
            else 
                from_date = Convert.ToDateTime(fromDate);

            if (toDate == null)
                to_date = DateTime.Now;
            else
                to_date = Convert.ToDateTime(toDate);

            List<ServeInfo> list_serve = null;
            List<ServeInfo> retList = new List<ServeInfo>();

            try
            {
                list_serve = dbContext.tbl_serves
                                            .OrderBy(p => p.serve_date)
                                            .Where(p => DateTime.Compare(p.serve_date, from_date) >= 0 && DateTime.Compare(p.serve_date, to_date) <= 0 && p.start_pos.Contains(start_pos) && ((p.end_pos.Contains(end_pos)) || (p.end_pos2.Contains(end_pos))))
                                            .Select(tbl_serve => new ServeInfo
                                            {
                                                uid = tbl_serve.uid,
                                                user_id1 = tbl_serve.user_id,
                                                user_id2 = tbl_serve.user_id2,
                                                serve_date = tbl_serve.serve_date,
                                                start_point = tbl_serve.start_pos,
                                                end_point1 = tbl_serve.end_pos,
                                                saved_money1 = tbl_serve.saving_money,
                                                waste1 = tbl_serve.waste_time,
                                                score1 = tbl_serve.score1,
                                                end_point2 = tbl_serve.end_pos2,
                                                saved_money2 = tbl_serve.saving_money2,
                                                waste2 = tbl_serve.waste_time2,
                                                score2 = tbl_serve.score2,
                                            }).ToList();

                List<User> list_user = dbContext.tbl_users
                                           .Where(p => p.deleted.Equals("0"))
                                           .Select(tbl_user => new User
                                           {
                                               uid = tbl_user.uid,
                                               name = tbl_user.name,
                                           }).ToList();

                if (list_serve.Count() > 0)
                {
                    foreach (var item in list_serve)
                    {
                        int nFlag = 0;
                        foreach (var user in list_user)
                        {
                            if (user.uid == item.user_id1)
                            {
                                item.user_name1 = user.name;
                                nFlag++;
                            }
                            else if (user.uid == item.user_id2)
                            {
                                item.user_name2 = user.name;
                                nFlag++;
                            }
                            if (nFlag >= 2)
                            {
                                retList.Add(item);
                                break;
                            }
                        }
                    }
                }

            }
            catch (System.Exception ex)
            {
                CommonModel.WriteLogFile("abc", "GetUserObjByUserNameOrMailAddr()", ex.ToString());
            }
            return retList;
        }

        public static bool DeleteSelectedItems(long[] items)
        {
            //string delSql = "UPDATE tbl_taxistand SET deleted = 1 WHERE ";
            string delSql = "DELETE from tbl_serve WHERE ";
            string whereSql = "";
            foreach (long uid in items)
            {
                if (whereSql != "") whereSql += " OR";
                whereSql += " uid = " + uid;
            }

            delSql += whereSql;

            try
            {
                dbContext.ExecuteCommand(delSql);
            }
            catch { }
            return true;
        }
    }
}