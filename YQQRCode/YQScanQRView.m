//
//  YQScanQRView.m
//  Demo
//
//  Created by maygolf on 16/12/19.
//  Copyright © 2016年 yiquan. All rights reserved.
//

#import "YQScanQRView.h"

static const CGFloat kHintImageViewHeight = 12.0;

@interface YQScanHintView : UIView

@property (nonatomic, assign) CGRect borderFrame;
@property (nonatomic, strong) NSString *alertText;

@property (nonatomic, strong) UILabel *alertLabel;
@property (nonatomic, strong) UIImageView *hintImageView;
@property (nonatomic, assign) BOOL isAnimation;

@property (nonatomic, strong) UIImage *leftTopAngle;
@property (nonatomic, strong) UIImage *leftBottomAngle;
@property (nonatomic, strong) UIImage *rightTopAngle;
@property (nonatomic, strong) UIImage *rightBottomAngle;

- (void)startAnimation;
- (void)stopAnimation;

@end

@implementation YQScanHintView

#pragma mark - override
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        self.leftTopAngle = [UIImage imageNamed:@"QRCodeTopLeft"];
        self.leftBottomAngle = [UIImage imageNamed:@"QRCodebottomLeft"];
        self.rightTopAngle = [UIImage imageNamed:@"QRCodeTopRight"];
        self.rightBottomAngle = [UIImage imageNamed:@"QRCodebottomRight"];
        
        [self addSubview:self.hintImageView];
        [self addSubview:self.alertLabel];
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddRect(context, self.bounds);
    CGContextAddRect(context, self.borderFrame);
    
    [[UIColor lightGrayColor] setStroke];
    [[UIColor colorWithRed:21.0/255 green:21.0/255 blue:24.0/255 alpha:0.6] setFill];
    CGContextSetLineWidth(context, 1);
    CGContextDrawPath(context, kCGPathEOFillStroke);
    
    CGSize angleSize = CGSizeMake(16.0, 16.0);
    [self.leftTopAngle drawInRect:CGRectMake(self.borderFrame.origin.x - 1, self.borderFrame.origin.y - 1, angleSize.width, angleSize.height)];
    [self.leftBottomAngle drawInRect:CGRectMake(self.borderFrame.origin.x - 1, CGRectGetMaxY(self.borderFrame) - angleSize.height + 1, angleSize.width, angleSize.height)];
    [self.rightTopAngle drawInRect:CGRectMake(CGRectGetMaxX(self.borderFrame) - angleSize.width + 1, self.borderFrame.origin.y - 1, angleSize.width, angleSize.height)];
    [self.rightBottomAngle drawInRect:CGRectMake(CGRectGetMaxX(self.borderFrame) - angleSize.width + 1, CGRectGetMaxY(self.borderFrame) - angleSize.height + 1, angleSize.width, angleSize.height)];
    
}

#pragma mark - getter
- (UILabel *)alertLabel{
    if (!_alertLabel) {
        _alertLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.borderFrame) + 10, self.bounds.size.width, 30)];
        _alertLabel.text = self.alertText;
        _alertLabel.textAlignment = NSTextAlignmentCenter;
        _alertLabel.backgroundColor = [UIColor clearColor];
        _alertLabel.font = [UIFont systemFontOfSize:12.0];
        _alertLabel.textColor = [UIColor whiteColor];
    }
    return _alertLabel;
}

- (UIImageView *)hintImageView{
    if (!_hintImageView) {
        _hintImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.borderFrame.origin.x, self.borderFrame.origin.y  + self.borderFrame.size.height / 2, self.borderFrame.size.width, kHintImageViewHeight)];
        _hintImageView.image = [UIImage imageNamed:@"QRCodeLine"];
        _hintImageView.backgroundColor = [UIColor clearColor];
    }
    return _hintImageView;
}

#pragma mark - setting
- (void)setBorderFrame:(CGRect)borderFrame{
    _borderFrame = borderFrame;
    
    self.hintImageView.frame = CGRectMake(self.borderFrame.origin.x, self.borderFrame.origin.y  + self.borderFrame.size.height / 2, self.borderFrame.size.width, kHintImageViewHeight);
    self.alertLabel.frame = CGRectMake(0, CGRectGetMaxY(self.borderFrame) + 10, self.bounds.size.width, 30);
    
    [self setNeedsDisplay];
    
    if (self.isAnimation) {
        [self startAnimation];
    }
}

- (void)setAlertText:(NSString *)alertText{
    _alertText = alertText;
    
    self.alertLabel.text = alertText;
}

#pragma mark - public
- (void)startAnimation{
    [self stopAnimation];
    
    self.hintImageView.frame = CGRectMake(self.borderFrame.origin.x, self.borderFrame.origin.y, self.borderFrame.size.width, kHintImageViewHeight);
    [UIView animateWithDuration:2 delay:0 options:UIViewAnimationOptionRepeat animations:^{
        self.hintImageView.frame = CGRectMake(self.borderFrame.origin.x, CGRectGetMaxY(self.borderFrame) - kHintImageViewHeight, self.borderFrame.size.width, kHintImageViewHeight);
    } completion:^(BOOL finished) {
        self.isAnimation = NO;
    }];
    
    self.isAnimation = YES;
}

