//
//  GMImagePickerController.m
//  GMPhotoPicker
//
//  Created by Guillermo Muntaner Perelló on 19/09/14.
//  Copyright (c) 2014 Guillermo Muntaner Perelló. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import "GMImagePickerController.h"
#import "GMAlbumsViewController.h"
#import "ProgressViewController.h"
#import <AWSS3/AWSS3.h>

@import Photos;

@interface GMImagePickerController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong) ProgressViewController *progressController;
@property (strong) GMAlbumsViewController *albumsController;

@property (strong) NSURL *toBeUploaded;
@property (strong) NSMutableDictionary *uploadResult;

@property (strong) NSString *bucket;
@property (strong) NSString *folder;

@end

@implementation GMImagePickerController

- (id)init
{
    if (self = [super init]) {
        
        _selectedAssets = [[NSMutableArray alloc] init];
        
        //Remove Temp file
        NSArray *paths = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
        NSURL *documentsURL = [paths lastObject];
        
        NSURL *finalUploading = [[NSURL alloc] initWithString: [[NSString alloc] initWithFormat:@"%@/temp", documentsURL.absoluteString]];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:[finalUploading path]]){
            [fileManager removeItemAtPath:[finalUploading path] error:nil];
        }
        
        // Default values:
        _displaySelectionInfoToolbar = YES;
        _displayAlbumsNumberOfAssets = YES;
        _autoDisableDoneButton = YES;
        _allowsMultipleSelection = NO;
        _confirmSingleSelection = YES;
        _showCameraButton = NO;
        
        // Grid configuration:
        _colsInPortrait = 3;
        _colsInLandscape = 5;
        _minimumInteritemSpacing = 2.0;
        
        // Sample of how to select the collections you want to display:
        // _customSmartCollections = @[@(PHAssetCollectionSubtypeSmartAlbumFavorites),
        //                             @(PHAssetCollectionSubtypeSmartAlbumRecentlyAdded),
        //                             @(PHAssetCollectionSubtypeSmartAlbumVideos),
        //                             @(PHAssetCollectionSubtypeSmartAlbumSlomoVideos),
        //                             @(PHAssetCollectionSubtypeSmartAlbumTimelapses),
        //                             @(PHAssetCollectionSubtypeSmartAlbumBursts),
        //                             @(PHAssetCollectionSubtypeSmartAlbumPanoramas)];
        _customSmartCollections = @[@(PHAssetCollectionSubtypeSmartAlbumVideos)];
        // If you don't want to show smart collections, just put _customSmartCollections to nil;
        //_customSmartCollections=nil;
        
        // Which media types will display
       _mediaTypes = @[@(PHAssetMediaTypeAudio),
                       @(PHAssetMediaTypeVideo),
                       @(PHAssetMediaTypeImage)];
        // _mediaTypes = @[@(PHAssetMediaTypeVideo)];
        
        self.preferredContentSize = kPopoverContentSize;
        
        // UI Customisation
        _pickerBackgroundColor = [UIColor whiteColor];
        _pickerTextColor = [UIColor darkTextColor];
        _pickerFontName = @"HelveticaNeue";
        _pickerBoldFontName = @"HelveticaNeue-Bold";
        _pickerFontNormalSize = 14.0f;
        _pickerFontHeaderSize = 17.0f;
        
        _navigationBarBackgroundColor = [UIColor whiteColor];
        _navigationBarTextColor = [UIColor darkTextColor];
        _navigationBarTintColor = [UIColor darkTextColor];
        
        _toolbarBarTintColor = [UIColor whiteColor];
        _toolbarTextColor = [UIColor darkTextColor];
        _toolbarTintColor = [UIColor darkTextColor];
        
        _pickerStatusBarStyle = UIStatusBarStyleDefault;
        
        
        _albumsController = [[GMAlbumsViewController alloc] init];
        
        
        
        _toBeUploaded = [[NSURL alloc] init];
        // _uploadPath = [[NSString alloc] initWithString:@""];
        
        _uploadResult = [NSMutableDictionary dictionary];
        
        
        [self setupNavigationController];
        
    }
    return self;
}

