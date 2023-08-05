package com.STData;

import android.os.Parcel;
import android.os.Parcelable;

public class STPairInfo implements Parcelable{
	public long Uid = 0;
	public double SrcLat = 0.0f;
	public double SrcLon = 0.0f;
	public double DstLat = 0.0f;
	public double DstLon = 0.0f;
	public String Destination = "";
	public int Count = 0;
	public int GrpGender = 2;
	public String Color = "";
	public String OtherFeature = "";
	
	public STPairInfo()	{}
	
	public STPairInfo(Parcel in)
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
		dest.writeLong(Uid);
		dest.writeDouble(SrcLat);
		dest.writeDouble(SrcLon);
		dest.writeDouble(DstLat);
		dest.writeDouble(DstLon);
		dest.writeString(Destination);
		dest.writeInt(Count);
		dest.writeInt(GrpGender);
		dest.writeString(Color);
		dest.writeString(OtherFeature);
	}
	
	private void readFromParcel(Parcel in)
	{
		Uid = in.readLong();
		SrcLat = in.readDouble();
		SrcLon = in.readDouble();
		DstLat = in.readDouble();
		DstLon = in.readDouble();
		Destination = in.readString();
		Count = in.readInt();
		GrpGender = in.readInt();
		Color = in.readString();
		OtherFeature = in.readString();
	}
	
	@SuppressWarnings({ "rawtypes", "unchecked" })
	public static final Parcelable.Creator<STPairInfo> CREATOR = new Parcelable.Creator() 
	{
	    @Override
	    public Object createFromParcel(Parcel source) {
	    	return new STPairInfo(source);
	    }
	    @Override
	    public Object[] newArray(int size) {
	    	return new STPairInfo[size];
	    }
    };
}
