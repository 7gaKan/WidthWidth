//
//  FuncBaseTableView.m
//  WidthWidth
//
//  Created by 韩佳岐 on 16/11/10.
//  Copyright © 2016年 www.hangagi.cn. All rights reserved.
//

#import "FuncBaseTableView.h"

@implementation FuncBaseTableView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (self = [super initWithFrame:frame style:style]) {
        [self data];
        self.delegate = self;
        self.dataSource = self;
        self.backgroundColor = [UIColor blackColor];
    }
    return  self;
}
- (void)data {
    
}
// 返回每个分区表尾的高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *uv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    uv.backgroundColor = [UIColor blackColor];
    UILabel *centerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
    centerLabel.center = CGPointMake(ViewWidth/ 2, 20);
    centerLabel.textColor = [UIColor whiteColor];
    centerLabel.backgroundColor = [UIColor blackColor];
    centerLabel.text = self.centerLabelText;
    NSLog(@"POINT:%f,%f",ViewWidth,tableView.tableHeaderView.frame.size.height);
    
    //返回button
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    [backBtn setTitle:@"X" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    backBtn.backgroundColor = [UIColor blackColor];
    [backBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    backBtn.center = CGPointMake(ViewWidth - backBtn.frame.size.width / 2, 20);
    [uv addSubview:backBtn];
    [uv addSubview:centerLabel];
    return uv;
}
- (void)back:(UIButton *)btn {
    NSLog(@"GOGGGG");
    NSNotificationCenter *ToolBarViewLayDown = [NSNotificationCenter defaultCenter];
    [ToolBarViewLayDown postNotificationName:@"ToolBarViewLayDown" object:nil];
    
}


@end
