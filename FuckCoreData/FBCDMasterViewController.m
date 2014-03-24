//
//  FBCDMasterViewController.m
//  FuckCoreData
//
//  Created by name on 14年3月22日.
//  Copyright (c) 2014年 com.kapple. All rights reserved.
//

#import "FBCDMasterViewController.h"
#import "SMBankDetailViewController.h"
#import "SMSearchViewController.h"

#import "FailedBankInfo.h"
#import "FailedBankDetail.h"
@interface FBCDMasterViewController ()


@end

@implementation FBCDMasterViewController
@synthesize fetchRequest;
@synthesize managedObjectContext;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
   

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                          target:self
                                                                                          action:@selector(addBank)];
    self.navigationItem.RightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                                                          target:self
                                                                                          action:@selector(showSearch)];
    
    
    
    
    NSError *error;
 /*
  1.All we do here is get a handle to our fetchedResultsController (which implicitly creates it as well)
  2.call performFetch to retrieve the first batch of data.
  */
    
    if (![[self fetchedResultsController]performFetch:&error]) {
       NSLog(@"检索+检索结果失败 %@, %@", error, [error userInfo]);
        exit(-1);
    }
    
    self.title = @"Failed Banks";

}
#pragma mark -增加+更新+搜索
-(void)addBank
{
    /*
     You create an instance of FailedBankInfo and you populate the properties with values
     */
    FailedBankInfo*info =[NSEntityDescription insertNewObjectForEntityForName:@"FailedBankInfo" inManagedObjectContext:managedObjectContext];
    info.name=@"工商银行";
    info.city=@"北京";
    info.state=@"北京区";
    
    FailedBankDetail*failedBankDetails=[NSEntityDescription insertNewObjectForEntityForName:@"FailedBankDetail" inManagedObjectContext:managedObjectContext];
    failedBankDetails.closeDate = [NSDate date];
    failedBankDetails.updateDate = [NSDate date];
    failedBankDetails.zip = [NSNumber numberWithInt:123];
    
    failedBankDetails.info=info;
    info.details=failedBankDetails;
    
    NSError*err;
    /*
     you save the context to make sure the insertion is committed to the database
     提交到数据库->上下文-持久化存储调试器-sqlite
     */
    if (![managedObjectContext save:&err]) {
        NSLog(@"存储失败");
        abort();
    }
   
    
    /*
     为什么没有[tableView reloadData],因为：
     
     1.This is due to the these functions, both inherited from previous versions of the project:
     
     2。controller:didChangeObject:atIndexPath:forChangeType:newIndexPath: This takes care of four possible changes to the table view: insertions, deletions, updates and moves.
     3.controllerWillChangeContent: This simply “alerts” the controller of upcoming changes via the fetched results controller.
     */
    
}
-(void)showSearch
{
    SMSearchViewController *search =[[SMSearchViewController alloc]init];
    search.searchManagedContext =managedObjectContext;
    [self.navigationController pushViewController:search animated:YES];
}





-(void)viewDidUnload
{
/*Another awesome thing about NSFetchedResultsController is you an set it to nil upon viewDidUnload, which means that all of the data that is in memory can be freed up in low memory conditions (and the view is offscreen).
 如果视图不在屏幕里，所以数据会被冻结在低内存条件下
 
 */
    
    self.fetchedResultsController=nil;
}
#pragma mark -creating our fetched results controller!

