//
//  FunctionView.m
//  WidthWidth
//
//  Created by 韩佳岐 on 16/11/10.
//  Copyright © 2016年 www.hangagi.cn. All rights reserved.
//

#import "FunctionView.h"
#import "FuncBaseTableView.h"


//@interface FunctionView : UIView<UITableViewDataSource,UITableViewDelegate>
//
//@end
@implementation FunctionView {
    FuncBaseTableView *funcBase;
    NSMutableArray *tableView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        UserDefault *user = [UserDefault shareUser];
        for (int i = 0; i < 6; i ++) {
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, i * ((ViewHeight - 50) / 6 + 10), 50, (ViewHeight - 50) / 6)];
            btn.tag = i + 1;
            [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@",user.btnPicArr[i]]] forState:UIControlStateNormal];
            [self addSubview:btn];
        }
        // 画直线
        CAShapeLayer *line = [CAShapeLayer layer];
        [line setFillColor:[[UIColor whiteColor] CGColor]];
        [line setStrokeColor:[[UIColor whiteColor] CGColor]];
        line.lineWidth = 3.0f ;
        
        UIBezierPath *path = [[UIBezierPath alloc]init];
        [path moveToPoint:CGPointMake(50, 0)];
        [path addLineToPoint:CGPointMake(50,ViewHeight)];
        line.path = path.CGPath;
        [self.layer addSublayer:line];
        NSArray *classArray = @[@"SubTableViewAt1",@"SubTableViewAt2",@"SubTableViewAt3",@"SubTableViewAt4",@"SubTableViewAt5",@"SubTableViewAt6"];
        tableView = [[NSMutableArray alloc] init];
        //创建tableView
        for (int i = 0; i < classArray.count; i ++) {
            funcBase = [[NSClassFromString(classArray[i]) alloc]  initWithFrame:CGRectMake(55, 0, ViewWidth - 55, ViewHeight) style:UITableViewStylePlain];
            funcBase.tag = i + 1;
            [tableView addObject:funcBase];
        }
        for (int i = 0; i < tableView.count; i ++) {
            [tableView[i] registerClass:[UITableViewCell class] forCellReuseIdentifier:[NSString stringWithFormat:@"cell%d",i + 1]];
        }
        NSNotificationCenter *tableViewClickAtOne = [NSNotificationCenter defaultCenter];
        [tableViewClickAtOne addObserver:self selector:@selector(tableViewClickAtOne:) name:@"tableViewClickAtOne" object:nil];
        
    }
    return self;
}

- (void)removeTableView {
    for (int i = 0; i < tableView.count; i ++) {
        [tableView[i] removeFromSuperview];
    }
}
- (void)tableViewClickAtOne:(NSNotification *)noti {
    [self removeTableView];
    [self addSubview:tableView[0]];
}
- (void)btnClick:(UIButton *)btn {
    switch (btn.tag) {
        case 1:
            NSLog(@"1");
            [self removeTableView];
            [self addSubview:tableView[0]];
            
            break;
        case 2:{
            NSLog(@"2");
            [self removeTableView];
            [self addSubview:tableView[1]];
            
            
        }
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
        case 6:
            NSLog(@"6");
            break;
        default:
            break;
    }
}

@end
