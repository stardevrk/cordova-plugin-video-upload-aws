//
//  RecordingUploader.m
//  MyApp
//
//  Created by DevMaster on 2/9/20.
//

#import "RecordingUploader.h"
#import <AWSS3/AWSS3.h>

@interface RecordingUploader ()

@end

@implementation RecordingUploader

- (id)init
{
    if (self = [super init]) {
//        self.preferredContentSize = kPopoverContentSize;
        self.view.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _progressController = [[ProgressViewController alloc] init];
    _progressController.view.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8f];
    _progressController.parentView = self.view;
    _progressController.parentWidth = self.view.frame.size.width;
    _progressController.parentHeight = self.view.frame.size.height;
    _recordingUploadResult = [NSMutableDictionary dictionary];
}

- (void)viewDidAppear:(BOOL)animated
{
    //    [self uploadRecodingFile];
    _progressController = [[ProgressViewController alloc] init];
    _progressController.view.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8f];
    _progressController.parentView = self.view;
    _progressController.parentWidth = self.view.frame.size.width;
    _progressController.parentHeight = self.view.frame.size.height;
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat: @"Upload Now?"]
                message:@"Do you need to upload recorded video now?"
                preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"No"]
                style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                // Ok action example
                [self dismissViewControllerAnimated:YES completion:nil];
                
            }];
            UIAlertAction *otherAction = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Yes"]
                style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                // Other action
//                [self.progressController formatCurrentValue:0];
//                [self.progressController setProgress:[[NSNumber alloc] initWithFloat:0.0]];
                [self uploadRecodingFile];
    
            }];
            [alert addAction:okAction];
            [alert addAction:otherAction];
            [self presentViewController:alert animated:YES completion:nil];
            
        });
}


- (void) setupRecodingAWSS3:(NSString *)CognitoPoolID region:(NSString *)region bucket:(NSString *)bucket folder:(NSString *)folder
{
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1
    identityPoolId:CognitoPoolID];
    
    AWSRegionType awsRegion;
    if ([region isEqualToString:@"us-east-1"]) {
        awsRegion = AWSRegionUSEast1;
    } else if ([region isEqualToString:@"us-east-2"]) {
        awsRegion = AWSRegionUSEast2;
    } else if ([region isEqualToString:@"us-west-1"]) {
        awsRegion = AWSRegionUSWest1;
    } else if ([region isEqualToString:@"us-west-2"]) {
        awsRegion = AWSRegionUSWest2;
    } else if ([region isEqualToString:@"ap-east-1"]) {
        awsRegion = AWSRegionAPEast1;
    } else if ([region isEqualToString:@"ap-south-1"]) {
        awsRegion = AWSRegionAPSouth1;
    } else if ([region isEqualToString:@"ap-northeast-2"]) {
        awsRegion = AWSRegionAPNortheast2;
    } else if ([region isEqualToString:@"ap-northeast-1"]) {
        awsRegion = AWSRegionAPNortheast1;
    } else if ([region isEqualToString:@"ap-southeast-1"]) {
        awsRegion = AWSRegionAPSoutheast1;
    } else if ([region isEqualToString:@"ap-southeast-2"]) {
        awsRegion = AWSRegionAPSoutheast2;
    } else if ([region isEqualToString:@"ap-south-1"]) {
        awsRegion = AWSRegionAPSouth1;
    } else if ([region isEqualToString:@"ap-east-1"]) {
        awsRegion = AWSRegionAPEast1;
    } else if ([region isEqualToString:@"ca-central-1"]) {
        awsRegion = AWSRegionCACentral1;
    } else if ([region isEqualToString:@"cn-north-1"]) {
        awsRegion = AWSRegionCNNorth1;
    } else if ([region isEqualToString:@"cn-northwest-1"]) {
        awsRegion = AWSRegionCNNorthWest1;
    } else if ([region isEqualToString:@"eu-central-1"]) {
        awsRegion = AWSRegionEUCentral1;
    } else if ([region isEqualToString:@"eu-west-1"]) {
        awsRegion = AWSRegionEUWest1;
    } else if ([region isEqualToString:@"eu-west-2"]) {
        awsRegion = AWSRegionEUWest2;
    } else if ([region isEqualToString:@"eu-west-3"]) {
        awsRegion = AWSRegionEUWest3;
    } else if ([region isEqualToString:@"eu-north-1"]) {
        awsRegion = AWSRegionEUNorth1;
    } else if ([region isEqualToString:@"me-south-1"]) {
        awsRegion = AWSRegionMESouth1;
    } else if ([region isEqualToString:@"sa-east-1"]) {
        awsRegion = AWSRegionSAEast1;
    } else if ([region isEqualToString:@"us-gov-east-1"]) {
        awsRegion = AWSRegionUSGovEast1;
    } else if ([region isEqualToString:@"us-gov-west-1"]) {
        awsRegion = AWSRegionUSGovWest1;
    } else {
        awsRegion = AWSRegionUSEast1;
    }

    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:awsRegion
                                                                         credentialsProvider:credentialsProvider];
    
    AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
    self.recordingBucket = [[NSString alloc] initWithString:bucket];
    self.recordingFolder = [[NSString alloc] initWithString:folder];
}

