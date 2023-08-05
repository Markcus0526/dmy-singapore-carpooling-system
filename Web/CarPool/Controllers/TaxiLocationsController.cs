using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Telerik.Web.Mvc;
using CarPool.Models.TaxiLocationsModel;
using CarPool.Models;

namespace CarPool.Controllers
{
    public class TaxiLocationsController : Controller
    {
        //
        // GET: /TaxiStand/
        private TaxiListModel my_model = new TaxiListModel(); 
        public ActionResult Index()
        {
            ViewData["selectedNav"] = "TSL";
            ViewData["selectedMenu"] = "TaxiStand Information";
            ViewData["standname"] = "";
            ViewData["gps_addr"] = "";
            ViewData["rootUri"] = string.Format("{0}://{1}{2}", Request.Url.Scheme, Request.Url.Authority, Url.Content("~"));
            List<tbl_taxistand> points = my_model.GetAllLocations();
            var str_map_data = "";

            foreach (var obj in points)
            {
                if (str_map_data.Length > 0)
                    str_map_data += "<#ROW#>";
                str_map_data += obj.stand_no + "<#COL#>" + obj.stand_name.Replace('\'', ' ') + "<#COL#>" + obj.gps_address.Replace('\'', ' ') + "<#COL#>" + obj.postcode + "<#COL#>" + obj.longitude + "<#COL#>" + obj.latitude + "<#COL#>" + obj.taxi_stand_type;
            }
            ViewData["points-data"] = str_map_data;

            List<TaxiStand> standpoints = my_model.GetTaxiStandList();
            ViewData["taxipoints"] = standpoints;

            return View();
        }
        [HttpPost]
        public ActionResult Index(TaxiStand standTaxi)
        {
            ViewData["selectedNav"] = "TSL";
            ViewData["selectedMenu"] = "TaxiStand Information";
            ViewData["rootUri"] = string.Format("{0}://{1}{2}", Request.Url.Scheme, Request.Url.Authority, Url.Content("~"));
            ViewData["standname"] = standTaxi.stand_name;
            ViewData["gps_addr"] = standTaxi.gps_address;

            List<TaxiStand> points = my_model.GetTaxiStandList();

            ViewData["taxipoints"] = points;

            return View();
        }
        
        [GridAction]
        public ActionResult _RetrieveTaxiList(string standname, string gps_addr)
        {
            GridModel gridModel;
            if(standname==null && gps_addr==null)
                gridModel = new GridModel(TaxiListModel.getTaxiStandList());
            else
                gridModel = new GridModel(TaxiListModel.getSearchList(standname, gps_addr));
            return View(gridModel);
        }
        
        public JsonResult _DeleteSelectedItems(long[] checkedRecords)
        {

            bool rst = TaxiListModel.DeleteSelectedItems(checkedRecords);
            Dictionary<string, string> results = new Dictionary<string, string>();
            results.Add("success", rst.ToString());
            results.Add("id", DateTime.Now.ToString());

            //int nState = CommonModel.getOperationState(true);
            //_syslogModel.InsertSyslog(_commonModel.getCurrentUserName(), Request.ServerVariables["REMOTE_ADDR"].ToString(), deleteLogMsg + "(选择删除)", nState, "");

            return (Json(results));
        }
        // GET: /TaxiStand/Add
        public ActionResult Add()
        {
            ViewData["selectedNav"] = "TSL";
            ViewData["selectedMenu"] = "Add TaxiStand";
            ViewData["rootUri"] = string.Format("{0}://{1}{2}", Request.Url.Scheme, Request.Url.Authority, Url.Content("~"));
            List<TaxiStand> points = my_model.GetTaxiStandList();

            ViewData["taxipoints"] = points;
            return View();

        }

        public JsonResult AddPoint(string stand_no, string stand_name, string gps_address, string post_code, string longitude, string latitude, string taxi_stand_type)
        {
            Dictionary<string, string> abc = new Dictionary<string, string>();

            long ret = my_model.AddTaxiLocation(stand_no, stand_name, gps_address, post_code, decimal.Parse(longitude), decimal.Parse(latitude), taxi_stand_type);

            abc.Add("success", "ok");
            abc.Add("uid", ret.ToString());

            return Json(abc);
        }

        public JsonResult EditPoint(long uid, string stand_no, string stand_name, string gps_address, string post_code, string longitude, string latitude, string taxi_stand_type)
        {
            Dictionary<string, string> abc = new Dictionary<string, string>();

            long ret = my_model.EditTaxiLocation(uid, stand_no, stand_name, gps_address, post_code, decimal.Parse(longitude), decimal.Parse(latitude), taxi_stand_type);

            abc.Add("success", "ok");
            abc.Add("uid", ret.ToString());

            return Json(abc);
        }

        public JsonResult DeletePoint(long uid)
        {
            //AddPoint
            my_model.DeleteTaxiLocation(uid);
            Dictionary<string, string> abc = new Dictionary<string, string>();
            abc.Add("success", "ok");
            return Json(abc);
        }

        public ActionResult Details(int id)
        {
            ViewData["selectedNav"] = "TSL";
            ViewData["selectedMenu"] = "TaxiStand Information";
            ViewData["rootUri"] = string.Format("{0}://{1}{2}", Request.Url.Scheme, Request.Url.Authority, Url.Content("~"));
            ViewData["uid"] = id;
            TaxiStand taxi_info = my_model.GetTaxiLocationDetail(id);
            //List<tbl_taxistand> points = my_model.GetAllLocations(id);
            if (taxi_info != null)
            {
                ViewData["taxi_stand_no"] = taxi_info.stand_no;
                ViewData["taxi_stand_name"] = taxi_info.stand_name;
                ViewData["gps_address"] = taxi_info.gps_address;
                ViewData["post_code"] = taxi_info.post_code;
                ViewData["longitude"] = taxi_info.longitude.ToString();
                ViewData["latitude"] = taxi_info.latitude.ToString();
                ViewData["taxi_stand_type"] = taxi_info.taxi_stand_type;
                /*
                var str_map_data = "";

                foreach (var obj in points)
                {
                    str_map_data += "<img src='"+ViewData["rootUri"]+"Content/Images/taxi-point.png' style='position:absolute;left:"+obj.longitude.ToString()+"px; top:"+obj.latitude.ToString()+"px'>";
                }
                ViewData["map_data"]            = str_map_data;
                */
                return View();
            }
            else
            {
                return RedirectToAction("Index");
            }
        }

        //
        // GET: /TaxiStand/Create
        [HttpPost]
        public ActionResult Details(TaxiStand model)
        {
            ViewData["rootUri"] = string.Format("{0}://{1}{2}", Request.Url.Scheme, Request.Url.Authority, Url.Content("~"));
            my_model.UpdateTaxiLocation(model);

            return RedirectToAction("Index");
        }
    }
}
