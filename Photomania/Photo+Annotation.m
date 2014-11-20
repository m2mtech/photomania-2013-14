//
//  Photo+Annotation.m
//  Photomania
//
//  Created by Martin Mandl on 14.06.14.
//  Copyright (c) 2014 m2m server software gmbh. All rights reserved.
//

#import "Photo+Annotation.h"

@implementation Photo (Annotation)

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coordinate;
    coordinate.longitude = [self.longitude doubleValue];
    coordinate.latitude = [self.latitude doubleValue];
    
    return coordinate;
}

@end
