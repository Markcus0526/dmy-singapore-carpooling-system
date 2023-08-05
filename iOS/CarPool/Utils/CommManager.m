//
//  CommManager.m
//  CarPool
//
//  Created by RiKS on 10/3/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import "CommManager.h"
#import "ServiceMethod.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "Common.h"
#import "STDataInfo.h"
#import <GoogleMaps/GoogleMaps.h>

#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"

#import <CoreLocation/CoreLocation.h>

@implementation UserManage

@synthesize userReg;

@synthesize delegate;


- (void) getRequestRegister:(STUserReg *)userreg
{	
	NSMutableString *method = [NSMutableString string];
	[method appendString:[ServiceMethod getServiceAddress]];
	[method appendString:[ServiceMethod cmdRequestRegister]];
    
	NSURL *url = [NSURL URLWithString:[ServiceMethod getServiceAddress]];
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    httpClient.parameterEncoding = AFJSONParameterEncoding;
	
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							userreg.UserName, @"UserName",
							userreg.PhoneNum, @"PhoneNum",
                            userreg.Password, @"Password",
                            [NSNumber numberWithInt:userreg.Gender], @"Gender",
                            [NSNumber numberWithInt:userreg.BirthYear], @"BirthYear",
                            userreg.Email, @"Email",
                            [NSNumber numberWithInt:userreg.IndGender], @"IndGender",
                            [NSNumber numberWithInt:userreg.GrpGender], @"GrpGender",
							[NSNumber numberWithInt:userreg.DelayTime], @"DelayTime",
							userreg.ImageData, @"ImageData",
							nil];
    
    NSDictionary * mainParam = [NSDictionary dictionaryWithObjectsAndKeys:
                                params, @"NewUser",
                                nil];
    
    [httpClient postPath:method parameters:mainParam success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
		 NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
		 
		 [self parseRequestRegister:responseStr];

		 NSLog(@"Request Successful, response '%@'", responseStr);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		 if (delegate != nil)
			 [delegate getRequestRegisterResult:nil ];
		 NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
     }];
}

- (void)getRequestIsRegistedUser:(NSString *)email
{
	NSMutableString *method = [NSMutableString string];
	[method appendString:[ServiceMethod getServiceAddress]];
	[method appendString:[ServiceMethod cmdRequestIsRegistedUser]];
	
	NSURL *url = [NSURL URLWithString:[ServiceMethod getServiceAddress]];
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    httpClient.parameterEncoding = AFJSONParameterEncoding;

	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							email, @"Email",
							nil];

	[httpClient postPath:method parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
	{
		NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];

	 	[self parseIsRegistedUser:responseStr];

	 	NSLog(@"Request Successful, response '%@'", responseStr);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[delegate getRequestIsRegistedUserResult:nil];
		NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
	}];
}

- (void)parseIsRegistedUser:(NSString *)responseStr
{
    NSError * e;
	NSDictionary  *jsonData = nil;
    STLoginResult * record = nil;
    
    if (responseStr)
    {
        jsonData = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers                                                             error: &e];
        
		record = [[STLoginResult alloc] init];
		record.Name = [jsonData objectForKey:@"Name"];
		record.Message = [jsonData objectForKey:@"Message"];
		record.ResultCode = [[jsonData objectForKey:@"ResultCode"] intValue];
		record.FirstLogin = [[jsonData objectForKey:@"FirstLogin"] intValue];
	}

    [delegate getRequestIsRegistedUserResult:record];
}

- (void)parseRequestRegister:(NSString *)responseStr
{
    NSError * e;
	NSDictionary  *jsonData = nil;
    StringContainer * record = nil;

    if (responseStr)
    {
        jsonData = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers                                                             error: &e];

		record = [[StringContainer alloc] init];
		record.Result = [[jsonData objectForKey:@"Result"] intValue];
		record.Value = [jsonData objectForKey:@"Value"];
	}

	if (delegate != nil)
	    [delegate getRequestRegisterResult:record];
}

- (void)getRequestLogin:(STAuthUser *)authuser
{
	NSMutableString *method = [NSMutableString string];
	[method appendString:[ServiceMethod getServiceAddress]];
	[method appendString:[ServiceMethod cmdRequestLogin]];

	NSURL *url = [NSURL URLWithString:[ServiceMethod getServiceAddress]];
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    httpClient.parameterEncoding = AFJSONParameterEncoding;

	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            authuser.Email, @"Email",
                            authuser.Password, @"Password",
							nil];

    NSDictionary * mainParam = [NSDictionary dictionaryWithObjectsAndKeys:
                                params, @"UserAuth",
                                nil];

    [httpClient postPath:method parameters:mainParam success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
		NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];

		[self parseRequestLogin:responseStr];
	}
	failure:^(AFHTTPRequestOperation *operation, NSError *error)
	{
		if (delegate != nil)
			[delegate getRequestLoginResult:nil ];
    }];
}

- (void)parseRequestLogin:(NSString *)responseStr
{
    NSError * e;
	NSDictionary  *jsonData = nil;
    STLoginResult * record = nil;
    
    if (responseStr)
    {
        jsonData = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers                                                             error: &e];
        
		record = [[STLoginResult alloc] init];
		record.ResultCode = [[jsonData objectForKey:@"ResultCode"] longValue];
		record.Message = [jsonData objectForKey:@"Message"];
		record.Name = [jsonData objectForKey:@"Name"];
	}
    
	if (delegate != nil)
	    [delegate getRequestLoginResult:record];
}

- (void)getRequestLogOut
{
	NSMutableString *method = [NSMutableString string];
	[method appendString:[ServiceMethod getServiceAddress]];
	[method appendString:[ServiceMethod cmdRequestPairOff]];
	[method appendString:@"/"];
	[method appendFormat:@"%ld", [Common readUserIdFromFile]];
    
	NSURL *url = [NSURL URLWithString:[ServiceMethod getServiceAddress]];
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    httpClient.parameterEncoding = AFJSONParameterEncoding;
	
	NSDictionary *params = nil;
    
    [httpClient getPath:method parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
	 {
		 NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
		 
		 [self parseRequestPairOff:responseStr];
		 
		 NSLog(@"Request Successful, response '%@'", responseStr);
	 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		 if (delegate != nil)
			 [delegate getRequestPairOffResult:nil];
		 NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
	 }];
}

- (void)parseRequestPairOff:(NSString *)responseStr
{
    NSError * e;
	NSDictionary  *jsonData = nil;
    StringContainer * record = nil;
    
    if (responseStr)
    {
        jsonData = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers                                                             error: &e];
        
		record = [[StringContainer alloc] init];
		record.Result = [[jsonData objectForKey:@"Result"] intValue];
		record.Value = [jsonData objectForKey:@"Value"];
	}
    
	if (delegate != nil)
	    [delegate getRequestPairOffResult:record];
}

- (void)getRequestPairAgree:(STPairAgree *)agreeInfo
{	
	NSMutableString *method = [NSMutableString string];
	[method appendString:[ServiceMethod getServiceAddress]];
	[method appendString:[ServiceMethod cmdRequestPairAgree]];
    
	NSURL *url = [NSURL URLWithString:[ServiceMethod getServiceAddress]];
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    httpClient.parameterEncoding = AFJSONParameterEncoding;
	
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSNumber numberWithLong:agreeInfo.Uid], @"Uid",
							[NSNumber numberWithBool:agreeInfo.IsAgree], @"IsAgree",
							nil];
    
    NSDictionary * mainParam = [NSDictionary dictionaryWithObjectsAndKeys:
                                params, @"AgreeInfo",
                                nil];
    
    [httpClient postPath:method parameters:mainParam success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
		 NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
		 
		 [self parseRequestPairAgree:responseStr];
		 
		 NSLog(@"Request Successful, response '%@'", responseStr);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		 if (delegate != nil)
			 [delegate getRequestPairAgreeResult:nil ];
		 NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
     }];
}

