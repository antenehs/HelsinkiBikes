//
//  SettingTableViewController.h
//  HelsinkiBikes
//
//  Created by Anteneh Sahledengel on 5/5/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface MoreTableViewController : UITableViewController<UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {
    
    IBOutlet UILabel *aboutBikesLabel;
    IBOutlet UILabel *notificationsLabel;
    IBOutlet UILabel *contactMeLabel;
    IBOutlet UILabel *tellAFriendLabel;
    IBOutlet UILabel *rateLabel;
}

@end
