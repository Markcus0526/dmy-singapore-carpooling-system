using System;
using System.Collections.Generic;
using System.Linq;
using System.IO;
using System.Web;
using System.Web.Mvc;
using Telerik.Web.Mvc;
using CarPool.Models;
using CarPool.Models.Users;
using System.Text;
using NPOI.HSSF.UserModel;

namespace CarPool.Controllers
{
    public class UserMngController : Controller
    {
        //
        // GET: /UserInfoView/
        private UserInfoViewModel thisModel = new UserInfoViewModel(); 
       
        public ActionResult Index()
        {
            return RedirectToAction("UserInfoView");
        }

        public ActionResult UserInfoView()
        {
            ViewData["rootUri"] = string.Format("{0}://{1}{2}", Request.Url.Scheme, Request.Url.Authority, Url.Content("~"));
            ViewData["selectedNav"] = "User";
            ViewData["selectedMenu"] = "User Information";
            return View(thisModel.GetUserList("", "", "", 0));
        }
        
        [HttpPost]
        public ActionResult UserInfoView(string user_name, string phone_number, string email_address)
        {
            ViewData["rootUri"] = string.Format("{0}://{1}{2}", Request.Url.Scheme, Request.Url.Authority, Url.Content("~"));
            ViewData["selectedNav"] = "User";
            ViewData["selectedMenu"] = "User Information";
            ViewData["user_name"] = user_name;
            ViewData["phone_number"] = phone_number;
            ViewData["email_address"] = email_address;
            return View(thisModel.GetUserList(user_name, phone_number, email_address, 0));
        }

        public ActionResult DeletedUser()
        {
            ViewData["rootUri"] = string.Format("{0}://{1}{2}", Request.Url.Scheme, Request.Url.Authority, Url.Content("~"));
            ViewData["selectedNav"] = "User";
            ViewData["selectedMenu"] = "Deleted User";
            return View();
        }

        [HttpPost]
        public ActionResult DeletedUser(string user_name, string phone_number, string email_address)
        {
            ViewData["rootUri"] = string.Format("{0}://{1}{2}", Request.Url.Scheme, Request.Url.Authority, Url.Content("~"));
            ViewData["selectedNav"] = "User";
            ViewData["selectedMenu"] = "Deleted User";
            ViewData["user_name"] = user_name;
            ViewData["phone_number"] = phone_number;
            ViewData["email_address"] = email_address;
            return View();
        }

        [GridAction]
        [AcceptVerbs(HttpVerbs.Post)]
        public ActionResult _DeleteUser(long id)
        {
            thisModel.DeleteUser(id);
            return RedirectToAction("UserInfoView", "UserMng");
        }

        [GridAction]
        [AcceptVerbs(HttpVerbs.Post)]
        public ActionResult _UpdateCredit(long id)
        {
            int credit = -1;

            try
            {
                string strcredit = Request.Form["credits"].ToString();
                credit = int.Parse(strcredit);
            }
            catch (System.Exception ex)
            {
            	
            }

            thisModel.UpdateCredit(id, credit);
            //return View(new GridModel(thisModel.GetUserList("", "", "", 0)));
            return RedirectToAction("UserInfoView");
        }

        [GridAction]
        public ActionResult _RetrieveDeletedUser(string userName, string phoneNumber, string email_address)
        {
            userName = (userName != null ? userName : "");
            phoneNumber = (phoneNumber != null ? phoneNumber : "");
            email_address = (email_address != null ? email_address : "");
            return View(new GridModel(thisModel.GetUserList(userName, phoneNumber, email_address, 1)));
        }


        public ActionResult _RestoreUser(long id)
        {
            thisModel.RestoreUser(id);
            return RedirectToAction("DeletedUser", "UserMng");
        }

        /*
        [GridAction]
        public ActionResult _RetrieveUserList(string userName, string phoneNumber, string email_address)
        {
            userName = (userName != null ? userName : "");
            phoneNumber = (phoneNumber != null ? phoneNumber : "");
            email_address = (email_address != null ? email_address : "");
            return View(new GridModel(thisModel.GetUserList(userName, phoneNumber, email_address, 0)));
        }
        */
        [GridAction]
        public ActionResult _RetrieveUserList()
        {
            String userName =  "";
            String phoneNumber = "";
            String email_address = "";
            return View(new GridModel(thisModel.GetUserList(userName, phoneNumber, email_address, 0)));
        }

