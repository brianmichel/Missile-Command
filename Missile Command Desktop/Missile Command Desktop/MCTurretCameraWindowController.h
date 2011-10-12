//
//  MCTurretCameraWindowController.h
//  Missile Command Desktop
//
//  Created by Brian Michel on 10/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MCTurretCameraWindowController : NSWindowController <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (strong) AVCaptureSession *captureSesion;
@property (strong) AVCaptureDeviceInput *captureInput;
@property (strong) NSArray *captureDevices;
@property (strong) IBOutlet NSProgressIndicator *progressIndicator;
@property (assign) dispatch_queue_t queue;
@end
