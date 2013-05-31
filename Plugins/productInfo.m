//
//  productInfo.m
//  Unity-iPhone
//
//  Created by Lee on 13-4-23.
//
//

#import "productInfo.h"
#import <NdComPlatform/NdComPlatform.h>
#import <NdComPlatform/NdCPNotifications.h>
#import <NDJSON/NDSBJSON.h>
#import <NDJSON/NDSBJsonWriter.h>
#import "UnityNdComPlatformDelegate.h"

@implementation productInfo

- (void)getCommodityListDidFinish:(int)error  cateId:(NSString*)cateId  feeType:(int)feeType
						packageId:(NSString*)packageId result:(NdBasePageList*)result
{
    if (error < 0)
    {
        NSLog(@"error!");
    }
    else
    {
        NSString *keyAllArray[result.records.count];
        NSString *valueAllArray[result.records.count];
        NSDictionary *jsonDictionary = nil;
        NSInteger index = 0;
        
        NSLog(@"result arr count %d", result.records.count);
        
        for (NdVGCommodityInfo *info in result.records)
        {
            NSLog(@"Got an ERROR : %@" , info.strProductName);
            NSLog(@"Got an ERROR : %@" , info.strProductId);
            NSLog(@"Got an ERROR : %@" , info.strOriginPrice);
            NSLog(@"Got an ERROR : %@" , info.strSalePrice);
            NSLog(@"Got an ERROR : %@" , info.strGoodsDesc);
            
            
            keyAllArray[index] = [NSString stringWithFormat:@"%d", index];
            valueAllArray[index] = [self getItem:info];
            
            index++;
        }
        
        jsonDictionary = [NSDictionary dictionaryWithObjects:(id *)valueAllArray forKeys:(id *)keyAllArray count:result.records.count];
        
        NSLog(@"json : %@", jsonDictionary);
        
		[UnityNdComPlatformDelegate sendU3dMessage:@"kNdCPProductListResultNotification" param:jsonDictionary];
    }
}

- (NSString *)getItem:(NdVGCommodityInfo*)info
{
    NSArray * contentArray = nil;
    NSArray * keyArray = nil;
    NSDictionary *theDictionary = nil;
    
	NSString * strProductName = info.strProductName;
    NSString * strProductId = info.strProductId;
    NSString * strOriginPrice = info.strOriginPrice;
    NSString * strSalePrice = info.strSalePrice;
    NSString * strGoodsDesc = info.strGoodsDesc;
    
    keyArray = [NSArray arrayWithObjects:@"strProductName",@"strProductId",@"strOriginPrice",@"strSalePrice",@"strGoodsDesc", nil];
    contentArray = [NSArray arrayWithObjects:strProductName,strProductId,strOriginPrice,strSalePrice,strGoodsDesc, nil];
    
    theDictionary = [NSDictionary dictionaryWithObjects:contentArray forKeys:keyArray];
    
    
    NSString *jsonString;
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:theDictionary options:NSJSONWritingPrettyPrinted error:&error];
    if(! jsonData)
    {
        NSLog(@"Got an ERROR : %@" , error);
    }
    else
    {
        NSLog(@"in....");
        jsonString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    }
    
    
    
    return jsonString;
}

@end
