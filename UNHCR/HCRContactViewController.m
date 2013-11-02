//
//  HCRContactViewController.m
//  UNHCR
//
//  Created by Sean Conrad on 11/1/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRContactViewController.h"
#import "HCRInformationCell.h"
#import "HCRTableFlowLayout.h"

////////////////////////////////////////////////////////////////////////////////

NSString *const kContactCellIdentifier = @"kContactCellIdentifier";
NSString *const kContactHeaderIdentifier = @"kContactHeaderIdentifier";
NSString *const kContactFooterIdentifier = @"kContactFooterIdentifier";

////////////////////////////////////////////////////////////////////////////////

@interface HCRContactViewController ()

@property NSArray *layoutData;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRContactViewController

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSParameterAssert(self.agencyDictionary);
    
    // LAYOUT META
    self.title = [self.agencyDictionary objectForKey:@"Abbr" ofClass:@"NSString"];
    
    NSMutableArray *mutableLayout = @[@"Agency Information"].mutableCopy;
    if ([self _contactStrings]) {
        [mutableLayout insertObject:@"Point of Contact" atIndex:0];
    }
    
    self.layoutData = mutableLayout;
    
    // LAYOUT AND REUSABLES
    HCRTableFlowLayout *tableLayout = (HCRTableFlowLayout *)self.collectionView.collectionViewLayout;
    NSParameterAssert([tableLayout isKindOfClass:[HCRTableFlowLayout class]]);
    
    [self.collectionView registerClass:[HCRInformationCell class]
            forCellWithReuseIdentifier:kContactCellIdentifier];
    
    [self.collectionView registerClass:[HCRHeaderView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:kContactHeaderIdentifier];
    
    [self.collectionView registerClass:[HCRFooterView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                   withReuseIdentifier:kContactFooterIdentifier];

}

#pragma mark - Class Methods

+ (UICollectionViewLayout *)preferredLayout {
    return [HCRTableFlowLayout new];
}

#pragma mark - UICollectionView Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.layoutData.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HCRInformationCell *infoCell = [collectionView dequeueReusableCellWithReuseIdentifier:kContactCellIdentifier
                                                                             forIndexPath:indexPath];
    
    infoCell.stringArray = ([self _sectionIsContactsSection:indexPath.section]) ? [self _contactStrings] : [self _overviewStrings];
    
    [infoCell setBottomLineStatusForCollectionView:collectionView atIndexPath:indexPath];
    
    return infoCell;
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        HCRHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                   withReuseIdentifier:kContactHeaderIdentifier
                                                                          forIndexPath:indexPath];
        
        header.titleString = [self.layoutData objectAtIndex:indexPath.section ofClass:@"NSString"];
        
        return header;
        
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        
        HCRFooterView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                   withReuseIdentifier:kContactFooterIdentifier
                                                                          forIndexPath:indexPath];
        
        return footer;
        
    }
    
    return nil;
    
}

#pragma mark - UICollectionView Delegate Flow Layout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return [HCRHeaderView preferredHeaderSizeForCollectionView:collectionView];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    
    CGSize preferredSize;
    
    if (section == [collectionView numberOfSections] - 1) {
        preferredSize = [HCRFooterView preferredFooterSizeForCollectionView:collectionView];
    } else {
        preferredSize = [HCRFooterView preferredFooterSizeWithBottomLineOnlyForCollectionView:collectionView];
    }
    
    return preferredSize;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *stringArray = ([self _sectionIsContactsSection:indexPath.section]) ? [self _contactStrings] : [self _overviewStrings];
    
    return [HCRInformationCell sizeForItemInCollectionView:collectionView withStringArray:stringArray];
    
}

#pragma mark - Private Methods

- (NSArray *)_contactStrings {
    
    NSDictionary *contactDictionary = [self.agencyDictionary objectForKey:@"Contact" ofClass:@"NSDictionary" mustExist:NO];
    if (contactDictionary) {
        NSMutableArray *contactsArray = @[].mutableCopy;
        
        NSString *name = [contactDictionary objectForKey:@"Name" ofClass:@"NSString" mustExist:NO];
        NSString *phone = [contactDictionary objectForKey:@"Phone" ofClass:@"NSString" mustExist:NO];
        NSString *email = [contactDictionary objectForKey:@"Email" ofClass:@"NSString" mustExist:NO];
        
        if (name) {
            [contactsArray addObject:name];
        }
        
        if (phone) {
            [contactsArray addObject:phone];
        }
        
        if (email) {
            [contactsArray addObject:email];
        }
        
        return contactsArray;
        
    } else {
        return nil;
    }
    
}

- (NSArray *)_overviewStrings {
    
    NSMutableArray *overviewStrings = @[].mutableCopy;
    
    NSString *name = [self.agencyDictionary objectForKey:@"Agency" ofClass:@"NSString" mustExist:NO];
    NSString *about = [self.agencyDictionary objectForKey:@"About" ofClass:@"NSString" mustExist:NO];
    NSString *website = [self.agencyDictionary objectForKey:@"Website" ofClass:@"NSString" mustExist:NO];
    
    if (name) {
        [overviewStrings addObject:name];
    }
    
    if (about) {
        [overviewStrings addObject:about];
    }
    
    if (website) {
        [overviewStrings addObject:website];
    }
    
    return overviewStrings;
    
}

- (BOOL)_sectionIsContactsSection:(NSInteger)section {
    return (self.layoutData.count > 1 && section == 0);
}

@end