- (void)parseRequestPairAgree:(NSString *)responseStr
{
    NSError * e;
	NSDictionary  *jsonData = nil;
    StringContainer * record = nil;
    
    if (responseStr)
    {
        jsonData = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers                                                             error: &e];
        
		record = [[StringContainer alloc] init];
		record.Value = [jsonData objectForKey:@"Value"];
		record.Result = [[jsonData objectForKey:@"Result"] intValue];
	}
    
	if (delegate != nil)
	    [delegate getRequestPairAgreeResult:record];
}

- (void)getRequestAddTaxiStand:(STTaxiStand *)taxiStand
{	
	NSMutableString *method = [NSMutableString string];
	[method appendString:[ServiceMethod getServiceAddress]];
	[method appendString:[ServiceMethod cmdRequestAddTaxiStand]];
    
	NSURL *url = [NSURL URLWithString:[ServiceMethod getServiceAddress]];
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    httpClient.parameterEncoding = AFJSONParameterEncoding;
	
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSNumber numberWithLong:0], @"Uid",
							taxiStand.StandNo, @"StandNo",
							taxiStand.StandName, @"StandName",
							taxiStand.GpsAddress, @"GpsAddress",
							taxiStand.PostCode, @"PostCode",
							[NSNumber numberWithDouble:taxiStand.Longitude], @"Longitude",
							[NSNumber numberWithDouble:taxiStand.Latitude], @"Latitude",
							taxiStand.StandType, @"StandType",
							nil];
    
    NSDictionary * mainParam = [NSDictionary dictionaryWithObjectsAndKeys:
                                params, @"TaxiStand",
                                nil];
    
    [httpClient postPath:method parameters:mainParam success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
		 NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
		 
		 [self parseRequestAddTaxiStand:responseStr];
		 
		 NSLog(@"Request Successful, response '%@'", responseStr);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		 if (delegate != nil)
			 [delegate getRequestAddTaxiStandResult:nil ];
		 NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
     }];
}

- (void)parseRequestAddTaxiStand:(NSString *)responseStr
{
    NSError * e;
	NSDictionary  *jsonData = nil;
    StringContainer * record = nil;
    
    if (responseStr)
    {
        jsonData = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers                                                             error: &e];
        
		record = [[StringContainer alloc] init];
		record.Value = [jsonData objectForKey:@"Value"];
		record.Result = [[jsonData objectForKey:@"Result"] intValue];
	}
    
	if (delegate != nil)
	    [delegate getRequestAddTaxiStandResult:record];
}

- (void)getRequestUserCredits:(NSString *)uid
{
	NSMutableString *method = [NSMutableString string];
	[method appendString:[ServiceMethod getServiceAddress]];
	[method appendString:[ServiceMethod cmdRequestUserCredits]];	
	[method appendString:@"/"];
	[method appendString:uid];
    
	NSURL *url = [NSURL URLWithString:[ServiceMethod getServiceAddress]];
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    httpClient.parameterEncoding = AFJSONParameterEncoding;
	
	NSDictionary *params = nil;
    
    [httpClient getPath:method parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
	 {
		 NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
		 
		 [self parseRequestUserCredits:responseStr];
		 
		 NSLog(@"Request Successful, response '%@'", responseStr);
	 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		 if (delegate != nil)
			 [delegate getRequestUserCreditsResult:nil];
		 NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
	 }];
}

- (void)parseRequestUserCredits:(NSString *)responseStr
{   
	if (delegate != nil)
	    [delegate getRequestUserCreditsResult:[responseStr intValue]];
}

- (void)getRequestOppoAgree:(NSString *)Uid
{
	NSMutableString *method = [NSMutableString string];
	[method appendString:[ServiceMethod getServiceAddress]];
	[method appendString:[ServiceMethod cmdRequestOppoAgree]];
	[method appendString:@"/"];
	[method appendString:Uid];
    
	NSURL *url = [NSURL URLWithString:[ServiceMethod getServiceAddress]];
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    httpClient.parameterEncoding = AFJSONParameterEncoding;
	
	NSDictionary *params = nil;
    
    [httpClient getPath:method parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
	 {
		 NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
		 
		 [self parseRequestOppoAgree:responseStr];
		 
		 NSLog(@"Request Successful, response '%@'", responseStr);
	 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		 if (delegate != nil)
			 [delegate getRequestOppoAgreeResult:nil];
		 NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
	 }];
}

- (void)parseRequestOppoAgree:(NSString *)responseStr
{
    NSError * e;
	NSDictionary  *jsonData = nil;
    STAgreeResponse * record = nil;
    
    if (responseStr)
    {
        jsonData = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers                                                             error: &e];
        
		record = [[STAgreeResponse alloc] init];
		record.ErrCode = [[jsonData objectForKey:@"ErrCode"] intValue];
		record.Message = [jsonData objectForKey:@"Message"];
		record.PairedTime = [jsonData objectForKey:@"PairTime"];
	}
    
	if (delegate != nil)
	    [delegate getRequestOppoAgreeResult:record];
}

- (NSMutableArray*) findPositionWithName:(NSString *)name Type:(NSString *)type Latitude:(double)lat Longitude:(double)lon Radius:(NSString*)radius
{
	NSURL *url = [Common getFindPositionUrlForLongitude:lon Latitude:lat Name:name Type:type Radius:radius];
	NSLog(@"URL = %@", url);

	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request startSynchronous];
	NSError *error = [request error];
	NSMutableArray *arrTaxiStands = [[NSMutableArray alloc] initWithCapacity:0];

	if (!error)
	{
		NSString *response = [request responseString];
		NSLog(@"\n\nresponse = %@\n\n", response);

		NSDictionary *dict = [response JSONValue];
		NSString *status = [dict objectForKey:@"status"];
		if (![status isEqualToString:@"OK"])
		{
			NSLog(@"Error occured : status : %@", status);
			return nil;
		}

		NSMutableArray *arrResults = [dict objectForKey:@"results"];
		for (int i = 0; i < [arrResults count]; i++)
		{
			NSDictionary *dictItem = [arrResults objectAtIndex:i];
			GoogleTaxiStand *taxiStand = [GoogleTaxiStand deserialize:dictItem];
			[arrTaxiStands addObject:taxiStand];
		}
	}
	else
	{
		NSLog(@"Error occured : %@", error.description);
		return nil;
	}

	return arrTaxiStands;
}

