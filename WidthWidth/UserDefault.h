//
//  UserDefault.h
//  WidthWidth
//
//  Created by 韩佳岐 on 16/11/6.
//  Copyright © 2016年 www.hangagi.cn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDefault : NSObject
@property (nonatomic,assign) BOOL record;
+ (UserDefault *)shareUser;
@end
