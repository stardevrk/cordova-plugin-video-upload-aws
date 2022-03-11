//
//  VidUploader.m
//  PitchAware
//
//  Created by DevMaster on 9/15/21.
//

#import "VidUploader.h"
#import <AWSS3/AWSS3.h>
#import "AppDelegate+VideoUpload.h"

@implementation VidUploader

- (id)init
{
    if (self = [super init]) {
        
    }
    
    return self;
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
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError *err;
            NSData *uploadData = [[NSData alloc] initWithContentsOfURL:self.recordingToBeUploaded options:NSDataReadingMappedIfSafe error:&err];
            if(err != nil) {
                NSLog(@"Getting File Data is disabled !!!%@", err.localizedDescription);
                if ([self.delegate respondsToSelector:@selector(vidUploadController:memeryLeak:)]) {
                    [self.delegate vidUploadController:self memeryLeak:@"memoryLeak"];
                }
                return;
            }
            
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
                
            AppDelegate* shared=[UIApplication sharedApplication].delegate;
            [shared saveUploadingStatus:TRUE];
            AWSS3TransferUtilityUploadExpression *expression = [AWSS3TransferUtilityUploadExpression new];
            [expression setValue:@"public-read" forRequestHeader:@"x-amz-acl"];
            expression.progressBlock = ^(AWSS3TransferUtilityTask *task, NSProgress *progress) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    //Do something with progress
                    NSLog(@"Progress: %@", progress);
                    if ([self.delegate respondsToSelector:@selector(vidUploadController:didPercent:)]) {
                        [self.delegate vidUploadController:self didPercent:progress.fractionCompleted];
                    }
                });
            };

            AWSS3TransferUtilityUploadCompletionHandlerBlock completionHandler = ^(AWSS3TransferUtilityUploadTask *task, NSError *error) {
                [shared saveUploadingStatus:FALSE];
                self.recordingUploadResult = [[NSMutableDictionary alloc] init];

                if ([task.response statusCode] == 200) {
                    
                } else {
                    
                }

                if (error != nil) {
                    NSLog(@"Finished: Error = %@", error);
                    [self.recordingUploadResult setObject:error forKey:@"Error"];
                    [self.recordingUploadResult setObject:@"Failed" forKey:@"Status"];
                } else {
                    NSLog(@"Finished: Response = %@", task.response);
                    [self.recordingUploadResult setObject:@"Stored" forKey:@"Status"];
                    NSURL *uploadURL = [task.response URL];
                    NSString *uploadPath = [[uploadURL.absoluteString componentsSeparatedByString:@"?"] objectAtIndex:0];
                    [self.recordingUploadResult setObject:uploadPath forKey:@"Location"];
                    [self.recordingUploadResult setObject:[[NSNumber alloc] initWithInt:1] forKey:@"Recording"];
                }
                if ([self.delegate respondsToSelector:@selector(vidUploadController:finished:)]) {
                    [self.delegate vidUploadController:self finished:self.recordingUploadResult];
                }
            };
            AWSS3TransferUtility *transferUtility = [AWSS3TransferUtility defaultS3TransferUtility];
            [transferUtility uploadData:uploadData bucket:self.recordingBucket key:finalPath contentType:@"video/quicktime" expression:expression completionHandler:completionHandler];
        });
    }
}

@end