- (void) getRequestTaxiStand : (STReqTaxiStand *)taxiStand
{
//	STTaxiStandResp *resp = nil;
//
//	NSMutableString *method = [NSMutableString string];
//	[method appendString:[ServiceMethod getServiceAddress]];
//	[method appendString:[ServiceMethod cmdRequestNearestTaxiStand]];
//
//	NSArray *keys = [NSArray arrayWithObjects:@"Uid", @"Longitude", @"Latitude", nil];
//
//#if true
//	NSArray *objects = [NSArray arrayWithObjects:[NSNumber numberWithLong:taxiStand.Uid], [NSNumber numberWithDouble:taxiStand.Longitude], [NSNumber numberWithDouble:taxiStand.Latitude], nil];
//#else
//	NSArray *objects = [NSArray arrayWithObjects:[NSNumber numberWithLong:taxiStand.Uid], [NSNumber numberWithDouble:211.328], [NSNumber numberWithDouble:324.328], nil];
//#endif
//
//	NSDictionary *req_taxistand = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
//	NSDictionary *param = [NSDictionary dictionaryWithObject:req_taxistand forKey:@"ReqTaxiStand"];
//	NSData *data = nil;
//
//	if ([NSJSONSerialization isValidJSONObject:param])
//	{
//		data = [NSJSONSerialization dataWithJSONObject:param options:0 error:nil];
//	}
//
//	NSURL *url = [NSURL URLWithString:[method stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//
//	[ASIHTTPRequest setShouldThrottleBandwidthForWWAN:YES];
//	[ASIHTTPRequest throttleBandwidthForWWANUsingLimit:50 * 1024];
//
//	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
//	[request addRequestHeader:@"Content-Type" value:@"application/json"];
//	[request setRequestMethod:@"POST"];
//
//	[request appendPostData:data];
//
//	[request setTimeOutSeconds:10];
//	[request setNumberOfTimesToRetryOnTimeout:2];
//
//
//	[request startSynchronous];
//	NSError *error = [request error];
//	if (!error)
//	{
//		NSString *response = [request responseString];
//
//		NSLog(@"%@", response);
//
//		NSDictionary *data = [response JSONValue];
//		NSDictionary *taxiStand = [data objectForKey:@"TaxiStand"];
//
//		resp = [[STTaxiStandResp alloc] init];
//		resp.Result = [[data objectForKey:@"Result"] longLongValue];
//		resp.Message = [data objectForKey:@"Message"];
//
//		resp.TaxiStand = [[STTaxiStand alloc] init];
//
//		resp.TaxiStand.Uid = [[taxiStand objectForKey:@"Uid"] longLongValue];
//		resp.TaxiStand.StandName = [taxiStand objectForKey:@"StandName"];
//		resp.TaxiStand.GpsAddress = [taxiStand objectForKey:@"GpsAddress"];
//		resp.TaxiStand.Longitude = [[taxiStand objectForKey:@"Longitude"] doubleValue];
//		resp.TaxiStand.Latitude = [[taxiStand objectForKey:@"Latitude"] doubleValue];
//		resp.TaxiStand.StandType = [taxiStand objectForKey:@"StandType"];
//		resp.TaxiStand.StandNo = [taxiStand objectForKey:@"StandNo"];
//		resp.TaxiStand.PostCode = [taxiStand objectForKey:@"PostCode"];
//	}
//
//	return resp;
	NSMutableString *method = [NSMutableString string];
	[method appendString:[ServiceMethod getServiceAddress]];
	[method appendString:[ServiceMethod cmdRequestNearestTaxiStand]];
    
	NSURL *url = [NSURL URLWithString:[ServiceMethod getServiceAddress]];
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    httpClient.parameterEncoding = AFJSONParameterEncoding;
	
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSNumber numberWithLong:taxiStand.Uid], @"Uid",
							[NSNumber numberWithDouble:taxiStand.Longitude], @"Longitude",
                            [NSNumber numberWithDouble:taxiStand.Latitude], @"Latitude",
							@"", @"Keyword",
							nil];
    
    NSDictionary * mainParam = [NSDictionary dictionaryWithObjectsAndKeys:
                                params, @"ReqTaxiStand",
                                nil];
    
    [httpClient postPath:method parameters:mainParam success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
		 NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
		 
		 [self parseRequestTaxiStand:responseStr];
		 
		 NSLog(@"Request Successful, response '%@'", responseStr);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		 if (delegate != nil)
			 [delegate getRequestTaxiStandResult:nil ];
		 NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
     }];
}

- (void)parseRequestTaxiStand:(NSString *)responseStr
{
    NSError * e;
	NSDictionary  *jsonData = nil;
    STTaxiStandResp * record = nil;
    
    if (responseStr)
    {
        jsonData = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers                                                             error: &e];
        
		record = [[STTaxiStandResp alloc] init];
		record.Result = [[jsonData objectForKey:@"Result"] longValue];
		record.Message = [jsonData objectForKey:@"Message"];

		NSDictionary *json = [jsonData objectForKey:@"TaxiStand"];
		STTaxiStand *taxiStand = [[STTaxiStand alloc] init];
		taxiStand.Uid = [[json objectForKey:@"Uid"] longValue];
		taxiStand.StandNo = [json objectForKey:@"StandNo"];
		taxiStand.StandName = [json objectForKey:@"StandName"];
		taxiStand.StandType = [json objectForKey:@"StandType"];
		taxiStand.GpsAddress = [json objectForKey:@"GpsAddress"];
		taxiStand.PostCode = [json objectForKey:@"PostCode"];
		taxiStand.Longitude = [[json objectForKey:@"Longitude"] doubleValue];
		taxiStand.Latitude = [[json objectForKey:@"Latitude"] doubleValue];

		record.TaxiStand = taxiStand;
	}
    
	if (delegate != nil)
	    [delegate getRequestTaxiStandResult:record];
}

- (void) getRequestTaxiStandList : (STReqTaxiStand *)taxiStand
{
	NSMutableString *method = [NSMutableString string];
	[method appendString:[ServiceMethod getServiceAddress]];
	[method appendString:[ServiceMethod cmdRequestTaxiStandList]];
    
	NSURL *url = [NSURL URLWithString:[ServiceMethod getServiceAddress]];
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    httpClient.parameterEncoding = AFJSONParameterEncoding;
	
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSNumber numberWithLong:taxiStand.Uid], @"Uid",
							[NSNumber numberWithDouble:taxiStand.Longitude], @"Longitude",
                            [NSNumber numberWithDouble:taxiStand.Latitude], @"Latitude",
                            taxiStand.Keyword, @"Keyword",
							nil];

    NSDictionary * mainParam = [NSDictionary dictionaryWithObjectsAndKeys:
                                params, @"ReqTaxiStand",
                                nil];
    
    [httpClient postPath:method parameters:mainParam success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
		 NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
		 
		 [self parseRequestTaxiStandList:responseStr];
		 
		 NSLog(@"Request Successful, response '%@'", responseStr);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		 if (delegate != nil)
			 [delegate getRequestTaxiStandListResult:nil ];
		 NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
     }];
}

- (void)parseRequestTaxiStandList:(NSString *)responseStr
{
    NSMutableArray *arrTaxiStand = [[NSMutableArray alloc] initWithCapacity:0];
	
	NSError * e;
    
    if (responseStr)
    {
        NSDictionary *tmp1 = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers                                                             error: &e];
		
		// make data array list
		for (NSDictionary *item in tmp1)
		{
			STTaxiStand *taxiStand = [[STTaxiStand alloc] init];
			taxiStand.Uid = [[item objectForKey:@"Uid"] longValue];
			taxiStand.StandNo = [item objectForKey:@"StandNo"];
			taxiStand.StandName = [item objectForKey:@"StandName"];
			taxiStand.GpsAddress = [item objectForKey:@"GpsAddress"];
			taxiStand.PostCode = [item objectForKey:@"PostCode"];
			taxiStand.StandType = [item objectForKey:@"StandType"];
			taxiStand.Longitude = [[item objectForKey:@"Longitude"] doubleValue];
			taxiStand.Latitude = [[item objectForKey:@"Latitude"] doubleValue];
			// add to list
			[arrTaxiStand addObject:taxiStand];
		}
    }
    
	if (delegate != nil)
	    [delegate getRequestTaxiStandListResult:arrTaxiStand];
}

