//
//  SMSearchViewController.m
//  FuckCoreData
//
//  Created by name on 14年3月23日.
//  Copyright (c) 2014年 com.kapple. All rights reserved.
//

#import "SMSearchViewController.h"

@interface SMSearchViewController ()
@property(nonatomic,strong)NSFetchRequest *fetchRequest;
@end

@implementation SMSearchViewController
@synthesize noResultsLabel;
@synthesize searchManagedContext;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.searchBar.delegate=self;
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    
    noResultsLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 90, 200, 30)];
    [self.view addSubview:noResultsLabel];
    noResultsLabel.text = @"No Results";
    [noResultsLabel setHidden:YES];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.searchBar becomeFirstResponder];
}

#pragma mark -searchDelegation

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSError *error;
	if (![[self searchFetchedResultsController] performFetch:&error]) {
		NSLog(@"Error in search %@, %@", error, [error userInfo]);
	} else {
        [self.tableView reloadData];
        [self.searchBar resignFirstResponder];
        [noResultsLabel setHidden:_searchFetchedResultsController.fetchedObjects.count > 0];
    }
}
#pragma mark -searchFetchedResultsController_Getting
-(NSFetchRequest*)fetchRequest
{
    if (_fetchRequest!=nil) {
        return _fetchRequest;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"FailedBankInfo"
                                              inManagedObjectContext:searchManagedContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"details.closeDate" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    [fetchRequest setFetchBatchSize:20];
    // Create predicate
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"name CONTAINS %@", self.searchBar.text];
    
    //包括字符
    [fetchRequest setPredicate:pred];
    
    return _fetchRequest;

}
#define SEARCH_TYPE 11

-(NSFetchedResultsController*)searchFetchedResultsController
{
    if (_searchFetchedResultsController!=nil) {
        return _searchFetchedResultsController;
    }
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"FailedBankInfo"
                                              inManagedObjectContext:searchManagedContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"details.closeDate" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    [fetchRequest setFetchBatchSize:20];
    // Create predicate
    NSArray *queryArray;
    
    if ([self.searchBar.text rangeOfString:@":"].location != NSNotFound) {
        
        queryArray = [self.searchBar.text componentsSeparatedByString:@":"];
        
    }
    
    NSLog(@"search is %@", self.searchBar.text);
    
    NSPredicate *pred;
    //SEARCH_TYPE=可以自己设定
    switch (SEARCH_TYPE) {
            
        case 0: // name contains, case sensitive
            pred = [NSPredicate predicateWithFormat:@"name CONTAINS %@", self.searchBar.text];
            break;
            
        case 1: // name contains, case insensitive
            pred = [NSPredicate predicateWithFormat:@"name CONTAINS[c] %@", self.searchBar.text];
            break;
            
        case 2: // name is exactly the same
            pred = [NSPredicate predicateWithFormat:@"name == %@", self.searchBar.text];
            break;
            
        case 3: { // name begins with
            pred = [NSPredicate predicateWithFormat:@"name BEGINSWITH[c] %@", self.searchBar.text];
            break;
        }
            
        case 4: { // name matches with, e.g. .*nk
            pred = [NSPredicate predicateWithFormat:@"name MATCHES %@", self.searchBar.text];
            break;
        }
            
        case 5: { // zip ends with
            
            pred = [NSPredicate predicateWithFormat: @"details.zip ENDSWITH %@", self.searchBar.text];
            break;
        }
            
        case 6: { // date is greater than, e.g 2011-12-14
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSDate *date = [dateFormatter dateFromString:self.searchBar.text];
            
            pred = [NSPredicate predicateWithFormat: @"details.closeDate > %@", date];
            
            break;
        }
            
        case 7: { // has at least a tag
            
            pred = [NSPredicate predicateWithFormat: @"details.tags.@count > 0"];
            
            break;
        }
            
            
        case 8: // string contains (case insensitive) X and zip is exactly equal to Y. e.g. bank:ville
            pred = [NSPredicate predicateWithFormat:@"(name CONTAINS[c] %@) AND (city CONTAINS[c] %@)", [queryArray objectAtIndex:0], [queryArray objectAtIndex:1]
                    ];
            break;
            
        case 9: // name contains X and zip is exactly equal to Y, e.g. bank:123
            pred = [NSPredicate predicateWithFormat:@"(name CONTAINS[c] %@) AND (details.zip == %i)", [queryArray objectAtIndex:0],
                    [[queryArray objectAtIndex:1] intValue]
                    ];
            break;
            
            
            
        case 10: // name contains X and tag name is exactly equal to Y, e.g. bank:tag1
            pred = [NSPredicate predicateWithFormat:@"(name CONTAINS[c] %@) AND (details.tags == %i)", [queryArray objectAtIndex:0],
                    [[queryArray objectAtIndex:1] intValue]
                    ];
            break;
            
        case 11: { // has a tag whose name contains
            
            pred = [NSPredicate predicateWithFormat: @"ANY details.tags.name contains[c] %@", self.searchBar.text];
            break;
        }
            
        default:
            break;
    }
    
    // Create fetched results controller
    NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                  managedObjectContext:searchManagedContext sectionNameKeyPath:nil cacheName:nil]; // better to not use cache
    _searchFetchedResultsController= theFetchedResultsController;
    _searchFetchedResultsController.delegate = self;
    
    
    return _searchFetchedResultsController;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)closeSearch
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -表视图委托
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id  sectionInfo =
    [[_searchFetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
    
}

-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    FailedBankInfo *info = [_searchFetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = info.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@",
                                 info.city, info.state];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

@end
