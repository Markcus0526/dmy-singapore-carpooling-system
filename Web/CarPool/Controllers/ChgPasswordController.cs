using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using CarPool.Models.ChgPasswordModel;

namespace CarPool.Controllers
{
    public class ChgPasswordController : Controller
    {
        //
        // GET: /ChgPassword/
        ChgPasswordModel chgPassModel = new ChgPasswordModel();
        public ActionResult Index()
        {
            ViewData["selectedNav"] = "Admin";
            ViewData["selectedMenu"] = "Change Manager Password";
            ViewData["rootUri"] = string.Format("{0}://{1}{2}", Request.Url.Scheme, Request.Url.Authority, Url.Content("~"));
            return View();
        }
        [HttpPost]
        public ActionResult Index(ChangeModel ChangeModel)
        {
            ViewData["selectedNav"] = "Admin";
            ViewData["selectedMenu"] = "Change Manager Password";
            ViewData["rootUri"] = string.Format("{0}://{1}{2}", Request.Url.Scheme, Request.Url.Authority, Url.Content("~"));
            if (ModelState.IsValid)
            {
                if (ChangeModel.NewPassword == ChangeModel.ConfirmPassword)
                {
                    if (chgPassModel.CheckOldPassword(HttpContext.Session["adminName"].ToString(), ChangeModel.OldPassword))
                    {
                        if (chgPassModel.UpdatePassword(HttpContext.Session["adminName"].ToString(), ChangeModel.NewPassword))
                            ModelState.AddModelError("OldPassword", "Password was successfully changed!");
                        else
                            ModelState.AddModelError("OldPassword", "Can not change your password!");
                    }
                    else
                        ModelState.AddModelError("OldPassword", "Old Password is not correct!");
                }else
                    ModelState.AddModelError("OldPassword", "Confirm Password is not correct!");
            }
            return View();
        }

    }
}
