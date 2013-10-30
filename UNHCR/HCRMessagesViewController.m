//
//  HCRMessagesViewController.m
//  UNHCR
//
//  Created by Sean Conrad on 10/29/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRMessagesViewController.h"

////////////////////////////////////////////////////////////////////////////////

@interface HCRMessagesViewController ()

@property NSArray *messagesArray;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRMessagesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.messagesArray = [HCRDataSource globalMessagesData];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}



@end
