//
//  YQScanQRView.h
//  Demo
//
//  Created by maygolf on 16/12/19.
//  Copyright © 2016年 yiquan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class YQScanQRView;
@protocol YQScanQRViewDelegate <NSObject>

- (void)scanQRView:(YQScanQRView *)scanQRView didFinish:(NSArray<AVMetadataMachineReadableCodeObject *> *)metadataObjects;

@end

/********************************************************************************/
/********************************************************************************/

@interface YQScanQRView : UIView

@property (nonatomic, weak) id<YQScanQRViewDelegate> delegate;

// 扫描完成是否播放声音，默认为YES
@property (nonatomic, assign) BOOL playAudioFinish;
@property (nonatomic, assign) CGRect borderFrame;
@property (nonatomic, strong) NSString *alertText;
@property (nonatomic, readonly) BOOL isScaning;

- (void)start;
- (void)stop;

@end
