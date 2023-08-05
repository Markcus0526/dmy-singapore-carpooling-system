using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Telerik.Web.Mvc;
using CarPool.Models;
namespace CarPool.Controllers
{
    public class ServeController : Controller
    {
        //
        // GET: /Serve/

        public ActionResult Index()
        {
            ViewData["selectedNav"] = "Queue";
            ViewData["selectedMenu"] = "Serve Information";
            ViewData["emptyLeftMenu"] = 1;
            ViewData["user_name"] = "";
            ViewData["start_pos"] = "";
            ViewData["end_pos"] = "";
            ViewData["from_date"] = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);
            ViewData["to_date"] = DateTime.Now;
            ViewData["rootUri"] = string.Format("{0}://{1}{2}", Request.Url.Scheme, Request.Url.Authority, Url.Content("~"));
            return View();
        }
        [HttpPost]
        public ActionResult Index(ServeInfo serveinfo)
        {
            ViewData["selectedNav"] = "Queue";
            ViewData["selectedMenu"] = "Serve Information";
            ViewData["emptyLeftMenu"] = 1;
            ViewData["rootUri"] = string.Format("{0}://{1}{2}", Request.Url.Scheme, Request.Url.Authority, Url.Content("~"));
            ViewData["user_name"] = serveinfo.user_name;
            ViewData["start_pos"] = serveinfo.start_point;
            ViewData["end_pos"] = serveinfo.end_point;
            ViewData["from_date"] = serveinfo.from_date;
            ViewData["to_date"] = serveinfo.to_date;
            return View();
        }

        [GridAction]
        public ActionResult _RetrieveServeList(string userName, string start_pos, string end_pos, string fromDate, string toDate)
        {
            GridModel gridModel;
            gridModel = new GridModel(ServeModel.getServeList(userName, start_pos, end_pos, fromDate, toDate));
            return View(gridModel);
        }
        [GridAction]
        public ActionResult _DeleteServeList(long uid)
        {
            return View();
        }
        public JsonResult _DeleteSelectedItems(long[] checkedRecords)
        {

            bool rst = ServeModel.DeleteSelectedItems(checkedRecords);
            Dictionary<string, string> results = new Dictionary<string, string>();
            results.Add("success", rst.ToString());
            results.Add("id", DateTime.Now.ToString());

            //int nState = CommonModel.getOperationState(true);
            //_syslogModel.InsertSyslog(_commonModel.getCurrentUserName(), Request.ServerVariables["REMOTE_ADDR"].ToString(), deleteLogMsg + "(选择删除)", nState, "");

            return (Json(results));
        }
    }
}
