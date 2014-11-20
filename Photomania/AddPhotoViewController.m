//
//  AddPhotoViewController.m
//  Photomania
//
//  Created by Martin Mandl on 15.06.14.
//  Copyright (c) 2014 m2m server software gmbh. All rights reserved.
//

#import "AddPhotoViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIImage+CS193p.h"

@interface AddPhotoViewController () <UITextFieldDelegate, UIAlertViewDelegate, CLLocationManagerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *subtitleTextField;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;
@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) NSURL *imageURL;
@property (strong, nonatomic) NSURL *thumbnailURL;
@property (strong, nonatomic, readwrite) Photo *addedPhoto;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSInteger locationErrorCode;

@end

@implementation AddPhotoViewController

#define ALERT_NO_PHOTO_TAKEN NSLocalizedStringFromTable(@"ALERT_NO_PHOTO_TAKEN", @"AddPhotoViewController", @"User tried to dismiss modal controller to add a photo, but had not taken a photo at that point.")
#define ALERT_CANT_ADD_PHOTO NSLocalizedStringFromTable(@"ALERT_CANT_ADD_PHOTO", @"AddPhotoViewController", @"Alert message delivered when there is something that prevents the user from adding a new photo to the database that the user can do nothing about.")
#define ALERT_TITLE_REQUIRED NSLocalizedStringFromTable(@"ALERT_TITLE_REQUIRED", @"AddPhotoViewController", @"User tried to dismiss modal controller to add a photo, but had not specified a title for the photo, which is required.")
#define ALERT_LOCATION_UNKNOWN_YET NSLocalizedStringFromTable(@"ALERT_LOCATION_UNKNOWN_YET", @"AddPhotoViewController", @"User tried to dismiss modal controller to add a photo, but the controller had not (yet) found the location the photo was taken.")
#define ALERT_LOCATION_SERVICES_DISABLED NSLocalizedStringFromTable(@"ALERT_LOCATION_SERVICES_DISABLED", @"AddPhotoViewController", @"User tried to dismiss modal controller to add a photo, but the location the photo was taken could not be found because the user needs to enable location services in the Settings application.")
#define ALERT_LOCATION_NETWORK_DISABLED NSLocalizedStringFromTable(@"ALERT_LOCATION_NETWORK_DISABLED", @"AddPhotoViewController", @"User tried to dismiss modal controller to add a photo, but the location the photo was taken could not be found maybe because the user has no network connection active.")
#define ALERT_LOCATION_UNKNOWN NSLocalizedStringFromTable(@"ALERT_LOCATION_UNKNOWN", @"AddPhotoViewController", @"User tried to dismiss modal controller to add a photo, but the controller cannot figure out the location the photo was taken.")
#define ALERT_TITLE_ADD_PHOTO NSLocalizedStringFromTable(@"ALERT_TITLE_ADD_PHOTO", @"AddPhotoViewController", @"Title of an alert that appears when there is a problem adding a photo to the database.")
#define ALERT_DISMISS_BUTTON NSLocalizedStringFromTable(@"ALERT_DISMISS_BUTTON", @"AddPhotoViewController", @"Text on button which dismisses an alert which explained a problem adding a photo to the database.")
#define ALERT_CANT_FILTER_WITHOUT_PHOTO NSLocalizedStringFromTable(@"ALERT_CANT_FILTER_WITHOUT_PHOTO", @"AddPhotoViewController", @"Alert given to user when they try to filter a photo, but they haven't even taken a photo yet.")
#define FILTER_ACTION_SHEET_TITLE NSLocalizedStringFromTable(@"FILTER_ACTION_SHEET_TITLE", @"AddPhotoViewController", @"Title of Filter Image action sheet.")
#define FILTER_ACTION_SHEET_CANCEL NSLocalizedStringFromTable(@"FILTER_ACTION_SHEET_CANCEL", @"AddPhotoViewController", @"Action sheet choice which cancels filtering an image.")
#define FILTER_CHROME NSLocalizedStringFromTable(@"FILTER_CHROME", @"AddPhotoViewController", @"Action sheet choice for applying a chrome filter to a photo taken by the user.")
#define FILTER_BLUR NSLocalizedStringFromTable(@"FILTER_BLUR", @"AddPhotoViewController", @"Action sheet choice for applying a blurring filter to a photo taken by the user.")
#define FILTER_NOIR NSLocalizedStringFromTable(@"FILTER_NOIR", @"AddPhotoViewController", @"Action sheet choice for applying a noir filter to a photo taken by the user.")
#define FILTER_FADE NSLocalizedStringFromTable(@"FILTER_FADE", @"AddPhotoViewController", @"Action sheet choice for applying a fade filter to a photo taken by the user.")

