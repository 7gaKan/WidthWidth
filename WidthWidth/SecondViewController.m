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


#define kMainScreenWidth [UIScreen mainScreen].bounds.size.width
#define kMainScreenHeight  [UIScreen mainScreen].bounds.size.height
static CGRect oldframe;
@interface SecondViewController ()<UIGestureRecognizerDelegate,AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate> {
    NSArray *_toolBarArray;
    //UI
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
//@property(nonatomic, assign) BOOL      isGIF;           //拍照片还是GIF
// 相机设置
@property(nonatomic, strong) AVCaptureDevice *device;
@property(nonatomic, strong) AVCaptureDevice *inactiveCamera;

@property(nonatomic) AVCaptureTorchMode torchMode;
@property(nonatomic) AVCaptureFlashMode flashMode;

// 设备方向
//@property(nonatomic, strong) CCMotionManager    *motionManager;
@property(readwrite) AVCaptureVideoOrientation	referenceOrientation; // 视频播放方向





/**
 *  预览图层
 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer* previewLayer;
//捕捉连接 AVCaptureConnection
@property (nonatomic, strong) AVCaptureConnection *videoConnection;
/**
 *  记录开始的缩放比例
 */
@property(nonatomic,assign)CGFloat beginGestureScale;
/**
 *  最后的缩放比例
 */
@property(nonatomic,assign)CGFloat effectiveScale;
@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor grayColor];
    
    
    //照相机
    [self createCama];
//    oldframe = self.previewLayer.frame;
    // 创建4个toolbar
    [self toolBarCreate];
    //创建手势
    [self setUpGesture];
    
    self.effectiveScale = self.beginGestureScale = 1.0f;
    
    //添加消息中心 处理Tool里面button点击事件
    NSNotificationCenter *startCaptureSession = [NSNotificationCenter defaultCenter];
    [startCaptureSession addObserver:self selector:@selector(startCaptureSession:) name:@"startCaptureSession" object:nil];
    NSNotificationCenter *startRecording = [NSNotificationCenter defaultCenter];
    [startRecording addObserver:self selector:@selector(startRecording:) name:@"startRecording" object:nil];
    NSNotificationCenter *stopRecording = [NSNotificationCenter defaultCenter];
    [stopRecording addObserver:self selector:@selector(stopRecording:) name:@"stopRecording" object:nil];
    NSNotificationCenter *takePictureImage = [NSNotificationCenter defaultCenter];
    [takePictureImage addObserver:self selector:@selector(takePictureImage:) name:@"takePictureImage" object:nil];
    
    

    
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
    
    
    //照相机
//    self.session = [[AVCaptureSession alloc] init];
    
//    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //更改这个设置的时候必须先锁定设备，修改完后再解锁，否则崩溃
    [_device lockForConfiguration:nil];
    //设置闪光灯为自动
    [_device setFlashMode:AVCaptureFlashModeAuto];
    [_device unlockForConfiguration];
    
//    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:_device error:&error];
//    if (error) {
//        NSLog(@"%@",error);
//    }
    
    
//    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
//    //输出设置。AVVideoCodecJPEG   输出jpeg格式图片
//    NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
//    [self.stillImageOutput setOutputSettings:outputSettings];
//    
//    if ([self.session canAddInput:self.videoInput]) {
//        [self.session addInput:self.videoInput];
//    }
////    if ([self.session canAddOutput:self.videoOutput]) {
////        [self.session addInput:self.videoOutput];
////    }
//    if ([self.session canAddOutput:self.stillImageOutput]) {
//        [self.session addOutput:self.stillImageOutput];
//    }
    
    //初始化预览图层
//    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
//    NSLog(@"%f",kMainScreenWidth);
//    self.previewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
//    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
//    self.previewLayer.frame = (CGRect){{0, 0}, self.view.frame.size.height,self.view.frame.size.width};
//    self.view.layer.masksToBounds = YES;
//    [self.view.layer addSublayer:self.previewLayer];
//    
//    oldframe = self.previewLayer.frame;
    
    // 比如在给会话设置视频输出后，设置捕捉连接
//    self.videoConnection = [_stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
//    self.videoConnection.videoOrientation =
    
