//
//  SMBankDetailViewController.m
//  FuckCoreData
//
//  Created by name on 14年3月23日.
//  Copyright (c) 2014年 com.kapple. All rights reserved.
//

#import "SMBankDetailViewController.h"
#import "TagListViewController.h"

@interface SMBankDetailViewController ()

-(void)showPicker;
-(void)hidePicker;
@end

@implementation SMBankDetailViewController
-(id)initWithBankInfo:(FailedBankInfo *)info
{
    if (self=[super init]) {
        _bankInfo=info;
    }
    return self;
}
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
   
    self.title=self.bankInfo.name;
    
    //1.右键-保存
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                           target:self
                                                                                           action:@selector(saveBankInfo)];
    
    //2.当点击时间标签，picker弹起
    self.dateLabel.userInteractionEnabled=YES;
    UITapGestureRecognizer*tap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showPicker)];
    tap.numberOfTapsRequired=1;
    [self.dateLabel addGestureRecognizer:tap];
    
    //3.设置picker
    [self.datePicker addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventValueChanged];
    //process,还有picker们的触摸事件都是ValueChanged
    
    //4.点击tag标签，弹出tag控制器
    self.tagsLabel.userInteractionEnabled=YES;
    UITapGestureRecognizer*tagTap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pushTag)];
    tagTap.numberOfTapsRequired=1;
    [self.tagsLabel addGestureRecognizer:tagTap];
    
    //5.着色标签,时间
    // self.tagsLabel.backgroundColor = self.dateLabel.backgroundColor = [UIColor lightGrayColor];
    
}
#pragma mark -视图启动

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    self.nameField.text=self.bankInfo.name;
    self.cityField.text = self.bankInfo.city;
    self.zipField.text = [self.bankInfo.details.zip stringValue];
    self.stateField.text = self.bankInfo.state;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    self.dateLabel.text = [formatter stringFromDate:self.bankInfo.details.closeDate];
    
    }
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    //2.标签
    
    NSSet *tags = self.bankInfo.details.tag;
    NSMutableArray *tagNamesArray = [[NSMutableArray alloc] initWithCapacity:tags.count];
    for (Tag *tag in tags) {
        [tagNamesArray addObject:tag.name];
    }
    self.tagsLabel.text = [tagNamesArray componentsJoinedByString:@","];//用逗号隔开标签

}
#pragma mark -action-Target控件方法
-(void)showPicker{
    
    [self.zipField resignFirstResponder];
    [self.nameField resignFirstResponder];
    [self.stateField resignFirstResponder];
    [self.cityField resignFirstResponder];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.datePicker.transform=CGAffineTransformMakeTranslation(0, -320);
        //Y方向上升216
    } completion:^(BOOL finished) {
        //
    }];
}
-(void)hidePicker
{
    [UIView animateWithDuration:0.5 animations:^{
        self.datePicker.transform=CGAffineTransformMakeTranslation(0, 320);
    } completion:^(BOOL finished) {
        //
    }];
}

-(void)pushTag
{
    TagListViewController*tagList=[[TagListViewController alloc]initWithBankDetail:self.bankInfo.details];
    [self.navigationController pushViewController:tagList animated:YES];
    
}
-(void)saveBankInfo
{
    NSManagedObjectContext *CTX =self.bankInfo.managedObjectContext;
    _bankInfo.name=_nameField.text;
    _bankInfo.details.zip=[NSNumber numberWithInt: [_zipField.text intValue]];
     self.bankInfo.state = self.stateField.text;
    self.bankInfo.city = self.cityField.text;
    self.bankInfo.details.closeDate=self.datePicker.date;
    
    NSError*err;
    if ([CTX hasChanges]&&![CTX save:&err]) {
        NSLog(@"数据改变，数据保存-失败原因:%@，%@",err,[err userInfo]);
        
    }
    
    [self.navigationController popViewControllerAnimated:YES];//保存后淡出，数据已经在sql里面了
}

-(void)changeDate:(id)sender
{
    NSDateFormatter *Formatter =[[NSDateFormatter alloc]init];
//    [Formatter setDateFormat:<#(NSString *)#>]
    [Formatter setDateStyle:NSDateFormatterMediumStyle];
    self.dateLabel.text=[Formatter stringFromDate:self.datePicker.date];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
