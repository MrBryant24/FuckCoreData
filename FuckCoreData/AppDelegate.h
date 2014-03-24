/*
 But what if you don’t want everything? What if you want a subset, such as:
 
 All the banks whose names contain a given string.
 All the banks closed on a given date.
 All the banks whose zip codes end with a specific digit or string of digits.
 All the banks closed after a given date.
 All the banks with at least one tag.

 
 */

#import <UIKit/UIKit.h>
#import "FailedBankInfo.h"
#import "FailedBankDetail.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

/*
 Core Data “stack”
 
 One creates a managed object context
 one creates a managed object model
 and one creates a persistent store coordinator.
 */

/*
 Apple recommends that whenever you create a link from one object to another,
 you create a link from the other object going back as well. So let’s do this.
 */

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
