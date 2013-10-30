//
//  HCRCampCollectionCell.m
//  UNHCR
//
//  Created by Sean Conrad on 9/30/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRCampCollectionCell.h"

////////////////////////////////////////////////////////////////////////////////

@interface HCRCampCollectionCell ()

@property UILabel *campNameLabel;
@property UIButton *disclosureButton;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRCampCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)prepareForReuse {
    self.campDictionary = nil;
}

#pragma mark - Getters & Setters

- (void)setCampDictionary:(NSDictionary *)campDictionary {
    
    _campDictionary = campDictionary;
    
    if ( campDictionary == nil ) {
        [self.campNameLabel removeFromSuperview];
        self.campNameLabel = nil;
        
        [self.disclosureButton removeFromSuperview];
        self.disclosureButton = nil;
        
        return;
    }
    
    if ( !self.campNameLabel && campDictionary ) {
        
        CGFloat xPadding = 8;
        CGRect campLabelFrame = CGRectMake(xPadding,
                                           0,
                                           CGRectGetWidth(self.bounds) - 2 * xPadding,
                                           CGRectGetHeight(self.bounds));
        
        self.campNameLabel = [[UILabel alloc] initWithFrame:campLabelFrame];
        [self addSubview:self.campNameLabel];
        
    }
    
    NSString *name = [campDictionary objectForKey:@"Name"];
    
    NSDictionary *titleAttributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18]};
    NSMutableAttributedString *campLabelString = [[NSMutableAttributedString alloc] initWithString:name
                                                                                        attributes:titleAttributes];
    
    NSNumber *persons = [campDictionary objectForKey:@"Persons"];
    if (persons) {
        
        self.campNameLabel.numberOfLines = 2;

        // format number
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.usesGroupingSeparator = YES;
        formatter.groupingSeparator = [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator];
        formatter.groupingSize = 3;
        
        NSString *personString = [NSString stringWithFormat:@"\n%@ displaced persons",
                                  [formatter stringFromNumber:persons]];
        
        NSDictionary *subtitleAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:15],
                                             NSForegroundColorAttributeName: [UIColor darkGrayColor]};
        NSAttributedString *personAttributedString = [[NSAttributedString alloc] initWithString:personString
                                                                                     attributes:subtitleAttributes];
        [campLabelString appendAttributedString:personAttributedString];
        
    }
    
    self.campNameLabel.attributedText = campLabelString;
    
    if ([HCRDataSource globalEmergenciesData].count > 0) {
        
        BOOL showDisclosure = NO;
        
        for (NSDictionary *alertsDictionary in [HCRDataSource globalEmergenciesData]) {
            
            NSString *alertCamp = [alertsDictionary objectForKey:@"Camp" ofClass:@"NSString"];
            if ([alertCamp isEqualToString:name]) {
                showDisclosure = YES;
                break;
            }
            
        }
        
        if (showDisclosure) {
            
            if (!self.disclosureButton) {
                self.disclosureButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
                [self addSubview:self.disclosureButton];
                
                self.disclosureButton.tintColor = [UIColor redColor];
                self.disclosureButton.userInteractionEnabled = NO;
            }
            
            self.disclosureButton.center = CGPointMake(CGRectGetMaxX(self.bounds) - CGRectGetMidX(self.disclosureButton.bounds) - 8,
                                                       CGRectGetMidY(self.bounds));
        }
        
    }
    
}

@end
