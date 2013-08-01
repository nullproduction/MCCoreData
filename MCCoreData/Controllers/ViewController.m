//
//  ViewController.m
//

#import "ViewController.h"


@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (NSManagedObjectContext *)managedObjectContext
{
    return [MCCoreDataManager sharedManager].managedObjectContext;
}

- (IBAction)insert:(id)sender
{
    // People entity
    People *people = (People *)[NSEntityDescription insertNewObjectForEntityForName:@"People" inManagedObjectContext:self.managedObjectContext];
    people.name = @"Alex";
    people.age = @23;
    
    // Network
    NSMutableSet* networks = [NSMutableSet set];
    for (NSString *url in @[@"http://facebook.com", @"http://vk.com"])
    {
        Network *network = (Network *)[NSEntityDescription insertNewObjectForEntityForName:@"Network" inManagedObjectContext:self.managedObjectContext];
        network.url = url;
        [networks addObject:network];
    }
    
    // Add networks
    [people addNetworks:networks];
    
    // Save
    [self.managedObjectContext save:nil];
}

- (IBAction)fetch:(id)sender
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"People"];
    NSArray *peoples = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    for (People *people in peoples)
    {
        for (Network *network in people.networks)
        {
            NSLog(@"%@", network.url);
        }
    }
}

@end
