#include "testApp.h"
#include "avFoundationViewController.h"

//topViewController *xibViewController;
avFoundationViewController *avViewController;



//--------------------------------------------------------------
void testApp::setup()
{
    /*** settings for iOS ***/
//	ofxAccelerometer.setup();    // initialize the accelerometer
//	iPhoneSetOrientation(OFXIPHONE_ORIENTATION_LANDSCAPE_RIGHT);  // If you want a landscape oreintation
    
    //set xib GUI
    //xibViewController = [[topViewController alloc]initWithNibName:@"topViewController" bundle:nil];
    avViewController = [[avFoundationViewController alloc]initWithNibName:@"avFoundationViewController" bundle:nil];
    
    //cameraViewController = [[CameraViewController alloc]initWithNibName:@"CameraViewController" bundle:nil];
    
    addGUI = false;
    
	ofSetVerticalSync(true);
    ofEnableAlphaBlending();
	ofSetDrawBitmapMode(OF_BITMAPMODE_MODEL_BILLBOARD);
    ofBackground(0, 0, 0);

	
    // setting of faceTracker for camera
	camTracker.setup();
    
    // load source image
    numImage = 1;
    srcImage.loadImage(DEFAULT_IMAGE_PATH);
    srcImage.setImageType(OF_IMAGE_COLOR_ALPHA);

    float resizeRate = max(srcImage.width / (float) ofGetWidth(), srcImage.height / (float)ofGetHeight());
    srcImage.resize(srcImage.width / resizeRate, srcImage.height / resizeRate);
    
    // setting of faceTracker for source image
    imgTracker.setup();
    imgTracker.update(toCv(srcImage));
    
    // get face position of source image
    position    = imgTracker.getPosition();
    scale       = imgTracker.getScale();
    orientation = imgTracker.getOrientation();
    
    // get face mesh from source image
    imgMesh = imgTracker.getImageMesh();
    imgMesh.clearTexCoords();
    ofVec2f normalizeFact = ofVec2f(ofNextPow2(srcImage.getWidth()), ofNextPow2(srcImage.getHeight()));
    for (int i = 0; i < imgMesh.getNumVertices(); i++) {
        imgMesh.addTexCoord(imgTracker.getImagePoint(i) / normalizeFact);   // should be implemented by overriding getMesh()?
    }
    
    // get mouth mesh from source image
    getMouthMeshFromSrcImageTracker();
    
    camObjPoints.clear();
    

    
    takePhotoFunctionIsCalled = false;
    
}

