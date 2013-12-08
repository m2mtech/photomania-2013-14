//
//  PhotographersCDTVC.h
//  Photomania
//
//  Created by Martin Mandl on 08.12.13.
//  Copyright (c) 2013 m2m server software gmbh. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface PhotographersCDTVC : CoreDataTableViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
