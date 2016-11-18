//
//  SubTableViewAt1.m
//  WidthWidth
//
//  Created by 韩佳岐 on 16/11/10.
//  Copyright © 2016年 www.hangagi.cn. All rights reserved.
//

#import "SubTableViewAt1.h"

@implementation SubTableViewAt1

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)data {
    self.cellName = @"cell1";
    self.centerLabelText = @"nice";
    self.cellText = @"gege";
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"%@",self.cellName] forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor blackColor];
    cell.textLabel.text = self.cellText;
    cell.textLabel.backgroundColor = [UIColor blackColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.selectedBackgroundView.backgroundColor = [UIColor yellowColor];
    
    UIView *uvForBack = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
    uvForBack.backgroundColor = [UIColor orangeColor];
    cell.selectedBackgroundView = uvForBack;
    return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}
@end
