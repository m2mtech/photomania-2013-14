//
//  PhotosByPhotographerImageViewController.m
//  Photomania
//
//  Created by Martin Mandl on 15.06.14.
//  Copyright (c) 2014 m2m server software gmbh. All rights reserved.
//

#import "PhotosByPhotographerImageViewController.h"
#import "PhotosByPhotographerMapViewController.h"


@interface PhotosByPhotographerImageViewController ()

@property (nonatomic, strong) PhotosByPhotographerMapViewController *mapvc;

@end

@implementation PhotosByPhotographerImageViewController

- (void)setPhotographer:(Photographer *)photographer
{
    _photographer = photographer;
    self.title = photographer.name;
    self.mapvc.photographer = photographer;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[PhotosByPhotographerMapViewController class]]) {
        PhotosByPhotographerMapViewController *pbpmapvc = (PhotosByPhotographerMapViewController *)segue.destinationViewController;
        pbpmapvc.photographer = self.photographer;
        self.mapvc = pbpmapvc;
    } else {
        [super prepareForSegue:segue sender:sender];
    }
}

@end
