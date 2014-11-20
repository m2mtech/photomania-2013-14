//
//  UIImage+CS193p.h
//  Photomania
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (CS193p)

// makes a copy at a different size
- (UIImage *)imageByScalingToSize:(CGSize)size;

// applies filter as described in Friday section
- (UIImage *)imageByApplyingFilterNamed:(NSString *)filterName;

@end
