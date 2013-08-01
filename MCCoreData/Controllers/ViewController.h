//
//  ViewController.h
//

#import <UIKit/UIKit.h>
#import "MCCoreData.h"
#import "Models.h"

@interface ViewController : UIViewController
<NSFetchedResultsControllerDelegate>

- (IBAction)insert:(id)sender;
- (IBAction)fetch:(id)sender;

@end
