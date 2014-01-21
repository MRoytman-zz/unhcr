//
//  HCRAlertListViewController.m
//  UNHCR
//
//  Created by Sean Conrad on 1/20/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRAlertListViewController.h"
#import "HCRTableFlowLayout.h"
#import "HCRAlertComposeViewController.h"

////////////////////////////////////////////////////////////////////////////////

@interface HCRAlertListViewController ()

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRAlertListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = @"Alerts";
    
    // BAR BUTTONS
    if ([HCRUser currentUser].canSendAlerts) {
        
        UIBarButtonItem *composeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                       target:self
                                                                                       action:@selector(_composeButtonPressed)];
        [self.navigationItem setRightBarButtonItem:composeButton];
        
    }
    
}

#pragma mark - Class Methods

+ (UICollectionViewLayout *)preferredLayout {
    return [[HCRTableFlowLayout alloc] init];
}

#pragma mark - Private Methods

- (void)_composeButtonPressed {
    
    HCRAlertComposeViewController *alertCompose = [[HCRAlertComposeViewController alloc] initWithCollectionViewLayout:[HCRAlertComposeViewController preferredLayout]];
    
    [self.navigationController presentViewController:alertCompose animated:YES completion:nil];
    
}

@end
