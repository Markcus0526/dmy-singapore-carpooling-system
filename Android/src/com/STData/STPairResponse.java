package com.STData;

import android.os.Parcel;
import android.os.Parcelable;

public class STPairResponse implements Parcelable{
	public int ErrCode = 0;
	public String Message = "";
	public String Name = "";
	public String Destination = "";
	public double DstLat = 0.0f;
	public double DstLon = 0.0f;	
	public int Count = 0;
	public int GrpGender = 0;
	public String Color = "";
	public String OtherFeature = "";
	public double SaveMoney = 0.0f;
	public double LostTime = 0.0f;
	public int OffOrder = 0;
	public long OppoID = 0;
	public int QueueOrder = 0;
	
	public STPairResponse()	{}
	
	public STPairResponse(Parcel in)
	{
		readFromParcel(in);
	}
	
	@Override
	public int describeContents() 
	{
		return 0;
	}
	
	@Override
	public void writeToParcel(Parcel dest, int flags) 
	{
		dest.writeInt(ErrCode);
		dest.writeString(Message);
		dest.writeString(Name);
		dest.writeString(Destination);
		dest.writeDouble(DstLat);
		dest.writeDouble(DstLon);
		dest.writeInt(Count);
		dest.writeInt(GrpGender);
		dest.writeString(Color);
		dest.writeString(OtherFeature);
		dest.writeDouble(SaveMoney);
		dest.writeDouble(LostTime);
		dest.writeInt(OffOrder);
		dest.writeLong(OppoID);
		dest.writeInt(QueueOrder);
	}
	
	private void readFromParcel(Parcel in)
	{
		ErrCode = in.readInt();
		Message = in.readString();
		Name = in.readString();
		Destination = in.readString();
		DstLat = in.readDouble();
		DstLon = in.readDouble();
		Count = in.readInt();
		GrpGender = in.readInt();
		Color = in.readString();
		OtherFeature = in.readString();
		SaveMoney = in.readDouble();
		LostTime = in.readDouble();
		OffOrder = in.readInt();
		OppoID = in.readLong();
		QueueOrder = in.readInt();
	}
	
	@SuppressWarnings({ "rawtypes", "unchecked" })
	public static final Parcelable.Creator<STPairResponse> CREATOR = new Parcelable.Creator() 
	{
	    @Override
	    public Object createFromParcel(Parcel source) {
	    	return new STPairResponse(source);
	    }
	    @Override
	    public Object[] newArray(int size) {
	    	return new STPairResponse[size];
	    }
    };
}
