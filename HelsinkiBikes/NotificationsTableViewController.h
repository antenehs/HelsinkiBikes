//
//  FilterTableViewController.h
//  HelsinkiBikes
//
//  Created by Anteneh Sahledengel on 5/5/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StaticDataTableViewController.h"

@interface NotificationsTableViewController : StaticDataTableViewController<UIPickerViewDelegate, UIPickerViewDataSource> {
    
    IBOutlet UILabel *enableNotificationLabel;
    IBOutlet UISwitch *enableNotifSwitch;
    IBOutlet UILabel *defaultNotifLabel;
    IBOutlet UILabel *customNotifLabel;
    IBOutlet UIPickerView *customNotifPicker;
    
    IBOutlet UITableViewCell *defaultNotifCell;
    IBOutlet UITableViewCell *customNotifCell;
    IBOutlet UITableViewCell *customnotifPickerCell;
    
    IBOutletCollection(UITableViewCell) NSArray *allNotifsCells;
    
    BOOL isCustomNotifications;
    NSDictionary *customeNotifValues;
    NSArray *pickerDataOptions;
}

@end
