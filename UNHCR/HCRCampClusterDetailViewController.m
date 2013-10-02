//
//  HCRCampClusterDetailViewController.m
//  UNHCR
//
//  Created by Sean Conrad on 10/2/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRCampClusterDetailViewController.h"

@interface HCRCampClusterDetailViewController ()

@end

@implementation HCRCampClusterDetailViewController

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
    
    NSParameterAssert(self.clusterDictionary);
    NSParameterAssert(self.campDictionary);
    
    self.title = [self.clusterDictionary objectForKey:@"Name"];
    self.view.backgroundColor = [UIColor whiteColor];
    self.collectionView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.85];
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:backgroundImageView];
    [self.view sendSubviewToBack:backgroundImageView];
    
    UIImage *clusterImage = [UIImage imageNamed:[self.clusterDictionary objectForKey:@"Image"]];
    backgroundImageView.image = [clusterImage colorImage:[UIColor UNHCRBlue] withBlendMode:kCGBlendModeNormal withTransparency:YES];
    backgroundImageView.backgroundColor = [UIColor whiteColor];
    backgroundImageView.alpha = 0.7;
    
    backgroundImageView.clipsToBounds = YES;
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    
}

@end
