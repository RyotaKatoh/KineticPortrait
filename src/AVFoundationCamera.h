//
//  AVFoundationCamera.h
//  KineticPortrait
//
//  Created by 加藤 亮太 on 2013/10/05.
//
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface UIImage (RotationMethods)
- (UIImage *)imageRotatedByDegrees: (CGFloat)degrees;
@end


@interface AVFoundationCamera : NSObject<AVCaptureVideoDataOutputSampleBufferDelegate>{
    
    BOOL isUsingFrontFacingCamera;
    AVCaptureStillImageOutput *stillImageOutput;
    AVCaptureVideoPreviewLayer *previewLayer;
    AVCaptureVideoDataOutput *videoDataOutput;
    dispatch_queue_t videoDataOutputQueue;
    
    CGFloat effectiveScale;
    
    UIView *previewView;
    
@public
    UIImage *capturedImage;
    
}

- (void)setupAVCapture;
- (void)tearDownAVCapture;
- (void)setPreviewView:(UIView *)view;
- (void)switchCamera;

- (UIImage *)capturedImage;

@property (strong, nonatomic) UIImage *capturedImage;

@property (strong, nonatomic) UIImage *testString;

@end
