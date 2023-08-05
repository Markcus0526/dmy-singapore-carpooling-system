using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Telerik.Web.Mvc;
using CarPool.Models;

namespace CarPool.Controllers
{
    public class QueueStatusController : Controller
    {
        //
        // GET: /WaitingQueue/

        public ActionResult QueueInfo()
        {
            ViewData["rootUri"] = string.Format("{0}://{1}{2}", Request.Url.Scheme, Request.Url.Authority, Url.Content("~"));
            ViewData["selectedNav"] = "Queue";
            ViewData["selectedMenu"] = "Queue Information";
            ViewData["UserName"] = "";
            ViewData["TLName"] = "";
            ViewData["Destination"] = "";
            ViewData["Same_Gender"] = "Both";

            //ViewData["PeoPleNum"] = 0;
            ViewData["EnterTime"] = new DateTime(DateTime.Now.Year, DateTime.Now.Month,1,DateTime.Now.Hour,DateTime.Now.Minute,DateTime.Now.Second);
            ViewData["EnterTimeTo"] = DateTime.Now;
            return View("QueueInfo");
        }

        [HttpPost]
        public ActionResult QueueInfo(TLQueueType WaitingQueue)
        {
            ViewData["rootUri"] = string.Format("{0}://{1}{2}", Request.Url.Scheme, Request.Url.Authority, Url.Content("~"));
            ViewData["selectedNav"] = "Queue";
            ViewData["selectedMenu"] = "Queue Information";
            ViewData["UserName"] = WaitingQueue.UserName;
            ViewData["TLName"] = WaitingQueue.TLName;
            ViewData["Destination"] = WaitingQueue.Destination;
            ViewData["PeoPleNum"] = WaitingQueue.People_Num;
            ViewData["EnterTime"] = WaitingQueue.EnterTime;
            ViewData["EnterTimeTo"] = WaitingQueue.EnterTimeto;
            ViewData["Same_Gender"] = WaitingQueue.GenderType;
            ViewData["Group_Exist"] = WaitingQueue.GroupMode;
            return View("QueueInfo");
        }
        //
        // GET: /WaitingQueue/Details/5

        [GridAction]
        public ActionResult _RetrieveQueueList(string UserName, string TLName, string Destination, Nullable<short> PeoPleNum,string GenderType, DateTime EnterTime,DateTime EnterTimeto)
        {
            GridModel gridModel;
            if (UserName == null && TLName == null && Destination == null && PeoPleNum == null && GenderType == null && EnterTime == null && EnterTimeto == null)
                gridModel = new GridModel(QueueInfoModel.GetQueueList());
            else
                gridModel = new GridModel(QueueInfoModel.GetSearchList(UserName, TLName, Destination, PeoPleNum, GenderType, EnterTime,EnterTimeto));
            return View(gridModel);
        }
        public JsonResult _DeleteSelectedItems(long[] checkedRecords)
        {

            bool rst = QueueInfoModel.DeleteSelectedItems(checkedRecords);
            Dictionary<string, string> results = new Dictionary<string, string>();
            results.Add("success", rst.ToString());
            results.Add("id", DateTime.Now.ToString());

            //int nState = CommonModel.getOperationState(true);
            //_syslogModel.InsertSyslog(_commonModel.getCurrentUserName(), Request.ServerVariables["REMOTE_ADDR"].ToString(), deleteLogMsg + "(选择删除)", nState, "");

            return (Json(results));
        }
    }
}
