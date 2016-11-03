//
//  tooBarBottom.m
//  WidthWidth
//
//  Created by 韩佳岐 on 16/11/3.
//  Copyright © 2016年 www.hangagi.cn. All rights reserved.
//

#import "tooBarBottom.h"

@implementation tooBarBottom

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)layout {
    self.alpha = 0.1;
    //添加view
//    UIView *fontView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
//    fontView.backgroundColor = [UIColor redColor];
//    [self addSubview:fontView];
//    fontView.alpha = 1;
//    NSLog(@"width:%f",self.frame.size.width);
//    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImage:)];
//    [fontView addGestureRecognizer: tap];
//    self.userInteractionEnabled = YES;
}
- (void)hideImage:(UITapGestureRecognizer*)tap{
    NSLog(@"ok");
}
@end
