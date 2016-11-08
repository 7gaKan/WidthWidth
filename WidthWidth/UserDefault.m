//
//  UserDefault.m
//  WidthWidth
//
//  Created by 韩佳岐 on 16/11/6.
//  Copyright © 2016年 www.hangagi.cn. All rights reserved.
//

#import "UserDefault.h"

@implementation UserDefault
+ (UserDefault *)shareUser {
    static UserDefault *sharedAccountManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedAccountManagerInstance = [[self alloc] init];
    });
    return sharedAccountManagerInstance;
}
@end
