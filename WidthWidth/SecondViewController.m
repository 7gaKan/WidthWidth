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
#import <Photos/Photos.h>
#import <CoreMedia/CMMetadata.h>
#import <GLKit/GLKit.h>
#import "FontView.h"
#import "UIView+CCHUD.h"
#import "CCTools+GIF.h"
#import "TakePictureViewController.h"
#import <CoreMotion/CoreMotion.h>
//#import "MAMapView.h"
#import <MAMapKit/MAMapKit.h>



#define kMainScreenWidth [UIScreen mainScreen].bounds.size.width
#define kMainScreenHeight  [UIScreen mainScreen].bounds.size.height
static CGRect oldframe;
static int _tapCount;
@interface SecondViewController ()<UIGestureRecognizerDelegate,AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate,MAMapViewDelegate> {
    NSArray *_toolBarArray;
    //UI
    toolBarBaseView *_base;
    toolBarBaseView *toolBarTop;
    toolBarBaseView *toolBarLeft;
    toolBarBaseView *toolBarRight;
    toolBarBaseView *toolBarBottom;
    FontView *fontView;
    //添加个后视图
    UIView *backgroundView;
    //添加个临时预览层
    AVCaptureVideoPreviewLayer *tempPreviewLayer;
    
}


@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) AVCaptureSession* session;
/**
 *  输入设备
 */
@property (nonatomic, strong) AVCaptureDeviceInput* videoInput;

/**
 *  照片输出流
 */
@property (nonatomic, strong) AVCaptureStillImageOutput* stillImageOutput;
@property (nonatomic, strong) AVCaptureVideoDataOutput    *videoOutput;
//写入相册
@property (nonatomic, strong) NSURL *movieURL;
@property (nonatomic, strong) AVAssetWriter *assetWriter;
@property (nonatomic, strong) AVAssetWriterInput *assetAudioInput;
@property (nonatomic, strong) AVAssetWriterInput *assetVideoInput;
@property (nonatomic, strong) dispatch_queue_t movieWritingQueue;

@property (nonatomic, assign) BOOL readyToRecordVideo;
@property (nonatomic, assign) BOOL readyToRecordAudio;
@property (nonatomic, assign) BOOL recording;

// 相机设置
@property(nonatomic, strong) AVCaptureDevice *device;
@property(nonatomic, strong) AVCaptureDevice *inactiveCamera;

@property(nonatomic) AVCaptureTorchMode torchMode;
@property(nonatomic) AVCaptureFlashMode flashMode;

// 设备方向
//通过移动管理者确定手机当前所处的方向
@property(nonatomic, strong) CMMotionManager    *motionManager;
@property(readwrite) AVCaptureVideoOrientation	referenceOrientation; // 视频播放方向
@property(nonatomic, assign)UIDeviceOrientation deviceOrientation;





