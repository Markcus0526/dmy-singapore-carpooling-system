using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Security;
using CarPool.Models;

namespace CarPool.Controllers
{
    public class LoginController : Controller
    {
        //
        // GET: /Login/
        private LoginModel loginModel = new LoginModel();
        public ActionResult Index()
        {
            ViewData["rootUri"] = string.Format("{0}://{1}{2}", Request.Url.Scheme, Request.Url.Authority, Url.Content("~"));
            if ( HttpContext.Session["adminName"] != null )
                if ( User.Identity.IsAuthenticated )
                    return RedirectToAction("UserInfoView", "UserMng");
            return View();
            //return View();
        }
        [HttpPost]
        public ActionResult Index(AccountModel model)
        {
            ViewData["rootUri"] = string.Format("{0}://{1}{2}", Request.Url.Scheme, Request.Url.Authority, Url.Content("~"));
            if (ModelState.IsValid)
            {
                switch(loginModel.ValidatePassword(model.Password, model.UserName, model.RememberMe))
                {
                    case 0:
                        ModelState.AddModelError("UserName", "UserName is incorrect!");
                        break;
                    case 1:
                        ModelState.AddModelError("Password", "Password is incorrect!");
                        break;
                    case 2:
                        HttpContext.Session.Add("loginTime", DateTime.Now);
                        HttpContext.Session.Add("adminName", model.UserName);
                        HttpContext.Session.Add("loginIP", Request.ServerVariables["REMOTE_ADDR"]);
                        return RedirectToAction("UserInfoView", "UserMng");
                    case 3:
                        ModelState.AddModelError("UserName", "Database connection is Failed!");
                        break;
                }    
            }
            return View();
        }
        public JsonResult UserName_Change(string userName)
        {
            Dictionary<string, string> ret = new Dictionary<string, string>();
            tbl_admin adminInfo = loginModel.GetUserStatus(userName);
            if (adminInfo == null)
            {
                ret.Add("success", "null");
            }
            else if (adminInfo.remember == 1)
            {
                ret.Add("success", "ok");
                ret.Add("password", adminInfo.password);
            }
            else
                ret.Add("success", "no");
            return Json(ret);
        }

        public ActionResult Logout()
        {
            HttpContext.Session.RemoveAll();
            return RedirectToAction("Index", "Login");
        }
    }
}
