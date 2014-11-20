//
//  AddPhotoViewController.h
//  Photomania
//
//  Created by Martin Mandl on 15.06.14.
//  Copyright (c) 2014 m2m server software gmbh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photographer.h"
#import "Photo.h"

@interface AddPhotoViewController : UIViewController

@property (nonatomic, strong) Photographer *photographerTakingPhoto;
@property (nonatomic, readonly) Photo *addedPhoto;

@end
