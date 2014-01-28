//
//  ViewController.h
//  instaGramSDKSample
//
//  Created by Mac Book on 23/01/14.
//  Copyright (c) 2014 Gourav Gupta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface ViewController : UIViewController<UIWebViewDelegate,IGSessionDelegate>
{
    UIWebView *webView;
    UIView *loginBackView;
    UIButton *btnCancle;
    AppDelegate* appDelegate;
}
@end
