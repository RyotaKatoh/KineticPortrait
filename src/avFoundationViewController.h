//
//  avFoundationViewController.h
//  KineticPortrait
//
//  Created by 加藤 亮太 on 2013/10/12.
//
//



#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#include "testApp.h"

#define NUM_IMAGE           5

@interface avFoundationViewController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>{

    testApp *kineticPortrait;
    
    BOOL isUsingFrontFacingCamera;
    BOOL isSelectedOpenCamera;
    AVCaptureStillImageOutput *stillImageOutput;
    AVCaptureVideoPreviewLayer *previewLayer;
    AVCaptureVideoDataOutput *videoDataOutput;
    dispatch_queue_t videoDataOutputQueue;
    
    CGFloat effectiveScale;
    UIView *previewView;
    
    int  srcImageNumber;
    
    
@public    
    BOOL isChangedSrcImage;
    BOOL isPushedArrowButton;


}

@property (retain, nonatomic) IBOutlet UIImageView *hiddenView;
@property (retain, nonatomic) IBOutlet UIImageView *wipeView;
@property (retain, nonatomic) IBOutlet UIImageView *srcImageView;
@property (retain, nonatomic) IBOutlet UISwitch *toggleWipeButton;
@property (retain, nonatomic) IBOutlet UIButton *switchCameraButton;
@property (retain, nonatomic) IBOutlet UIButton *openCameraButton;
@property (retain, nonatomic) IBOutlet UIImageView *detectedImage;
@property (retain, nonatomic) IBOutlet UIButton *leftArrowButton;
@property (retain, nonatomic) IBOutlet UIButton *rightArrowButton;

- (IBAction)toggleWipe:(id)sender;
- (IBAction)switchCamera:(id)sender;
- (IBAction)openCamera:(id)sender;
- (IBAction)changeSrcImageLeft:(id)sender;
- (IBAction)changeSrcImageRight:(id)sender;

@end
