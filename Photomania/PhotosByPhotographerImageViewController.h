//
//  PhotosByPhotographerImageViewController.h
//  Photomania
//
//  Created by Martin Mandl on 15.06.14.
//  Copyright (c) 2014 m2m server software gmbh. All rights reserved.
//

#import "ImageViewController.h"
#import "Photographer.h"

@interface PhotosByPhotographerImageViewController : ImageViewController

@property (nonatomic, strong) Photographer *photographer;

@end
