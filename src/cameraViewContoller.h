//
//  cameraViewContoller.h
//  KineticPortrait
//
//  Created by 加藤 亮太 on 2013/09/16.
//
//

#import <Foundation/Foundation.h>

@interface CameraViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
    
    UIImage *takenPhoto;
    
}
- (void)openCamera;
- (void)openPhotoLibrary;

@end
