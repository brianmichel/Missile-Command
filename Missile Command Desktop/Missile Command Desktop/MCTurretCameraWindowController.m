//
//  MCTurretCameraWindowController.m
//  Missile Command Desktop
//
//  Created by Brian Michel on 10/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MCTurretCameraWindowController.h"

@implementation MCTurretCameraWindowController

@synthesize previewLayer = __previewLayer;
@synthesize captureSesion = __captureSession;
@synthesize captureDevices = __captureDevices;
@synthesize progressIndicator = _progressIndicator;
@synthesize captureInput = __captureInput;
@synthesize queue = __queue;

- (id)initWithWindow:(NSWindow *)window
{
  self = [super initWithWindow:window];
  if (self) {
    // Initialization code here.
    [[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureSessionRuntimeErrorNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
      NSDictionary *dict = note.userInfo;
      NSLog(@"Error %@", dict);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureSessionDidStartRunningNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
      NSDictionary *dict = note.userInfo;
      NSLog(@"Start %@", dict);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureSessionDidStopRunningNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
      NSDictionary *dict = note.userInfo;
      NSLog(@"Stop %@", dict);
    }];
  }
  
  return self;
}

- (NSString *)windowNibName {
  return @"MCTurretCameraWindow";
}

- (void)windowDidLoad
{
  [super windowDidLoad];
  NSArray *captureDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
  AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
  
  NSError *error = nil;
  AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput deviceInputWithDevice:[captureDevices objectAtIndex:1] error:&error];
  
  [captureSession addInput:captureInput];
  
  AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
  [captureSession addOutput:output];
  NSArray *outputs = [output availableVideoCVPixelFormatTypes];
  output.videoSettings = [NSDictionary dictionaryWithObject:[outputs objectAtIndex:0]
                                                     forKey:(id)kCVPixelBufferPixelFormatTypeKey];
  
  dispatch_queue_t queue = dispatch_queue_create("get_video_frames", NULL);
  [output setSampleBufferDelegate:self queue:queue];
  
  [captureSession startRunning];
  
  // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
  AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
  
  /* Configure it.*/
	[previewLayer setFrame:[[self.window.contentView layer] bounds]];
	[previewLayer setAutoresizingMask:kCALayerWidthSizable|kCALayerHeightSizable];
  
  /* Add the preview layer as a sublayer to the view. */
  [[self.window.contentView layer] addSublayer:previewLayer];
  /* Specify the background color of the layer. */
	[[self.window.contentView layer] setBackgroundColor:CGColorGetConstantColor(kCGColorBlack)];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
  CIContext *ctx = [[CIContext alloc] init];
  CIDetector *faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:ctx options:nil];
  
  CIImage *image = [CIImage imageWithCVImageBuffer:CMSampleBufferGetImageBuffer(sampleBuffer)];
  
  NSArray *features = [faceDetector featuresInImage:image];
  if ([features count] > 0) {
    for (CIFaceFeature *feature in features) {
      NSLog(@"Feature: %@, %@, %@", NSStringFromPoint(feature.leftEyePosition), NSStringFromPoint(feature.rightEyePosition), NSStringFromPoint(feature.mouthPosition));
    }
  }
}

@end