//--------------------------------------------------------------
void testApp::update()
{    
    if(!addGUI){
        CGSize addViewSize = CGSizeMake(ofGetWidth(), ofGetHeight());
        
        CGRect addViewRect = [avViewController.view frame];
        //CGRect addViewRect = [cameraViewController.view frame];
        
        addViewRect.size.width = addViewSize.width;
        addViewRect.size.height = addViewSize.height;
        [avViewController.view setFrame:addViewRect];
        
        
        [ofxiPhoneGetUIWindow() addSubview:avViewController.view];
        
        
        addGUI = true;
        
    }
    
    
    // load source image
    if(avViewController->isChangedSrcImage){
    
        ofxiPhoneUIImageToOFImage([[avViewController srcImageView]image], srcImage);
        if(avViewController->isPushedArrowButton){
            avViewController->isPushedArrowButton = NO;
        }
        else{
            srcImage.rotate90(45);
        }
        float resizeRate = max(srcImage.width / (float) ofGetWidth(), srcImage.height / (float)ofGetHeight());
        srcImage.resize(srcImage.width / resizeRate, srcImage.height / resizeRate);
        
        changeSrcImageTracker();
        
        avViewController->isChangedSrcImage = NO;
    }
    

    
#ifndef DEBUG_IPHONE_SIMULATOR
//    if (imgPicker.imageUpdated) {
//        imgPicker.imageUpdated = false;
//        srcImage.setFromPixels(imgPicker.pixels, imgPicker.width, imgPicker.height, OF_IMAGE_COLOR_ALPHA);
////        srcImage.resize(ofGetWidth(), ofGetHeight());
//        float resizeRate = max(srcImage.width / (float) ofGetWidth(), srcImage.height / (float)ofGetHeight());
//        srcImage.resize(srcImage.width / resizeRate, srcImage.height / resizeRate);
//
//        imgPicker.close();
//        
//        changeSrcImageTracker();
//        
//        if(takePhotoFunctionIsCalled){
//
//            cam.setDeviceID(camID);
//            cam.initGrabber(ofGetWidth(), ofGetHeight());
//        
//            takePhotoFunctionIsCalled = false;
//
//        }
//        
//    }
//    
//    
//    if(imgPicker.imagePicker->didcanceled){
//        imgPicker.imagePicker->didcanceled = false;
//        imgPicker.close();
//        
//        cam.setDeviceID(camID);
//        cam.initGrabber(ofGetWidth(), ofGetHeight());
//        
//    }
#endif

//    cam.update();
//    
//    if (cam.isFrameNew()) {
//        camTracker.update(toCv(cam));
//    }

    
    
    static int t = 0;
    t++;
    if(t == FRAMERATE_PER_1UPDATE){
        // load camera image
            ofxiPhoneUIImageToOFImage([[avViewController hiddenView]image], cameraImage);
            cameraImage.rotate90(45);
            camTracker.update(toCv(cameraImage));
        
            t= 0;
    
    
        if (camTracker.getFound()) {

            // initialize vertex vectors and eye openness
            if (camObjPoints.empty()) {
                camObjPoints = camTracker.getObjectPoints();
                camObjPointsDiff = camTracker.getObjectPoints();
                leftEyeOpennessTh = camTracker.getGesture(ofxFaceTracker::LEFT_EYE_OPENNESS) - EYE_OPENNESS_OFFSET;
                rightEyeOpennessTh = camTracker.getGesture(ofxFaceTracker::RIGHT_EYE_OPENNESS) - EYE_OPENNESS_OFFSET;
            }
            // copy vertex motion of camTracker to imgMesh
            for (int i = 0; i < imgMesh.getNumVertices(); i++) {
                // ignore face outline
                if (i < 18) {
                    imgMesh.setVertex(i, imgTracker.getObjectPoint(i));
                } else {
#ifdef DEBUG_IPHONE_SIMULATOR
                    if (i >= 63 && i <= 65) {
                        camObjPointsDiff[i] = (camTracker.getObjectPoint(i) + ofVec3f(0, 1.1) * ofGetElapsedTimef()/2 - camObjPoints[i]);
                    } else {
                        camObjPointsDiff[i] = (camTracker.getObjectPoint(i) - camObjPoints[i]);
                    }
#else
                    camObjPointsDiff[i] = (camTracker.getObjectPoint(i) - camObjPoints[i]);
#endif
                    camObjPointsDiff[i] = camObjPointsDiff[i] + imgTracker.getObjectPoint(i);
                    imgMesh.setVertex(i, camObjPointsDiff[i]);
                    // set vertex for mouth mesh
                    mouthMesh.setVertex(convertVertexIndexForMouthMesh(i), camObjPointsDiff[i]);
                }
            }
            // check eye openness
            if (camTracker.getGesture(ofxFaceTracker::LEFT_EYE_OPENNESS) < leftEyeOpennessTh) {
                imgMesh.setVertex(37, camObjPoints[41]);
                imgMesh.setVertex(38, camObjPoints[40]);
            }
            if (camTracker.getGesture(ofxFaceTracker::RIGHT_EYE_OPENNESS) < rightEyeOpennessTh) {
                imgMesh.setVertex(43, camObjPoints[47]);
                imgMesh.setVertex(44, camObjPoints[46]);
            }
            
            [avViewController detectedImage].hidden = NO;
        }
        else {
            camObjPoints.clear();
            for (int i = 0; i < imgMesh.getNumVertices(); i++) {
                imgMesh.setVertex(i, imgTracker.getObjectPoint(i));
            }
            
            [avViewController detectedImage].hidden = YES;
            
        }
    }
}

//--------------------------------------------------------------
void testApp::draw()
{
    

    if (imgTracker.getFound()) {
    
        // draw source image
        srcImage.draw((ofGetWidth()/2 - srcImage.width/2), (ofGetHeight()/2 - srcImage.height/2));
    
    } else {
       
        ofDrawBitmapString("face was not fouond.", 25, ofGetHeight()/2);
        ofDrawBitmapString("Please change the source image.", 25, ofGetHeight()/2 + 10);
    }
    
    // draw frame rate
//	ofSetColor(255);
//	ofDrawBitmapString(ofToString((int) ofGetFrameRate()), 10, 20);
    
    // disable display 3D pharse
    ofSetupScreenOrtho(ofGetWindowWidth(), ofGetWindowHeight(), OF_ORIENTATION_DEFAULT, true, -1000,1000);
    
    // draw mesh
    glEnable(GL_DEPTH_TEST);
    ofPushMatrix();
    ofTranslate((ofGetWidth()/2 - srcImage.width/2) + position.x, (ofGetHeight()/2 - srcImage.height/2) + position.y);
    ofScale(scale, scale, scale);
    ofRotateX(orientation.x * 45.0f);
    ofRotateY(orientation.y * 45.0f);
    ofRotateZ(orientation.z * 45.0f);
    mouthMesh.addColor(ofFloatColor(0.2, 0, 0));
    mouthMesh.drawFaces();
    srcImage.bind();
    imgMesh.draw();
    srcImage.unbind();
    ofPopMatrix();
    
    
    glDisable(GL_DEPTH_TEST);

    
    
    
}

