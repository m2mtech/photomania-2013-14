//
//  PhotomaniaAppDelegate+MOC.h
//  Photomania
//
//  This code comes from the Xcode template for Master-Detail application.
//

#import "PhotomaniaAppDelegate.h"

@interface PhotomaniaAppDelegate (MOC)

- (void)saveContext:(NSManagedObjectContext *)managedObjectContext;

- (NSManagedObjectContext *)createMainQueueManagedObjectContext;

@end
