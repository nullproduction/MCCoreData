//
//  ViewController.h
//

#import <UIKit/UIKit.h>
#import "Models.h"

@interface ViewController : UITableViewController
<NSFetchedResultsControllerDelegate>

- (IBAction)insert:(id)sender;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end