- (void)getRequestUserProfile
{	
	NSMutableString *method = [NSMutableString string];
	[method appendString:[ServiceMethod getServiceAddress]];
	[method appendString:[ServiceMethod cmdRequestUserProfile]];
	[method appendString:@"/"];
	[method appendFormat:@"%ld", [Common readUserIdFromFile]];
    
	NSURL *url = [NSURL URLWithString:[ServiceMethod getServiceAddress]];
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    httpClient.parameterEncoding = AFJSONParameterEncoding;
	
	NSDictionary *params = nil;
    
    [httpClient getPath:method parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
	 {
		 NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
		 
		 [self parseRequestUserProfile:responseStr];
		 
		 NSLog(@"Request Successful, response '%@'", responseStr);
	 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		 if (delegate != nil)
			 [delegate getRequestUserProfileResult:nil];
		 NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
	 }];
}

- (void)parseRequestUserProfile:(NSString *)responseStr
{
    NSError * e;
	NSDictionary  *jsonData = nil;
    STUserProfile * record = nil;
    
    if (responseStr)
    {
        jsonData = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers                                                             error: &e];
        
		record = [[STUserProfile alloc] init];
		record.ErrCode = [[jsonData objectForKey:@"ErrCode"] intValue];
		record.Message = [jsonData objectForKey:@"Message"];
		record.Uid = [[jsonData objectForKey:@"Uid"] longValue];
		record.UserName = [jsonData objectForKey:@"UserName"];
		record.PhoneNum = [jsonData objectForKey:@"PhoneNum"];
		record.Password = [jsonData objectForKey:@"Password"];
		record.Gender = [[jsonData objectForKey:@"Gender"] intValue];
		record.BirthYear = [[jsonData objectForKey:@"BirthYear"] intValue];
		record.Email = [jsonData objectForKey:@"Email"];
		record.IndGender = [[jsonData objectForKey:@"IndGender"] intValue];
		record.GrpGender = [[jsonData objectForKey:@"GrpGender"] intValue];
		record.DelayTime = [[jsonData objectForKey:@"DelayTime"] intValue];
		record.LoginDate = [jsonData objectForKey:@"LoginDate"];
		record.Credit = [[jsonData objectForKey:@"Credit"] intValue];
		record.StarCount = [[jsonData objectForKey:@"StarCount"] doubleValue];
		record.ImageData = [jsonData objectForKey:@"ImageData"];
		record.TotalSaving = [[jsonData objectForKey:@"TotalSaving"] doubleValue];
		record.IsGroup = [[jsonData objectForKey:@"IsGroup"] intValue];
	}
    
	if (delegate != nil)
	    [delegate getRequestUserProfileResult:record];
}

- (void)getRequestResetPassword:(STReqResetPassword *)resetPass
{
	NSMutableString *method = [NSMutableString string];
	[method appendString:[ServiceMethod getServiceAddress]];
	[method appendString:[ServiceMethod cmdRequestResetPassword]];
    
	NSURL *url = [NSURL URLWithString:[ServiceMethod getServiceAddress]];
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    httpClient.parameterEncoding = AFJSONParameterEncoding;
	
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							resetPass.email, @"Email",
							nil];
	
	NSDictionary * mainParam = [NSDictionary dictionaryWithObjectsAndKeys:
                                params, @"ResetPassword",
                                nil];
    
    [httpClient postPath:method parameters:mainParam success:^(AFHTTPRequestOperation *operation, id responseObject)
	 {
		 NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
		 
		 [self parseRequestResetPassword:responseStr];
		 
		 NSLog(@"Request Successful, response '%@'", responseStr);
	 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		 if (delegate != nil)
			 [delegate getRequestResetPasswordResult:nil];
		 NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
	 }];
}

- (void)parseRequestResetPassword:(NSString *)responseStr
{
    NSError * e;
	NSDictionary  *jsonData = nil;
    StringContainer * record = nil;
    
    if (responseStr)
    {
        jsonData = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers                                                             error: &e];
        
		record = [[StringContainer alloc] init];
		record.Result = [[jsonData objectForKey:@"Result"] intValue];
		record.Value = [jsonData objectForKey:@"Value"];
	}
    
	if (delegate != nil)
	    [delegate getRequestResetPasswordResult:record];
}

- (void)getRequestSendSMS:(STSendSMS *)sendInfo
{
	NSMutableString *method = [NSMutableString string];
	[method appendString:[ServiceMethod getServiceAddress]];
	[method appendString:[ServiceMethod cmdRequestSendSMS]];
    
	NSURL *url = [NSURL URLWithString:[ServiceMethod getServiceAddress]];
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    httpClient.parameterEncoding = AFJSONParameterEncoding;
	
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithLong:sendInfo.Uid], @"Uid",
                            sendInfo.PhoneNum, @"PhoneNum",
							nil];
    
    NSDictionary * mainParam = [NSDictionary dictionaryWithObjectsAndKeys:
                                params, @"SendInfo",
                                nil];
    
    [httpClient postPath:method parameters:mainParam success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
		 NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
		 NSLog(@"Request Successful, response '%@'", responseStr);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
	}];
}

- (void)getRequestFLLogin:(STFLAuthInfo*)AuthInfo
{
	NSMutableString *method = [NSMutableString string];
	[method appendString:[ServiceMethod getServiceAddress]];
	[method appendString:[ServiceMethod cmdRequestFLLogin]];
    
	NSURL *url = [NSURL URLWithString:[ServiceMethod getServiceAddress]];
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    httpClient.parameterEncoding = AFJSONParameterEncoding;
	
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            AuthInfo.Name, @"Name",
                            AuthInfo.Email, @"Email",
							[NSNumber numberWithInt:AuthInfo.Gender], @"Gender",
							[NSNumber numberWithInt:AuthInfo.BirthYear], @"BirthYear",
							AuthInfo.PhoneNum, @"PhoneNum",
							AuthInfo.ImageData == nil ? @"" : AuthInfo.ImageData, @"ImageData",
							nil];
    
    NSDictionary * mainParam = [NSDictionary dictionaryWithObjectsAndKeys:
                                params, @"AuthInfo",
                                nil];
    
    [httpClient postPath:method parameters:mainParam success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
		 NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
		 
		 [self parseRequestFLLogin:responseStr];
		 
		 NSLog(@"Request Successful, response '%@'", responseStr);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		 if (delegate != nil)
			 [delegate getRequestFLLoginResult:nil ];
		 NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
     }];
}

- (void)parseRequestFLLogin:(NSString *)responseStr
{
    NSError * e;
	NSDictionary  *jsonData = nil;
    STLoginResult * record = nil;

    if (responseStr)
    {
        jsonData = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers                                                             error: &e];
        
		record = [[STLoginResult alloc] init];
		record.ResultCode = [[jsonData objectForKey:@"ResultCode"] longValue];
		record.Message = [jsonData objectForKey:@"Message"];
		record.Name = [jsonData objectForKey:@"Name"];
		record.firstLogin = [[jsonData objectForKey:@"FirstLogin"] intValue];
	}

	if (delegate != nil)
	    [delegate getRequestFLLoginResult:record];
}

