//
//  ViewController.m
//  WidthWidth
//
//  Created by 韩佳岐 on 16/11/2.
//  Copyright © 2016年 www.hangagi.cn. All rights reserved.
//

#import "ViewController.h"
#import <ShareSDK/ShareSDK.h>
// 导入头文件
#import <ShareSDKExtension/SSEThirdPartyLoginHelper.h>
//社会化分享
#import <ShareSDK/ShareSDK.h>
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *userImage;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (IBAction)login:(id)sender {
    [ShareSDK getUserInfo:SSDKPlatformTypeQQ
           onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error)
     {
         if (state == SSDKResponseStateSuccess)
         {
             
             NSLog(@"uid=%@",user.uid);
             NSLog(@"%@",user.credential);
             NSLog(@"token=%@",user.credential.token);
             NSLog(@"nickname=%@",user.nickname);
         }
         
         else
         {
             NSLog(@"%@",error);
         }
         
     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//支持旋转
-(BOOL)shouldAutorotate{
    return YES;
}

//支持的方向 因为界面A我们只需要支持竖屏
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


@end
