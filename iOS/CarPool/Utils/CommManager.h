//
//  CommManager.h
//  CarPool
//
//  Created by RiKS on 10/3/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "ASINetworkQueue.h"
#import "STDataInfo.h"
#import "SBJson.h"

@protocol UserManageDelegate;
@protocol PairManageDelegate;

@interface UserManage : NSObject {
	STUserReg *userReg;
	STAuthUser *authUser;
}

- (void)getRequestRegister : (STUserReg *)userReg;
- (void)getRequestLogin : (STAuthUser *)authUser;
- (void)getRequestLogOut;
- (void)getRequestUserCredits : (NSString *)uid;
- (void)getRequestResetPassword : (STReqResetPassword *)resetPass;
- (void) getRequestTaxiStand : (STReqTaxiStand *)taxiStand;
- (void) getRequestTaxiStandList : (STReqTaxiStand *)taxiStand;
- (NSMutableArray*) findPositionWithName:(NSString *)name Type:(NSString *)type Latitude:(double)lat Longitude:(double)lon Radius:(NSString*)radius;
- (void)getRequestAddTaxiStand : (STTaxiStand *)taxiStand;
- (void)getRequestPairAgree:(STPairAgree *)agreeInfo;
- (NSMutableArray*)getRouteStepsFrom:(CLLocationCoordinate2D)start_coord to:(CLLocationCoordinate2D)end_coord;
- (void)getRequestOppoAgree:(NSString *)Uid;
- (void)getRequestUserProfile;
- (void)getRequestUserProfileUpdate:(STUserProfile *)profile;
- (void)getRequestSendSMS:(STSendSMS *)sendInfo;
- (void)getRequestFLLogin:(STFLAuthInfo*)AuthInfo;
- (void)getRequestPairingHistoryCount:(long)Uid;
- (void)getRequestPairingHistoryList:(STReqPairHistory *)ReqHistory;
- (void)getGetPairingHistoryCount:(NSString *)Uid paegno:(NSString *)PageNo;
- (void)getRequestEvaluate:(STEvaluate *)evalate;
- (int)getSharable;
- (void)getRequestShareLog:(STShareLog *)shareLog;
- (NSMutableArray*)getDestList:(NSString*)destName withPageNo:(int)pageno;
- (void)getRequestIsRegistedUser : (NSString *)Email;
- (void)getPairIsNext;
- (void)getSetNext;

@property(nonatomic, retain) STUserReg *userReg;
@property (nonatomic, retain) id<UserManageDelegate> delegate;

@end

@protocol UserManageDelegate<NSObject>
@optional
- (void)getRequestRegisterResult:(StringContainer *)result;
- (void)getRequestLoginResult:(STLoginResult*)result;
- (void)getRequestFLLoginResult:(STLoginResult*)result;
- (void)getRequestPairOffResult:(StringContainer *)result;
- (void)getRequestPairAgreeResult:(StringContainer *)result;
- (void)getRequestUserProfileResult:(STUserProfile *)result;
- (void)getRequestUserProfileUpdateResult:(StringContainer *)result;
- (void)getRequestAddTaxiStandResult:(StringContainer *)result;
- (void)getRequestResetPasswordResult:(StringContainer *)result;
- (void)getRequestOppoAgreeResult:(STAgreeResponse *)result;
- (void)getRequestUserCreditsResult:(int)result;
- (void)getRequestPairingHistoryCountResult:(STPairHistoryCount *)result;
- (void)getRequestPairingHistoryListResult:(NSMutableArray *)result;
- (void)getRequestEvaluateResult:(StringContainer *)result;
- (void)getRequestTaxiStandResult:(STTaxiStandResp *)result;
- (void)getRequestTaxiStandListResult:(NSMutableArray *)result;
- (void)getRequestIsRegistedUserResult:(STLoginResult *)result;
- (void)getPairIsNextResult:(StringContainer*)result;
- (void)getSetNextResult:(StringContainer*)result;


@end

@protocol PairManageDelegate<NSObject>

-(void) getRequestPairResult:(StringContainer*) pairInfo;
-(void) getRequestIsPairedResult:(STPairResponse *) isPaired;

@end

@interface PairManage : NSObject
{
	STPairInfo *pairInfo;
}

@property(nonatomic, retain) STPairInfo *pairInfo;

- (void)getRequestPair:(STPairInfo *)pairInfo;
- (void)getRequestIsPaired;

@property (nonatomic, retain) id<PairManageDelegate> delegate;

@end


@interface CommManager : NSObject
{
	CommManager		*commMgr;


	UserManage		*userManage;
	PairManage		*pairManage;

	double			fSrcLat;
	double			fSrcLon;
	double			fDstLat;
	double			fDstLon;
	NSString		*strSrcAddress;
	NSString		*strDstAddress;
	int				nPax;
	int				nGrpGender;
	NSString		*strColor;
	NSString		*strOtherFeature;
	NSString		*strPairedTime;

	STPairResponse	*g_pairResp;
}

+ (CommManager*)getGlobalCommMgr;
+ (CommManager *)getCommMgr;
+ (BOOL) hasConnectivity;
- (void) loadCommModules;

@property(atomic, retain) UserManage *userManage;
@property(atomic, retain) PairManage *pairManage;
@property(atomic, retain) CommManager *commMgr;


@property(nonatomic, readwrite) double		fSrcLat;
@property(nonatomic, readwrite) double		fSrcLon;
@property(nonatomic, readwrite) double		fDstLat;
@property(nonatomic, readwrite) double		fDstLon;
@property(nonatomic, retain) NSString		*strDstAddress;
@property(nonatomic, retain) NSString		*strSrcAddress;
@property(nonatomic, readwrite) int			nPax;
@property(nonatomic, readwrite) int			nGrpGender;
@property(nonatomic, retain) NSString		*strColor;
@property(nonatomic, retain) NSString		*strOtherFeature;
@property(nonatomic, retain) NSString		*strPairedTime;

@property(nonatomic, retain) STPairResponse *g_pairResp;


@end