//    if () {
//        <#statements#>
//    }
    

}
// 拍照
#pragma mark - 拍照
-(void)takePictureImage{
    AVCaptureConnection *connection = [_stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    id takePictureSuccess = ^(CMSampleBufferRef sampleBuffer,NSError *error){
        if (sampleBuffer == NULL) {
            [self showError:error];
            return ;
        }
//        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:sampleBuffer];
//        UIImage *image = [[UIImage alloc]initWithData:imageData];
//        CCImagePreviewController *vc = [[CCImagePreviewController alloc]initWithImage:image frame:self.previewView.frame];
//        [self.navigationController pushViewController:vc animated:YES];
    };
    [_stillImageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:takePictureSuccess];
}

- (BOOL)inputsReadyToRecord
{
    return (_readyToRecordAudio && _readyToRecordVideo);
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
        else if (mediaType == AVMediaTypeAudio){
            if (_assetAudioInput.readyForMoreMediaData)
            {
                if (![_assetAudioInput appendSampleBuffer:sampleBuffer]){
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
        NSNotificationCenter *recordingY = [NSNotificationCenter defaultCenter];
        [recordingY postNotificationName:@"recordingY" object:[NSString stringWithFormat:@"%d",_recording]];
    });
}

// 停止录制
- (void)stopRecording
{
    // 录制完成后 要马上停止视频捕捉 否则写入相册会失败
    [self stopCaptureSession];
    _recording = NO;
    NSNotificationCenter *recordingN = [NSNotificationCenter defaultCenter];
    [recordingN postNotificationName:@"recordingN" object:[NSString stringWithFormat:@"%d",_recording]];
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
                    [self.view showAlertView:self message:@"是否保存到相册，确定将保存2个文件到相册，一个视频，一个GIF动图(由于苹果相册不支持查看GIF，所以只有通过QQ等软件查看)" sure:^(UIAlertAction *act) {
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
    _videoConnection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
    
    // 静态图片输出
    AVCaptureStillImageOutput *imageOutput = [[AVCaptureStillImageOutput alloc] init];
    imageOutput.outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
    if ([_session canAddOutput:imageOutput]) {
        [_session addOutput:imageOutput];
        _stillImageOutput = imageOutput;
    }

}
//10块钱
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    self.previewLayer.frame = (CGRect){{0, 0}, size};
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

#pragma 创建手势
- (void)setUpGesture{
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    pinch.delegate = self;
    [self.view addGestureRecognizer:pinch];
}
#pragma mark gestureRecognizer delegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ( [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] ) {
        self.beginGestureScale = self.effectiveScale;
    }
    return YES;
}

//缩放手势 用于调整焦距
- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer{
    
    BOOL allTouchesAreOnThePreviewLayer = YES;
    //手指数
    NSUInteger numTouches = [recognizer numberOfTouches];
    for ( int i = 0; i < numTouches; ++i ) {
        CGPoint location = [recognizer locationOfTouch:i inView:self.view];
        CGPoint convertedLocation = [self.previewLayer convertPoint:location fromLayer:self.previewLayer.superlayer];
        if ( ! [self.previewLayer containsPoint:convertedLocation] ) {
            allTouchesAreOnThePreviewLayer = NO;
            break;
        }
    }
    
    if ( allTouchesAreOnThePreviewLayer ) {
        
        
        self.effectiveScale = self.beginGestureScale * recognizer.scale;
        if (self.effectiveScale < 1.0){
            self.effectiveScale = 1.0;
        }
        
        NSLog(@"%f-------------->%f------------recognizerScale%f",self.effectiveScale,self.beginGestureScale,recognizer.scale);
        
        CGFloat maxScaleAndCropFactor = [[self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo] videoMaxScaleAndCropFactor];
        
        NSLog(@"%f",maxScaleAndCropFactor);
        if (self.effectiveScale > maxScaleAndCropFactor)
            self.effectiveScale = maxScaleAndCropFactor;
        
        [CATransaction begin];
        [CATransaction setAnimationDuration:.025];
        [self.previewLayer setAffineTransform:CGAffineTransformMakeScale(self.effectiveScale, self.effectiveScale)];
        [CATransaction commit];
        
    }
    
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
