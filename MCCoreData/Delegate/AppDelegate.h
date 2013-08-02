//
//  AppDelegate.h
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) PKSyncManager *syncManager;
- (void)setSyncEnabled:(BOOL)enabled;

@end
