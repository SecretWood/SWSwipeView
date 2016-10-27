//
//  SWSwipeView.h
//  SWSwipeViewDeom
//
//  Created by EShi on 10/19/16.
//  Copyright © 2016 Eren. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SWSwipeView;
@protocol SWSwipeViewDataSource <NSObject>

- (NSInteger)numberOfPagesInSwipeView:(SWSwipeView *)swipeView;
- (UIView *)swipeView:(SWSwipeView *)swipeView viewForPageAtIndex:(NSInteger)index resuingView:(UIView *)resuingView;

@end

@interface SWSwipeView : UIView
@property(nonatomic, assign, readonly) NSInteger numberOfItems;
@property(nonatomic, assign, readonly) NSInteger currentIndex;
@property(nonatomic, weak) id<SWSwipeViewDataSource> dataSource;

- (UIView *)viewForItemAtIndex:(NSInteger)index;
- (void)scrollToIndex:(NSInteger) index duration:(NSTimeInterval)duration;

- (void)reloadData;
- (void)reloadDataAtIndex:(NSInteger) index;
@end
