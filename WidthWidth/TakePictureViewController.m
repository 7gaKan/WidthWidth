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
//- (void)viewWillAppear:(BOOL)animated {
//    NSNumber *orientationUnknown = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
//    [[UIDevice currentDevice] setValue:orientationUnknown forKey:@"orientation"];
//    
//    NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
//    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
//}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    imv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:imv];
//    NSData *uploadData1 = UIImageJPEGRepresentation(self.image, 1.0);
//    self.view.frame = CGRectMake(0, 0, self.self.view.frame.size.width, <#CGFloat height#>)

//     UIImage *croppedImage = [UIImage imageWithCGImage:(__bridge CGImageRef _Nonnull)(self.image) scale:1.0 orientation:UIImageOrientationUp];
    imv.image = self.image;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
////10块钱
//- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
//    imv.frame = (CGRect){{0, 0}, size};
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