- (void)getRequestPairingHistoryCount:(long)Uid
{
//	STPairHistoryCount *szRes = nil;
//
//	NSMutableString *method = [NSMutableString string];
//	[method appendString:[ServiceMethod getServiceAddress]];
//	[method appendString:[ServiceMethod cmdRequestPairingHistoryCount]];
//	[method appendString:[NSString stringWithFormat:@"/%ld", Uid]];
//
//	NSURL *url = [NSURL URLWithString:[method stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//
//	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
//	[request startSynchronous];
//	NSError *error = [request error];
//	if (!error)
//	{
//		NSString *response = [request responseString];
//		NSDictionary *data = [response JSONValue];
//
//		szRes = [[STPairHistoryCount alloc] init];
//		szRes.ErrCode = [[data objectForKey:@"ErrCode"] longLongValue];
//		szRes.Message = [data objectForKey:@"Message"];
//		szRes.TotalCount = [[data objectForKey:@"TotalCount"] longLongValue];
//		szRes.TotalSaving = [[data objectForKey:@"TotalSaving"] doubleValue];
//	}
//
//
//	return szRes;
	NSMutableString *method = [NSMutableString string];
	[method appendString:[ServiceMethod getServiceAddress]];
	[method appendString:[ServiceMethod cmdRequestPairingHistoryCount]];
	[method appendString:[NSString stringWithFormat:@"/%ld", Uid]];
    
	NSURL *url = [NSURL URLWithString:[ServiceMethod getServiceAddress]];
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    httpClient.parameterEncoding = AFJSONParameterEncoding;
	
	NSDictionary *params = nil;
    
    [httpClient getPath:method parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
	 {
		 NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
		 
		 [self parseRequestPairingHistoryCount:responseStr];
		 
		 NSLog(@"Request Successful, response '%@'", responseStr);
	 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		 if (delegate != nil)
			 [delegate getRequestPairingHistoryCountResult:nil];
		 NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
	 }];
}

- (void)parseRequestPairingHistoryCount:(NSString *)responseStr
{
    NSError * e;
	NSDictionary  *jsonData = nil;
    STPairHistoryCount * record = nil;
    
    if (responseStr)
    {
        jsonData = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers                                                             error: &e];
        
		record = [[STPairHistoryCount alloc] init];
		record.ErrCode = [[jsonData objectForKey:@"ErrCode"] longValue];
		record.Message = [jsonData objectForKey:@"Message"];
		record.TotalCount = [[jsonData objectForKey:@"TotalCount"] longValue];
		record.TotalSaving = [[jsonData objectForKey:@"TotalSaving"] doubleValue];
	}
    
	if (delegate != nil)
	    [delegate getRequestPairingHistoryCountResult:record];
}

- (void)getRequestPairingHistoryList:(STReqPairHistory *)ReqHistory
{
//	NSMutableArray *arrHistory = [[NSMutableArray alloc] initWithCapacity:0];
//
//	NSArray *infoKeys = [NSArray arrayWithObjects:@"Uid", @"PageNo", nil];
//	NSArray *infoObjects = [NSArray arrayWithObjects:[NSNumber numberWithLong:ReqHistory.Uid], [NSNumber numberWithLong:ReqHistory.PageNo], nil];
//
//	NSDictionary *infoDic = [NSDictionary dictionaryWithObjects:infoObjects forKeys:infoKeys];
//
//	NSArray *keys = [NSArray arrayWithObjects:@"ReqHistory", nil];
//	NSArray *objects = [NSArray arrayWithObjects:infoDic, nil];
//	NSData *jsonData = nil;
//
//	NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
//
//	if([NSJSONSerialization isValidJSONObject:jsonDictionary])
//	{
//		jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:nil];
//	}
//
//	NSMutableString *method = [NSMutableString string];
//	[method appendString:[ServiceMethod getServiceAddress]];
//	[method appendString:[ServiceMethod cmdRequestPairingHistoryList]];
//	
//	NSURL *url = [NSURL URLWithString:[method stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//	
//	[ASIHTTPRequest setShouldThrottleBandwidthForWWAN:YES];
//	[ASIHTTPRequest throttleBandwidthForWWANUsingLimit:50 * 1024];
//	
//	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
//	[request addRequestHeader:@"Content-Type" value:@"application/json"];
//	[request setRequestMethod:@"POST"];
//	
//	[request appendPostData:jsonData];
//	
//	[request setTimeOutSeconds:10];
//	[request setNumberOfTimesToRetryOnTimeout:2];
//	
//	[request startSynchronous];
//	NSError *error = [request error];
//	if (!error)
//	{
//		NSString *response = [request responseString];
//		NSMutableArray *data = [response JSONValue];
//
//		for (int i = 0; i < data.count; i++)
//		{
//			NSDictionary *historyItem = [data objectAtIndex:i];
//			STPairHistory *pairHistory = [[STPairHistory alloc] init];
//			pairHistory.PairingTime = [historyItem objectForKey:@"PairingTime"];
//			pairHistory.Uid1 = [[historyItem objectForKey:@"Uid1"] longLongValue];
//			pairHistory.Uid2 = [[historyItem objectForKey:@"Uid2"] longLongValue];
//			pairHistory.Name1 = [historyItem objectForKey:@"Name1"];
//			pairHistory.Name2 = [historyItem objectForKey:@"Name2"];
//			pairHistory.SrcAddr = [historyItem objectForKey:@"SrcAddr"];
//			pairHistory.DstAddr1 = [historyItem objectForKey:@"DstAddr1"];
//			pairHistory.DstAddr2 = [historyItem objectForKey:@"DstAddr2"];
//			pairHistory.SavePrice = [[historyItem objectForKey:@"SavePrice"] doubleValue];
//			pairHistory.WasteTime = [[historyItem objectForKey:@"WasteTime"] doubleValue];
//			pairHistory.OffOrder = [[historyItem objectForKey:@"OffOrder"] intValue];
//			pairHistory.Score1 = [[historyItem objectForKey:@"Score1"] doubleValue];
//			pairHistory.Score2 = [[historyItem objectForKey:@"Score2"] doubleValue];
//			pairHistory.Gender1 = [[historyItem objectForKey:@"Gender1"] intValue];
//			pairHistory.Gender2 = [[historyItem objectForKey:@"Gender2"] intValue];
//
//			[arrHistory addObject:pairHistory];
//		}
//	}
//
//	return arrHistory;
	NSMutableString *method = [NSMutableString string];
	[method appendString:[ServiceMethod getServiceAddress]];
	[method appendString:[ServiceMethod cmdRequestPairingHistoryList]];
    
	NSURL *url = [NSURL URLWithString:[ServiceMethod getServiceAddress]];
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    httpClient.parameterEncoding = AFJSONParameterEncoding;
	
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSNumber numberWithLong:ReqHistory.Uid], @"Uid",
							[NSNumber numberWithLong:ReqHistory.PageNo], @"PageNo",
							nil];
    
    NSDictionary * mainParam = [NSDictionary dictionaryWithObjectsAndKeys:
                                params, @"ReqHistory",
                                nil];
    
    [httpClient postPath:method parameters:mainParam success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
		 NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
		 
		 [self parseRequestPairingHistoryList:responseStr];
		 
		 NSLog(@"Request Successful, response '%@'", responseStr);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		 if (delegate != nil)
			 [delegate getRequestPairingHistoryListResult:nil ];
		 NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
     }];
}