- (void) setupRecordedURL:(NSURL *)recordedFile
{
    self.recordingToBeUploaded = recordedFile;
}

- (void) uploadRecodingFile
{
    if (self.recordingToBeUploaded.absoluteString.length != 0) {

        NSError *err;
        NSData *uploadData = [[NSData alloc] initWithContentsOfURL:self.recordingToBeUploaded options:NSDataReadingMappedIfSafe error:&err];
        if(err != nil) {
            NSLog(@"Getting File Data is disabled !!!%@", err.localizedDescription);
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Low Memory?"]
                message:@"Your phone does not have enough memory to read video file"
                preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"OK"]
                style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                // Ok action example
            }];
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        
        
        self.progressController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [self presentViewController:self.progressController animated:YES completion:nil];
        
            
            NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
            NSMutableString *randomString = [NSMutableString stringWithCapacity: 8];

            for (int i=0; i<8; i++) {
                 [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
            }
            
            NSTimeInterval  today = [[NSDate date] timeIntervalSince1970];
            NSInteger time = today;
            NSString *ts = [NSString stringWithFormat:@"%ld", (long)time];
            
            NSString *fileName = [self.recordingToBeUploaded lastPathComponent];
            NSString *finalPath = [[NSString alloc] initWithFormat:@"%@%@-%@-%@", self.recordingFolder, randomString, ts, fileName];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

                AWSS3TransferUtilityUploadExpression *expression = [AWSS3TransferUtilityUploadExpression new];
                [expression setValue:@"public-read" forRequestHeader:@"x-amz-acl"];
                expression.progressBlock = ^(AWSS3TransferUtilityTask *task, NSProgress *progress) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //Do something with progress
                        NSLog(@"Progress: %@", progress);
                        [self.progressController setProgress:[[NSNumber alloc] initWithDouble:progress.fractionCompleted]];
                    });
                };

                AWSS3TransferUtilityUploadCompletionHandlerBlock completionHandler = ^(AWSS3TransferUtilityUploadTask *task, NSError *error) {

                    if ([task.response statusCode] == 200) {
                        [self.recordingUploadResult setObject:@"Stored" forKey:@"Status"];
                    } else {
                        [self.recordingUploadResult setObject:@"Failed" forKey:@"Status"];
                    }

                    
                        // Do something e.g. Alert a user for transfer completion.
                        // On failed uploads, `error` contains the error object.
                        
                        if (error != nil) {
                            NSLog(@"Finished: Error = %@", error);
                            [self.recordingUploadResult setObject:error forKey:@"Error"];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.progressController dismissViewControllerAnimated:YES completion:nil];
                                [self dismissViewControllerAnimated:YES completion:nil];
                            });
                        } else {
                            NSLog(@"Finished: Response = %@", task.response);
                            NSURL *uploadURL = [task.response URL];
                            NSString *uploadPath = [[uploadURL.absoluteString componentsSeparatedByString:@"?"] objectAtIndex:0];
                            [self.recordingUploadResult setObject:uploadPath forKey:@"Location"];
                            [self.recordingUploadResult setObject:[[NSNumber alloc] initWithInt:1] forKey:@"Recording"];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.progressController dismissViewControllerAnimated:YES completion:nil];
                                [self dismissViewControllerAnimated:YES completion:nil];
                            });
                            [self finishUploadingRecordFile:self];
                            
//                            [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:self.recordingUploadResult] callbackId:self.actionCallbackId];
                        }
                    
                };

                AWSS3TransferUtility *transferUtility = [AWSS3TransferUtility defaultS3TransferUtility];
                [transferUtility uploadData:uploadData bucket:self.recordingBucket key:finalPath contentType:@"video/quicktime" expression:expression completionHandler:completionHandler];
            });
            
            
        }
}

- (void)finishUploadingRecordFile:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(recordingUploadController:didFinishUploading:)]) {
        [self.delegate recordingUploadController:self didFinishUploading:self.recordingUploadResult];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//#pragma mark - RecordingViewDelegate
//
//- (void)videoRecordingView:(RecordingView *)view didFinishRecording:(NSURL *)recordingResult;
//{
//    NSLog(@"Delegate Calling Result ==== %@", recordingResult);
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat: @"Upload Now?"]
//            message:@"Do you need to upload recorded video now?"
//            preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *okAction = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"No"]
//            style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
//            // Ok action example
////            [self uploadRecodingFile:recordingResult];
//        }];
//        UIAlertAction *otherAction = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Yes"]
//            style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
//            // Other action
//            
//        }];
//        [alert addAction:okAction];
//        [alert addAction:otherAction];
//        [self presentViewController:alert animated:YES completion:nil];
//        
//    });
//}
@end
