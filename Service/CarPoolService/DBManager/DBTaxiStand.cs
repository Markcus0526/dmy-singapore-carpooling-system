using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Runtime.Serialization;
using CarPoolService.CarPoolDB;

namespace CarPoolService.DBManager
{
	public class DBTaxiStand
	{
		#region Field and Properties
        #endregion

		#region Constructor

        public DBTaxiStand()
        {
        }

        #endregion

		#region Public_Methods

		public static int PAGE_ITEMCOUNT = 20;
		public STTaxiStand IsValidStand(STTaxiStand taxiStand)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			STTaxiStand strRes = new STTaxiStand();
			IEnumerable<tbl_taxistand> queryEnums = null;
			IList<tbl_taxistand> queryList = null;

			try
			{
				if (taxiStand.StandName == null || taxiStand.StandName == String.Empty)
				{
					strRes = null;
				}
				else
				{
#if false
					String szQuery = "SELECT * FROM tbl_taxistand WHERE "
						+ " stand_name = '" + taxiStand.StandName + "' AND "
						+ " gps_address = '" + taxiStand.GpsAddress + "'";
#else
					String szQuery = "SELECT * FROM tbl_taxistand";
#endif

					queryEnums = dbContext.ExecuteQuery<tbl_taxistand>(szQuery);
					queryList = queryEnums.ToList();

					bool isValid = false;
					int i = 0;
					for (i = 0; i < queryList.Count; i++)
					{
						if (Math.Abs((double)queryList[i].latitude - taxiStand.Latitude) < Global.COORD_OFFSET_LIMIT &&
							Math.Abs((double)queryList[i].longitude - taxiStand.Longitude) < Global.COORD_OFFSET_LIMIT)
						{
							isValid = true;
							break;
						}
					}

					if (isValid)
					{
						strRes.Uid = queryList[i].uid;
						strRes.StandName = queryList[i].stand_name;
						strRes.GpsAddress = queryList[i].gps_address;
						strRes.Longitude = (double)queryList[i].longitude;
						strRes.Latitude = (double)queryList[i].latitude;
						strRes.StandType = queryList[i].taxi_stand_type;
						strRes.StandNo = queryList[i].stand_no;
						strRes.PostCode = queryList[i].postcode;
					}
					else
					{
						strRes = null;
					}
				}
			}
			catch (System.Exception ex)
			{
				CommMisc.LogErrors(ex.ToString());

				strRes = null;
			}

			return strRes;
		}

        public STTaxiStand[] GetDestList(String DestName, int nPageNo)
        {
            CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
            List<STTaxiStand> arrResult = new List<STTaxiStand>();
            String strQuery = String.Empty;

            try
            {
				String szNum = String.Empty, szAddr = String.Empty;
				int nSpacePos = DestName.IndexOf(" ");

				if (nSpacePos < 0)
				{
					szAddr = DestName;
				}
				else
				{
					szNum = DestName.Substring(0, nSpacePos);
					int nResult = 0;

					if (!int.TryParse(szNum, out nResult))
					{
						szAddr = DestName;
						szNum = String.Empty;
					}
					else
					{
						szAddr = DestName.Substring(nSpacePos + 1);
					}
				}



#if false				// Commented by KHM. 2013.11.29
                strQuery = "Select * From tbl_dest Where Region1 + Region2 + Region3 + Region4 like '%" + DestName + "%' OR " + "ZIP like '%" + DestName + "%' OR " + "Area1 + Area2 like '%" + DestName + "%'";
#else
				strQuery = "Select * From tbl_dest Where ZIP like '%" + DestName + "%' OR (" + "Area1 + Area2 like '%" + szNum + "%' AND " + "Area1 + Area2 like '%" + szAddr + "%')";
#endif
                IEnumerable<tbl_dest> infoEnums = dbContext.ExecuteQuery<tbl_dest>(strQuery);
                IList<tbl_dest> infoList = infoEnums.ToList();

                for (int i = 0; i < infoList.Count; i++)
                {
                    try
                    {
                        STTaxiStand taxiStand = new STTaxiStand();

                        taxiStand.Uid = infoList[i].uid;
                        taxiStand.StandNo = infoList[i].ID.ToString();

                        String strArea1 = infoList[i].Area1 == null ? String.Empty : infoList[i].Area1;
                        String realArea = String.Empty;
						if (strArea1 == String.Empty || strArea1.Length < 1)
						{
							realArea = String.Empty;
						}
						else
						{
							int nPos = strArea1.LastIndexOf(",");
							if (nPos > 0)
							{
								try
								{
									String subStr, subStr2;
									subStr = strArea1.Substring(nPos + 1, strArea1.Length - nPos - 1).Trim();
									subStr2 = strArea1.Substring(0, nPos);
									realArea = subStr + " " + subStr2;
								}
								catch (System.Exception ex)
								{
									realArea = strArea1;
								}
							}
							else
								realArea = strArea1;
						}

                        taxiStand.StandName = realArea;
						String szArea2 = infoList[i].Area2 == null ? String.Empty : infoList[i].Area2;

                        if (!realArea.ToUpper().Contains(DestName.ToUpper()) &&
                            !szArea2.ToUpper().Contains(DestName.ToUpper()))
                        {
                            continue;
                        }

						taxiStand.GpsAddress = szArea2;
                        taxiStand.PostCode = infoList[i].ZIP;
                        taxiStand.Latitude = Convert.ToDouble(infoList[i].Lat);
                        taxiStand.Longitude = Convert.ToDouble(infoList[i].Lng);
                        taxiStand.StandType = @"TaxiStand";

                        arrResult.Add(taxiStand);
                    }
                    catch (Exception ex) {
                        continue;                        
                    }
                }

            }
            catch (Exception e) {
                arrResult = null;
            }

			return arrResult.Skip(PAGE_ITEMCOUNT * (nPageNo - 1)).Take(PAGE_ITEMCOUNT).ToArray();
        }

