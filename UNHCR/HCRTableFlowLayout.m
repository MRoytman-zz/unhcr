//
//  HCRTableFlowLayout.m
//  UNHCR
//
//  Created by Sean Conrad on 9/30/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRTableFlowLayout.h"

////////////////////////////////////////////////////////////////////////////////

CGFloat const kTableCellHeight = 44;
CGFloat const kTableCellSingleLineHeight = 34;
CGFloat const kTableCellDoubleLineHeight = 54;

////////////////////////////////////////////////////////////////////////////////

@interface HCRTableFlowLayout ()

//@property UIDynamicAnimator *dynamicAnimator;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRTableFlowLayout

- (void)prepareLayout {
    
    // set initial values of stuff
    
    [super prepareLayout];
    
    // set vars only if not set by owner
    if ( CGSizeEqualToSize(self.itemSize, CGSizeMake(50.0, 50.0)) ) {
        self.itemSize = CGSizeMake(CGRectGetWidth(self.collectionView.bounds),
                                   kTableCellHeight);
    }
    
    self.minimumInteritemSpacing = (self.minimumInteritemSpacing != 0) ? self.minimumInteritemSpacing :  0;
    self.minimumLineSpacing = (self.minimumLineSpacing != 0) ? self.minimumLineSpacing :  0;
    
//    if ( !self.dynamicAnimator ) {
//        self.dynamicAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
//        
//        // grab all items in collection - NOTE: may be lots of items
//        CGSize contentSize = [self collectionViewContentSize];
//        NSArray *items = [super layoutAttributesForElementsInRect:CGRectMake(0, 0, contentSize.width, contentSize.height)];
//        
//        for (UICollectionViewLayoutAttributes *item in items) {
//            
//            UIAttachmentBehavior *spring = [[UIAttachmentBehavior alloc] initWithItem:item attachedToAnchor:item.center];
//            spring.length = 0;
//            spring.damping = 0.5;
//            spring.frequency = 0.8;
//            
//            [self.dynamicAnimator addBehavior:spring];
//        }
//        
//    }
    
}

//- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
//    return [self.dynamicAnimator itemsInRect:rect];
//}
//
//- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
//    return [self.dynamicAnimator layoutAttributesForCellAtIndexPath:indexPath];
//}
//
//- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
//    UIScrollView *scrollView = self.collectionView;
//    CGFloat scrollDelta = newBounds.origin.y - scrollView.bounds.origin.y;
//    CGPoint touchLocation = [scrollView.panGestureRecognizer locationInView:scrollView];
//    
//    for (UIAttachmentBehavior *spring in self.dynamicAnimator.behaviors) {
//        CGPoint anchorPoint = spring.anchorPoint;
//        CGFloat distanceFromTouch = fabsf(touchLocation.y - anchorPoint.y);
//        CGFloat scrollResistance = distanceFromTouch / 500;
//        
//        UICollectionViewLayoutAttributes *item = [spring.items firstObject];
//        CGPoint center = item.center;
//        if (scrollDelta < 0) {
//            center.y += MAX(scrollDelta, scrollDelta * scrollResistance);
//        } else {
//            center.y += MIN(scrollDelta, scrollDelta * scrollResistance);
//        }
//        item.center = center;
//        
//        [self.dynamicAnimator updateItemUsingCurrentState:item];
//    }
//    
//    return NO;
//    
//}

#pragma mark - Class Methods

+ (CGSize)preferredTableFlowCellSizeForCollectionView:(UICollectionView *)collectionView {
    return CGSizeMake(CGRectGetWidth(collectionView.bounds),
                      kTableCellHeight);
}

+ (CGSize)preferredTableFlowSingleLineCellSizeForCollectionView:(UICollectionView *)collectionView {
    return CGSizeMake(CGRectGetWidth(collectionView.bounds),
                      kTableCellSingleLineHeight);
}

+ (CGSize)preferredTableFlowDoubleLineCellSizeForCollectionView:(UICollectionView *)collectionView {
    return CGSizeMake(CGRectGetWidth(collectionView.bounds),
                      kTableCellDoubleLineHeight);
}

@end
