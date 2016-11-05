//
//  SecondViewController.m
//  WidthWidth
//
//  Created by 韩佳岐 on 16/11/2.
//  Copyright © 2016年 www.hangagi.cn. All rights reserved.
//

#import "SecondViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "FontView.h"
#define kMainScreenWidth [UIScreen mainScreen].bounds.size.width
#define kMainScreenHeight  [UIScreen mainScreen].bounds.size.height
static CGRect oldframe;
@interface SecondViewController () {
    NSArray *_toolBarArray;
    toolBarBaseView *_base;
//    UIView *fontView;
    toolBarBaseView *toolBarTop;
    toolBarBaseView *toolBarLeft;
    toolBarBaseView *toolBarRight;
    toolBarBaseView *toolBarBottom;
    FontView *fontView;
    //点击小视图次数
    int _tapCount;
    //添加个后视图
    UIView *backgroundView;
    //添加个临时预览层
    AVCaptureVideoPreviewLayer *tempPreviewLayer;
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
    self.view.backgroundColor = [UIColor grayColor];
    //照相机
    [self createCama];
    oldframe = self.previewLayer.frame;
    // 创建4个toolbar
    [self toolBarCreate];
    

    
}
- (void)toolBarCreate {
    //创建4个toolBar
    _toolBarArray = @[@"toolBarTop",@"toolBarLeft",@"tooBarBottom",@"toolBarRight"];
    toolBarTop = [[NSClassFromString(_toolBarArray[0]) alloc] initWithFrame:CGRectMake(0, 0, kMainScreenHeight, 50)];
    toolBarLeft = [[NSClassFromString(_toolBarArray[1]) alloc] initWithFrame:CGRectMake(0, 50, 50,kMainScreenWidth - 150)];
    toolBarBottom = [[NSClassFromString(_toolBarArray[2]) alloc] initWithFrame:CGRectMake(0, kMainScreenWidth - 100, kMainScreenHeight, 100)];
    toolBarRight = [[NSClassFromString(_toolBarArray[3]) alloc] initWithFrame:CGRectMake(kMainScreenHeight - 50,50, 50, kMainScreenWidth - 150)];
    [self.view addSubview:toolBarTop];
    [self.view addSubview:toolBarRight];
    [self.view addSubview:toolBarLeft];
    [self.view addSubview:toolBarBottom];
    //创建前视图
    fontView = [[FontView alloc] initWithFrame:CGRectMake(20, kMainScreenWidth - 120, kMainScreenHeight / 4, 100)];
//    fontView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:fontView];
    
//    给前视图添加手势
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showImage:)];
        [fontView addGestureRecognizer: tap];
        fontView.userInteractionEnabled = YES;

}
- (void)showImage:(UITapGestureRecognizer*)tap{
    _tapCount++;
    //创建小的预览层
    tempPreviewLayer = self.previewLayer;
    if (_tapCount %2 != 0) {
        backgroundView = [[UIView alloc] init];
        backgroundView = [fontView copy];
        [self.view addSubview:backgroundView];
        [fontView.layer addSublayer:tempPreviewLayer];
        
        //返回当前视图的point
        NSLog(@"%f,%f,%f,%f",oldframe.origin.x,oldframe.origin.y,oldframe.size.width,oldframe.size.height);
        [self.view bringSubviewToFront:toolBarTop];
        [self.view bringSubviewToFront:toolBarBottom];
        [self.view bringSubviewToFront:toolBarLeft];
        [self.view bringSubviewToFront:toolBarRight];
        [self.view bringSubviewToFront:fontView];
        NSLog(@"all subviews of self.view:%@",[self.view subviews]);
        [UIView animateWithDuration:0.3 animations:^{
            backgroundView.frame = CGRectMake(0,0, kMainScreenWidth, kMainScreenHeight);
            tempPreviewLayer.frame = CGRectMake(0,0, fontView.frame.size.width,fontView.frame.size.height);
        } completion:^(BOOL finished) {
            
        }];
    }else {
        
        
        
        [tempPreviewLayer removeFromSuperlayer];
        self.previewLayer.frame = oldframe;
        [self.view.layer addSublayer:self.previewLayer];
        [self.view bringSubviewToFront:toolBarTop];
        [self.view bringSubviewToFront:toolBarBottom];
        [self.view bringSubviewToFront:toolBarLeft];
        [self.view bringSubviewToFront:toolBarRight];
        [self.view bringSubviewToFront:fontView];
        [UIView animateWithDuration:0.3 animations:^{
            [backgroundView removeFromSuperview];
            backgroundView = nil;
        } completion:^(BOOL finished) {
        }];
        
    }
    
}
- (void)hideView:(UITapGestureRecognizer*)tap {

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
