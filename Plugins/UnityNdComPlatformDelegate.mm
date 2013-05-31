//
//  UnityNdComPlatformDelegate.m
//  Untitled
//
//  Created by Sie Kensou on 12-8-2.
//  Copyright 2012 NetDragon WebSoft Inc. All rights reserved.
//

#import "UnityNdComPlatformDelegate.h"
#import <NdComPlatform/NdComPlatform.h>
#import <NdComPlatform/NdCPNotifications.h>
#include "U3dNdComPlatformInterface.h"
#include "ProductInfo.h"

char* MakeAutonomouseStringCopy(const char* string)
{
    if (string == NULL)
    {
        return NULL;
    }
    
    char *res = (char *)malloc(strlen(string) + 1);
    strcpy(res, string);
    return res;
}


#if defined(__cplusplus)
extern "C" {
#endif
extern void UnitySendMessage(const char *, const char *, const char *);
extern NSString* CreateNSString (const char* string);
#if defined(__cplusplus)
}
#endif
        
#pragma mark UnityNdComPlatformDelegate

@implementation UnityNdComPlatformDelegate
+ (void)addNdComPlatformObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginFinished:) name:kNdCPLoginNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(buyFinished:) name:kNdCPBuyResultNotification object:nil];    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(leavePlatform:) name:kNdCPLeavePlatformNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionInvalid:) name:kNdCPSessionInvalidNotification object:nil];
}

+ (void)sendU3dMessage:(NSString *)messageName param:(NSDictionary *)dict
{
    NSString *param = @"";
    for (NSString *key in dict)
    {
        if ([param length] == 0)
        {
            param = [param stringByAppendingFormat:@"%@=%@", key, [dict valueForKey:key]];
        }
        else
        {
            param = [param stringByAppendingFormat:@"&%@=%@", key, [dict valueForKey:key]];            
        }
    }
    
    NSLog(@"param : %@", param);

    
    UnitySendMessage("sdk91Listener", [messageName UTF8String], [param UTF8String]);
}

+ (void)loginFinished:(NSNotification *)aNotify
{
/**  登录接口通知 **/ 
	NSDictionary *dict = [aNotify userInfo];
    [self sendU3dMessage:@"kNdCPLoginNotification" param:
                [NSDictionary dictionaryWithObjectsAndKeys:[dict objectForKey:@"result"], @"result", [dict objectForKey:@"error"], @"error", nil]];
}

+ (void)buyFinished:(NSNotification *)aNotify
{
    NSDictionary *dict = [aNotify userInfo];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[dict objectForKey:@"result"], @"result", [dict objectForKey:@"error"], @"error", nil];
    
    NdBuyInfo *buyInfo = [dict objectForKey:@"buyInfo"];

    if (buyInfo)
    {
        [paramDict setValue:buyInfo.cooOrderSerial forKey:@"CooOrderSerial"];
        [paramDict setValue:buyInfo.productId forKey:@"ProductId"];
        [paramDict setValue:buyInfo.productName forKey:@"ProductName"];
        [paramDict setValue:[NSNumber numberWithFloat:buyInfo.productPrice] forKey:@"ProductPrice"];
        [paramDict setValue:[NSNumber numberWithFloat:buyInfo.productOrignalPrice] forKey:@"ProductOrignalPrice"];
        [paramDict setValue:[NSNumber numberWithInt:buyInfo.productCount] forKey:@"ProductCount"];
        [paramDict setValue:buyInfo.payDescription forKey:@"PayDescription"];

    }
    
/**  支付结果通知 详情查看文档 **/  
    [self sendU3dMessage:@"kNdCPBuyResultNotification" param:paramDict];
}

+ (void)leavePlatform:(NSNotification *)aNotify
{

/**  关闭91平台通知，包括用户取消登录，取消支付等通知，详情查看文档 **/  
    [self sendU3dMessage:@"kNdCPLeavePlatformNotification" param:nil];
}

+ (void)sessionInvalid:(NSNotification *)aNotify
{

/**  登录会话超时，或失效通知 **/ 
    [self sendU3dMessage:@"kNdCPSessionInvalidNotification" param:nil];
}


+ (void)appVersionUpdateDidFinish:(ND_APP_UPDATE_RESULT)updateResult
{   

/**  版本升级回调 **/  
    [self sendU3dMessage:@"kNappVersionUpdateDidFinish" param:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:updateResult] forKey:@"updateResult"]];
}

