//
//  SMBankDetailViewController.h
//  FuckCoreData
//
//  Created by name on 14年3月23日.
//  Copyright (c) 2014年 com.kapple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FailedBankInfo.h"
#import "FailedBankDetail.h"
@interface SMBankDetailViewController : UIViewController



@property (nonatomic, weak) IBOutlet UITextField *nameField;
@property (nonatomic, weak) IBOutlet UITextField *cityField;
@property (nonatomic, weak) IBOutlet UITextField *zipField;
@property (nonatomic, weak) IBOutlet UITextField *stateField;
@property (nonatomic, weak) IBOutlet UILabel *tagsLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UIDatePicker *datePicker;


@property (nonatomic, strong) FailedBankInfo *bankInfo;
-(id)initWithBankInfo:(FailedBankInfo *) info;
@end
