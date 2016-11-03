//
//  toolBarBaseView.m
//  WidthWidth
//
//  Created by 韩佳岐 on 16/11/3.
//  Copyright © 2016年 www.hangagi.cn. All rights reserved.
//

#import "toolBarBaseView.h"

@implementation toolBarBaseView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor blackColor];
        [self layout];
    }
    return self;
}
- (void)layout {
    
}
@end
