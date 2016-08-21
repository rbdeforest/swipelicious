#import "InitialSlidingViewController.h"

#import "HomeNavigationController.h"

@interface InitialSlidingViewController ()

@end

@implementation InitialSlidingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        //        self.shouldAdjustChildViewHeightForStatusBar = YES;
        //        self.statusBarBackgroundView.backgroundColor = [UIColor blackColor];
    }
    
    self.topViewController = (HomeNavigationController*)[STORYBOARD instantiateViewControllerWithIdentifier: @"HomeNavigationController"];
    self.shouldAddPanGestureRecognizerToTopViewSnapshot = YES;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    self.navigationController.navigationBarHidden = true;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
