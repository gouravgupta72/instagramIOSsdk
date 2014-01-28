//
//  ViewController.m
//  instaGramSDKSample
//
//  Created by Mac Book on 23/01/14.
//  Copyright (c) 2014 Gourav Gupta. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Instagram.h"
static NSString* kDialogBaseURL = @"https://instagram.com/";
static NSString* kLogin = @"oauth/authorize";

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
- (IBAction)loginAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnLogOut;
- (IBAction)logOutAction:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad
{
    appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    appDelegate.instagram = [[Instagram alloc] initWithClientId:APP_ID delegate:self];
    
    // here i can set accessToken received on previous login
    appDelegate.instagram.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"];
    appDelegate.instagram.sessionDelegate = self;
  
    [super viewDidLoad];
    
    self.btnLogin.hidden = NO;
    self.btnLogOut.hidden = YES;
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)createLoginPage
{
    btnCancle = [[UIButton alloc]init];
    
    UIImageView *topView=[[UIImageView alloc]init];
    
    webView=[[UIWebView alloc]init];
    
              loginBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 10, 320, 440)];
            [self.view addSubview:loginBackView];
            
            btnCancle.frame=CGRectMake(285,5, 30, 30);
            [btnCancle setImage:[UIImage imageNamed:@"cross_iphone"] forState:UIControlStateNormal];
            
            topView.frame=CGRectMake(0, 0, CGRectGetWidth(loginBackView.frame), 40);
            topView.image=[UIImage imageNamed:@"TopBar.png"];
    
            webView.frame= CGRectMake(0, 40,CGRectGetWidth(loginBackView.frame),CGRectGetHeight(loginBackView.frame)-40);

    loginBackView.layer.borderWidth=3.0f;
    loginBackView.layer.cornerRadius=5.0f;
    loginBackView.layer.borderColor=[UIColor colorWithRed:170.0/255.0 green:170.0/255.0 blue:170.0/255.0 alpha:1.0].CGColor;
    loginBackView.layer.masksToBounds=YES;
    
    
    webView.delegate=self;
    [loginBackView addSubview:webView];
    
    [loginBackView addSubview:topView];
    
    [btnCancle addTarget:self
                  action:@selector(removWebView)
        forControlEvents:UIControlEventTouchUpInside];
    
    [loginBackView addSubview:btnCancle];
    
    [self login];
}

-(void)login
{
    appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    [self authorize:[NSArray arrayWithObjects:@"comments", @"likes", nil]];
}


-(void)authorize:(NSArray *)scopes
{
    [self authorizeinWebView :scopes];
}

- (void)authorizeinWebView :(NSArray *)scop
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   APP_ID, @"client_id",
                                   @"token", @"response_type",
                                   [NSString stringWithFormat:@"ig%@://authorize", APP_ID], @"redirect_uri",
                                   nil];
    
    NSString *loginDialogURL = [kDialogBaseURL stringByAppendingString:kLogin];
    
    if (scop != nil)
    {
        NSString* scope = [scop componentsJoinedByString:@"+"];
        [params setValue:scope forKey:@"scope"];
    }
    
    
    NSString *igAppUrl = [IGRequest serializeURL:loginDialogURL params:params];
    
    webView.userInteractionEnabled = YES;
    [webView loadRequest:[[NSURLRequest alloc] initWithURL:[[NSURL alloc]   initWithString:igAppUrl]]];
}


-(void)removWebView
{
    if ([loginBackView isDescendantOfView:self.view])
    {
        [loginBackView removeFromSuperview];
        loginBackView=nil;
    }
}

#pragma - IGSessionDelegate

-(void)igDidLogin
{
    self.btnLogin.hidden = YES;
    self.btnLogOut.hidden = NO;
    [self removWebView];
    NSLog(@"Instagram did login");
    // here i can store accessToken
    appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [[NSUserDefaults standardUserDefaults] setObject:appDelegate.instagram.accessToken forKey:@"accessToken"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)igDidNotLogin:(BOOL)cancelled
{
    self.btnLogin.hidden = NO;
    self.btnLogOut.hidden = YES;
    
    [self removWebView];
    NSLog(@"Instagram did not login");
    NSString* message = nil;
    if (cancelled) {
        message = @"Access cancelled!";
    } else {
        message = @"Access denied!";
    }
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [alertView show];
}

-(void)igDidLogout
{
    self.btnLogin.hidden = NO;
    self.btnLogOut.hidden = YES;
    
    NSLog(@"Instagram did logout");
    // remove the accessToken
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"accessToken"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)igSessionInvalidated
{
    NSLog(@"Instagram session was invalidated");
}


- (IBAction)loginAction:(id)sender
{
      [self createLoginPage];
}
- (IBAction)logOutAction:(id)sender
{
    [appDelegate.instagram logout];
}
@end
