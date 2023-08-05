using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;
using System.Configuration;

namespace CarPool.Models.Users
{
    #region Model_Defines
    public class StructUserInfo
    {
        public long uid { get; set; }
        public long show_uid { get; set; }
        public string name { get; set; }
        public int? gender { get; set; }
        public string show_gender { get; set; }
        public int? birthyear { get; set; }
        public string password { get; set; }
        public string phone_number { get; set; }
        public string email_address { get; set; }
        public int? credits { get; set; }
        public double? total_savings { get; set; }
        public System.DateTime? regist_date { get; set; }
        public System.DateTime? last_login_date { get; set; }
    }
    #endregion
    public class UserInfoViewModel
    {
        CarPoolDataContext dbContext = new CarPoolDataContext(ConfigurationManager.ConnectionStrings["carpoolConnectionString"].ConnectionString);
        public IEnumerable<StructUserInfo> GetUserList(string userName, string phoneNumber, string email_address, short isDeleted)
        {
            try
            {
                List<StructUserInfo> list = (from m in dbContext.tbl_users
                            where m.name.Contains( userName ) && m.phone_number.Contains(phoneNumber) && m.email_address.Contains(email_address) && m.deleted == isDeleted
                            select new StructUserInfo
                            {
                                uid=m.uid,
                                name=m.name,
                                gender = m.gender,
                                show_gender=(m.gender == 0 ? "Male" : "Female"),
                                birthyear=m.birthyear,
                                phone_number=m.phone_number,
                                email_address=m.email_address,
                                credits=m.credits,
                                total_savings=m.total_savings,
                                last_login_date=m.last_login_date
                            }).ToList();

                for (int i = 0; i < list.Count; i++)
                {
                    list[i].show_uid = i+1;
                }
                return list;
            }
            catch (Exception ex)
            {
                CommonModel.WriteLogFile(this.GetType().Name, "GetUserList(userName,phoneNumber,isDeleted)", ex.ToString());
            }
            return null;
        }

        public List<StructUserInfo> GetAllUserList()
        {
            try
            {
                List<StructUserInfo> list = (from m in dbContext.tbl_users
                                             where m.deleted == 0
                                             select new StructUserInfo
                                             {
                                                 uid = m.uid,
                                                 name = m.name,
                                                 gender = m.gender,
                                                 show_gender = (m.gender == 0 ? "Male" : "Female"),
                                                 birthyear = m.birthyear,
                                                 phone_number = m.phone_number,
                                                 email_address = m.email_address,
                                                 credits = m.credits,
                                                 total_savings = m.total_savings,
                                                 last_login_date = m.last_login_date
                                             }).ToList();

                for (int i = 0; i < list.Count; i++)
                {
                    list[i].show_uid = i + 1;
                }
                return list;
            }
            catch (Exception ex)
            {
                CommonModel.WriteLogFile(this.GetType().Name, "GetAllUserList(userName,phoneNumber,isDeleted)", ex.ToString());
            }
            return null;
        }

        public tbl_user GetUserInfoDetail(int uid)
        {
            tbl_user user = (from u in dbContext.tbl_users
                             where (u.uid == uid)
                             select u).SingleOrDefault();
            return user;
        }

        public double GetUserRating(int uid)
        {
            double fRating = 0.0f;
            IEnumerable<tbl_serve> queue = (from u in dbContext.tbl_serves
                             where (u.user_id == uid || u.user_id2 == uid)
                             select u);

            IList<tbl_serve> tblList = queue.ToList();
            int nCount = 0;
            double? fTotal = 0.0f;
            foreach (var item in tblList)
            {
                if (item.user_id == uid)
                {                    
                    if (item.score1 != null && item.score1 != -1)
                    {
                        nCount++;
                        fTotal += item.score1;
                    }
                }
                if (item.user_id2 == uid)
                {
                    if (item.score2 != null && item.score2 != -1)
                    {
                        nCount++;
                        fTotal += item.score2;
                    }
                }
            }

            if (nCount != 0)
                fRating = ((double)fTotal / nCount);

            return fRating;
        }

        public bool DeleteUser(long uid)
        {
            tbl_user user = (from u in dbContext.tbl_users
                             where (u.uid == uid)
                             select u).FirstOrDefault();

            if (user != null)
            {
                user.deleted = 1;

                dbContext.SubmitChanges();
            }

            return true;
        }

        public bool UpdateCredit(long uid, int credit)
        {
            if (credit < 0)
            {
                return false;
            }

            tbl_user user = (from u in dbContext.tbl_users
                             where (u.uid == uid)
                             select u).FirstOrDefault();

            if (user != null)
            {
                user.credits = credit;
                dbContext.SubmitChanges();
            }

            return true;
        }

        public bool RestoreUser(long uid)
        {
            tbl_user user = (from u in dbContext.tbl_users
                             where (u.uid == uid)
                             select u).FirstOrDefault();

            if (user != null)
            {
                user.deleted = 0;

                dbContext.SubmitChanges();
            }

            return true;
        }
    }
}