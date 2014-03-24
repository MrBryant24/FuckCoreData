//
//  TagListViewController.m
//  FuckCoreData
//
//  Created by name on 14年3月23日.
//  Copyright (c) 2014年 com.kapple. All rights reserved.
//

#import "TagListViewController.h"

@interface TagListViewController ()

@end

@implementation TagListViewController
-(id)initWithBankDetail:(FailedBankDetail*)details
{
    if (self=[super init]) {
        self.bankDetail=details;
    }
    
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewDidDisappear:(BOOL)animated
{
    //视图消失
    [super viewDidDisappear:YES];
    //所有details有很多tag
    self.bankDetail.tag=self.pickerTags;
    NSError*error;
    if (![self.bankDetail.managedObjectContext save:&error]) {
        NSLog(@"保存detail里的所有tag,%@,%@",error,[error userInfo]);
        abort();
    }
}

- (void)viewDidLoad
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                           target:self action:@selector(addTag)];
    
    [super viewDidLoad];
    
    NSError *error;
    if (![self.tagFetchedResultsController performFetch:&error]) {
	    NSLog(@"Error in tag retrieval %@, %@", error, [error userInfo]);
	    abort();
	}
    self.pickerTags =[[NSMutableSet alloc]init];
    //每个tag会连接多个details，所有tags都在array
    NSSet *tags =self.bankDetail.tag;
    for (Tag * tag in tags) {
        [self.pickerTags  addObject:tag];
    }
    

    
}
#pragma mark -加tag UIAlertDelegate
-(void)addTag
{
    UIAlertView *newTagAlert = [[UIAlertView alloc] initWithTitle:@"New tag"
                                                          message:@"Insert new tag name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
    newTagAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [newTagAlert show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSLog(@"cancel");
    }
    else
    {
        //1.拿到tag
        NSString *tagString =[[alertView textFieldAtIndex:0]text];
        //2.把tagStirng存储到coreData的tag的name
        //上下文引用detail的context
        Tag *tag= [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:self.bankDetail.managedObjectContext];
        //
        tag.name=tagString;
        NSError*error;
        if (![self.bankDetail.managedObjectContext save:&error]) {
            NSLog(@"保存detail里的所有tag,%@,%@",error,[error userInfo]);
            abort();
        }
        
        [self.tagFetchedResultsController performFetch:&error];
        [self.tableView reloadData];

    }
}
#pragma mark -tagFetchedResultsController
-(NSFetchedResultsController*)tagFetchedResultsController
{
    if (_tagFetchedResultsController!=nil) {
        return _tagFetchedResultsController;
    }
    /*
     筛选过程
     */
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tag"
                                              inManagedObjectContext:self.bankDetail.managedObjectContext];
    //managedObjectContext在多线程里不可以只有这一个
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                                   ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]
                                                             initWithFetchRequest:fetchRequest managedObjectContext:self.bankDetail.managedObjectContext
                                                             sectionNameKeyPath:nil cacheName:nil];
    self.tagFetchedResultsController = aFetchedResultsController;
	NSError *error = nil;
    if (![self.tagFetchedResultsController performFetch:&error]) {
	    NSLog(@"Core data error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    
    
    
    return _tagFetchedResultsController;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return [self.tagFetchedResultsController sections].count;;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    NSArray * sections =[self.tagFetchedResultsController sections];
    id sectionInfo =[sections objectAtIndex:section];
    
    return [sectionInfo numberOfObjects];
    /*
    there is only one section, and the number of rows is calculated according to the results controller. 
     只有一个section,所以行数根据筛选结果控制器去计算
     
     */
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    [self configure:cell AtIndexPath:indexPath];
    
    return cell;
}
-(void)configure:(UITableViewCell*)cell AtIndexPath:(NSIndexPath*)indexPath
{
    cell.accessoryType=UITableViewCellAccessoryNone;
    Tag*tag =(Tag*)[[self tagFetchedResultsController]objectAtIndexPath:indexPath];
    
    if ([self.pickerTags containsObject:tag]) {
        //检查对象数组是否存在这个对象
        cell.accessoryType=UITableViewCellAccessoryCheckmark;
    }
    
    cell.textLabel.text=tag.name;
    
    

}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}



// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}



#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Tag *tag =(Tag*)[[self tagFetchedResultsController]objectAtIndexPath:indexPath];
    UITableViewCell*cell =[self.tableView cellForRowAtIndexPath:indexPath];//取得按的那个cell
    
    [cell setSelected:NO animated:YES];
    
    if ([self.pickerTags containsObject:tag]) {
        [_pickerTags removeObject:tag];
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        [_pickerTags addObject:tag];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
}//这个是detail控制器push进来后的，想todo列
 


@end
