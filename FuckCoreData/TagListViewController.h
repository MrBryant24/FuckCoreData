//
//  TagListViewController.h
//  FuckCoreData
//
//  Created by name on 14年3月23日.
//  Copyright (c) 2014年 com.kapple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tag.h"
#import "FailedBankDetail.h"

@interface TagListViewController : UITableViewController<UIAlertViewDelegate>
/*
 这个是tag列表，关联bankDetails
 */
//1.the bank details that refer to the previous screen
//a set to collect the picked tags for the current details, and a results controller to fetch the whole list of tags.
@property(nonatomic,strong)NSFetchedResultsController*tagFetchedResultsController;//检索结果管理器
@property(nonatomic,strong)NSMutableSet *pickerTags;

@property(nonatomic,strong)FailedBankDetail*bankDetail;



//2.初始化加载details
-(id)initWithBankDetail:(FailedBankDetail*)details;

@end