- (void)stopAnimation{
    [self.hintImageView.layer removeAllAnimations];
    self.hintImageView.frame = CGRectMake(self.borderFrame.origin.x, self.borderFrame.origin.y  + self.borderFrame.size.height / 2, self.borderFrame.size.width, kHintImageViewHeight);
}

@end

/********************************************************************************/
/********************************************************************************/

@interface YQScanQRView ()<AVCaptureMetadataOutputObjectsDelegate>
{
    struct{
        BOOL scanFinish;
    } _delegateFlag;
}

@property (nonatomic, strong) YQScanHintView *hintView;
@property (nonatomic, strong) AVCaptureSession *session;

@property (nonatomic, assign) BOOL isScaning;

@end

@implementation YQScanQRView

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        self.playAudioFinish = YES;
        [self addSubview:self.hintView];
    }
    return self;
}

#pragma mark - getter
- (YQScanHintView *)hintView{
    if (!_hintView) {
        _hintView = [[YQScanHintView alloc] initWithFrame:self.bounds];
        _hintView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _hintView;
}

- (CGRect)borderFrame{
    return self.hintView.borderFrame;
}

- (NSString *)alertText{
    return self.hintView.alertText;
}

- (AVCaptureSession *)session{
    if (!_session) {
        
        // 相机不可用直接返回
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) {
            return nil;
        }
        
        // 没有相机访问权限，直接返回
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted) {
            return nil;
        }
        
        // 1、获取摄像设备
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        // 2、创建输入流
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        
        // 3、创建输出流
        AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
        
        // 4、设置代理 在主线程里刷新
        [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        
        // 设置扫描范围(每一个取值0～1，以屏幕右上角为坐标原点)
        // 注：微信二维码的扫描范围是整个屏幕，这里并没有做处理（可不用设置）
        //        output.rectOfInterest = CGRectMake(0, 0, 1, 1);
        
        // 5、初始化链接对象（会话对象）
        _session = [[AVCaptureSession alloc] init];
        // 高质量采集率
        [_session setSessionPreset:AVCaptureSessionPresetHigh];
        
        // 5.1 添加会话输入
        [_session addInput:input];
        
        // 5.2 添加会话输出
        [_session addOutput:output];
        
        // 6、设置输出数据类型，需要将元数据输出添加到会话后，才能指定元数据类型，否则会报错
        // 设置扫码支持的编码格式(如下设置条形码和二维码兼容)
        output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code,  AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
        
        // 7、实例化预览图层, 传递_session是为了告诉图层将来显示什么内容
        AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        previewLayer.frame = self.layer.bounds;
        previewLayer.backgroundColor = [UIColor clearColor].CGColor;
        
        [[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureInputPortFormatDescriptionDidChangeNotification object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification * _Nonnull note) {
            output.rectOfInterest = [previewLayer metadataOutputRectOfInterestForRect:self.borderFrame];
        }];
        
        // 8、将图层插入当前视图
        [self.layer insertSublayer:previewLayer atIndex:0];
        
    }
    return _session;
}

#pragma mark - setting
-(void)setDelegate:(id<YQScanQRViewDelegate>)delegate{
    _delegateFlag.scanFinish = NO;
    
    if (delegate && [delegate respondsToSelector:@selector(scanQRView:didFinish:)]) {
        _delegateFlag.scanFinish = YES;
    }
    
    _delegate = delegate;
}

- (void)setBorderFrame:(CGRect)borderFrame{
    self.hintView.borderFrame = borderFrame;
}

- (void)setAlertText:(NSString *)alertText{
    self.hintView.alertText = alertText;
}

#pragma mark - public
- (void)start{
    [self.session startRunning];
    [self.hintView startAnimation];
    
    self.isScaning = YES;
}

- (void)stop{
    [self.session stopRunning];
    [self.hintView stopAnimation];
    
    self.isScaning = NO;
}


#pragma mark - private - - 扫描提示声
/**
 *  播放完成回调函数
 *
 *  @param soundID    系统声音ID
 *  @param clientData 回调时传递的数据
 */
void soundCompleteCallback(SystemSoundID soundID,void * clientData){
    
}

/**
 *  播放音效文件
 *
 *  @param name 音频文件名称
 */
- (void)playSoundEffect:(NSString *)name{
    NSString *audioFile = [[NSBundle mainBundle] pathForResource:name ofType:nil];
    NSURL *fileUrl = [NSURL fileURLWithPath:audioFile];
    // 1、获得系统声音ID
    SystemSoundID soundID = 0;
    /**
     * inFileUrl:音频文件url
     * outSystemSoundID:声音id（此函数会将音效文件加入到系统音频服务中并返回一个长整形ID）
     */
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileUrl), &soundID);
    
    // 如果需要在播放完之后执行某些操作，可以调用如下方法注册一个播放完成回调函数
    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, soundCompleteCallback, NULL);
    
    // 2、播放音频
    AudioServicesPlaySystemSound(soundID); // 播放音效
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    // 0、扫描成功之后的提示音
    [self playSoundEffect:@"YQQRSound.caf"];
    
    [self stop];
    
    if (_delegateFlag.scanFinish) {
        [self.delegate scanQRView:self didFinish:metadataObjects];
    }
}

@end