- (void) setupAWSS3:(NSString *)CognitoPoolID region:(NSString *)region bucket:(NSString *)bucket folder:(NSString *)folder
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
    self.bucket = [[NSString alloc] initWithString:bucket];
    self.folder = [[NSString alloc] initWithString:folder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Ensure nav and toolbar customisations are set. Defaults are in place, but the user may have changed them
    self.view.backgroundColor = _pickerBackgroundColor;

    _navigationController.toolbar.translucent = YES;
    _navigationController.toolbar.barTintColor = _toolbarBarTintColor;
    _navigationController.toolbar.tintColor = _toolbarTintColor;
//    [(UIView*)[_navigationController.toolbar.subviews objectAtIndex:0] setAlpha:0.75f];  // URGH - I know!
    
    _navigationController.navigationBar.backgroundColor = _navigationBarBackgroundColor;
    _navigationController.navigationBar.tintColor = _navigationBarTintColor;
    NSDictionary *attributes;
    if (_useCustomFontForNavigationBar) {
        attributes = @{NSForegroundColorAttributeName : _navigationBarTextColor,
                       NSFontAttributeName : [UIFont fontWithName:_pickerBoldFontName size:_pickerFontHeaderSize]};
    } else {
        attributes = @{NSForegroundColorAttributeName : _navigationBarTextColor};
    }
    _navigationController.navigationBar.titleTextAttributes = attributes;
    
    [self updateToolbar];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return _pickerStatusBarStyle;
}

-(BOOL) shouldAutorotate{ return YES; }

-(UIInterfaceOrientationMask) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


#pragma mark - Setup Navigation Controller

- (void)setupNavigationController
{
    _navigationController = [[UINavigationController alloc] initWithRootViewController:_albumsController];
    _navigationController.delegate = self;
    
    _navigationController.navigationBar.translucent = YES;
    [_navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    _navigationController.navigationBar.shadowImage = [UIImage new];
    
    [_navigationController willMoveToParentViewController:self];
    [_navigationController.view setFrame:self.view.frame];
    [self.view addSubview:_navigationController.view];
    [self addChildViewController:_navigationController];
    [_navigationController didMoveToParentViewController:self];
    
}

-(void)uploadSelectedFile
{
    // If selected Video exist
    if (self.toBeUploaded.absoluteString.length != 0) {

        NSError *err;
        NSData *uploadData = [[NSData alloc] initWithContentsOfURL:self.toBeUploaded options:NSDataReadingMappedIfSafe error:&err];
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
                 
        self.progressController = [[ProgressViewController alloc] init];
        self.progressController.view.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8f];
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
        
        NSString *fileName = [self.toBeUploaded lastPathComponent];
        NSString *finalPath = [[NSString alloc] initWithFormat:@"%@%@-%@-%@", self.folder, randomString, ts, fileName];
        
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
                    [self.uploadResult setObject:@"Stored" forKey:@"Status"];
                } else {
                    [self.uploadResult setObject:@"Failed" forKey:@"Status"];
                }

                dispatch_async(dispatch_get_main_queue(), ^{
                    // Do something e.g. Alert a user for transfer completion.
                    // On failed uploads, `error` contains the error object.
                    
                    if (error != nil) {
                        NSLog(@"Finished: Error = %@", error);
                        [self.uploadResult setObject:error forKey:@"Error"];
                        [self.progressController dismissViewControllerAnimated:YES completion:nil];
                    } else {
                        NSLog(@"Finished: Response = %@", task.response);
                        NSURL *uploadURL = [task.response URL];
                        NSString *uploadPath = [[uploadURL.absoluteString componentsSeparatedByString:@"?"] objectAtIndex:0];
                        [self.uploadResult setObject:uploadPath forKey:@"Location"];
                        [self.progressController dismissViewControllerAnimated:YES completion:nil];
                        [self finishPickingAssets:self];
                    }
                });
            };

            AWSS3TransferUtility *transferUtility = [AWSS3TransferUtility defaultS3TransferUtility];
            [transferUtility uploadData:uploadData bucket:self.bucket key:finalPath contentType:@"video/quicktime" expression:expression completionHandler:completionHandler];
            
        });
        
        
    }
    
}


#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // Only if OK was pressed do we want to completge the selection
//        [self finishPickingAssets:self];
        
