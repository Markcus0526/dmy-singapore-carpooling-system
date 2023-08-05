//
//  STDataInfo.h
//  CarPool
//
//  Created by RiKS on 10/2/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@interface STDataInfo : NSObject

@end

@interface STUserReg : NSObject
{
	NSString *UserName;
	NSString *PhoneNum;
	NSString *Password;
	NSInteger Gender;
	NSInteger BirthYear;
	NSString *Email;
	NSInteger IndGender;
	NSInteger GrpGender;
	NSInteger DelayTime;
	NSString *ImageData;
}

@property (nonatomic, retain) NSString *UserName;
@property (nonatomic, retain) NSString *PhoneNum;
@property (nonatomic, retain) NSString *Password;
@property (nonatomic, readwrite) NSInteger Gender;
@property (nonatomic, readwrite) NSInteger BirthYear;
@property (nonatomic, retain) NSString *Email;
@property (nonatomic, readwrite) NSInteger IndGender;
@property (nonatomic, readwrite) NSInteger GrpGender;
@property (nonatomic, readwrite) NSInteger DelayTime;
@property (nonatomic, retain) NSString *ImageData;

@end

@interface STAuthUser : NSObject
{
	NSString *Email;
	NSString *Password;
}

@property (nonatomic, retain) NSString *Email;
@property (nonatomic, retain) NSString *Password;

@end

@interface STLoginResult : NSObject
{
	long		ResultCode;
	NSString	*Message;
	NSString	*Name;
	int			firstLogin;
}

@property (nonatomic, readwrite) long ResultCode;
@property (nonatomic, readwrite) int firstLogin;
@property (nonatomic, retain) NSString *Message;
@property (nonatomic, retain) NSString *Name;

@end

@interface STPairInfo : NSObject
{
	long Uid;
	double SrcLat;
	double SrcLon;
	double DstLat;
	double DstLon;
	NSString *Destination;
	int Count;
	int GrpGender;
	NSString *Color;
	NSString *OtherFeature;
}

@property(nonatomic, readwrite) long Uid;
@property(nonatomic, readwrite) double SrcLat;
@property(nonatomic, readwrite) double SrcLon;
@property(nonatomic, readwrite) double DstLat;
@property(nonatomic, readwrite) double DstLon;
@property(nonatomic, retain) NSString *Destination;
@property(nonatomic, readwrite) int Count;
@property(nonatomic, readwrite) int GrpGender;
@property(nonatomic, retain) NSString *Color;
@property(nonatomic, retain) NSString *OtherFeature;

@end

@interface STPairResponse : NSObject
{
	int ErrCode;
	NSString *Message;
	long Uid;
	NSString *Name;
	NSString *Destination;
	double DstLat;
	double DstLon;
	int Count;
	int GrpGender;
	NSString *Color;
	NSString *OtherFeature;
	double SaveMoney;
	double LostTime;
	int OffOrder;
	int QueueOrder;
}

@property(nonatomic, readwrite) int ErrCode;
@property(nonatomic, retain) NSString *Message;
@property(nonatomic, readwrite) long Uid;
@property(nonatomic, retain) NSString *Name;
@property(nonatomic, retain) NSString *Destination;
@property(nonatomic, readwrite) double DstLat;
@property(nonatomic, readwrite) double DstLon;
@property(nonatomic, readwrite) int Count;
@property(nonatomic, readwrite) int GrpGender;
@property(nonatomic, retain) NSString *Color;
@property(nonatomic, retain) NSString *OtherFeature;
@property(nonatomic, readwrite) double SaveMoney;
@property(nonatomic, readwrite) double LostTime;
@property(nonatomic, readwrite) int OffOrder;
@property(nonatomic, readwrite) int QueueOrder;

@end

@interface StringContainer : NSObject
{
	NSInteger Result;
	NSString *Value;
}

@property (nonatomic, readwrite) NSInteger Result;
@property (nonatomic, retain) NSString *Value;

@end




@interface STReqTaxiStand : NSObject
{
	long Uid;
	double Longitude;
	double Latitude;
	NSString *Keyword;
}

@property (nonatomic, nonatomic) long Uid;
@property (nonatomic, nonatomic) double Longitude;
@property (nonatomic, nonatomic) double Latitude;
@property (nonatomic, retain) NSString *Keyword;

@end



@interface STTaxiStand : NSObject
{
	long Uid;
	NSString *StandName;
	NSString *GpsAddress;
	double Longitude;
	double Latitude;
	NSString *StandType;
	NSString *StandNo;
	NSString *PostCode;
}

@property (nonatomic, nonatomic) long Uid;
@property (nonatomic, retain) NSString *StandName;
@property (nonatomic, retain) NSString *GpsAddress;
@property (nonatomic, nonatomic) double Longitude;
@property (nonatomic, nonatomic) double Latitude;
@property (nonatomic, retain) NSString *StandType;
@property (nonatomic, retain) NSString *StandNo;
@property (nonatomic, retain) NSString *PostCode;

@end


@interface STTaxiStandResp : NSObject
{
	long Result;
	NSString *Message;
	STTaxiStand *TaxiStand;
}

@property (nonatomic, nonatomic) long Result;
@property (nonatomic, retain) NSString *Message;
@property (nonatomic, retain) STTaxiStand *TaxiStand;

@end



@interface GoogleTaxiStand : NSObject
{
	CLLocationCoordinate2D	location;
	NSString				*icon;
	NSString				*_id;
	NSString				*name;
	NSString				*reference;
	NSString				*vicinity;
	UIImage					*icon_image;
}

