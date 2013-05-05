//
//  topViewController.h
//  KineticPortrait
//
//  Created by 加藤 亮太 on 2013/04/26.
//
//

#import <UIKit/UIKit.h>

#include "testApp.h"

@interface topViewController : UIViewController<UIActionSheetDelegate>{
    testApp *kineticPortrait;
}
- (IBAction)wipeSwitch:(id)sender;

- (IBAction)switchCamera:(id)sender;
//- (IBAction)takePhoto:(id)sender;
- (IBAction)openPhotoLibrary:(id)sender;

- (IBAction)leftArrowButton:(id)sender;
- (IBAction)rightArrowButtoin:(id)sender;

@end
