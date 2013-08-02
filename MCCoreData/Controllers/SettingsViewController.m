//
//  SettingsViewController.m
//

#import "SettingsViewController.h"

@implementation SettingsViewController

- (void)viewDidLoad
{
    // Super
    [super viewDidLoad];
    
    // Title
    self.navigationItem.title  = NSLocalizedString(@"Settings", nil);
}

/*
 * Will Appear
 */
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.syncSwitch.on = [[DBAccountManager sharedManager] linkedAccount] != nil;
}


/*
 * Toggle sync action
 */
- (IBAction)toggleSyncAction:(id)sender
{
    DBAccountManager *accountManager = [DBAccountManager sharedManager];
    DBAccount *account = [accountManager linkedAccount];
    
    if ([sender isOn]) {
        if (!account) {
            [accountManager addObserver:self block:^(DBAccount *account) {
                if ([account isLinked]) {
                    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
                    [delegate setSyncEnabled:YES];
                }
            }];
            
            [[DBAccountManager sharedManager] linkFromController:self];
        }
    } else {
        AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        [delegate setSyncEnabled:NO];
        [account unlink];
    }
}


@end