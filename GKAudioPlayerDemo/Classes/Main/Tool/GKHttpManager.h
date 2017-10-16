//
//  GKHttpManager.h
//  GKAudioPlayerDemo
//
//  Created by QuintGao on 2017/10/14.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^successBlock)(id responseObject);
typedef void(^failureBlock)(NSError *error);

@interface GKHttpManager : NSObject

+ (void)getRequestWithApi:(NSString *)api params:(NSDictionary *)params successBlock:(successBlock)successBlock failureBlock:(failureBlock)failureBlock;

@end