+ (void)searchPayResultInfoDidFinish:(int)error bSuccess:(BOOL)bSuccess buyInfo:(NdBuyInfo*)buyInfo
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:[NSNumber numberWithInt:error] forKey:@"error"];
    [dict setValue:[NSNumber numberWithBool:bSuccess]  forKey:@"success"];

    if (buyInfo)
    {
        [dict setValue:buyInfo.cooOrderSerial forKey:@"CooOrderSerial"];
        [dict setValue:buyInfo.productId forKey:@"ProductId"];
        [dict setValue:buyInfo.productName forKey:@"ProductName"];
        [dict setValue:[NSNumber numberWithFloat:buyInfo.productPrice] forKey:@"ProductPrice"];
        [dict setValue:[NSNumber numberWithFloat:buyInfo.productOrignalPrice] forKey:@"ProductOrignalPrice"];
        [dict setValue:[NSNumber numberWithInt:buyInfo.productCount] forKey:@"ProductCount"];
        [dict setValue:buyInfo.payDescription forKey:@"PayDescription"];
    }

/**  订单查询回调 **/  
    [self sendU3dMessage:@"kNsearchPayResultInfoDidFinish" param:dict];
}
@end





#if defined(__cplusplus)
extern "C" {
#endif
    
#pragma mark other useful c func utility
// Converts C style string to NSString
NSString* CreateNSString (const char* string)
{
	if (string)
		return [NSString stringWithUTF8String: string];
	else
		return [NSString stringWithUTF8String: ""];
}

// Helper method to create C string copy
char* MakeStringCopy (const char* string)
{
	if (string == NULL)
		return NULL;
	
	char* res = (char*)malloc(strlen(string) + 1);
	strcpy(res, string);
	return res;
}

#pragma mark c apis
void U3dNdSetAppId(int appId)
{
    [UnityNdComPlatformDelegate addNdComPlatformObservers];
    [[NdComPlatform defaultPlatform] setAppId:appId];
}

void U3dNdSetAppKey(const char * szAppKey)
{
    if (szAppKey == NULL)
        return;
    [[NdComPlatform defaultPlatform] setAppKey:CreateNSString(szAppKey)];
}

int U3dNdLogin(int nFlag)
{
    return [[NdComPlatform defaultPlatform] NdLogin:nFlag];
}
int U3dGetCurrentLoginState()
{
    return [[NdComPlatform defaultPlatform] getCurrentLoginState];
}
    
void U3dNdGuestRegist(int nFlag)
{
     [[NdComPlatform defaultPlatform] NdGuestRegist:nFlag];
}
void U3dNdGetCommodityList()
{
    NSLog(@"xcode U3dNdGetCommodityList");
    
    NSString *str = nil;
    int feeType = ND_VG_FEE_TYPE_POSSESS | ND_VG_FEE_TYPE_SUBSCRIBE | ND_VG_FEE_TYPE_CONSUME;
    NdPagination *ndPagination = [[[NdPagination alloc]init]autorelease];
    ndPagination.pageIndex = 1;
    ndPagination.pageSize = 50;
    productInfo *product = [[[productInfo alloc]init]autorelease];
    
    NSLog(@"ndPagin %d", ndPagination.pageIndex);
    
    [[NdComPlatform defaultPlatform] NdGetCommodityList:str feeType:feeType pagination:ndPagination packageId:nil delegate:(id)product];
    
    NSLog(@"xcode U3dNdGetCommodityList end");
}

long U3dNdGetUin()
{
    NSString *strUin = [[NdComPlatform defaultPlatform] loginUin];
    if ([strUin length] == 0)
        return -1;
    return [strUin longLongValue];
}
    
void U3dNdLogout(int nFlag)
{
    [[NdComPlatform defaultPlatform] NdLogout:nFlag];
}    
    
char *U3dNdGetSession()
{
    return MakeAutonomouseStringCopy([[[NdComPlatform defaultPlatform] sessionId] UTF8String]);
}
    
void U3dNdSetDebugMode(int nFlag)
{
    [[NdComPlatform defaultPlatform] NdSetDebugMode:nFlag];
}
    
void U3dNdSetScreenOrientation(int orientation)
{
    UIInterfaceOrientation orient = UIInterfaceOrientationPortrait;
    switch (orientation) {
        case 0:
            orient = UIInterfaceOrientationPortrait;
            break;
        case 1:
            orient = UIInterfaceOrientationLandscapeLeft;
            break;
        case 2:
            orient = UIInterfaceOrientationPortraitUpsideDown;
            break;
        case 3:
            orient = UIInterfaceOrientationLandscapeRight;
            break;
        default:
            break;
    }
    [[NdComPlatform defaultPlatform] NdSetScreenOrientation:orient];
}

void U3dNdSetAutoRotation(bool isAuto)
{
	[[NdComPlatform defaultPlatform] NdSetAutoRotation:isAuto];
}

bool U3dNdIsLogined()
{
    return [[NdComPlatform defaultPlatform] isLogined];
}

char *U3dNdGetNickname()
{
    return MakeAutonomouseStringCopy([[[NdComPlatform defaultPlatform] nickName] UTF8String]);
}
    
int U3dNdEnterRecharge(int nFlag, const char *content)
{
    return [[NdComPlatform defaultPlatform] NdEnterRecharge:nFlag content:CreateNSString(content)];
}

void U3dNdEnterPlatform(int nFlag)
{
    [[NdComPlatform defaultPlatform] NdEnterPlatform:nFlag];
}

int U3dNdUserFeedBack()
{
    return [[NdComPlatform defaultPlatform] NdUserFeedBack];
}
    
int U3dNdCheckUpdate(int nFlag)
{
    return [[NdComPlatform defaultPlatform] NdAppVersionUpdate:nFlag delegate:[UnityNdComPlatformDelegate class]];
}

int U3dNdSearchPayResult(const char *cooOrderSerial)
{
    NSString *order = nil;
    if (strlen(cooOrderSerial) != 0)
        order = CreateNSString(cooOrderSerial);
    return [[NdComPlatform defaultPlatform] NdSearchPayResultInfo:order delegate:[UnityNdComPlatformDelegate class]];
}
 
int U3dNdUniPay(const char *cooOrderSerial, const char *productId, const char *productName,
                       double productPrice, double productOriginalPrice, int productCount, const char *payDescription)
{
    NdBuyInfo *buyInfo = [[[NdBuyInfo alloc] init] autorelease];
    buyInfo.cooOrderSerial = CreateNSString(cooOrderSerial);
    buyInfo.productId = CreateNSString(productId);
    buyInfo.productName = CreateNSString(productName);
    buyInfo.productPrice = productPrice;
    buyInfo.productOrignalPrice = productOriginalPrice;
    buyInfo.productCount = productCount;
    buyInfo.payDescription = CreateNSString(payDescription);

    return [[NdComPlatform defaultPlatform] NdUniPay:buyInfo];
}

void U3dNdEnterVirtualShop()
{
    NSString *str = nil;
    int feeType = ND_VG_FEE_TYPE_POSSESS | ND_VG_FEE_TYPE_SUBSCRIBE | ND_VG_FEE_TYPE_CONSUME;
    
    [[NdComPlatform defaultPlatform]NdEnterVirtualShop:str feeType:feeType];
    
}
int U3dNdUniPayAsyn(const char *cooOrderSerial,
                    const char *productId,
                    const char *productName,
                    double productPrice,
                    double productOriginalPrice,
                    int productCount,
                    const char *payDescription)


{
    NdBuyInfo *buyInfo = [[[NdBuyInfo alloc] init] autorelease];
    buyInfo.cooOrderSerial = CreateNSString(cooOrderSerial);
    buyInfo.productId = CreateNSString(productId);
    buyInfo.productName = CreateNSString(productName);
    buyInfo.productPrice = productPrice;
    buyInfo.productOrignalPrice = productOriginalPrice;
    buyInfo.productCount = productCount;
    buyInfo.payDescription = CreateNSString(payDescription);
    
    return [[NdComPlatform defaultPlatform] NdUniPayAsyn:buyInfo];    
}

int U3dNdUniPayForCoin(const char *cooOrderSerial, int needPayCoins, const char *payDescription)
{
    return [[NdComPlatform defaultPlatform] NdUniPayForCoin:CreateNSString(cooOrderSerial) needPayCoins:needPayCoins payDescription:CreateNSString(payDescription)];
}
    
#if defined(__cplusplus)
}
#endif
