using System.Linq;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Data.SqlClient;
using System.Web;
using System.Web.Mvc;
using System.Collections.Generic;
using System.Configuration;
using System;

namespace CarPool.Models.TaxiLocationsModel
{
    #region Models
    public class TaxiStand
    {
        public long uid { get; set; }
        public string stand_no { get; set; }
        public string stand_name { get; set; }
        public string gps_address { get; set; }
        public string post_code { get; set; }
        public decimal longitude { get; set; }
        public decimal latitude { get; set; }
        public string taxi_stand_type { get; set; }
    }
    #endregion

    public class TaxiListModel
    {
        static CarPoolDataContext dbContext = new CarPoolDataContext(ConfigurationManager.ConnectionStrings["carpoolConnectionString"].ConnectionString);
        public static IEnumerable<TaxiStand> getTaxiStandList()
        {
            IQueryable<TaxiStand> retList = null;
            try
            {
                retList = dbContext.tbl_taxistands
                    .OrderBy(p => p.stand_name)
                    .Select(taxistand => new TaxiStand
                    {
                        uid = taxistand.uid,
                        stand_no = taxistand.stand_no,
                        stand_name = taxistand.stand_name.Trim(),
                        gps_address = taxistand.gps_address,
                        post_code = taxistand.postcode,
                        longitude = taxistand.longitude,
                        latitude = taxistand.latitude,
                        taxi_stand_type = taxistand.taxi_stand_type
                    });
            }catch(System.Exception ex)
            {
                CommonModel.WriteLogFile("abc", "GetUserObjByUserNameOrMailAddr()", ex.ToString());
            }
            return retList;
        }
        public static IEnumerable<TaxiStand> getSearchList(string standname, string gps_addr)
        {
            IQueryable<TaxiStand> retList = null;
            try
            {
                if (standname == null)
                    standname = "";
                if (gps_addr == null)
                    gps_addr = "";
                retList = dbContext.tbl_taxistands
                        .OrderBy(p => p.stand_name)
                        .Where(p => p.stand_name.Contains(standname) && p.gps_address.Contains(gps_addr))
                        //.Where(p => (System.Data.Linq.SqlClient.SqlMethods.Like(p.stand_name, standname)) && System.Data.Linq.SqlClient.SqlMethods.Like(p.gps_address, gps_addr))
                        //.Where(p => (p.stand_name.StartsWith(standname, false, null)) && (p.gps_address.StartsWith(gps_addr, false, null)))
                        .Select(taxistand => new TaxiStand
                        {
                            uid = taxistand.uid,
                            stand_no = taxistand.stand_no,
                            stand_name = taxistand.stand_name.Trim(),
                            gps_address = taxistand.gps_address,
                            post_code = taxistand.postcode,
                            longitude = taxistand.longitude,
                            latitude = taxistand.latitude
                        });
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
            string delSql = "DELETE from tbl_taxistand WHERE ";
            string whereSql = "";
            string whereQueueSql = "";
            foreach (long uid in items)
            {
                if (whereSql != "") whereSql += " OR";
                whereSql += " uid = " + uid;
                if (whereQueueSql != "") whereQueueSql += " OR";
                whereQueueSql += " taxistand_id=" + uid;
            }

            delSql += whereSql;

            string sql = "Select * From tbl_queue Where "+whereQueueSql;

            IEnumerable<tbl_queue> queryEnums = dbContext.ExecuteQuery<tbl_queue>(sql);
            if (queryEnums.Count() > 0)
                return false;
            try
            {
                dbContext.ExecuteCommand(delSql);
            }
            catch (System.Exception ex)
            {
                CommonModel.WriteLogFile("abc", "GetUserObjByUserNameOrMailAddr()", ex.ToString());
            }

            return true;
        }
        public long AddTaxiLocation( string stand_no, string stand_name, string gps_address, string post_code, decimal longitude, decimal latitude, string stand_type)
        {
            tbl_taxistand newitem = new tbl_taxistand();
            newitem.stand_no = stand_no;
            newitem.stand_name = stand_name;
            newitem.gps_address = gps_address;
            newitem.postcode = post_code;
            newitem.longitude = longitude;
            newitem.latitude = latitude;
            newitem.taxi_stand_type = stand_type;

            dbContext.tbl_taxistands.InsertOnSubmit(newitem);
            dbContext.SubmitChanges();
            
            return newitem.uid;
        }

        public long EditTaxiLocation(long uid, string stand_no, string stand_name, string gps_address, string post_code, decimal longitude, decimal latitude, string stand_type)
        {
            tbl_taxistand edititem = (from m in dbContext.tbl_taxistands
                                      where m.uid == uid
                                      select m).FirstOrDefault();

            if (edititem != null)
            {
                edititem.stand_no = stand_no;
                edititem.stand_name = stand_name;
                edititem.gps_address = gps_address;
                edititem.postcode = post_code;
                edititem.longitude = longitude;
                edititem.latitude = latitude;
                edititem.taxi_stand_type = stand_type;

                dbContext.SubmitChanges();

                return edititem.uid;
            }

            return 0;
        }

        public int DeleteTaxiLocation(long uid)
        {

            string strSQL = "DELETE from tbl_taxistand WHERE uid = " + uid.ToString();
            try
            {
                dbContext.ExecuteCommand(strSQL);
            }
            catch { }
            return 1;
        }

        public List<tbl_taxistand> GetAllLocations()
        {
            var rst = (from m in dbContext.tbl_taxistands select m);
            List<tbl_taxistand> points;
            if (rst != null)
            {
                points = rst.ToList();

            }
            else
            {
                points = null;
            }
            return points;
        }

        public List<TaxiStand> GetTaxiStandList()
        {
            return (from m in dbContext.tbl_taxistands
                    select new TaxiStand
                    {
                        uid = m.uid,
                        stand_no = m.stand_no,
                        stand_name = m.stand_name,
                        gps_address = m.gps_address,
                        post_code = m.postcode,
                        longitude = m.longitude,
                        latitude = m.latitude,
                        taxi_stand_type = m.taxi_stand_type
                    }).ToList();
        }
        public TaxiStand GetTaxiLocationDetail(int uid)
        {
            TaxiStand taxi_info = (from u in dbContext.tbl_taxistands
                                          where (u.uid == uid)
                                   select new TaxiStand
                                          {
                                              uid = u.uid,
                                              stand_no = u.stand_no,
                                              stand_name = u.stand_name.Trim(),
                                              gps_address = u.gps_address,
                                              post_code = u.postcode,
                                              longitude = u.longitude,
                                              latitude = u.latitude,
                                              taxi_stand_type = u.taxi_stand_type
                                          }).SingleOrDefault();


            return taxi_info;
        }
        public int UpdateTaxiLocation(TaxiStand model)
        {

            tbl_taxistand updateItem = dbContext.tbl_taxistands.Where(m => m.uid == model.uid).FirstOrDefault();
            updateItem.stand_no = model.stand_no;
            updateItem.stand_name = model.stand_name;
            updateItem.gps_address = model.gps_address;
            updateItem.postcode = model.post_code;
            updateItem.longitude = model.longitude;
            updateItem.latitude = model.latitude;
            updateItem.taxi_stand_type = model.taxi_stand_type;
            dbContext.SubmitChanges();

            return 1;
        }
    }
}