//        [self.navigationController setViewControllers:[NSArray arrayWithObject: _progressController]];
//        [_progressController setProgress:[[NSNumber alloc] initWithFloat:0.5]];
           
        
        
        
    }
}


#pragma mark - Select / Deselect Asset

- (void)selectAsset:(PHAsset *)asset
{
    [self.selectedAssets insertObject:asset atIndex:self.selectedAssets.count];
    [self updateDoneButton];
    
    if (!self.allowsMultipleSelection) {
        if (self.confirmSingleSelection) {
            NSString *message = self.confirmSingleSelectionPrompt ? self.confirmSingleSelectionPrompt : [NSString stringWithFormat:@"Do you want to upload video you tapped on? Upload Task will be continued in Background."];
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat: @"Upload Ready?"]
                message:message
                preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"No"]
                style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                // Ok action example
            }];
            UIAlertAction *otherAction = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Yes"]
                style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                // Other action
                PHAsset *firstAsset = [self.selectedAssets objectAtIndex:0];
                if (firstAsset.mediaType == PHAssetMediaTypeVideo) {
                    [[PHImageManager defaultManager] requestAVAssetForVideo:firstAsset options:nil resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info)
                    {
                        if ([asset isKindOfClass:[AVURLAsset class]])
                        {
                            NSURL *url = [(AVURLAsset*)asset URL];
                             // do what you want with it

                            self.toBeUploaded = [(AVURLAsset*)asset URL];
                            dispatch_async(dispatch_get_main_queue(), ^(void){
                                 [self uploadSelectedFile];
                            });
                            
                            NSString *path=[NSString stringWithFormat:@"%@",url];
                            NSLog(@"GMImagePicker: User ended picking assets. Video Path is: %@", path);
                        }
                    }];
                }
            }];
            [alert addAction:okAction];
            [alert addAction:otherAction];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
//            [self finishPickingAssets:self];
            
            /// Hide assetPickerController if singleSelection disabled
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }
    } else if (self.displaySelectionInfoToolbar || self.showCameraButton) {
        [self updateToolbar];
    }
}

- (void)deselectAsset:(PHAsset *)asset
{
    [self.selectedAssets removeObjectAtIndex:[self.selectedAssets indexOfObject:asset]];
    if (self.selectedAssets.count == 0) {
        [self updateDoneButton];
    }
    
    if (self.displaySelectionInfoToolbar || self.showCameraButton) {
        [self updateToolbar];
    }
}

- (void)updateDoneButton
{
    if (!self.allowsMultipleSelection) {
        return;
    }
    
    UINavigationController *nav = (UINavigationController *)self.childViewControllers[0];
    for (UIViewController *viewController in nav.viewControllers) {
        viewController.navigationItem.rightBarButtonItem.enabled = (self.autoDisableDoneButton ? self.selectedAssets.count > 0 : TRUE);
    }
}

- (void)updateToolbar
{
    if (!self.allowsMultipleSelection && !self.showCameraButton) {
        return;
    }

    UINavigationController *nav = (UINavigationController *)self.childViewControllers[0];
    for (UIViewController *viewController in nav.viewControllers) {
        NSUInteger index = 1;
        if (_showCameraButton) {
            index++;
        }
        [[viewController.toolbarItems objectAtIndex:index] setTitleTextAttributes:[self toolbarTitleTextAttributes] forState:UIControlStateNormal];
        [[viewController.toolbarItems objectAtIndex:index] setTitleTextAttributes:[self toolbarTitleTextAttributes] forState:UIControlStateDisabled];
        [[viewController.toolbarItems objectAtIndex:index] setTitle:[self toolbarTitle]];
        [viewController.navigationController setToolbarHidden:(self.selectedAssets.count == 0 && !self.showCameraButton) animated:YES];
    }
}


#pragma mark - User finish Actions

- (void)dismiss:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(assetsPickerControllerDidCancel:)]) {
        [self.delegate assetsPickerControllerDidCancel:self];
    }
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


- (void)finishPickingAssets:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(assetsPickerController:didFinishUpload:)]) {
        [self.delegate assetsPickerController:self didFinishUpload:self.uploadResult];
    }
}