        public ActionResult ExportExcel()
        {
            List<StructUserInfo> userList = thisModel.GetAllUserList();

            var workbook = new HSSFWorkbook();
            var sheet = workbook.CreateSheet();

            sheet.SetColumnWidth(0, 20 * 256);
            sheet.SetColumnWidth(1, 10 * 256);
            sheet.SetColumnWidth(2, 10 * 256);
            sheet.SetColumnWidth(3, 30 * 256);
            sheet.SetColumnWidth(4, 30 * 256);
            sheet.SetColumnWidth(5, 10 * 256);
            sheet.SetColumnWidth(6, 20 * 256);
            sheet.SetColumnWidth(7, 30 * 256);

            var headerRow = sheet.CreateRow(0);

            headerRow.CreateCell(0).SetCellValue("User Name");
            headerRow.CreateCell(1).SetCellValue("Gender");
            headerRow.CreateCell(2).SetCellValue("BirthYear");
            headerRow.CreateCell(3).SetCellValue("PhoneNumber");
            headerRow.CreateCell(4).SetCellValue("Email Address");
            headerRow.CreateCell(5).SetCellValue("Credits");
            headerRow.CreateCell(6).SetCellValue("Total Savings");
            headerRow.CreateCell(7).SetCellValue("Last Login Time");
            
            sheet.CreateFreezePane(0, 1, 0, 1);

            if (userList != null)
            {
                int rowNumber = 1;
                for (int i = 0; i < userList.Count; i++)
                {
                    var row = sheet.CreateRow(rowNumber++);

                    row.CreateCell(0).SetCellValue(userList[i].name);
                    row.CreateCell(1).SetCellValue(userList[i].show_gender);
                    row.CreateCell(2).SetCellValue(userList[i].birthyear.ToString());
                    row.CreateCell(3).SetCellValue(userList[i].phone_number);
                    row.CreateCell(4).SetCellValue(userList[i].email_address);
                    row.CreateCell(5).SetCellValue(userList[i].credits.ToString());
                    row.CreateCell(6).SetCellValue(userList[i].total_savings.ToString());
                    row.CreateCell(7).SetCellValue(userList[i].last_login_date.ToString());
                }
            }

            MemoryStream output = new MemoryStream();
            workbook.Write(output);
            
            return File(output.ToArray(), "application/vnd.ms-excel", "UserList.xls");
        }

        public ActionResult UserInfoDetail(int id)
        {
            ViewData["rootUri"] = string.Format("{0}://{1}{2}", Request.Url.Scheme, Request.Url.Authority, Url.Content("~"));
            ViewData["selectedNav"] = "User";
            ViewData["uid"] = id;
            tbl_user user = thisModel.GetUserInfoDetail(id);
            double userRating = thisModel.GetUserRating(id);
            if (user != null)
            {
                ViewData["uid"] = user.uid;
                ViewData["name"] = user.name;
                if (user.gender == 0)
                    ViewData["gender"] = "Male";
                else
                    ViewData["gender"] = "Female";
                ViewData["age"] = user.birthyear;
                ViewData["phone_number"] = user.phone_number.Trim();
                ViewData["email_address"] = user.email_address.Trim();
                ViewData["credits"] = user.credits;
                ViewData["regist_date"] = ((DateTime)user.regist_date).ToShortDateString();
                ViewData["total_savings"] = user.total_savings;
                ViewData["delay_time"] = user.delay_time;
                ViewData["password"] = user.password;
                ViewData["rating"] = userRating;
                if (user.last_login_date == null)
                    ViewData["last_login_date"] = "";
                else
                    ViewData["last_login_date"] = ((DateTime)user.last_login_date).ToString();
                if (user.is_grouping == 1)
                    ViewData["is_grouping"] = "Yes";
                else
                    ViewData["is_grouping"] = "No";
                if (user.ind_gender == 0)
                    ViewData["ind_gender"] = "Male";
                else if (user.ind_gender == 1)
                    ViewData["ind_gender"] = "Female";
                else if (user.ind_gender == 2)
                    ViewData["ind_gender"] = "Mixed";

                if (user.grp_gender == 0)
                    ViewData["grp_gender"] = "Male";
                else if (user.grp_gender == 1)
                    ViewData["grp_gender"] = "Female";
                else if (user.grp_gender == 2)
                    ViewData["grp_gender"] = "Mixed";
                else if (user.grp_gender == 3)
                    ViewData["grp_gender"] = "Male or Mixed";
                else if (user.grp_gender == 4)
                    ViewData["grp_gender"] = "Female or Mixed";
                else if (user.grp_gender == 5)
                    ViewData["grp_gender"] = "Any";

                String szImageData = String.Empty;
                
                String DecodedString = "";
                FileStream fs;
                StreamReader r = null;
                try
                {
                    fs = new FileStream(user.image_path, FileMode.Open, FileAccess.Read);
                    //fs = new FileStream(Server.MapPath(user.image_path), FileMode.Open);
                    r = new StreamReader(fs);
                    r.BaseStream.Seek(0, SeekOrigin.Begin);
                    while (r.Peek() > -1)
                        DecodedString += Server.HtmlDecode(r.ReadLine());
                    r.Close();
                }
                catch (System.Exception ex)
                {
                    DecodedString = "";
                    if (r != null)
                        r.Close();
                }
                

                ViewData["photo"] = DecodedString;
                return View();
            }
            else
            {
                return RedirectToAction("Index");
            }
        }
    }
}
