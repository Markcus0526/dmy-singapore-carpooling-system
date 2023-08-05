//
//  STDataInfo.m
//  CarPool
//
//  Created by RiKS on 10/2/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import "STDataInfo.h"

@implementation STDataInfo

@end

@implementation STUserReg

@synthesize UserName;
@synthesize PhoneNum;
@synthesize Password;
@synthesize Gender;
@synthesize BirthYear;
@synthesize Email;
@synthesize IndGender;
@synthesize GrpGender;
@synthesize DelayTime;
@synthesize ImageData;

@end

@implementation STAuthUser

@synthesize Email;
@synthesize Password;

@end

@implementation STLoginResult

@synthesize ResultCode;
@synthesize Message;
@synthesize Name;
@synthesize firstLogin;

@end

@implementation STPairInfo

@synthesize Uid;
@synthesize SrcLat;
@synthesize SrcLon;
@synthesize DstLat;
@synthesize DstLon;
@synthesize Destination;
@synthesize Count;
@synthesize GrpGender;
@synthesize Color;
@synthesize OtherFeature;

@end

@implementation STPairResponse

@synthesize ErrCode;
@synthesize Message;
@synthesize Uid;
@synthesize Name;
@synthesize Destination;
@synthesize DstLat;
@synthesize DstLon;
@synthesize Count;
@synthesize GrpGender;
@synthesize Color;
@synthesize OtherFeature;
@synthesize SaveMoney;
@synthesize LostTime;
@synthesize OffOrder;
@synthesize QueueOrder;

@end

@implementation StringContainer

@synthesize Result;
@synthesize Value;

@end




@implementation STReqTaxiStand

@synthesize Uid;
@synthesize Latitude;
@synthesize Longitude;
@synthesize Keyword;

@end


@implementation STTaxiStand

@synthesize Uid;
@synthesize StandName;
@synthesize GpsAddress;
@synthesize Longitude;
@synthesize Latitude;
@synthesize StandType;
@synthesize StandNo;
@synthesize PostCode;

@end


@implementation STTaxiStandResp

@synthesize Result;
@synthesize Message;
@synthesize TaxiStand;

@end


@implementation GoogleTaxiStand

@synthesize _id;
@synthesize icon;
@synthesize location;
@synthesize name;
@synthesize reference;
@synthesize vicinity;
@synthesize icon_image;

+ (GoogleTaxiStand*)deserialize:(NSDictionary*)dict
{
	GoogleTaxiStand *taxiStand = [[GoogleTaxiStand alloc] init];

	taxiStand._id = [dict objectForKey:@"id"];
	taxiStand.name = [dict objectForKey:@"name"];
	taxiStand.icon = [dict objectForKey:@"icon"];
	taxiStand.reference = [dict objectForKey:@"reference"];
	taxiStand.vicinity = [dict objectForKey:@"vicinity"];

	taxiStand.icon_image = [UIImage imageNamed:@"buildmark.png"];

	NSDictionary *geometry = [dict objectForKey:@"geometry"];
	NSDictionary *loc = [geometry objectForKey:@"location"];
	taxiStand.location = CLLocationCoordinate2DMake([[loc objectForKey:@"lat"] doubleValue], [[loc objectForKey:@"lng"] doubleValue]);

	return taxiStand;
}


@end


@implementation STPairAgree

@synthesize Uid;
@synthesize IsAgree;

@end




@implementation STAgreeResponse

@synthesize ErrCode;
@synthesize Message;
@synthesize PairedTime;

@end



@implementation STUserProfile

@synthesize ErrCode;
@synthesize Message;
@synthesize Uid;
@synthesize UserName;
@synthesize PhoneNum;
@synthesize Password;
@synthesize Gender;
@synthesize BirthYear;
@synthesize Email;
@synthesize IndGender;
@synthesize GrpGender;
@synthesize DelayTime;
@synthesize LoginDate;
@synthesize Credit;
@synthesize StarCount;
@synthesize ImageData;
@synthesize TotalSaving;
@synthesize IsGroup;

@end


@implementation STSendSMS

@synthesize Uid;
@synthesize PhoneNum;

@end



@implementation STFLAuthInfo

@synthesize Name;
@synthesize Email;
@synthesize Gender;
@synthesize BirthYear;
@synthesize PhoneNum;
@synthesize ImageData;

@end




@implementation STPairHistory

@synthesize PairingTime;
@synthesize Uid1;
@synthesize Uid2;
@synthesize Name1;
@synthesize Name2;
@synthesize SrcAddr;
@synthesize DstAddr1;
@synthesize DstAddr2;
@synthesize SavePrice;
@synthesize WasteTime;
@synthesize OffOrder;
@synthesize Score1;
@synthesize Score2;
@synthesize Gender1;
@synthesize Gender2;

@end



@implementation STPairHistoryCount

@synthesize ErrCode;
@synthesize Message;
@synthesize TotalCount;
@synthesize TotalSaving;

@end



@implementation STReqPairHistory

@synthesize Uid;
@synthesize PageNo;

@end




@implementation STEvaluate

@synthesize Uid;
@synthesize OppoID;
@synthesize Score;
@synthesize ServeTime;

@end




@implementation STReqResetPassword

@synthesize email;

@end



@implementation STShareLog

@synthesize Uid;
@synthesize Content;

@end