+ (BOOL)canAddPhoto
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        if ([availableMediaTypes containsObject:(NSString *)kUTTypeImage]) {
            if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusRestricted) {
                return YES;
            }
        }
    }
    return NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![[self class] canAddPhoto]) {
        [self fatalAlert:ALERT_CANT_ADD_PHOTO]; // @"Sorry, this device cannot add a photo."
    } else {
        [self.locationManager startUpdatingLocation];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.locationManager stopUpdatingLocation];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#define UNWIND_SEGUE_IDENTIFIER @"Do Add Photo"

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:UNWIND_SEGUE_IDENTIFIER]) {
        NSManagedObjectContext *context = self.photographerTakingPhoto.managedObjectContext;
        if (context) {
            Photo *photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo"
                                                         inManagedObjectContext:context];
            photo.title = self.titleTextField.text;
            photo.subtitle = self.subtitleTextField.text;
            photo.whoTook = self.photographerTakingPhoto;
            photo.latitude = @(self.location.coordinate.latitude);
            photo.longitude = @(self.location.coordinate.longitude);
            photo.imageURL = [self.imageURL absoluteString];
            photo.thumbnailURL = [self.thumbnailURL absoluteString];
            
            self.addedPhoto = photo;
            
            self.imageURL = nil;
            self.thumbnailURL = nil;
        }
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:UNWIND_SEGUE_IDENTIFIER]) {
        if (!self.image) {
            [self alert:ALERT_NO_PHOTO_TAKEN]; // @"No photo taken!"
            return NO;
        } else if (![self.titleTextField.text length]) {
            [self alert:ALERT_TITLE_REQUIRED]; // @"Title required!"
            return NO;
        } else if (!self.location) {
            switch (self.locationErrorCode) {
                case kCLErrorLocationUnknown:
                    [self alert:ALERT_LOCATION_UNKNOWN_YET]; break; // @"Couldn't figure out where this photo was taken (yet)."
                case kCLErrorDenied:
                    [self alert:ALERT_LOCATION_SERVICES_DISABLED]; break; // @"Location Services disabled under Privacy in Settings application."
                case kCLErrorNetwork:
                    [self alert:ALERT_LOCATION_NETWORK_DISABLED]; break; // @"Can't figure out where this photo is being taken.  Verify your connection to the network."
                default:
                    [self alert:ALERT_LOCATION_UNKNOWN]; break; // @"Cant figure out where this photo is being taken, sorry."
            }
            return NO;
        } else {
            return YES;
        }
    } else {
        return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
    }
}

- (void)alert:(NSString *)msg
{
    [[[UIAlertView alloc] initWithTitle:ALERT_TITLE_ADD_PHOTO // @"Add Photo"
                                message:msg
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:ALERT_DISMISS_BUTTON, nil] show];
}

- (void)fatalAlert:(NSString *)msg
{
    [[[UIAlertView alloc] initWithTitle:ALERT_TITLE_ADD_PHOTO
                                message:msg
                               delegate:self // we're going to cancel when dismissed
                      cancelButtonTitle:nil
                      otherButtonTitles:ALERT_DISMISS_BUTTON, nil] show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self cancel];
}

- (CLLocationManager *)locationManager
{
    if (!_locationManager) {
        CLLocationManager *locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager = locationManager;
    }
    return _locationManager;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.location = [locations lastObject];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    self.locationErrorCode = error.code;
}

- (NSURL *)uniqueDocumentURL
{
    NSArray *documentDirectories = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSString *unique = [NSString stringWithFormat:@"%.0f", floor([NSDate timeIntervalSinceReferenceDate])];
    return [[documentDirectories firstObject] URLByAppendingPathComponent:unique];
}

- (NSURL *)imageURL
{
    if (!_imageURL && self.image) {
        NSURL *url = [self uniqueDocumentURL];
        if (url) {
            NSData *imageData = UIImageJPEGRepresentation(self.image, 1.0);
            if ([imageData writeToURL:url atomically:YES]) {
                _imageURL = url;
            }
        }
    }
    return _imageURL;
}

- (NSURL *)thumbnailURL
{
    NSURL *url = [self.imageURL URLByAppendingPathExtension:@"thumbnail"];
    if (![_thumbnailURL isEqual:url]) {
        _thumbnailURL = nil;
        if (url) {
            UIImage *thumbnail = [self.image imageByScalingToSize:CGSizeMake(75, 75)];
            NSData *imageData = UIImageJPEGRepresentation(thumbnail, 0.5);
            if ([imageData writeToURL:url atomically:YES]) {
                _thumbnailURL = url;
            }
        }
    }
    return _thumbnailURL;
}

- (void)setImage:(UIImage *)image
{
    self.imageView.image = image;
    
    [[NSFileManager defaultManager] removeItemAtURL:_imageURL error:NULL];
    [[NSFileManager defaultManager] removeItemAtURL:_thumbnailURL error:NULL];
    self.imageURL = nil;
    self.thumbnailURL = nil;
}

- (UIImage *)image
{
    return self.imageView.image;
}

- (IBAction)cancel
{
    self.image = nil;
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)takePhoto
{
    UIImagePickerController *uiipc = [[UIImagePickerController alloc] init];
    uiipc.delegate = self;
    uiipc.mediaTypes = @[(NSString *)kUTTypeImage];
    uiipc.sourceType = UIImagePickerControllerSourceTypeCamera;
    uiipc.allowsEditing = YES;
    [self presentViewController:uiipc animated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (!image) image = info[UIImagePickerControllerOriginalImage];
    self.image = image;
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)filterImage
{
    if (!self.image) {
        [self alert:ALERT_CANT_FILTER_WITHOUT_PHOTO]; // @"You must take a photo first!"
    } else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:FILTER_ACTION_SHEET_TITLE // @"Filter Image"
                                                                 delegate:self
                                                        cancelButtonTitle:nil
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:nil];
        
        for (NSString *filter in [self filters]) {
            [actionSheet addButtonWithTitle:filter];
        }
        [actionSheet addButtonWithTitle:FILTER_ACTION_SHEET_CANCEL];
        
        [actionSheet showInView:self.view];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *choice = [actionSheet buttonTitleAtIndex:buttonIndex];
    NSString *filterName = [self filters][choice];
    self.image = [self.image imageByApplyingFilterNamed:filterName];
}

- (NSDictionary *)filters
{
    return @{ FILTER_CHROME : @"CIPhotoEffectChrome", // @"Chrome"
              FILTER_BLUR : @"CIGaussianBlur", // @"BLUR"
              FILTER_NOIR : @"CIPhotoEffectNoir", // @"Noir"
              FILTER_FADE : @"CIPhotoEffectFade" }; // @"Fade"
}

@end
