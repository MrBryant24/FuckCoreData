//
//  FBCDMasterViewController.h
//  FuckCoreData
//
//  Created by name on 14年3月22日.
//  Copyright (c) 2014年 com.kapple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FBCDMasterViewController : UITableViewController<NSFetchedResultsControllerDelegate>
@property(nonatomic,strong)NSManagedObjectContext *managedObjectContext;
//对象上下文,用它来检索managedObject

//@property (nonatomic, strong) NSArray *failedBankInfos;
//用获取结果控制器来优化列表，整理列表
@property(nonatomic,strong)NSFetchedResultsController*fetchedResultsController;
@property(nonatomic,strong)NSFetchRequest *fetchRequest;
@end
