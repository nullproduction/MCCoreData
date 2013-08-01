//
//  ViewController.h
//

#import <UIKit/UIKit.h>
#import "MCCoreData.h"
#import "Models.h"

@interface ViewController : UITableViewController
<NSFetchedResultsControllerDelegate>

- (IBAction)insert:(id)sender;

@property (nonatomic, retain) NSMutableArray *data;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end
