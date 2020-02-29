//
//  ViewController.m
//  iOSAuidoCapture
//
//  Created by 韩力 on 2020/2/28.
//  Copyright © 2020 韩力. All rights reserved.
//

#import "ViewController.h"

#import <AVFoundation/AVFoundation.h>

@interface ViewController () <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureSession  *session;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput  *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    
    AVCaptureMetadataOutput *metalOutput = [[AVCaptureMetadataOutput alloc]init];
    metalOutput.rectOfInterest = self.view.bounds;
    
    [metalOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
    
    if ([captureSession canAddInput:input]) {
        
        [captureSession addInput:input];
    }
    
    if ([captureSession canAddOutput:metalOutput]) {
        
        [captureSession addOutput:metalOutput];
    }
    
    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
    
    previewLayer.frame = self.view.bounds;
    
    [self.view.layer addSublayer:previewLayer];
    
    [captureSession startRunning];



    // Do any additional setup after loading the view.
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    
    
}


@end
