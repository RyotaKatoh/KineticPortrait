//
//  topViewController.m
//  KineticPortrait
//
//  Created by 加藤 亮太 on 2013/04/26.
//
//

#import "topViewController.h"

@interface topViewController ()

@end

@implementation topViewController

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
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)wipeSwitch:(id)sender {
    kineticPortrait->setWipe();
}

- (IBAction)switchCamera:(id)sender {
    kineticPortrait->switchCamera();
}

- (IBAction)takePhoto:(id)sender {
    //kineticPortrait->takePhoto();
    kineticPortrait->setVideoGrabber();

}

- (IBAction)openPhotoLibrary:(id)sender {
    UIActionSheet *sheet = [[UIActionSheet alloc]init];
    
    sheet.delegate = self;
    
    [sheet addButtonWithTitle:@"Camera"];
    [sheet addButtonWithTitle:@"Photo albums"];
    [sheet addButtonWithTitle:@"Cancel"];
    
    sheet.cancelButtonIndex = 2;
    [sheet showInView:self.view];

}

- (IBAction)leftArrowButton:(id)sender {
    kineticPortrait->changeSamplePhoto(0);
}

- (IBAction)rightArrowButtoin:(id)sender {
    kineticPortrait->changeSamplePhoto(1);
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{    
    
    
    
    switch(buttonIndex){
        case 0:
            kineticPortrait->takePhoto();
            break;
        case 1:
            kineticPortrait->openPhotoLibrary();
            
        default:
            return;
            
    }
    
//    UIImagePickerControllerSourceType sourceType;
//    
//    
//    switch(buttonIndex){
//        case 0:
//            sourceType = UIImagePickerControllerSourceTypeCamera;
//            break;
//        case 1:
//            sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//            break;
//        case 2:
//            sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
//            break;
//            
//        default:
//            return;
//            
//    }
//    
//    if(![UIImagePickerController isSourceTypeAvailable:sourceType])
//        return;
//    
//    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
//    
//    picker.sourceType = sourceType;
//    
//    picker.allowsEditing = YES;
//    
//    [self presentModalViewController:picker animated:YES];
//    
}
@end
