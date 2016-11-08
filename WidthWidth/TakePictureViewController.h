//
//  TakePictureViewController.h
//  WidthWidth
//
//  Created by 韩佳岐 on 16/11/6.
//  Copyright © 2016年 www.hangagi.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TakePictureViewController : UIViewController
@property (nonatomic,strong) UIImage *image;
- (instancetype)initWithImage:(UIImage *)mage;
@end
