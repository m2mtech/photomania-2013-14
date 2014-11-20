//
//  Photographer+Create.h
//  Photomania
//
//  Created by Martin Mandl on 07.12.13.
//  Copyright (c) 2014 m2m server software gmbh. All rights reserved.
//

#import "Photographer.h"

@interface Photographer (Create)

+ (Photographer *)userInManagedObjectContext:(NSManagedObjectContext *)context;

- (BOOL)isUser;

+ (Photographer *)photographerWithName:(NSString *)name
                inManagedObjectContext:(NSManagedObjectContext *)context;

@end