/**
 *  预览图层
 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer* previewLayer;
//捕捉连接 AVCaptureConnection
@property (nonatomic, strong) AVCaptureConnection *videoConnection;
@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor grayColor];
    //照相机
    [self createCama];
    // 创建4个toolbar
    [self toolBarCreate];
    
    
    //添加消息中心 处理Tool里面button点击事件
    [self notifitionSet];
    //通过设备的移动(motionManager)判断设备的方向
    [self createMotionManager];
    
}
#pragma  mark -消息中心集合
- (void)notifitionSet  {
    NSNotificationCenter *startCaptureSession = [NSNotificationCenter defaultCenter];
    [startCaptureSession addObserver:self selector:@selector(startCaptureSession:) name:@"startCaptureSession" object:nil];
    NSNotificationCenter *startRecording = [NSNotificationCenter defaultCenter];
    [startRecording addObserver:self selector:@selector(startRecording:) name:@"startRecording" object:nil];
    NSNotificationCenter *stopRecording = [NSNotificationCenter defaultCenter];
    [stopRecording addObserver:self selector:@selector(stopRecording:) name:@"stopRecording" object:nil];
    NSNotificationCenter *takePictureImage = [NSNotificationCenter defaultCenter];
    [takePictureImage addObserver:self selector:@selector(takePictureImage:) name:@"takePictureImage" object:nil];
}
#pragma mark - 通过设备的移动(motionManager)判断设备的方向
- (void)createMotionManager {
    _motionManager = [[CMMotionManager alloc] init];
    _motionManager.deviceMotionUpdateInterval = 1/15.0;
    
    if (_motionManager.deviceMotionAvailable) {
        [_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue]
                                            withHandler: ^(CMDeviceMotion *motion, NSError *error){
                                                [self performSelectorOnMainThread:@selector(handleDeviceMotion:) withObject:motion waitUntilDone:YES];
                                            }];
    }
}
- (void)handleDeviceMotion:(CMDeviceMotion *)deviceMotion{
    double x = deviceMotion.gravity.x;
    double y = deviceMotion.gravity.y;
    NSLog(@"%f,%f",x,y);
    //求浮点数x的绝对值 C语言
    if (fabs(y) >= fabs(x))
    {
        if (y >= 0){
            _deviceOrientation = UIDeviceOrientationPortraitUpsideDown;
            _referenceOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
        }
        else{
            _deviceOrientation = UIDeviceOrientationPortrait;
            _referenceOrientation = AVCaptureVideoOrientationPortrait;
        }
    }
    else{
        if (x >= 0){
            _deviceOrientation = UIDeviceOrientationLandscapeRight;
            _referenceOrientation = AVCaptureVideoOrientationLandscapeRight;
        }
        else{
            _deviceOrientation = UIDeviceOrientationLandscapeLeft;
            _referenceOrientation = AVCaptureVideoOrientationLandscapeLeft;
        }
    }
}
- (void)viewDidAppear:(BOOL)animated {
    // 开启定位
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
}
- (void)viewWillAppear:(BOOL)animated {
    //没有这句照片照出来之后不是横屏
    NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
}
#pragma  mark -消息中心-
- (void)startCaptureSession:(NSNotification *)noti {
            [self startCaptureSession];
    
}
- (void)startRecording:(NSNotification *)noti {
    [self startRecording];
    
}
- (void)stopRecording:(NSNotification *)noti {
    [self stopRecording];
    
}
- (void)takePictureImage:(NSNotification *)noti {
    [self takePictureImage];
    
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
    [self.view addSubview:fontView];
//    给前视图添加手势
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showImage:)];
        [fontView addGestureRecognizer: tap];
        fontView.userInteractionEnabled = YES;
    
    self.mapView = [[MAMapView alloc] initWithFrame:fontView.frame];
    self.mapView.delegate = self;
    self.mapView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:_mapView];
    [self.view insertSubview:_mapView aboveSubview:fontView];
    self.mapView.userInteractionEnabled = YES;

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
    
    _movieURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"movie.mov"]];
    NSError *error;
    [self setupSession:&error];
    
    if (!error) {
        [self createLayer];
        [self startCaptureSession];
    }
    else{
        [self showError:error];
    }
}
// 拍照
#pragma mark - 拍照
-(void)takePictureImage{
    AVCaptureConnection *connection = [_stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    //*********************************************
    if (connection.isVideoOrientationSupported) {
        connection.videoOrientation = [self currentVideoOrientation];
    }
    id takePictureSuccess = ^(CMSampleBufferRef sampleBuffer,NSError *error){
        if (sampleBuffer == NULL) {
            [self showError:error];
            return ;
        }
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:sampleBuffer];
        UIImage *image = [[UIImage alloc]initWithData:imageData];
        
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [[PHAssetCreationRequest creationRequestForAsset] addResourceWithType:PHAssetResourceTypePhoto data:imageData options:nil];
        } completionHandler:^( BOOL success, NSError *error ) {
            if ( ! success ) {
                NSLog( @"Error occurred while saving image to photo library: %@", error );
            }
        }];
        TakePictureViewController *takePicture = [[TakePictureViewController alloc] initWithImage:image];
        [self presentViewController:takePicture animated:NO completion:nil];
    };
    [_stillImageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:takePictureSuccess];
    
}

- (void)writeSampleBuffer:(CMSampleBufferRef)sampleBuffer ofType:(NSString *)mediaType
{
    if (_assetWriter.status == AVAssetWriterStatusUnknown)
    {
        if ([_assetWriter startWriting]){
            [_assetWriter startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
        }
        else{
            [self showError:_assetWriter.error];
        }
    }
    
    if (_assetWriter.status == AVAssetWriterStatusWriting)
    {
        if (mediaType == AVMediaTypeVideo)
        {
            if (_assetVideoInput.readyForMoreMediaData)
            {
                if (![_assetVideoInput appendSampleBuffer:sampleBuffer]){
                    [self showError:_assetWriter.error];
                }
            }
        }

    }
}

#pragma mark - Tools
// 将屏幕坐标系的点转换为摄像头坐标系的点
- (CGPoint)captureDevicePointForPoint:(CGPoint)point {
    AVCaptureVideoPreviewLayer *layer = (AVCaptureVideoPreviewLayer *)self.previewLayer;
    return [layer captureDevicePointOfInterestForPoint:point];
}

// 移除文件
- (void)removeFile:(NSURL *)fileURL
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = fileURL.path;
    if ([fileManager fileExistsAtPath:filePath])
    {
        NSError *error;
        BOOL success = [fileManager removeItemAtPath:filePath error:&error];
        if (!success){
            [self showError:error];
        }
        else{
            NSLog(@"删除视频文件成功");
        }
    }
}

#pragma mark - AVDELEGATE实现
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if (_recording) {
        CFRetain(sampleBuffer);
        dispatch_async(_movieWritingQueue, ^{
            if (_assetWriter)
            {
                if (connection == _videoConnection)
                {
                    if (!_readyToRecordVideo){
                        _readyToRecordVideo = [self setupAssetWriterVideoInput:CMSampleBufferGetFormatDescription(sampleBuffer)];
                    }
                    
                    if ([self inputsReadyToRecord]){
                        [self writeSampleBuffer:sampleBuffer ofType:AVMediaTypeVideo];
                    }
                }
                else if (connection == _videoConnection){
//                    if (!_readyToRecordAudio){
//                        _readyToRecordAudio = [self setupAssetWriterAudioInput:CMSampleBufferGetFormatDescription(sampleBuffer)];
//                    }
                    
                    if ([self inputsReadyToRecord]){
                        [self writeSampleBuffer:sampleBuffer ofType:AVMediaTypeAudio];
                    }
                }
            }
            CFRelease(sampleBuffer);
        });
    }
}
#pragma mark - 配置视频输入
// 配置视频输入
- (BOOL)setupAssetWriterVideoInput:(CMFormatDescriptionRef)currentFormatDescription
{
    CGFloat bitsPerPixel;
    CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(currentFormatDescription);
    NSUInteger numPixels = dimensions.width * dimensions.height;
    NSUInteger bitsPerSecond;
    
    if (numPixels < (640 * 480)){
        bitsPerPixel = 4.05;
    }
    else{
        bitsPerPixel = 11.4;
    }
    
    bitsPerSecond = numPixels * bitsPerPixel;
    NSDictionary *videoCompressionSettings = @{AVVideoCodecKey  : AVVideoCodecH264,
                                               AVVideoWidthKey  : [NSNumber numberWithInteger:dimensions.width],
                                               AVVideoHeightKey : [NSNumber numberWithInteger:dimensions.height],
                                               AVVideoCompressionPropertiesKey:@{AVVideoAverageBitRateKey:[NSNumber numberWithInteger:bitsPerSecond],
                                                                                 AVVideoMaxKeyFrameIntervalKey:[NSNumber numberWithInteger:30]}
                                               };
    if ([_assetWriter canApplyOutputSettings:videoCompressionSettings forMediaType:AVMediaTypeVideo])
    {
        _assetVideoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoCompressionSettings];
        _assetVideoInput.expectsMediaDataInRealTime = YES;
//        _assetVideoInput.transform = [self transformFromCurrentVideoOrientationToOrientation:self.referenceOrientation];
        if ([_assetWriter canAddInput:_assetVideoInput]){
            [_assetWriter addInput:_assetVideoInput];
        }
        else{
            [self showError:_assetWriter.error];
            return NO;
        }
    }
    else{
        [self showError:_assetWriter.error];
        return NO;
    }
    return YES;
}
#pragma mark - 设备方向
// 调整设备取向
- (AVCaptureVideoOrientation)currentVideoOrientation{
    AVCaptureVideoOrientation orientation;
    switch (_deviceOrientation) {
        case UIDeviceOrientationPortrait:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
    }
    return orientation;
}
//#pragma mark  -视频旋转方向
// 旋转视频方向
- (CGAffineTransform)transformFromCurrentVideoOrientationToOrientation:(AVCaptureVideoOrientation)orientation
{
    CGFloat orientationAngleOffset = [self angleOffsetFromPortraitOrientationToOrientation:orientation];
    CGFloat videoOrientationAngleOffset = [self angleOffsetFromPortraitOrientationToOrientation:UIDeviceOrientationLandscapeRight];
    
    CGFloat angleOffset;
    if ([self activeCamera].position == AVCaptureDevicePositionBack) {
        angleOffset = orientationAngleOffset - videoOrientationAngleOffset;
    }
    else{
        angleOffset = videoOrientationAngleOffset - orientationAngleOffset + M_PI_2;
    }
    CGAffineTransform transform = CGAffineTransformMakeRotation(angleOffset);
    return transform;
}

- (CGFloat)angleOffsetFromPortraitOrientationToOrientation:(AVCaptureVideoOrientation)orientation
{
    CGFloat angle = 0.0;
    switch (orientation)
    {
        case AVCaptureVideoOrientationPortrait:
            angle = 0.0;
            break;
        case AVCaptureVideoOrientationPortraitUpsideDown:
            angle = M_PI;
            break;
        case AVCaptureVideoOrientationLandscapeRight:
            angle = -M_PI_2;
            break;
        case AVCaptureVideoOrientationLandscapeLeft:
            angle = M_PI_2;
            break;
        default:
            break;
    }
    return angle;
}
#pragma mark - 录制视频
// 开始录制
- (void)startRecording
{
    dispatch_async(_movieWritingQueue, ^{
        
        [self removeFile:_movieURL];// 删除原来的视频文件
        
        if (!_assetWriter) {
            NSError *error;
            _assetWriter = [[AVAssetWriter alloc] initWithURL:_movieURL fileType:AVFileTypeQuickTimeMovie error:&error];
            if (error){
                [self showError:error];
            }
        }
        _recording = YES;
        UserDefault *user = [UserDefault shareUser];
        user.record = _recording;
//        NSNotificationCenter *recordingY = [NSNotificationCenter defaultCenter];
//        [recordingY postNotificationName:@"recordingY" object:[NSString stringWithFormat:@"%d",_recording]];
    });
}

// 停止录制
- (void)stopRecording
{
    // 录制完成后 要马上停止视频捕捉 否则写入相册会失败
    [self stopCaptureSession];
    _recording = NO;
    UserDefault *user = [UserDefault shareUser];
    user.record = _recording;

    dispatch_async(_movieWritingQueue, ^{
        
        [_assetWriter finishWritingWithCompletionHandler:^(){
            
            BOOL isSave = NO;
            switch (_assetWriter.status)
            {
                case AVAssetWriterStatusCompleted:
                {
                    _readyToRecordVideo = NO;
                    _readyToRecordAudio = NO;
                    _assetWriter = nil;
                    isSave = YES;
                    break;
                }
                case AVAssetWriterStatusFailed:
                {
                    isSave = NO;
                    [self showError:_assetWriter.error];
                    break;
                }
                default:
                    break;
            }
            if (isSave) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self.view showAlertView:self message:@"Save Success!)" sure:^(UIAlertAction *act) {
                        [self saveMovieToCameraRoll];
                    } cancel:^(UIAlertAction *act) {
                        
                    }];
                });
            }
            
        }];
        
        [self startCaptureSession]; // 重新开启会话
    });
}
- (void)saveMovieToCameraRoll
{
    [self.view showLoadHUD:self message:@"保存中..."];
    [CCTools createGIFfromURL:_movieURL loopCount:0 completion:^(NSURL *GifURL) {
        BOOL isSaveGif = YES;
        if (!GifURL) {
            NSLog(@"生成GIF失败");
            isSaveGif = NO;
        }
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_9_0
        ALAssetsLibrary *lab = [[ALAssetsLibrary alloc]init];
        
        if (isSaveGif) {
            // 保存GIF
            NSData *data = [[NSData alloc]initWithContentsOfURL:GifURL];
            [lab writeImageDataToSavedPhotosAlbum:data metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
                [self.view hideHUD];
                if (error) {
                    [self showError:error];
                }
            }];
        }
        
        // 保存视频
        [lab writeVideoAtPathToSavedPhotosAlbum:_movieURL completionBlock:^(NSURL *assetURL, NSError *error) {
            [self.view hideHUD];
            if (error) {
                [self showError:error];
            }
        }];
        
#else
        [PHPhotoLibrary requestAuthorization:^( PHAuthorizationStatus status ) {
            if (status == PHAuthorizationStatusAuthorized) {
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    
                    if (isSaveGif) {
                        // 保存GIF
                        NSData *data = [[NSData alloc]initWithContentsOfURL:GifURL];
                        PHAssetCreationRequest *gifRequest = [PHAssetCreationRequest creationRequestForAsset];
                        [gifRequest addResourceWithType:PHAssetResourceTypePhoto data:data options:nil];
                    }
                    
                    
                    // 保存视频
                    PHAssetCreationRequest *videoRequest = [PHAssetCreationRequest creationRequestForAsset];
                    [videoRequest addResourceWithType:PHAssetResourceTypeVideo fileURL:_movieURL options:nil];
                    
                } completionHandler:^( BOOL success, NSError * _Nullable error ) {
                    [self.view hideHUD];
                    if (!success) {
                        [self showError:error];
                    }
                }];
            }
        }];
#endif
    }];}
#pragma mark - 捕捉设备
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}
- (AVCaptureDevice *)activeCamera {
    return _videoInput.device;
}
- (AVCaptureDevice *)inactiveCamera {
    AVCaptureDevice *device = nil;
    if ([[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count] > 1) {
        if ([self activeCamera].position == AVCaptureDevicePositionBack) {
            device = [self cameraWithPosition:AVCaptureDevicePositionFront];
        }
        else{
            device = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }
    }
    return device;
}
#pragma mark - 开始捕捉  停止捕捉
// 开启捕捉
- (void)startCaptureSession
{
    if (!_movieWritingQueue) {
        _movieWritingQueue = dispatch_queue_create("Movie Writing Queue", DISPATCH_QUEUE_SERIAL);
    }
    
    if (!_session.isRunning){
        [_session startRunning];
    }
}

// 停止捕捉
- (void)stopCaptureSession
{
    if (_session.isRunning){
        [_session stopRunning];
    }
}

#pragma mark - 展示错误封装
// 展示错误
- (void)showError:(NSError *)error
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void){
        [self.view showAlertView:self title:error.localizedDescription message:error.localizedFailureReason sureTitle:@"确定" cancelTitle:nil sure:nil cancel:nil];
    });
}
#pragma mark - 初始化图层
- (void)createLayer {
    //初始化预览图层
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    NSLog(@"%f",kMainScreenWidth);
    self.previewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.previewLayer.frame = (CGRect){{0, 0}, self.view.frame.size.height,self.view.frame.size.width};
    self.view.layer.masksToBounds = YES;
    [self.view.layer addSublayer:self.previewLayer];
    
    oldframe = self.previewLayer.frame;
}
#pragma mark - AVCaptureSession life cycle
- (void)setupSession:(NSError **)error {
    self.session = [[AVCaptureSession alloc] init];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    
    [self setupSessionInputs:error];
    [self setupSessionOutputs:error];
}
- (void)setupSessionInputs:(NSError **)error{
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:_device error:error];
    if ([self.session canAddInput:videoInput]){
        [self.session addInput:videoInput];
        _videoInput = videoInput;

    }
}
//outPut
- (void)setupSessionOutputs:(NSError **)error{
     dispatch_queue_t captureQueue = dispatch_queue_create("com.kangagi.MovieCaptureQueue", DISPATCH_QUEUE_SERIAL);
    // 视频输出
    AVCaptureVideoDataOutput *videoOut = [[AVCaptureVideoDataOutput alloc] init];
    [videoOut setAlwaysDiscardsLateVideoFrames:YES];
    [videoOut setVideoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]}];
    [videoOut setSampleBufferDelegate:self queue:captureQueue];
    if ([_session canAddOutput:videoOut]){
        [_session addOutput:videoOut];
        _videoOutput = videoOut;
    }
    _videoConnection = [videoOut connectionWithMediaType:AVMediaTypeVideo];
//    _videoConnection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
    
    // 静态图片输出
    AVCaptureStillImageOutput *imageOutput = [[AVCaptureStillImageOutput alloc] init];
    imageOutput.outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
    if ([_session canAddOutput:imageOutput]) {
        [_session addOutput:imageOutput];
        _stillImageOutput = imageOutput;
    }

}
//10块钱

- (BOOL)inputsReadyToRecord
{
    return _readyToRecordVideo;
}
//展示错误封装代码
#pragma mark - 展示错误
-(void)showAlertView:(UIViewController *)vc title:(NSString *)title message:(NSString *)message sureTitle:(NSString *)sureTitle cancelTitle:(NSString *)cancelTitle sure:(void(^)(UIAlertAction * act))sure cancel:(void(^)(UIAlertAction * act))cancel{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    if (cancelTitle) {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if (cancel) {
                cancel(action);
            }
        }];
        [alertController addAction:cancelAction];
    }
    
    if (sureTitle) {
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:sureTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (sure) {
                sure(action);
            }
        }];
        [alertController addAction:okAction];
    }
    
    [vc presentViewController:alertController animated:YES completion:nil];
}
-(void)resetupVideoOutput{
    [_session beginConfiguration];
    [_session removeOutput:_videoOutput];
    
    AVCaptureVideoDataOutput *videoOut = [[AVCaptureVideoDataOutput alloc] init];
    [videoOut setAlwaysDiscardsLateVideoFrames:YES];
    [videoOut setVideoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]}];
    dispatch_queue_t videoCaptureQueue = dispatch_queue_create("Video Capture Queue", DISPATCH_QUEUE_SERIAL);
    [videoOut setSampleBufferDelegate:self queue:videoCaptureQueue];
    
    if ([_session canAddOutput:videoOut]) {
        [_session addOutput:videoOut];
        _videoOutput = videoOut;
    }
    _videoConnection = [videoOut connectionWithMediaType:AVMediaTypeVideo];
    _videoConnection.videoOrientation = self.referenceOrientation;
    [_session commitConfiguration];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//支持旋转
-(BOOL)shouldAutorotate{
    return NO;
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