- (void)parseRequestPairingHistoryList:(NSString *)responseStr
{    
    NSMutableArray *arrHistory = [[NSMutableArray alloc] initWithCapacity:0];
		
	NSError * e;
    
    if (responseStr)
    {
        NSDictionary *tmp1 = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers                                                             error: &e];
                    
		// make data array list
		for (NSDictionary *item in tmp1)
		{			
			STPairHistory *pairHistory = [[STPairHistory alloc] init];
			pairHistory.PairingTime = [item objectForKey:@"PairingTime"];
			pairHistory.Uid1 = [[item objectForKey:@"Uid1"] longLongValue];
			pairHistory.Uid2 = [[item objectForKey:@"Uid2"] longLongValue];
			pairHistory.Name1 = [item objectForKey:@"Name1"];
			pairHistory.Name2 = [item objectForKey:@"Name2"];
			pairHistory.SrcAddr = [item objectForKey:@"SrcAddr"];
			pairHistory.DstAddr1 = [item objectForKey:@"DstAddr1"];
			pairHistory.DstAddr2 = [item objectForKey:@"DstAddr2"];
			pairHistory.SavePrice = [[item objectForKey:@"SavePrice"] doubleValue];
			pairHistory.WasteTime = [[item objectForKey:@"WasteTime"] doubleValue];
			pairHistory.OffOrder = [[item objectForKey:@"OffOrder"] intValue];
			pairHistory.Score1 = [[item objectForKey:@"Score1"] doubleValue];
			pairHistory.Score2 = [[item objectForKey:@"Score2"] doubleValue];
			pairHistory.Gender1 = [[item objectForKey:@"Gender1"] intValue];
			pairHistory.Gender2 = [[item objectForKey:@"Gender2"] intValue];
			
			// add to list
			[arrHistory addObject:pairHistory];
		}
    }
    
	if (delegate != nil)
	    [delegate getRequestPairingHistoryListResult:arrHistory];
}

- (void)getGetPairingHistoryCount:(NSString *)Uid paegno:(NSString *)PageNo
{
	NSMutableString *method = [NSMutableString string];
	[method appendString:[ServiceMethod getServiceAddress]];
	[method appendString:[ServiceMethod cmdGetPairingHistoryList]];
    
	NSURL *url = [NSURL URLWithString:[ServiceMethod getServiceAddress]];
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    httpClient.parameterEncoding = AFJSONParameterEncoding;
	
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSNumber numberWithLong:Uid], @"Uid",
							[NSNumber numberWithLong:PageNo], @"PageNo",
							nil];
    
    [httpClient getPath:method parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
	 {
		 NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
		 
		 [self parseRequestPairingHistoryList:responseStr];
		 
		 NSLog(@"Request Successful, response '%@'", responseStr);
	 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		 if (delegate != nil)
			 [delegate getRequestPairingHistoryListResult:nil];
		 NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
	 }];
}

- (void)getRequestEvaluate:(STEvaluate *)evaluate
{
	NSMutableString *method = [NSMutableString string];
	[method appendString:[ServiceMethod getServiceAddress]];
	[method appendString:[ServiceMethod cmdRequestEvaluate]];
    
	NSURL *url = [NSURL URLWithString:[ServiceMethod getServiceAddress]];
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    httpClient.parameterEncoding = AFJSONParameterEncoding;
	
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSNumber numberWithLong:evaluate.Uid], @"Uid",
							[NSNumber numberWithLong:evaluate.OppoID], @"OppoID",
                            [NSNumber numberWithDouble:evaluate.Score], @"Score",
                            evaluate.ServeTime, @"ServeTime",
							nil];
    
    NSDictionary * mainParam = [NSDictionary dictionaryWithObjectsAndKeys:
                                params, @"Evaluate",
                                nil];
    
    [httpClient postPath:method parameters:mainParam success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
		 NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
		 
		 [self parsetRequestEvaluate:responseStr];
		 
		 NSLog(@"Request Successful, response '%@'", responseStr);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		 if (delegate != nil)
			 [delegate getRequestEvaluateResult:nil ];
		 NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
     }];
}

- (void)parsetRequestEvaluate:(NSString *)responseStr
{
    NSError * e;
	NSDictionary  *jsonData = nil;
    StringContainer * record = nil;
    
    if (responseStr)
    {
        jsonData = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers                                                             error: &e];
        
		record = [[StringContainer alloc] init];
		record.Result = [[jsonData objectForKey:@"Result"] longValue];
		record.Value = [jsonData objectForKey:@"Value"];
	}
    
	if (delegate != nil)
	    [delegate getRequestEvaluateResult:record];
}

- (void)getRequestUserProfileUpdate:(STUserProfile *)profile
{	
	NSMutableString *method = [NSMutableString string];
	[method appendString:[ServiceMethod getServiceAddress]];
	[method appendString:[ServiceMethod cmdRequestUpdateProfile]];
    
	NSURL *url = [NSURL URLWithString:[ServiceMethod getServiceAddress]];
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    httpClient.parameterEncoding = AFJSONParameterEncoding;
	
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSNumber numberWithInt:0], @"ErrCode",
							@"", @"Message",
							[NSNumber numberWithLong:profile.Uid], @"Uid",
							profile.UserName, @"UserName",
                            profile.PhoneNum, @"PhoneNum",
							profile.Password, @"Password",
							[NSNumber numberWithInt:profile.Gender], @"Gender",
                            [NSNumber numberWithInt:profile.BirthYear], @"BirthYear",
                            profile.Email, @"Email",
                            [NSNumber numberWithInt:profile.IndGender], @"IndGender",
                            [NSNumber numberWithInt:profile.GrpGender], @"GrpGender",
							[NSNumber numberWithInt:profile.DelayTime], @"DelayTime",
							profile.LoginDate, @"LoginDate",
							[NSNumber numberWithInt:profile.Credit], @"Credit",
							[NSNumber numberWithDouble:profile.StarCount], @"StarCount",
							profile.ImageData, @"ImageData",
							[NSNumber numberWithDouble:profile.TotalSaving], @"TotalSaving",
							[NSNumber numberWithInt:profile.IsGroup], @"IsGroup",
							nil];
    
    NSDictionary * mainParam = [NSDictionary dictionaryWithObjectsAndKeys:
                                params, @"UserProfile",
                                nil];
    
    [httpClient postPath:method parameters:mainParam success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
		 NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
		 
		 [self parseRequestUserProfileUpdate:responseStr];
		 
		 NSLog(@"Request Successful, response '%@'", responseStr);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		 if (delegate != nil)
			 [delegate getRequestUserProfileUpdateResult:nil ];
		 NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
     }];
}

- (void)parseRequestUserProfileUpdate:(NSString *)responseStr
{
    NSError * e;
	NSDictionary  *jsonData = nil;
    StringContainer * record = nil;
    
    if (responseStr)
    {
        jsonData = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers                                                             error: &e];
        
		record = [[StringContainer alloc] init];
		record.Value = [jsonData objectForKey:@"Value"];
		record.Result = [[jsonData objectForKey:@"Result"] intValue];
	}
    
	if (delegate != nil)
	    [delegate getRequestUserProfileUpdateResult:record];
}

