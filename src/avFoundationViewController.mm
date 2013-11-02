//
//  avFoundationViewController.m
//  KineticPortrait
//
//  Created by 加藤 亮太 on 2013/10/12.
//
//

#import "avFoundationViewController.h"
#import <CoreImage/CoreImage.h>
#import <ImageIO/ImageIO.h>
#import <AssertMacros.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface avFoundationViewController ()

@end

@implementation avFoundationViewController

@synthesize hiddenView;
@synthesize srcImageView;
@synthesize wipeView;
@synthesize toggleWipeButton;
@synthesize switchCameraButton;
@synthesize openCameraButton;
@synthesize detectedImage;
@synthesize leftArrowButton;
@synthesize rightArrowButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    kineticPortrait = (testApp *)ofGetAppPtr();
    
    srcImageView.image = [UIImage imageNamed:@"1.jpg"];
    srcImageNumber     = 1;
    
    srcImageView.hidden = YES;
    
    [self setupAVCapture];
    
    hiddenView.hidden    = YES;
    isSelectedOpenCamera = NO;
    
    isChangedSrcImage   = NO;
    isPushedArrowButton = NO;
    
    detectedImage.image = [UIImage imageNamed:@"detected.png"];
    detectedImage.hidden = YES;
    
    
}


-(AVCaptureDevice *)frontFacingCameraIfAvailable
{
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *captureDevice = nil;
    for (AVCaptureDevice *device in videoDevices)
    {
        if (device.position == AVCaptureDevicePositionFront)
        {
            captureDevice = device;
            break;
        }
    }
    
    //  couldn't find one on the front, so just get the default video device.
    if ( ! captureDevice)
    {
        captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    
    return captureDevice;
}

- (void) setupAVCapture{
    
    NSError *error = nil;
    
    //AVCaptureSession *session = [AVCaptureSession new];
    AVCaptureSession *session = [AVCaptureSession new];
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        [session setSessionPreset:AVCaptureSessionPreset640x480];
    else
        [session setSessionPreset:AVCaptureSessionPresetPhoto];
    
    if(!isUsingFrontFacingCamera){
        isUsingFrontFacingCamera = NO;
        
    }
    
    // select a video device, make an input
    AVCaptureDevice *device;
    
    if(isUsingFrontFacingCamera)
        device = [self frontFacingCameraIfAvailable];
    else
        device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    //require( error == nil, bail);
    
    
    //if([session canAddInput:deviceInput])
    //    [session addInput:deviceInput];
    
    // make a still image output
    stillImageOutput = [AVCaptureStillImageOutput new];
    if([session canAddOutput:stillImageOutput])
        [session addOutput:stillImageOutput];
    
    // make a video data output
    videoDataOutput = [AVCaptureVideoDataOutput new];
    
    // Create BGRA data. because both CoreGraphics and OpenGL work well with 'BGRA'
    NSDictionary *rgbOutputSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCMPixelFormat_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    [videoDataOutput setVideoSettings:rgbOutputSettings];
    [videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
    
    videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
    [videoDataOutput setSampleBufferDelegate:self queue:videoDataOutputQueue];
    
    if([session canAddOutput:videoDataOutput])
        [session addOutput:videoDataOutput];
    [[videoDataOutput connectionWithMediaType:AVMediaTypeVideo]setEnabled:NO];
    
    effectiveScale = 1.0;
    
    previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:session];
    [previewLayer setBackgroundColor:[[UIColor blackColor]CGColor]];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    [[previewLayer session]addInput:deviceInput];
    CALayer *rootLayer = [previewView layer];
    [rootLayer setMasksToBounds:YES];
    [previewLayer setFrame:[rootLayer bounds]];
    [rootLayer addSublayer:previewLayer];
    
     
    //    testString = [UIImage imageNamed:@"Default-568h@2x.png"];
    //    NSLog(@"av:%f, %f",testString.size.width, testString.size.height);
    
    [session startRunning];
    
    
bail:
    [session release];
    
    if(error){
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"Failed with error %d", (int) [error code]] message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        [self tearDownAVCapture];
    }
    
}

// clean up capture setup
- (void)tearDownAVCapture{
    
    [videoDataOutput release];
    if(videoDataOutputQueue)
        dispatch_release(videoDataOutputQueue);
    
    [stillImageOutput release];
    [previewLayer removeFromSuperlayer];
    [previewLayer release];
}

#pragma mark openCamera


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    
    
    switch(buttonIndex){
        case 0:
            isSelectedOpenCamera = true;
            
            [self tearDownAVCapture];
            
            [self openCamera];
            break;
        case 1:
            
            [self openPhotoLibrary];
            break;
            
        default:
            return;
            
    }
    
}

