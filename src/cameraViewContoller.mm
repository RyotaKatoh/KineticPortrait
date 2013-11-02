//
//  cameraViewContoller.m
//  KineticPortrait
//
//  Created by 加藤 亮太 on 2013/09/16.
//
//

#import "cameraViewContoller.h"


#pragma mark CameraViewController

@implementation CameraViewController

// initialize camera param, open camera.
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
    
    takenPhoto = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end

