//
//  toolBarRight.m
//  WidthWidth
//
//  Created by 韩佳岐 on 16/11/3.
//  Copyright © 2016年 www.hangagi.cn. All rights reserved.
//

#import "toolBarRight.h"

@implementation toolBarRight

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)layout {
    self.alpha = 0.5;
    //拍照还是录像
    _pickButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    _pickButton.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    _pickButton.backgroundColor = [UIColor orangeColor];
    [self addSubview:_pickButton];
    self.userInteractionEnabled = YES;
    [_pickButton addTarget:self action:@selector(pick:) forControlEvents:UIControlEventTouchUpInside];
    [_pickButton setTitle:@"拍照" forState:UIControlStateNormal];
    [_pickButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_pickButton sizeToFit];
    
    _changeTypeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    _changeTypeBtn.backgroundColor = [UIColor orangeColor];
    [self addSubview:_changeTypeBtn];
    [_changeTypeBtn addTarget:self action:@selector(changeType:) forControlEvents:UIControlEventTouchUpInside];
    [_changeTypeBtn setTitle:@"[照片]" forState:UIControlStateNormal];
    [_changeTypeBtn setTitle:@"[视频]" forState:UIControlStateSelected];
    [_changeTypeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_changeTypeBtn sizeToFit];
}

- (void)pick:(UIButton *)btn {
    UserDefault *user = [UserDefault shareUser];
    if (_isGIF){
        if (!user.record) {
            NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
            [notiCenter postNotificationName:@"startRecording" object:nil];
            [_pickButton setTitle:@"停止" forState:UIControlStateNormal];
        }
        else{
            NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
            [notiCenter postNotificationName:@"stopRecording" object:nil];
            [_pickButton setTitle:@"开始" forState:UIControlStateNormal];
        }
    }
    else{
        NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
        [notiCenter postNotificationName:@"takePictureImage" object:nil];

    }
}

- (void)changeType:(UIButton *)btn {
    btn.selected = !btn.selected;
    if (btn.selected) {
        _isGIF = YES;
        [_pickButton setTitle:@"开始" forState:UIControlStateNormal];
    }
    else{
        _isGIF = NO;
        [_pickButton setTitle:@"拍照" forState:UIControlStateNormal];
        //创建消息中心
        NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
        [notiCenter postNotificationName:@"startCaptureSession" object:nil];

    }
    
}
//#pragma  mark -消息中心-
//- (void)recordingY:(NSNotification *)noti {
//    self.recording = [noti.object intValue];
//    
//}
//- (void)recordingN:(NSNotification *)noti {
//    self.recording = [noti.object intValue];
//    
//}
@end
