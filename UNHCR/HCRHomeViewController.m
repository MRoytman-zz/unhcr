//
//  HCRHomeViewController.m
//  UNHCR
//
//  Created by Sean Conrad on 10/2/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRHomeViewController.h"
#import "HCRCountryCollectionViewController.h"
#import "HCRTableFlowLayout.h"

////////////////////////////////////////////////////////////////////////////////

@interface HCRHomeViewController ()

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.view.backgroundColor = [UIColor whiteColor];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = @"Home";
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    CGFloat yPadding = 20;
    CGFloat xPadding = 20;
    
    // title label
    CGRect titleLabelFrame = CGRectMake(xPadding,
                                        [UIApplication sharedApplication].statusBarFrame.size.height + yPadding,
                                        200,
                                        80);
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleLabelFrame];
    [self.view addSubview:titleLabel];
    
//    titleLabel.backgroundColor = [UIColor greenColor];
    
    titleLabel.numberOfLines = 3;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineHeightMultiple = 0.8;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSDictionary *titleAttributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:24],
                                      NSParagraphStyleAttributeName: paragraphStyle};
    
    NSAttributedString *attributedTitleString = [[NSAttributedString alloc] initWithString:@"Refugee\nInformation\nService"
                                                                                attributes:titleAttributes];
    titleLabel.attributedText = attributedTitleString;
    
    // subtitle label
    CGRect subtitleLabelFrame = CGRectMake(xPadding,
                                           CGRectGetMaxY(titleLabel.frame),
                                           CGRectGetWidth(self.view.bounds) - 2 * xPadding,
                                           44);
    UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:subtitleLabelFrame];
    [self.view addSubview:subtitleLabel];

    subtitleLabel.numberOfLines = 2;
    
    NSDictionary *subtitleAttributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:18],
                                         NSParagraphStyleAttributeName: paragraphStyle};
    
    NSAttributedString *attributedSubtitleString = [[NSAttributedString alloc] initWithString:@"Camp Services App\nfor Humanitarian Aid Providers"
                                                                                   attributes:subtitleAttributes];
    
    subtitleLabel.attributedText = attributedSubtitleString;
    
    // body label
    CGRect bodyLabelFrame = CGRectMake(xPadding,
                                       CGRectGetMaxY(subtitleLabel.frame) + 4,
                                       CGRectGetWidth(self.view.bounds) - 2 * xPadding,
                                       164);
    UILabel *bodyLabel = [[UILabel alloc] initWithFrame:bodyLabelFrame];
    [self.view addSubview:bodyLabel];
    
    bodyLabel.numberOfLines = 0;
    
    NSMutableParagraphStyle *bodyParagraph = paragraphStyle.mutableCopy;
    bodyParagraph.lineHeightMultiple = 1.05;
    
    NSDictionary *bodyAttributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:12],
                                     NSParagraphStyleAttributeName: bodyParagraph};
    
    NSDictionary *boldAttributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:12]};
    
    NSMutableAttributedString *attributedBodyString = [[NSMutableAttributedString alloc] initWithString:@"The Camp Services App system allows Humanitarian Aid Providers to view realtime and aggregated Refugee request information directly on their mobile phones, as well as view contact information for all camp-affiliated NGO and UN actors working in the camp to better coordinate and maximize the impact of any intervention. Centralizing this information opens up a new level of cross-Cluster collaboration and maximizes the effect of all interventions throughout the camp."
                                                                                                 attributes:bodyAttributes];
    
    [attributedBodyString setAttributes:boldAttributes range:NSMakeRange(3, 18)];
    
    bodyLabel.attributedText = attributedBodyString;
    
    // country button
    CGFloat buttonPadding = 6;
    CGFloat buttonHeight = 50;
    
    CGFloat yButtonOffset = (self.view.bounds.size.height - CGRectGetMaxY(bodyLabel.frame) - (buttonHeight * 2 + buttonPadding)) * 0.5;
    
    UIButton *countryButton = [UIButton buttonWithUNHCRTextStyleWithString:@"Countries"
                                                       horizontalAlignment:UIControlContentHorizontalAlignmentCenter
                                                                buttonSize:CGSizeMake(200, buttonHeight)
                                                                  fontSize:nil];
    [self.view addSubview:countryButton];
    
    countryButton.center = CGPointMake(CGRectGetMidX(self.view.bounds),
                                       CGRectGetMaxY(bodyLabel.frame) + MIN(yButtonOffset,30) + CGRectGetMidY(countryButton.bounds));
    
    [countryButton addTarget:self
                      action:@selector(_countryButtonPressed)
            forControlEvents:UIControlEventTouchUpInside];
    
    // camps button
    UIButton *campsButton = [UIButton buttonWithUNHCRTextStyleWithString:@"Camps"
                                                     horizontalAlignment:UIControlContentHorizontalAlignmentCenter
                                                              buttonSize:CGSizeMake(170, buttonHeight)
                                                                fontSize:nil];
    [self.view addSubview:campsButton];
    
    campsButton.center = CGPointMake(CGRectGetMidX(self.view.bounds),
                                     CGRectGetMaxY(countryButton.frame) + buttonPadding + CGRectGetMidY(campsButton.bounds));
    
    [campsButton addTarget:self
                    action:@selector(_campsButtonPressed)
          forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

#pragma mark - Private Methods

- (void)_countryButtonPressed {
    
    HCRCountryCollectionViewController *countryCollection = [[HCRCountryCollectionViewController alloc] initWithCollectionViewLayout:[HCRCountryCollectionViewController preferredLayout]];
    
    [self.navigationController pushViewController:countryCollection animated:YES];
    
}

- (void)_campsButtonPressed {
    
    //
    
}

@end