@property (nonatomic, readwrite)	CLLocationCoordinate2D	location;
@property (nonatomic, retain)		NSString				*icon;
@property (nonatomic, retain)		NSString				*_id;
@property (nonatomic, retain)		NSString				*name;
@property (nonatomic, retain)		NSString				*reference;
@property (nonatomic, retain)		NSString				*vicinity;
@property (nonatomic, retain)		UIImage					*icon_image;

+ (GoogleTaxiStand*)deserialize:(NSDictionary*)szText;

@end



@interface STPairAgree : NSObject
{
	long		Uid;
	bool		IsAgree;
}

@property (nonatomic, nonatomic) long Uid;
@property (nonatomic, nonatomic) bool IsAgree;

@end



@interface STAgreeResponse : NSObject
{
	int			ErrCode;
	NSString	*Message;
	NSString	*PairedTime;
}

@property (nonatomic, nonatomic) int ErrCode;
@property (nonatomic, retain) NSString *Message;
@property (nonatomic, retain) NSString *PairedTime;

@end


@interface STUserProfile : NSObject
{
	int			ErrCode;
	NSString	*Message;
	long		Uid;
	NSString	*UserName;
	NSString	*PhoneNum;
	NSString	*Password;
	int			Gender;
	int			BirthYear;
	NSString	*Email;
	int			IndGender;
	int			GrpGender;
	int			DelayTime;
	NSString	*LoginDate;
	int			Credit;
	double		StarCount;
	NSString	*ImageData;
	double		TotalSaving;
	int			IsGroup;
}

@property (nonatomic, readwrite) int		ErrCode;
@property (nonatomic, retain) NSString	*Message;
@property (nonatomic, readwrite) long		Uid;
@property (nonatomic, retain) NSString	*UserName;
@property (nonatomic, retain) NSString	*PhoneNum;
@property (nonatomic, retain) NSString	*Password;
@property (nonatomic, readwrite) int		Gender;
@property (nonatomic, readwrite) int		BirthYear;
@property (nonatomic, retain) NSString	*Email;
@property (nonatomic, readwrite) int		IndGender;
@property (nonatomic, readwrite) int		GrpGender;
@property (nonatomic, readwrite) int		DelayTime;
@property (nonatomic, retain) NSString	*LoginDate;
@property (nonatomic, readwrite) int		Credit;
@property (nonatomic, readwrite) double		StarCount;
@property (nonatomic, retain) NSString	*ImageData;
@property (nonatomic, readwrite) double		TotalSaving;
@property (nonatomic, readwrite) int		IsGroup;

@end

@interface STSendSMS : NSObject
{
	long			Uid;
	NSString		*PhoneNum;
}

@property (nonatomic, readwrite) long Uid;
@property (nonatomic, retain) NSString *PhoneNum;

@end


@interface STFLAuthInfo : NSObject
{
	NSString *Name;
	NSString *Email;
	int Gender;
	int BirthYear;
	NSString *PhoneNum;
	NSString *ImageData;
}

@property (nonatomic, retain) NSString *Name;
@property (nonatomic, retain) NSString *Email;
@property (nonatomic, readwrite) int Gender;
@property (nonatomic, readwrite) int BirthYear;
@property (nonatomic, retain) NSString *PhoneNum;
@property (nonatomic, retain) NSString *ImageData;

@end




@interface STPairHistory : NSObject
{
	NSString *PairingTime;
	long Uid1;
	long Uid2;
	NSString *Name1;
	NSString *Name2;
	NSString *SrcAddr;
	NSString *DstAddr1;
	NSString *DstAddr2;
	double SavePrice;
	double WasteTime;
	int OffOrder;
	double Score1;
	double Score2;
	int Gender1;
	int Gender2;
}

@property(nonatomic, retain) NSString *PairingTime;
@property(nonatomic, readwrite) long Uid1;
@property(nonatomic, readwrite) long Uid2;
@property(nonatomic, retain) NSString *Name1;
@property(nonatomic, retain) NSString *Name2;
@property(nonatomic, retain) NSString *SrcAddr;
@property(nonatomic, retain) NSString *DstAddr1;
@property(nonatomic, retain) NSString *DstAddr2;
@property(nonatomic, readwrite) double SavePrice;
@property(nonatomic, readwrite) double WasteTime;
@property(nonatomic, readwrite) int OffOrder;
@property(nonatomic, readwrite) double Score1;
@property(nonatomic, readwrite) double Score2;
@property(nonatomic, readwrite) int Gender1;
@property(nonatomic, readwrite) int Gender2;

@end



@interface STPairHistoryCount : NSObject
{
	long ErrCode;
	NSString *Message;
	long TotalCount;
	double TotalSaving;
}

@property (nonatomic, nonatomic) long ErrCode;
@property (nonatomic, retain) NSString *Message;
@property (nonatomic, nonatomic) long TotalCount;
@property (nonatomic, nonatomic) double TotalSaving;

@end




@interface STReqPairHistory : NSObject
{
	long Uid;
	long PageNo;
}

@property (nonatomic, nonatomic) long Uid;
@property (nonatomic, nonatomic) long PageNo;

@end





@interface STEvaluate : NSObject
{
	long Uid;
	long OppoID;
	double Score;
	NSString *ServeTime;
}

@property (nonatomic, nonatomic) long Uid;
@property (nonatomic, nonatomic) long OppoID;
@property (nonatomic, nonatomic) double Score;
@property (nonatomic, retain) NSString *ServeTime;

@end




@interface STReqResetPassword : NSObject
{
	NSString	*email;
}

@property (nonatomic, retain) NSString *email;

@end




@interface STShareLog : NSObject
{
	long		Uid;
	NSString*	Content;
}

@property (nonatomic, readwrite) long Uid;
@property (nonatomic, retain) NSString *Content;

@end