-(NSFetchedResultsController*)fetchedResultsController{
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    //overRide =@property
    
    
    //1.获取结果条件，还有限制一次获取大小
    fetchRequest =[[NSFetchRequest alloc]init];
    NSEntityDescription*entity = [NSEntityDescription entityForName:@"FailedBankInfo" inManagedObjectContext:managedObjectContext];
    /*
     2. Not only can you sort on any property of the object you are returning
     but you can sort on properties of related objects
     相关对象的属性都可以排序筛选
     3.only receive the data in FailedBankInfo
     
     
     */
    NSSortDescriptor*sort=[NSSortDescriptor sortDescriptorWithKey:@"details.updateDate" ascending:NO];
    fetchRequest.entity=entity;
    fetchRequest.sortDescriptors=[NSArray arrayWithObject:sort];
    /*batchSize=批量大小,
     4.This way, the fetched results controller will only retrieve a subset of objects at a time from the underlying 2.database,  automatically fetch mroe as we scroll.
     */
    fetchRequest.fetchBatchSize=20;
    

    
    //2.设定非视图控制器的NSFetchedResultsController
    self.fetchedResultsController=[[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];//[self fetchRequest]不可以直接引用，要引用重写那个，
    self.fetchedResultsController.delegate=self;//这个委托方法好几个
    
    return self.fetchedResultsController;
    /*
  
     2.For the managed object context, we just pass in our context.
     3. The section name key path lets us sort the data into sections in our table view. We could sort the banks by State if we wanted to, for example, here.
     4.   The cacheName the name of the file the fetched results controller should use to cache any repeat work such as setting up sections and ordering contents.

     
     */
    
    
}
#pragma mark -NSFetchedResultControllerDelegate
/*
 NSFetchedResultController那个对象的可以控制筛选结果，除非=nil
 */

//1.表视图开始更新
-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
    //fetch Controller将要开始发送改变的消息
    //所以通知表视图准备更新
}
//2.筛选结果中，结果对象有改变-插入+删除+更新+移动位置
-(void)controller:(NSFetchedResultsController *)controller
  didChangeObject:(id)anObject
      atIndexPath:(NSIndexPath *)indexPath
    forChangeType:(NSFetchedResultsChangeType)type
     newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView*tableView =self.tableView;
    
    switch (type) {
            case NSFetchedResultsChangeInsert: //插入，根据indexPath来插入
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
            case NSFetchedResultsChangeDelete://删除
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
            break;
            
            case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
            case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
            
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
            
            break;
            
            
        default:
            break;
    }

}
//3.改变表视图的section,插入section,删除section,如果instagram的直接是这个
-(void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch (type) {
            case NSFetchedResultsChangeInsert://插入
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationRight];
            
            //NSIndexSet也是一种数组，不过是装index的
            break;
            
            case NSFetchedResultsChangeDelete://删除
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationRight];
            break;
            
            case NSFetchedResultsChangeMove://移动
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationRight];
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationRight];
            break;
            
            
            
            
            
            
        default:
            break;
    }

}
//4.表视图结束改变
-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    //
    [self.tableView endUpdates];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id sectionInfo = [[self.fetchedResultsController sections]objectAtIndex:section];
    
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    FailedBankInfo *info = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = info.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@",
                                 info.city, info.state];
}
#pragma mark -表视图委托

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;//允许编辑
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle==UITableViewCellEditingStyleDelete) {
        [managedObjectContext deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        //1.从筛选结果中删除对象 2.fetchedResultsController的委托会响应
        
        NSError *err;
        if (![managedObjectContext save:&err]) {
            NSLog(@"保存删除结果失败:%@",err);
            abort();
        }
    }
    if (editingStyle==UITableViewCellEditingStyleInsert) {
        [managedObjectContext insertObject: [self.fetchedResultsController objectAtIndexPath:indexPath]];
   //1.从筛选结果中删除对象 2.fetchedResultsController的委托会响应
        
        NSError *err;
        if (![managedObjectContext save:&err]) {
            NSLog(@"保存删除结果失败:%@",err);
            abort();
        }
    }

}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    FailedBankInfo *info =[self.fetchedResultsController objectAtIndexPath:indexPath];
    SMBankDetailViewController *SMBank =[[SMBankDetailViewController alloc]initWithBankInfo:info];
    
    [self.navigationController pushViewController:SMBank animated:YES];
}

@end
