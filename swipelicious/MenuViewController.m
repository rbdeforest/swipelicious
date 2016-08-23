#import "MenuViewController.h"
#import "MainViewController.h"

#import "ECSlidingViewController.h"
#import <SDWebImage/SDWebImageManager.h>

#import "swipelicious-Swift.h"

@interface MenuViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imgvPhoto;
@property (weak, nonatomic) IBOutlet UILabel *lblName;

@end

@implementation MenuViewController

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    [self.navigationController setNavigationBarHidden: true animated: true];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.slidingViewController setAnchorRightRevealAmount: SCREEN_WIDTH - 50];
    self.slidingViewController.underLeftWidthLayout = ECFullWidth;

    User* currentUser = [[AppSession sharedInstance] user];
    _lblName.text = @"";
    _lblName.text = [NSString stringWithFormat: @"%@ %@", currentUser.profile.first_name, currentUser.profile.last_name];
    
    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:currentUser.profile.photo] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (image) {
            [self.imgvPhoto setImage: image];
        }
    }];
}

- (IBAction)onBtnSubmitRecipe:(id)sender {
    
    NSString *messagebody;
    
    messagebody = @"";
    //    NSLog(@"%@" , messagebody);
    
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setSubject:@"Recipe Submission"];
        [mail setMessageBody:messagebody isHTML:NO];
        [mail setToRecipients:@[@"contact@swipelicious.com"]];
        
        [self presentViewController:mail animated:YES completion:NULL];
    }
    else
    {
        NSLog(@"This device cannot send email");
    }
}

- (IBAction)onBtnSignOut:(id)sender {
    
    [login logOut];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"" forKey:@"userfacebookid"];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)onBtnContactUs:(id)sender {
    
    NSString *messagebody;
    
    messagebody = @"";
    //    NSLog(@"%@" , messagebody);
    
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setSubject:@"Recipes App Submission"];
        [mail setMessageBody:messagebody isHTML:NO];
        [mail setToRecipients:@[@"contact@swipelicious.com"]];
        
        [self presentViewController:mail animated:YES completion:NULL];
    }
    else
    {
        NSLog(@"This device cannot send email");
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultSent:
            NSLog(@"You sent the email.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"You saved a draft of this email");
            break;
        case MFMailComposeResultCancelled:
            NSLog(@"You cancelled sending this email.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed:  An error occurred when trying to compose this email");
            break;
        default:
            NSLog(@"An error occurred when trying to compose this email");
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end