#pragma mark - Toolbar Title

- (NSPredicate *)predicateOfAssetType:(PHAssetMediaType)type
{
    return [NSPredicate predicateWithBlock:^BOOL(PHAsset *asset, NSDictionary *bindings) {
        return (asset.mediaType == type);
    }];
}

- (NSString *)toolbarTitle
{
    if (self.selectedAssets.count == 0) {
        return nil;
    }
    
    NSPredicate *photoPredicate = [self predicateOfAssetType:PHAssetMediaTypeImage];
    NSPredicate *videoPredicate = [self predicateOfAssetType:PHAssetMediaTypeVideo];
    
    NSInteger nImages = [self.selectedAssets filteredArrayUsingPredicate:photoPredicate].count;
    NSInteger nVideos = [self.selectedAssets filteredArrayUsingPredicate:videoPredicate].count;
    
    if (nImages > 0 && nVideos > 0) {
        return [NSString stringWithFormat:@"%@ Items Selected", @(nImages + nVideos)];
    } else if (nImages > 1) {
        return [NSString stringWithFormat:@"%@ Photos Selected", @(nImages)];
    } else if (nImages == 1) {
        return @"1 Photo Selected";
    } else if (nVideos > 1) {
        return [NSString stringWithFormat:@"%@ Videos Selected", @(nVideos)];
    } else if (nVideos == 1) {
        return @"1 Video Selected";
    } else {
        return nil;
    }
}


#pragma mark - Toolbar Items

- (void)cameraButtonPressed:(UIBarButtonItem *)button
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Camera!"
                                                        message:@"Sorry, this device does not have a camera."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];

        return;
    }
    
    // This allows the selection of the image taken to be better seen if the user is not already in that VC
    if (self.autoSelectCameraImages && [self.navigationController.topViewController isKindOfClass:[GMAlbumsViewController class]]) {
        [((GMAlbumsViewController *)self.navigationController.topViewController) selectAllAlbumsCell];
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.mediaTypes = @[(NSString *)kUTTypeImage];
    picker.allowsEditing = self.allowsEditingCameraImages;
    picker.delegate = self;
    picker.modalPresentationStyle = UIModalPresentationPopover;
    
    UIPopoverPresentationController *popPC = picker.popoverPresentationController;
    popPC.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popPC.barButtonItem = button;
    
    [self showViewController:picker sender:button];
}

- (NSDictionary *)toolbarTitleTextAttributes {
    return @{NSForegroundColorAttributeName : _toolbarTextColor,
             NSFontAttributeName : [UIFont fontWithName:_pickerFontName size:_pickerFontHeaderSize]};
}

- (UIBarButtonItem *)titleButtonItem
{
    UIBarButtonItem *title = [[UIBarButtonItem alloc] initWithTitle:self.toolbarTitle
                                                              style:UIBarButtonItemStylePlain
                                                             target:nil
                                                             action:nil];
    
    NSDictionary *attributes = [self toolbarTitleTextAttributes];
    [title setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [title setTitleTextAttributes:attributes forState:UIControlStateDisabled];
    [title setEnabled:NO];
    
    return title;
}

- (UIBarButtonItem *)spaceButtonItem
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
}

- (UIBarButtonItem *)cameraButtonItem
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(cameraButtonPressed:)];
}

- (NSArray *)toolbarItems
{
    UIBarButtonItem *camera = [self cameraButtonItem];
    UIBarButtonItem *title  = [self titleButtonItem];
    UIBarButtonItem *space  = [self spaceButtonItem];
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    if (_showCameraButton) {
        [items addObject:camera];
    }
    [items addObject:space];
    [items addObject:title];
    [items addObject:space];
    
    return [NSArray arrayWithArray:items];
}


#pragma mark - Camera Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];

    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = info[UIImagePickerControllerEditedImage] ? : info[UIImagePickerControllerOriginalImage];
        UIImageWriteToSavedPhotosAlbum(image,
                                       self,
                                       @selector(image:finishedSavingWithError:contextInfo:),
                                       nil);
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Image Not Saved"
                                                        message:@"Sorry, unable to save the new image!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    // Note: The image view will auto refresh as the photo's are being observed in the other VCs
}

@end