- (void)openCamera{
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
        
        [imagePickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
        
        [imagePickerController setAllowsEditing:NO];
        [imagePickerController setDelegate:self];
        
        [self presentViewController:imagePickerController animated:YES completion:nil];
        
        
        
    }
    else{
        NSLog(@"camera invalid");
    }
    
}

- (void)openPhotoLibrary{
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
        [imagePickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [imagePickerController setAllowsEditing:NO];
        [imagePickerController setDelegate:self];
        
        [self presentViewController:imagePickerController animated:YES completion:nil];
        
    }
    else{
        
        NSLog(@"photo library invalid");
        
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    srcImageView.image = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
    isChangedSrcImage = YES;
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
    if(isSelectedOpenCamera){
        [self setupAVCapture];
        
        isSelectedOpenCamera = false;
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if(isSelectedOpenCamera){
        [self setupAVCapture];
        
        isSelectedOpenCamera = false;
    }
}

- (void)switchCamera{
    
    AVCaptureDevicePosition desiredPosition;
    if(isUsingFrontFacingCamera)
        desiredPosition = AVCaptureDevicePositionBack;
    else
        desiredPosition = AVCaptureDevicePositionFront;
    
    for(AVCaptureDevice *d in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]){
        
        if([d position] == desiredPosition){
            
            [[previewLayer session]beginConfiguration];
            AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:d error:nil];
            for(AVCaptureInput *oldInput in [[previewLayer session] inputs]){
                
                [[previewLayer session]removeInput:oldInput];
            }
            [[previewLayer session] addInput:input];
            [[previewLayer session]commitConfiguration];
            break;
            
        }
        
    }
    
    isUsingFrontFacingCamera = !isUsingFrontFacingCamera;
}

#pragma mark captureOutput

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    
    UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // write something code.
        hiddenView.image = image;
        wipeView.image   = image;
        
    });
    
    
}

- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
    
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height= CVPixelBufferGetHeight(imageBuffer);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    
    CGImageRef cgImage = CGBitmapContextCreateImage(newContext);
    CGColorSpaceRelease(colorSpace);
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    UIImage *image = [UIImage imageWithCGImage:cgImage scale:1.0 orientation:UIImageOrientationRight];
    CGImageRelease(cgImage);
    
    return image;
}

#pragma mark touchEvent

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 0.4;
    
    [toggleWipeButton.layer addAnimation:animation forKey:nil];
    [switchCameraButton.layer addAnimation:animation forKey:nil];
    [openCameraButton.layer addAnimation:animation forKey:nil];
    [leftArrowButton.layer addAnimation:animation forKey:nil];
    [rightArrowButton.layer addAnimation:animation forKey:nil];
    
    if(toggleWipeButton.hidden){
    
        toggleWipeButton.hidden   = NO;
        switchCameraButton.hidden = NO;
        openCameraButton.hidden   = NO;
        leftArrowButton.hidden    = NO;
        rightArrowButton.hidden   = NO;
    }
    
    else{
    
        toggleWipeButton.hidden   = YES;
        switchCameraButton.hidden = YES;
        openCameraButton.hidden   = YES;
        leftArrowButton.hidden    = YES;
        rightArrowButton.hidden   = YES;
    }
    
}


- (void)dealloc {

    [super dealloc];
}


- (IBAction)toggleWipe:(id)sender {
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 0.4;
    
    [wipeView.layer addAnimation:animation forKey:nil];
    
    if(toggleWipeButton.on)
        wipeView.hidden = NO;
    else
        wipeView.hidden = YES;
    
}

- (IBAction)switchCamera:(id)sender {
    [self switchCamera];
}

- (IBAction)openCamera:(id)sender {
    
    UIActionSheet *sheet = [[UIActionSheet alloc]init];
    
    sheet.delegate = self;
    
    [sheet addButtonWithTitle:@"Camera"];
    [sheet addButtonWithTitle:@"Photo albums"];
    [sheet addButtonWithTitle:@"Cancel"];
    
    sheet.cancelButtonIndex = 2;
    [sheet showInView:self.view];
    
}

- (IBAction)changeSrcImageLeft:(id)sender {
    isChangedSrcImage = YES;
    srcImageNumber --;
    if(srcImageNumber <= 0)
        srcImageNumber = NUM_IMAGE;
    
    NSString *imageFile = [NSString stringWithFormat:@"%d.jpg", srcImageNumber];
    srcImageView.image = [UIImage imageNamed:imageFile];
    
    isPushedArrowButton = YES;

}

- (IBAction)changeSrcImageRight:(id)sender {
    isChangedSrcImage = YES;
    srcImageNumber ++;
    if(srcImageNumber > NUM_IMAGE)
        srcImageNumber = 1;
    
    NSString *imageFile = [NSString stringWithFormat:@"%d.jpg", srcImageNumber];
    srcImageView.image = [UIImage imageNamed:imageFile];
    
    isPushedArrowButton = YES;

}
@end