/**
 * @function    getMouthMeshFromSrcImageTracker
 * @abstract    gets a mouth mesh from the source image.
 * @param       none
 * @return      none
 */
void testApp::getMouthMeshFromSrcImageTracker()
{
    ofPolyline mouthLine;
    ofTessellator tessellator;
    
    mouthLine = imgTracker.getObjectFeature(ofxFaceTracker::INNER_MOUTH);
    mouthMesh.setMode(OF_PRIMITIVE_TRIANGLE_STRIP);
    tessellator.tessellateToMesh(mouthLine, OF_POLY_WINDING_ODD, mouthMesh);
    mouthMesh.addColor(ofFloatColor(0.2, 0, 0));
}

/**
 * @function    changeSrcImageTracker
 * @abstract    change sourch image.
 * @param       none
 * @return      none
 */
void testApp::changeSrcImageTracker()
{
    imgTracker.reset();
    imgTracker.setup();
    imgTracker.update(toCv(srcImage));
    
    // get face position of source image
    position    = imgTracker.getPosition();
    scale       = imgTracker.getScale();
    orientation = imgTracker.getOrientation();
    
    // get face mesh from source image
    imgMesh.clear();
    imgMesh = imgTracker.getImageMesh();
    imgMesh.clearTexCoords();
    ofVec2f normalizeFact = ofVec2f(ofNextPow2(srcImage.getWidth()), ofNextPow2(srcImage.getHeight()));
    for (int i = 0; i < imgMesh.getNumVertices(); i++) {
        imgMesh.addTexCoord(imgTracker.getImagePoint(i) / normalizeFact);   // should be implemented by overriding getMesh()?
    }
    
    // get mouth mesh from source image
    getMouthMeshFromSrcImageTracker();
    camObjPoints.clear();
}

/**
 * @function    convertVertexIndexForMouthMesh
 * @abstract    converts vertex index of ofxFaceTracker for a mouth mesh.
 * @param       vertex index of FaceTracker
 * @return      converted vertex index
 */
ofIndexType testApp::convertVertexIndexForMouthMesh(ofIndexType faceTrackerVertexIndex)
{
    int index = 0;
    
    switch (faceTrackerVertexIndex) {
        case 48:
            index = 2;
            break;
        case 60:
            index = 0;
            break;
        case 61:
            index = 4;
            break;
        case 62:
            index = 6;
            break;
        case 54:
            index = 7;
            break;
        case 63:
            index = 5;
            break;
        case 64:
            index = 3;
            break;
        case 65:
            index = 1;
            break;
        default:
            break;
    }
    
    return index;
}



//--------------------------------------------------------------
void testApp::exit()
{

}

//--------------------------------------------------------------
void testApp::touchDown(ofTouchEventArgs & touch)
{


}




void testApp::changeSamplePhoto(int leftOrRight){
    if(leftOrRight == 0){ //mean left
        numImage --;
        if(numImage <= 0)
            numImage = NUM_IMAGE;
    }
    
    else if(leftOrRight == 1){ //mean right
        numImage ++;
        if(numImage > NUM_IMAGE)
            numImage = 1;
    }
    
    else{
        return;
        
    }
    
    srcImage.clear();
    
    char imagePath[256];
    sprintf(imagePath, "image/%d.jpg",numImage);
    srcImage.loadImage(imagePath);
    
    srcImage.setImageType(OF_IMAGE_COLOR_ALPHA);
    
    float resizeRate = max(srcImage.width / (float) ofGetWidth(), srcImage.height / (float)ofGetHeight());
    srcImage.resize(srcImage.width / resizeRate, srcImage.height / resizeRate);
    changeSrcImageTracker();
}


//--------------------------------------------------------------
void testApp::touchMoved(ofTouchEventArgs & touch)
{

}

//--------------------------------------------------------------
void testApp::touchUp(ofTouchEventArgs & touch)
{

}

//--------------------------------------------------------------
void testApp::touchDoubleTap(ofTouchEventArgs & touch)
{

}

//--------------------------------------------------------------
void testApp::touchCancelled(ofTouchEventArgs & touch)
{
    
}

//--------------------------------------------------------------
void testApp::lostFocus()
{

}

//--------------------------------------------------------------
void testApp::gotFocus(){

}

//--------------------------------------------------------------
void testApp::gotMemoryWarning()
{

}

//--------------------------------------------------------------
void testApp::deviceOrientationChanged(int newOrientation)
{

}

//


