//
//  UnityNdComPlatformDelegate.h
//  Untitled
//
//  Created by Sie Kensou on 12-8-2.
//  Copyright 2012 NetDragon WebSoft Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UnityNdComPlatformDelegate : NSObject {
    
}

+ (void)sendU3dMessage:(NSString *)messageName param:(NSDictionary *)dict;
@end

