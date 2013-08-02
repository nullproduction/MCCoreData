//
//  SettingsViewController.h
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface SettingsViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UISwitch *syncSwitch;

- (IBAction)toggleSyncAction:(id)sender;


@end
