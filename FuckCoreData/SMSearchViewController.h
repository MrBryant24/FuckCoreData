//
//  SMSearchViewController.h
//  FuckCoreData
//
//  Created by name on 14年3月23日.
//  Copyright (c) 2014年 com.kapple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FailedBankInfo.h"
@interface SMSearchViewController : UIViewController<UITabBarControllerDelegate,UITableViewDataSource,
NSFetchedResultsControllerDelegate,UISearchBarDelegate>

@property(nonatomic,strong)NSManagedObjectContext*searchManagedContext;
@property(nonatomic,strong)NSFetchedResultsController*searchFetchedResultsController;

@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UILabel *noResultsLabel;

-(IBAction)closeSearch;



@end
