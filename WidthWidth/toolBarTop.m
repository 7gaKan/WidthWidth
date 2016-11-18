//
//  toolBarTop.m
//  WidthWidth
//
//  Created by 韩佳岐 on 16/11/3.
//  Copyright © 2016年 www.hangagi.cn. All rights reserved.
//

#import "toolBarTop.h"

@implementation toolBarTop

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)layout {
    //父视图透明子视图不透明*****
    self.backgroundColor = [[UIColor grayColor]colorWithAlphaComponent:0.4f];
    UserDefault *user = [UserDefault shareUser];
    for (int i = 0; i < 6; i ++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(ViewWidth / 2 + i * (10 + (ViewWidth  /2 - 50) / 6), 0, (ViewWidth / 2 - 50) / 6, ViewHeight)];
        [self addSubview:btn];
        btn.tag = i + 1;
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@",user.btnPicArr[i]]] forState:UIControlStateNormal];
    }
}
- (void)btnClick:(UIButton *)btn {
    switch (btn.tag) {
        case 1:
            NSLog(@"1");
            break;
            case 2:
            NSLog(@"2");
            break;
        case 3:
            NSLog(@"3");
            break;
        case 4:
            NSLog(@"4");
            break;
        case 5:
            NSLog(@"5");
            break;
        case 6: {
            //通知主界面收起toolBarView
            NSNotificationCenter *putToolBarViewAway = [NSNotificationCenter defaultCenter];
            [putToolBarViewAway postNotificationName:@"putToolBarViewAway" object:nil];
        }
            break;
        default:
            break;
    }
}
//- (void)setAddViewDelegate:(id<AddViewDelegate>)addViewDelegate {
//    [addViewDelegate secControllerAddSubView:v];
//}
- (void)layoutSubviews {
    
}
@end
