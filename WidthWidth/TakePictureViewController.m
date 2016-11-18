//
//  TakePictureViewController.m
//  WidthWidth
//
//  Created by 韩佳岐 on 16/11/6.
//  Copyright © 2016年 www.hangagi.cn. All rights reserved.
//

#import "TakePictureViewController.h"

@interface TakePictureViewController () {
    UIImageView *imv;
}

@end

@implementation TakePictureViewController
- (instancetype)initWithImage:(UIImage *)mage {
    if (self = [super init]) {
        _image = mage;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    imv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:imv];
    imv.image = self.image;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
