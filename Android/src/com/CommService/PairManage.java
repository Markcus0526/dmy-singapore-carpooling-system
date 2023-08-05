package com.CommService;

import java.io.UnsupportedEncodingException;
import java.util.ArrayList;

import org.apache.http.entity.StringEntity;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONStringer;

import com.HttpConn.AsyncHttpClient;
import com.HttpConn.JsonHttpResponseHandler;
import com.STData.STAgreeResponse;
import com.STData.STPairAgree;
import com.STData.STPairInfo;
import com.STData.STPairResponse;
import com.STData.STReqTaxiStand;
import com.STData.STServiceData;
import com.STData.STTaxiStand;
import com.STData.STTaxiStandResp;
import com.STData.StringContainer;

public class PairManage {
	
	public PairManage()
	{
	}
	
	public void RequestPair( STPairInfo PairInfo, JsonHttpResponseHandler handler )
	{
		JSONStringer data = null;
		try {
			data = new JSONStringer()
			.object()
        	.key("PairInfo")
            	.object()
                	.key("Uid").value(PairInfo.Uid)
                	.key("SrcLat").value(PairInfo.SrcLat)
                	.key("SrcLon").value(PairInfo.SrcLon)
                	.key("DstLat").value(PairInfo.DstLat)
                	.key("DstLon").value(PairInfo.DstLon)
                	.key("Destination").value(PairInfo.Destination)
                	.key("Count").value(PairInfo.Count)
                	.key("GrpGender").value(PairInfo.GrpGender)
	            	.key("Color").value(PairInfo.Color)
	            	.key("OtherFeature").value(PairInfo.OtherFeature)
                .endObject()
           .endObject();

			StringEntity entity = new StringEntity(data.toString(), "UTF-8");
			AsyncHttpClient client = new AsyncHttpClient();
			client.setTimeout(STServiceData.connectTimeout);
			client.post(null, STServiceData.serviceAddr + STServiceData.strRequestPair, 
					entity, "application/json; charset=UTF-8", handler);
		} catch (JSONException e) {
			e.printStackTrace();
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		
		return;
	}
	
	public StringContainer GetRequestPairFromJsonData(JSONObject jsonData)
	{
		StringContainer data = new StringContainer();
		
		try {
            data.Result = jsonData.getInt("Result");
            data.Value = jsonData.getString("Value");
        } 
		catch(Exception e){}
		
		return data;
	}	
	
	public void RequestPairAgree( STPairAgree AgreeInfo, JsonHttpResponseHandler handler )
	{
		JSONStringer data = null;
		try {
			data = new JSONStringer()
			.object()
        	.key("AgreeInfo")
            	.object()
                	.key("Uid").value(AgreeInfo.Uid)
                	.key("IsAgree").value(AgreeInfo.IsAgree)
                .endObject()
           .endObject();

			StringEntity entity = new StringEntity(data.toString(), "UTF-8");
			AsyncHttpClient client = new AsyncHttpClient();
			client.setTimeout(STServiceData.connectTimeout);
			client.post(null, STServiceData.serviceAddr + STServiceData.strRequestPairAgree, 
					entity, "application/json; charset=UTF-8", handler);
		} catch (JSONException e) {
			e.printStackTrace();
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		
		return;
	}
	
	public StringContainer GetPairAgreeFromJsonData(JSONObject jsonData)
	{
		StringContainer data = new StringContainer();
		
		try {
            data.Result = jsonData.getInt("Result");
            data.Value = jsonData.getString("Value");
        } 
		catch(Exception e){}
		
		return data;
	}
	
	public void RequestAddTaxiStand( STTaxiStand TaxiStand, JsonHttpResponseHandler handler )
	{
		JSONStringer data = null;
		try {
			data = new JSONStringer()
			.object()
        	.key("TaxiStand")
            	.object()
                	.key("Uid").value(TaxiStand.Uid)
                	.key("StandNo").value(TaxiStand.StandNo)
                	.key("StandName").value(TaxiStand.StandName)
                	.key("GpsAddress").value(TaxiStand.GpsAddress)
                	.key("PostCode").value(TaxiStand.PostCode)
                	.key("Latitude").value(TaxiStand.Latitude)
                	.key("Longitude").value(TaxiStand.Longitude)
                	.key("StandType").value(TaxiStand.StandType)
                .endObject()
           .endObject();

			StringEntity entity = new StringEntity(data.toString(), "UTF-8");
			AsyncHttpClient client = new AsyncHttpClient();
			client.setTimeout(STServiceData.connectTimeout);
			client.post(null, STServiceData.serviceAddr + STServiceData.strRequestAddTaxiStand, 
					entity, "application/json; charset=UTF-8", handler);
		} catch (JSONException e) {
			e.printStackTrace();
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		
		return;
	}
	
	public StringContainer GetAddTaxiStandFromJsonData(JSONObject jsonData)
	{
		StringContainer data = new StringContainer();
		
		try {
            data.Result = jsonData.getInt("Result");
            data.Value = jsonData.getString("Value");
        } 
		catch(Exception e){}
		
		return data;
	}
	
	public void RequestTaxiStand( STReqTaxiStand reqTaxiStand, JsonHttpResponseHandler handler )
	{
		JSONStringer data = null;
		try {
			data = new JSONStringer()
			.object()
        	.key("ReqTaxiStand")
            	.object()
                	.key("Uid").value(reqTaxiStand.Uid)
                	.key("Latitude").value(reqTaxiStand.Latitude)
                	.key("Longitude").value(reqTaxiStand.Longitude)
                .endObject()
           .endObject();

			StringEntity entity = new StringEntity(data.toString(), "UTF-8");
			AsyncHttpClient client = new AsyncHttpClient();
			client.setTimeout(STServiceData.connectTimeout);
			client.post(null, STServiceData.serviceAddr + STServiceData.strRequestTaxiStand, 
					entity, "application/json; charset=UTF-8", handler);
		} catch (JSONException e) {
			e.printStackTrace();
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		
		return;
	}
	
	public STTaxiStandResp GetTaxiStandFromJsonData(JSONObject jsonData)
	{
		STTaxiStandResp data = new STTaxiStandResp();
		
		try {
            data.Result = jsonData.getInt("Result");
            data.Message = jsonData.getString("Message");
            JSONObject obj = jsonData.getJSONObject("TaxiStand");
            data.TaxiStand.Uid = obj.getLong("Uid");
            data.TaxiStand.GpsAddress = obj.getString("GpsAddress");
            data.TaxiStand.Latitude = obj.getDouble("Latitude");
            data.TaxiStand.Longitude = obj.getDouble("Longitude");
            data.TaxiStand.StandNo = obj.getString("StandNo");
            data.TaxiStand.StandName = obj.getString("StandName");
            data.TaxiStand.StandType = obj.getString("StandType");
        } 
		catch(Exception e){}
		
		return data;
	}
	
	public void RequestTaxiStandList( STReqTaxiStand reqTaxiStand, JsonHttpResponseHandler handler )
	{
		JSONStringer data = null;
		try {
			data = new JSONStringer()
			.object()
        	.key("ReqTaxiStand")
            	.object()
                	.key("Uid").value(reqTaxiStand.Uid)
                	.key("Latitude").value(reqTaxiStand.Latitude)
                	.key("Longitude").value(reqTaxiStand.Longitude)
                	.key("Keyword").value(reqTaxiStand.Keyword)
                .endObject()
           .endObject();

			StringEntity entity = new StringEntity(data.toString(), "UTF-8");
			AsyncHttpClient client = new AsyncHttpClient();
			client.setTimeout(STServiceData.connectTimeout);
			client.post(null, STServiceData.serviceAddr + STServiceData.strRequestTaxiStandList, 
					entity, "application/json; charset=UTF-8", handler);
		} catch (JSONException e) {
			e.printStackTrace();
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		
		return;
	}
	
	public ArrayList<STTaxiStand> GetTaxiStandListFromJsonData(JSONArray jsonArr)
	{
		ArrayList<STTaxiStand> vdDataArr = new ArrayList<STTaxiStand>();
				
		try {
			for ( int i = 0; i < jsonArr.length(); i++ )
			{
				JSONObject jsonData = jsonArr.getJSONObject(i);
				
				STTaxiStand taxiStand = new STTaxiStand();
				taxiStand.Uid = jsonData.getLong("Uid");
				taxiStand.Latitude = jsonData.getDouble("Latitude");
				taxiStand.Longitude = jsonData.getDouble("Longitude");
				taxiStand.PostCode = jsonData.getString("PostCode");
				taxiStand.StandName = jsonData.getString("StandName");
				taxiStand.StandNo = jsonData.getString("StandNo");
				taxiStand.StandType = jsonData.getString("StandType");
				taxiStand.GpsAddress = jsonData.getString("GpsAddress");
				
				vdDataArr.add(taxiStand);
			}
        } 
		catch(Exception e){}
		
		return vdDataArr;
	}
	
	public void RequestIsPaired(long Uid, JsonHttpResponseHandler handler)
	{
		AsyncHttpClient client = new AsyncHttpClient();
		client.setTimeout(STServiceData.connectTimeout);
		client.get(STServiceData.serviceAddr + STServiceData.strRequestIsPaired + "/" + Long.toString(Uid), handler);
	}
	
	public STPairResponse GetIsPairedFromJsonData(JSONObject jsonData)
	{
		STPairResponse data = new STPairResponse();
		
		try {			
            data.ErrCode = jsonData.getInt("ErrCode");
            data.Message = jsonData.getString("Message");
            data.Name = jsonData.getString("Name");
            data.Destination = jsonData.getString("Destination");
            data.DstLat = jsonData.getDouble("DstLat");
            data.DstLon = jsonData.getDouble("DstLon");
            data.Count = jsonData.getInt("Count");
            data.GrpGender = jsonData.getInt("GrpGender");
            data.Color = jsonData.getString("Color");
            data.OtherFeature = jsonData.getString("OtherFeature");
            data.SaveMoney = jsonData.getDouble("SaveMoney");
            data.LostTime = jsonData.getDouble("LostTime");
            data.OffOrder = jsonData.getInt("OffOrder");
            data.OppoID = jsonData.getLong("OppoID");
            data.QueueOrder = jsonData.getInt("QueueOrder");
        } 
		catch(Exception e){
			e.printStackTrace();
		}
		
		return data;
	}
	
	public void RequestPairOff(long Uid, JsonHttpResponseHandler handler)
	{
		AsyncHttpClient client = new AsyncHttpClient();
		client.setTimeout(STServiceData.connectTimeout);
		client.get(STServiceData.serviceAddr + STServiceData.strRequestPairOff + "/" + Long.toString(Uid), handler);
	}
	
	public StringContainer GetPairOffFromJsonData(JSONObject jsonData)
	{
		StringContainer data = new StringContainer();
		
		try {			
            data.Result = jsonData.getInt("Result");
            data.Value = jsonData.getString("Value");
        } 
		catch(Exception e){
			e.printStackTrace();
		}
		
		return data;
	}
	
	public void RequestOppoAgree(long Uid, JsonHttpResponseHandler handler)
	{
		AsyncHttpClient client = new AsyncHttpClient();
		client.setTimeout(STServiceData.connectTimeout);
		client.get(STServiceData.serviceAddr + STServiceData.strRequestOppoAgree + "/" + Long.toString(Uid), handler);
	}
	
	public STAgreeResponse GetOppoAgreeFromJsonData(JSONObject jsonData)
	{
		STAgreeResponse data = new STAgreeResponse();
		
		try {			
            data.ErrCode = jsonData.getInt("ErrCode");
            data.Message = jsonData.getString("Message");
            data.PairTime = jsonData.getString("PairTime");
        } 
		catch(Exception e){
			e.printStackTrace();
		}
		
		return data;
	}
	
	public void RequestPairIsNext(String Uid, JsonHttpResponseHandler handler)
	{
		AsyncHttpClient client = new AsyncHttpClient();
		client.setTimeout(STServiceData.connectTimeout);
		client.get(STServiceData.serviceAddr + STServiceData.strRequestPairIsNext + "/" + Uid, handler);
	}
	
	public StringContainer GetPairIsNextFromJsonData(JSONObject jsonData)
	{
		StringContainer data = new StringContainer();
		
		try {			
            data.Result = jsonData.getInt("Result");
            data.Value = jsonData.getString("Value");
        } 
		catch(Exception e){
			e.printStackTrace();
		}
		
		return data;
	}
	
	public void RequestSetNextTurn(String Uid, JsonHttpResponseHandler handler)
	{
		AsyncHttpClient client = new AsyncHttpClient();
		client.setTimeout(STServiceData.connectTimeout);
		client.get(STServiceData.serviceAddr + STServiceData.strRequestSetNextTurn + "/" + Uid, handler);
	}
	
	public StringContainer GetSetNextTurnFromJsonData(JSONObject jsonData)
	{
		StringContainer data = new StringContainer();
		
		try {			
            data.Result = jsonData.getInt("Result");
            data.Value = jsonData.getString("Value");
        } 
		catch(Exception e){
			e.printStackTrace();
		}
		
		return data;
	}
}