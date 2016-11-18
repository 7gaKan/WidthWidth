//
//  FuncBaseTableView.h
//  WidthWidth
//
//  Created by 韩佳岐 on 16/11/10.
//  Copyright © 2016年 www.hangagi.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FuncBaseTableView : UITableView<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,copy)NSString *centerLabelText;
@property (nonatomic,copy)NSString *cellText;
@property (nonatomic,copy)NSString *cellName;
- (void)data;
@end
