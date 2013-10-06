//
//  HCRTallySheetInputViewController.m
//  UNHCR
//
//  Created by Sean Conrad on 10/6/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRTallySheetDetailInputViewController.h"
#import "HCRTableFlowLayout.h"

////////////////////////////////////////////////////////////////////////////////

@interface HCRTallySheetDetailInputViewController ()

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRTallySheetDetailInputViewController

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
}

#pragma mark - Class Methods

+ (UICollectionViewLayout *)preferredLayout {
    return [[HCRTableFlowLayout alloc] init];
}

@end
