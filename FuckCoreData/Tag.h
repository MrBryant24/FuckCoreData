//
//  Tag.h
//  FuckCoreData
//
//  Created by name on 14年3月23日.
//  Copyright (c) 2014年 com.kapple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FailedBankDetail;

@interface Tag : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *bankdetails;
@end

@interface Tag (CoreDataGeneratedAccessors)

- (void)addBankdetailsObject:(FailedBankDetail *)value;
- (void)removeBankdetailsObject:(FailedBankDetail *)value;
- (void)addBankdetails:(NSSet *)values;
- (void)removeBankdetails:(NSSet *)values;

@end
