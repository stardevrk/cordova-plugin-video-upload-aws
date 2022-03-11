//
//  AppDelegate+VideoUpload.m
//  MyApp
//
//  Created by DevMaster on 8/21/20.
//

#import "AppDelegate+VideoUpload.h"

#define BLOCK_ROTATION_KEY @"BLOCK_ROTATION"
#define UPLOADING_STATUS_KEY @"UPLOADING_STATUS"

@implementation AppDelegate (VideoUpload)

- (void)saveBlockRotation:(BOOL)blockRotation {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:blockRotation forKey:BLOCK_ROTATION_KEY];
    [userDefaults synchronize];
}

- (BOOL)getBlockRotation {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:BLOCK_ROTATION_KEY];
}

- (void) saveUploadingStatus: (BOOL)uploading {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:uploading forKey:UPLOADING_STATUS_KEY];
    [userDefaults synchronize];
}

- (BOOL) getUploadingStatus {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:UPLOADING_STATUS_KEY];
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if ([self getBlockRotation]) {
        return UIInterfaceOrientationMaskPortrait;
    }
    
    return UIInterfaceOrientationMaskAll;
}





@end
