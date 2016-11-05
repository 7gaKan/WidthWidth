//
//  previewLayer.m
//  WidthWidth
//
//  Created by 韩佳岐 on 16/11/5.
//  Copyright © 2016年 www.hangagi.cn. All rights reserved.
//

#import "previewLayer.h"

@implementation previewLayer
- (id)copyWithZone:(NSZone *)zone
{
    previewLayer *f = [[previewLayer allocWithZone:zone] init];
    return f;
    
    // 有些人可能下面alloc,重新初始化空间，但这方法已给你分配了zone，自己就无需再次alloc内存空间了
    //    HSPerson *person = [[HSPerson alloc] init];
}
@end