		public StringContainer RequestAddTaxiStand(STTaxiStand taxiStand)
		{
			CarPoolDBDataContext dbContext = new CarPoolDBDataContext();
			StringContainer szRes = new StringContainer { Result = ErrManager.ERR_FAILURE };
			String szName = String.Empty, szGpsName = String.Empty, szQuery = String.Empty;
			STTaxiStand existStand = null;
			int resultCnt = 0;
			bool bUpdateStandNo = false, bUpdatePostCode = false;

			try
			{
				CommMisc.LogErrors(String.Format("({0}, {1}, {2})", taxiStand.Latitude, taxiStand.Longitude, Global.calcDist(taxiStand.Latitude, taxiStand.Longitude, 41.73, 123.379, 'K')));

				if (taxiStand == null)
				{
					szRes.Result = ErrManager.ERR_FAILURE;
					szRes.Message = ErrManager.code2Msg((int)szRes.Result);
				}
				else
				{
					szName = taxiStand.StandName;
					szGpsName = taxiStand.GpsAddress;

					existStand = IsValidStand(taxiStand);

					if (existStand != null)
					{
// 						szRes.Result = ErrManager.ERR_TAXISTAND_EXIST;
// 						szRes.Message = ErrManager.code2Msg(ErrManager.ERR_TAXISTAND_EXIST);
						if (taxiStand.StandNo != null && taxiStand.StandNo != String.Empty)
							bUpdateStandNo = true;

						if (taxiStand.PostCode != null && taxiStand.PostCode != String.Empty)
							bUpdatePostCode = true;

						if (bUpdatePostCode || bUpdateStandNo)
						{
							szQuery = "UPDATE tbl_taxistand SET ";

							if (bUpdatePostCode)
								szQuery += "postcode = N'" + taxiStand.PostCode + "' ";
							if (bUpdateStandNo)
								szQuery += "stand_no = N'" + taxiStand.StandNo + "' ";

							szQuery += (" WHERE uid = " + existStand.Uid);

							resultCnt = dbContext.ExecuteCommand(szQuery);
							if (resultCnt != 1)
							{
								szRes.Result = ErrManager.ERR_TAXISTAND_UPDATE_FAIL;
								szRes.Message = ErrManager.code2Msg(szRes.Result);
							}
							else
							{
								szRes.Result = existStand.Uid;
								szRes.Message = ErrManager.code2Msg(szRes.Result);
							}
						}
						else
						{
							szRes.Result = ErrManager.ERR_TAXISTAND_EXIST;
							szRes.Message = ErrManager.code2Msg(ErrManager.ERR_TAXISTAND_EXIST);
						}
					}
					else
					{
						szQuery = "INSERT INTO tbl_taxistand (stand_name, gps_address, longitude, latitude, taxi_stand_type, stand_no, postcode) values(N'"
							+ taxiStand.StandName + "', N'"
							+ taxiStand.GpsAddress + "', '"
							+ taxiStand.Longitude + "', '"
							+ taxiStand.Latitude + "',N'"
							+ taxiStand.StandType + "',N'"
							+ taxiStand.StandNo + "',N'"
							+ taxiStand.PostCode + "')";

						resultCnt = dbContext.ExecuteCommand(szQuery);
						if (resultCnt == 1)
						{
							szQuery = "SELECT * FROM tbl_taxistand WHERE gps_address = '" + taxiStand.GpsAddress + "'";

							IEnumerable<tbl_user> infoEnums = dbContext.ExecuteQuery<tbl_user>(szQuery);
							IList<tbl_user> infoList = infoEnums.ToList();

							szRes.Result = infoList.FirstOrDefault().uid;
							szRes.Message = ErrManager.code2Msg(ErrManager.ERR_NONE);
						}
						else
						{
							szRes.Result = ErrManager.ERR_UNKNOWN;
							szRes.Message = ErrManager.code2Msg((int)szRes.Result);
						}
					}
				}
			}
			catch (System.Exception ex)
			{
				CommMisc.LogErrors(ex.ToString());

				szRes.Result = ErrManager.ERR_FAILURE;
				szRes.Message = ex.Message;
			}

			return szRes;
		}

		#endregion

        #region Private_Methods


        #endregion
    }
}