- (NSMutableArray *)getRouteStepsFrom:(CLLocationCoordinate2D)start_coord to:(CLLocationCoordinate2D)end_coord
{
	NSMutableString *szUrl = [NSMutableString string];
	NSMutableArray *arrLines = [[NSMutableArray alloc] initWithCapacity:0];

	[szUrl appendString:[Common getGoogleRoutesUrl]];
	[szUrl appendString:[NSString stringWithFormat:@"origin=%f,%f&destination=%f,%f&sensor=false&mode=driving&language=en-US", start_coord.latitude, start_coord.longitude, end_coord.latitude, end_coord.longitude]];

	ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:szUrl]];
	[request startSynchronous];
	NSError *error = [request error];
	if (!error)
	{
		NSString *response = [request responseString];
		NSDictionary *dict = [response JSONValue];

		NSMutableArray *arrRoutes = [dict objectForKey:@"routes"];
		if (arrRoutes != nil && arrRoutes.count != 0)
		{
			NSDictionary *firstRoot = [arrRoutes objectAtIndex:0];
			NSMutableArray *arrLegs = [firstRoot objectForKey:@"legs"];
			if (arrLegs != nil && arrLegs.count != 0)
			{
				NSDictionary *firstLeg = [arrLegs objectAtIndex:0];
				NSMutableArray *arrSteps = [firstLeg objectForKey:@"steps"];
				if (arrSteps != nil)
				{
					for (int i = 0; i < arrSteps.count; i++)
					{
						NSDictionary *stepItem = [arrSteps objectAtIndex:i];
						NSDictionary *start_loc = [stepItem objectForKey:@"start_location"];
						NSDictionary *end_loc = [stepItem objectForKey:@"end_location"];

						double latitude = [[start_loc objectForKey:@"lat"] doubleValue];
						double longitude = [[start_loc objectForKey:@"lng"] doubleValue];

						CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];

						[arrLines addObject:location];

						if (i == arrSteps.count - 1)
						{
							latitude = [[end_loc objectForKey:@"lat"] doubleValue];
							longitude = [[end_loc objectForKey:@"lng"] doubleValue];

							CLLocation *end_location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
							[arrLines addObject:end_location];
						}
					}
				}
			}
		}
	}

	return arrLines;
}

- (int)getSharable
{
	NSMutableString *method = [NSMutableString string];
	[method appendString:[ServiceMethod getServiceAddress]];
	[method appendString:[ServiceMethod cmdGetSharable]];
	[method appendString:[NSString stringWithFormat:@"/%ld", [Common readUserIdFromFile]]];
	
	NSURL *url = [NSURL URLWithString:[method stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request startSynchronous];
	NSError *error = [request error];
	
	int nRet = -2;
	if (!error)
	{
		NSString *response = [request responseString];
		nRet = [response intValue];
	}
	else
	{
		NSLog(@"Network error");
		nRet = -2;
	}
	
	return nRet;
}

- (void)getRequestShareLog:(STShareLog *)shareLog
{
	NSArray *infoKeys = [NSArray arrayWithObjects:@"UserID", @"Content", nil];
	NSArray *infoObjects = [NSArray arrayWithObjects:[NSNumber numberWithLong:shareLog.Uid], shareLog.Content, nil];
	
	NSDictionary *infoDic = [NSDictionary dictionaryWithObjects:infoObjects forKeys:infoKeys];
	
	NSArray *keys = [NSArray arrayWithObjects:@"ShareLog", nil];
	NSArray *objects = [NSArray arrayWithObjects:infoDic, nil];
	NSData *jsonData = nil;
	
	NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
	
	if([NSJSONSerialization isValidJSONObject:jsonDictionary])
	{
		jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:nil];
	}
	
	NSMutableString *method = [NSMutableString string];
	[method appendString:[ServiceMethod getServiceAddress]];
	[method appendString:[ServiceMethod cmdRequestShareLog]];
	
	NSURL *url = [NSURL URLWithString:[method stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	
	[ASIHTTPRequest setShouldThrottleBandwidthForWWAN:YES];
	[ASIHTTPRequest throttleBandwidthForWWANUsingLimit:50 * 1024];
	
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request addRequestHeader:@"Content-Type" value:@"application/json"];
	[request setRequestMethod:@"POST"];
	
	[request appendPostData:jsonData];
	
	[request setTimeOutSeconds:10];
	[request setNumberOfTimesToRetryOnTimeout:2];
	
	[request startSynchronous];
	NSError *error = [request error];
	
	if (!error)
	{
		NSLog(@"Share Log Success");
	}
	else
	{
		NSLog(@"Share Log Failed");
	}
}


- (NSMutableArray *)getDestList:(NSString*)destName withPageNo:(int)pageno
{
	NSMutableArray *arrDestList = nil;

	NSMutableString *method = [NSMutableString string];
	[method appendString:[ServiceMethod getServiceAddress]];
	[method appendString:[ServiceMethod cmdGetDestList]];
	[method appendString:[NSString stringWithFormat:@"/%@/%d", destName, pageno]];

	NSURL *url = [NSURL URLWithString:[method stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request startSynchronous];
	NSError *error = [request error];

	int nRet = -2;
	if (!error)
	{
		NSString *response = [request responseString];
		NSMutableArray *arrResults = [response JSONValue];
		if (arrResults == nil)
			return nil;

		arrDestList = [[NSMutableArray alloc] initWithCapacity:0];
		for (int i = 0; i < arrResults.count; i++)
		{
			NSDictionary *dictItem = [arrResults objectAtIndex:i];

			STTaxiStand *taxiStand = [[STTaxiStand alloc] init];
			taxiStand.Uid = [[dictItem objectForKey:@"Uid"] longLongValue];
			taxiStand.StandNo = [dictItem objectForKey:@"StandNo"];
			taxiStand.StandName = [dictItem objectForKey:@"StandName"];
			taxiStand.GpsAddress = [dictItem objectForKey:@"GpsAddress"];
			taxiStand.Longitude = [[dictItem objectForKey:@"Longitude"] doubleValue];
			taxiStand.Latitude = [[dictItem objectForKey:@"Latitude"] doubleValue];
			taxiStand.StandType = [dictItem objectForKey:@"StandType"];
			taxiStand.PostCode = [dictItem objectForKey:@"PostCode"];

			[arrDestList addObject:taxiStand];
		}
	}
	else
	{
		NSLog(@"Network error");
		nRet = -2;
	}

	return arrDestList;
}


- (void)getPairIsNext
{
	NSMutableString *method = [NSMutableString string];
	[method appendString:[ServiceMethod getServiceAddress]];
	[method appendString:[ServiceMethod cmdIsNext]];
	[method appendString:@"/"];
	[method appendFormat:@"%ld", [Common readUserIdFromFile]];

	NSURL *url = [NSURL URLWithString:[ServiceMethod getServiceAddress]];
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    httpClient.parameterEncoding = AFJSONParameterEncoding;

	NSDictionary *params = nil;
	StringContainer* szRes = [[StringContainer alloc] init];

    [httpClient getPath:method parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
	{
		NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
		NSDictionary* jsonData = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error:nil];
		szRes.Result = [[jsonData objectForKey:@"Result"] longValue];
		szRes.Value = [jsonData objectForKey:@"Value"];
		[delegate getPairIsNextResult:szRes];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (delegate != nil)
			[delegate getPairIsNextResult:nil];
		NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
	}];
}

- (void)getSetNext
{
	NSMutableString *method = [NSMutableString string];
	[method appendString:[ServiceMethod getServiceAddress]];
	[method appendString:[ServiceMethod cmdSetNext]];
	[method appendString:@"/"];
	[method appendFormat:@"%ld", [Common readUserIdFromFile]];

	NSURL *url = [NSURL URLWithString:[ServiceMethod getServiceAddress]];
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    httpClient.parameterEncoding = AFJSONParameterEncoding;

	NSDictionary *params = nil;
	StringContainer* szRes = [[StringContainer alloc] init];

    [httpClient getPath:method parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
	{
		NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
		NSDictionary* jsonData = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error:nil];
		szRes.Result = [[jsonData objectForKey:@"Result"] longValue];
		szRes.Value = [jsonData objectForKey:@"Value"];
		[delegate getSetNextResult:szRes];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (delegate != nil)
			[delegate getSetNextResult:nil];
		NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
	}];
}

