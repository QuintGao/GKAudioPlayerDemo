//
//  GKHttpManager.m
//  GKAudioPlayerDemo
//
//  Created by QuintGao on 2017/10/14.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import "GKHttpManager.h"

#define kBaseUrl @"http://192.168.18.236/api/"

@implementation GKHttpManager

+ (void)getRequestWithApi:(NSString *)api params:(NSDictionary *)params successBlock:(successBlock)successBlock failureBlock:(failureBlock)failureBlock {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    // 设置固定参数
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:params];
    
    NSDictionary *infoDic = [NSBundle mainBundle].infoDictionary;
    
    dic[@"version"]       = infoDic[@"CFBundleShortVersionString"];
    dic[@"devicetype"]    = @"ios";
    dic[@"systemversion"] = [UIDevice currentDevice].systemVersion;
    
    NSString *url = [kBaseUrl stringByAppendingString:api];
    
    [manager GET:url parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        
        NSInteger code = [dic[@"errorCode"] integerValue];
        
        if (code == 22000) {
            successBlock(dic[@"data"]);
        }else {
            
            NSError *error = [NSError errorWithDomain:@"" code:code userInfo:responseObject[@"data"]];
            failureBlock(error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failureBlock(error);
    }];
}

@end
