using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Hosting;
using System.Xml;
using System.IO;
using System.Configuration;

namespace CarPool.Models
{
    public class CommonModel
    {
        public static string getDisplayDateFormat()
        {
            return "yyyy年M月d日";
        }

        public static string getDisplayDateTimeFormat()
        {
            return "yyyy/M/d HH:mm:ss";
        }
        public static string _logFilename = "Log.txt";
        private static CarPoolDataContext _db;
        public static void WriteLogFile(string fileName, string methodName, string message)
        {
            try
            {
                string filepath = HostingEnvironment.MapPath("~/") + "\\" + _logFilename;
                if (!string.IsNullOrEmpty(message))
                {
                    using (FileStream file = new FileStream(filepath, File.Exists(filepath) ? FileMode.Append : FileMode.OpenOrCreate, FileAccess.Write))
                    {
                        StreamWriter streamWriter = new StreamWriter(file);
                        streamWriter.WriteLine((((System.DateTime.Now + " - ") + fileName + " - ") + methodName + " - ") + message);
                        streamWriter.Close();
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
            }

        }
        public static string GetStringValue(object obj)
        {
            if (obj != null)
                return obj.ToString();
            else
                return "";
        }
        public static IList<XmlNode> GetNavigation(string selectedNav)
        {
            IList<XmlNode> navList = new List<XmlNode>();
            XmlDocument navs = new XmlDocument();
            navs.Load(HttpContext.Current.Server.MapPath("~/Web.sitemap"));
            foreach (XmlNode node in navs.SelectNodes("//siteMapNode"))
            {
                if (node.Attributes["bizName"] != null && node.Attributes["bizName"].Value == selectedNav)
                    navList.Add(node);
            }
            return navList;
        }
        public static CarPoolDataContext GetDBContext()
        {
#if TESTSITE
            _db = new CarPoolDataContext(ConfigurationManager.ConnectionStrings["TestSDBConnectionString"].ConnectionString);
            return _db;
#else
            //_db = new FurniShowDBDataContext(ConfigurationManager.ConnectionStrings["FourSDBConnectionString"].ConnectionString);
            _db = new CarPoolDataContext(ConfigurationManager.ConnectionStrings["carpoolConnectionString"].ConnectionString);
            return _db;
#endif
        }
    }
}