#import "MenuViewController.h"
#import "MainViewController.h"

#import "ECSlidingViewController.h"
#import <SDWebImage/SDWebImageManager.h>

#import "swipelicious-Swift.h"
#import "FriendsViewController.h"
#import "HomeNavigationController.h"

@interface MenuViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imgvPhoto;
@property (weak, nonatomic) IBOutlet UILabel *lblName;

@end

@implementation MenuViewController

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel identify: [[NSUserDefaults standardUserDefaults] stringForKey: @"userfacebookid"]];
    [mixpanel.people increment:USER_CLICKED_TOP_LEFT_MENU by:@1];
    [mixpanel track: USER_CLICKED_TOP_LEFT_MENU];
    
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
    
    if (currentUser.fbid != nil && ![currentUser.fbid isEqualToString:@""]) {
        NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", currentUser.fbid]];
        
        SDWebImageDownloader *downloader = [[SDWebImageManager sharedManager] imageDownloader];
        
        [downloader downloadImageWithURL:imageURL options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
            if (image) {
                self.imgvPhoto.contentMode = UIViewContentModeScaleAspectFit;
                [self.imgvPhoto setImage: image];
            }
        }];
        
    }
    
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
        [mail setToRecipients:@[@"contact@sousrecipes.com"]];
        
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


- (IBAction)onBtnFriends:(id)sender {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel identify: [[NSUserDefaults standardUserDefaults] stringForKey: @"userfacebookid"]];
    [mixpanel.people increment:USER_CLICKED_MY_FRIENDS by:@1];
    [mixpanel track: USER_CLICKED_MY_FRIENDS];
    
    FriendsViewController *friendsVC = (FriendsViewController*)[STORYBOARD instantiateViewControllerWithIdentifier: @"FriendsViewController"];
    
    [(HomeNavigationController *)self.slidingViewController.topViewController pushViewController:friendsVC animated:YES];
    [self.slidingViewController resetTopView];
}

- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didCompleteWithResults:(NSDictionary *)results{
    NSLog(@"%@", results);
}

- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didFailWithError:(NSError *)error{
    NSLog(@"%@", error);
}


- (IBAction)onBtnInvite:(id)sender {    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel identify: [[NSUserDefaults standardUserDefaults] stringForKey: @"userfacebookid"]];
    [mixpanel.people increment:USER_CLICKED_INVITE_FRIENDS by:@1];
    [mixpanel track: USER_CLICKED_INVITE_FRIENDS];
    
    
    FBSDKAppInviteContent *content =[[FBSDKAppInviteContent alloc] init];
    content.appLinkURL = [NSURL URLWithString:kShareAppURL];
    
    [FBSDKAppInviteDialog showFromViewController:self
                                     withContent:content
                                        delegate:self];
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
        [mail setToRecipients:@[@"contact@sousrecipes.com"]];
        
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
