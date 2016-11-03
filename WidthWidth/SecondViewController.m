//
//  SecondViewController.m
//  WidthWidth
//
//  Created by 韩佳岐 on 16/11/2.
//  Copyright © 2016年 www.hangagi.cn. All rights reserved.
//

#import "SecondViewController.h"
#import "Masonry.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#define kMainScreenWidth [UIScreen mainScreen].bounds.size.width
#define kMainScreenHeight  [UIScreen mainScreen].bounds.size.height

@interface SecondViewController () {
    NSArray *_toolBarArray;
    toolBarBaseView *_base;
}
@property (nonatomic, strong) AVCaptureSession* session;
/**
 *  输入设备
 */
@property (nonatomic, strong) AVCaptureDeviceInput* videoInput;
/**
 *  照片输出流
 */
@property (nonatomic, strong) AVCaptureStillImageOutput* stillImageOutput;
/**
 *  预览图层
 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer* previewLayer;
@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //照相机
    [self createCama];
    // 创建4个toolbar
    [self toolBarCreate];
    

    
}
- (void)toolBarCreate {
    _toolBarArray = @[@"toolBarTop",@"toolBarLeft",@"tooBarBottom",@"toolBarRight"];
    toolBarBaseView *toolBarTop = [[NSClassFromString(_toolBarArray[0]) alloc] init];
    toolBarBaseView *toolBarLeft = [[NSClassFromString(_toolBarArray[1]) alloc] init];
    toolBarBaseView *toolBarBottom = [[NSClassFromString(_toolBarArray[2]) alloc] init];
    toolBarBaseView *toolBarRight = [[NSClassFromString(_toolBarArray[3]) alloc] init];
//    toolBarBaseView *base = [[toolBarBaseView alloc] init];
    UIView *fontView = [[UIView alloc] init];
    fontView.backgroundColor = [UIColor blueColor];
    [toolBarTop mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.height.equalTo(@50);
        make.width.equalTo([NSNumber numberWithFloat:kMainScreenHeight]);
        make.top.equalTo(self.view);
        [self.view addSubview:toolBarTop];
    }];
    [toolBarLeft mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.height.equalTo([NSNumber numberWithFloat:kMainScreenWidth - 150]);
        make.width.equalTo(@50);
        make.top.equalTo(toolBarTop.mas_bottom);
        [self.view addSubview:toolBarLeft];
    }];
    [toolBarBottom mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.height.equalTo(@100);
        make.width.equalTo(toolBarTop.mas_width);
        make.top.equalTo(toolBarLeft.mas_bottom);
        [self.view addSubview:toolBarBottom];
    }];
    [toolBarRight mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.height.equalTo(toolBarLeft.mas_height);
        make.width.equalTo(toolBarLeft.mas_width);
        make.top.equalTo(toolBarTop.mas_bottom);
        make.right.equalTo(self.view.mas_right);
        [self.view addSubview:toolBarRight];
    }];
    
    //前视图
    [fontView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.height.equalTo(toolBarBottom.mas_height);
        make.width.equalTo([NSNumber numberWithFloat:kMainScreenHeight / 4]);
        
        make.bottom.equalTo(self.view).offset(-20);
        make.left.equalTo(self.view).offset(20);
        [self.view addSubview:fontView];
    }];
    
}
- (void)createCama {
    //照相机
    self.session = [[AVCaptureSession alloc] init];
    
    NSError *error;
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //更改这个设置的时候必须先锁定设备，修改完后再解锁，否则崩溃
    [device lockForConfiguration:nil];
    //设置闪光灯为自动
    [device setFlashMode:AVCaptureFlashModeAuto];
    [device unlockForConfiguration];
    
    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    //输出设置。AVVideoCodecJPEG   输出jpeg格式图片
    NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    [self.stillImageOutput setOutputSettings:outputSettings];
    
    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }
    if ([self.session canAddOutput:self.stillImageOutput]) {
        [self.session addOutput:self.stillImageOutput];
    }
    
    //初始化预览图层
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    NSLog(@"%f",kMainScreenWidth);
    self.previewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.previewLayer.frame = (CGRect){{0, 0}, self.view.frame.size.height,self.view.frame.size.width};
    self.view.layer.masksToBounds = YES;
    [self.view.layer addSublayer:self.previewLayer];

}
//10块钱
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    self.previewLayer.frame = (CGRect){{0, 0}, size};
}
//照相机附带
- (AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
    AVCaptureVideoOrientation result = (AVCaptureVideoOrientation)deviceOrientation;
    if ( deviceOrientation == UIDeviceOrientationLandscapeLeft )
        result = AVCaptureVideoOrientationLandscapeRight;
    else if ( deviceOrientation == UIDeviceOrientationLandscapeRight )
        result = AVCaptureVideoOrientationLandscapeLeft;
    return result;
}
- (void)viewWillAppear:(BOOL)animated {
    if (self.session) {
        
        [self.session startRunning];
    }
}
- (void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:YES];
    
    if (self.session) {
        
        [self.session stopRunning];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//支持旋转
-(BOOL)shouldAutorotate{
    return YES;
}
//
//支持的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight;
}

//一开始的方向  很重要
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationLandscapeRight;
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