@end

@implementation PairManage

@synthesize pairInfo;
@synthesize delegate;

- (void)getRequestPair:(STPairInfo *)pairinfo
{
	NSMutableString *method = [NSMutableString string];
	[method appendString:[ServiceMethod getServiceAddress]];
	[method appendString:[ServiceMethod cmdRequestPair]];
    
	NSURL *url = [NSURL URLWithString:[ServiceMethod getServiceAddress]];
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    httpClient.parameterEncoding = AFJSONParameterEncoding;
	
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSNumber numberWithLong:pairinfo.Uid], @"Uid",
							[NSNumber numberWithDouble:pairinfo.SrcLat], @"SrcLat",
                            [NSNumber numberWithDouble:pairinfo.SrcLon], @"SrcLon",
                            [NSNumber numberWithDouble:pairinfo.DstLat], @"DstLat",
                            [NSNumber numberWithDouble:pairinfo.DstLon], @"DstLon",
                            pairinfo.Destination, @"Destination",
                            [NSNumber numberWithInt:pairinfo.Count], @"Count",
                            [NSNumber numberWithInt:pairinfo.GrpGender], @"GrpGender",
							pairinfo.Color, @"Color",
							pairinfo.OtherFeature, @"OtherFeature",
							nil];

    NSDictionary * mainParam = [NSDictionary dictionaryWithObjectsAndKeys:
                                params, @"PairInfo",
                                nil];

    [httpClient postPath:method parameters:mainParam success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
		 NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];

		 [self parseRequestPair:responseStr];

		 NSLog(@"Request Successful, response '%@'", responseStr);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		 if (delegate != nil)
			 [delegate getRequestPairResult:nil ];
		 NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
     }];
}

- (void)parseRequestPair:(NSString *)responseStr
{
    NSError * e;
	NSDictionary  *jsonData = nil;
    StringContainer * record = nil;

    if (responseStr)
    {
        jsonData = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers                                                             error: &e];

		record = [[StringContainer alloc] init];
		record.Result = [[jsonData objectForKey:@"Result"] longValue];
		record.Value = [jsonData objectForKey:@"Value"];
	}

	if (delegate != nil)
	    [delegate getRequestPairResult:record];
}

- (void)getRequestIsPaired
{	
	NSMutableString *method = [NSMutableString string];
	[method appendString:[ServiceMethod getServiceAddress]];
	[method appendString:[ServiceMethod cmdRequestIsPaired]];	
	[method appendString:@"/"];
	[method appendFormat:@"%ld", [Common readUserIdFromFile]];

	NSURL *url = [NSURL URLWithString:[ServiceMethod getServiceAddress]];
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    httpClient.parameterEncoding = AFJSONParameterEncoding;

	NSDictionary *params = nil;

    [httpClient getPath:method parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
	{
		NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];

		[self parseRequestIsPaired:responseStr];

		NSLog(@"Request Successful, response '%@'", responseStr);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (delegate != nil)
			[delegate getRequestIsPairedResult:nil];
		NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
	}];
}

- (void)parseRequestIsPaired:(NSString *)responseStr
{
    NSError * e;
	NSDictionary  *jsonData = nil;
    STPairResponse * record = nil;
    
    if (responseStr)
    {
        jsonData = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers                                                             error: &e];

		record = [[STPairResponse alloc] init];
		record.ErrCode = [[jsonData objectForKey:@"ErrCode"] intValue];
		record.Message = [jsonData objectForKey:@"Message"];
		record.Name = [jsonData objectForKey:@"Name"];
		record.Destination = [jsonData objectForKey:@"Destination"];
		record.DstLat = [[jsonData objectForKey:@"DstLat"] doubleValue];
		record.DstLon = [[jsonData objectForKey:@"DstLon"] doubleValue];
		record.Count = [[jsonData objectForKey:@"Count"] intValue];
		record.GrpGender = [[jsonData objectForKey:@"GrpGender"] intValue];
		record.Color = [jsonData objectForKey:@"Color"];
		record.OtherFeature = [jsonData objectForKey:@"OtherFeature"];
		record.SaveMoney = [[jsonData objectForKey:@"SaveMoney"] doubleValue];
		record.LostTime = [[jsonData objectForKey:@"LostTime"] doubleValue];
		record.OffOrder = [[jsonData objectForKey:@"OffOrder"] intValue];
		record.Uid = [[jsonData objectForKey:@"OppoID"] intValue];
		record.QueueOrder = [[jsonData objectForKey:@"QueueOrder"] intValue];
	}

	if (delegate != nil)
	    [delegate getRequestIsPairedResult:record];
}
@end



@implementation CommManager

@synthesize commMgr;
@synthesize userManage;
@synthesize pairManage;

@synthesize fSrcLat;
@synthesize fSrcLon;
@synthesize fDstLat;
@synthesize fDstLon;
@synthesize strSrcAddress;
@synthesize strDstAddress;
@synthesize nPax;
@synthesize nGrpGender;
@synthesize strColor;
@synthesize strOtherFeature;
@synthesize strPairedTime;

@synthesize g_pairResp;

static CommManager* g_commMgr = nil;

+ (CommManager*)getGlobalCommMgr
{
	if (g_commMgr == nil)
	{
		g_commMgr = [[CommManager alloc] init];
		[g_commMgr loadCommModules];
	}

	return g_commMgr;
}

+ (CommManager *)getCommMgr
{
	CommManager* commMgr = [[CommManager alloc] init];
	[commMgr loadCommModules];
	return commMgr;
}

+ (BOOL)hasConnectivity
{
	struct sockaddr_in zeroAddress;
	bzero(&zeroAddress, sizeof(zeroAddress));
	zeroAddress.sin_len = sizeof(zeroAddress);
	zeroAddress.sin_family = AF_INET;

	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&zeroAddress);

	if(reachability != NULL)
	{
		SCNetworkReachabilityFlags flags;
		if (SCNetworkReachabilityGetFlags(reachability, &flags))
		{
			if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
			{
				return NO;
			}

			if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
			{
				return YES;
			}

			if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
				(flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
			{
				if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
				{
					return YES;
				}
			}

			if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
			{
				return YES;
			}
		}
	}
	
	return NO;
}

- (void)loadCommModules
{
	userManage = [[UserManage alloc] init];
	pairManage = [[PairManage alloc] init];
	g_pairResp = nil;
}


@end
