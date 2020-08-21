//
//  AppDelegate+VideoUpload.m
//  MyApp
//
//  Created by DevMaster on 8/21/20.
//

#import "AppDelegate+VideoUpload.h"

#define BLOCK_ROTATION_KEY @"BLOCK_ROTATION"

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

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if ([self getBlockRotation]) {
        return UIInterfaceOrientationMaskPortrait;
    }
    
    return UIInterfaceOrientationMaskAll;
}





@end
