//
//  SWSwipeView.m
//  SWSwipeViewDeom
//
//  Created by EShi on 10/19/16.
//  Copyright © 2016 Eren. All rights reserved.
//

#import "SWSwipeView.h"
@interface SWSwipeView()<UIScrollViewDelegate>
@property(nonatomic, strong) UIScrollView *scrollView;
@property(nonatomic, assign) NSInteger numberOfItems;
@property(nonatomic, strong) NSMutableSet *itemViewsPool;
@property(nonatomic, strong) NSMutableDictionary *itemViews; // 当前可见item views字典

@property (nonatomic, assign) CGFloat scrollOffset;  // scroll 共翻过了几页
@property (nonatomic, assign) CGPoint previousContentOffset; // scrollview 上一次的contentOffset
// for animation
@property (nonatomic, strong) NSTimer *timer;  // 用于设置动画翻页效果的timer
@property (nonatomic, assign) NSTimeInterval startTime;
@property (nonatomic, assign) NSTimeInterval scrollDuration;
@property (nonatomic, assign) CGFloat startOffset;
@property (nonatomic, assign) CGFloat endOffset;
@end
@implementation SWSwipeView

#pragma mark - Initialisation
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self setUp];
    }
    return self;
}

- (void)setUp
{
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.scrollsToTop = NO;
    _scrollView.backgroundColor = [UIColor redColor];
    self.backgroundColor = [UIColor greenColor];
    
    _scrollOffset = 0.0f;
    _previousContentOffset = _scrollView.contentOffset;
    
    [self insertSubview:_scrollView atIndex:0];
    
    [self reloadData];
    
    
}

#pragma mark - Layout
- (void)layoutSubviews
{
    [super layoutSubviews];
    [self updateItemCount];
    [self updateScrollViewDimensions];
    [self updateLayout];
    //
    [self scrollToIndex:self.currentIndex duration:0.5];
}

- (void) updateLayout
{
    [self updateScrollOffset];
    [self loadUnloadViews];
    [self layoutItemViews];
   
}

- (void)didScroll
{
    [self updateScrollOffset];
   // [self layoutItemViews];
    [self loadUnloadViews];
}

- (void)updateScrollOffset
{
    CGFloat delta = _scrollView.contentOffset.x - _previousContentOffset.x;
    _previousContentOffset = _scrollView.contentOffset;
    _scrollOffset += delta / _scrollView.bounds.size.width;  // 记录翻过了几页
    
    // 当翻到边缘时 0 or maxpage 设置_scrollview 为0 或 maxpage
//    if (_scrollOffset < 0) {
//        _scrollOffset = 0.0f;
//    }else if(_scrollOffset > self.itemNum)
//    {
//        _scrollOffset = self.itemNum -1;
//    }
    
    
    _currentIndex = round(_scrollOffset);
    
}


- (void)layoutItemViews
{
    for (UIView *view in [self visibleItemViews]) {
        [self layoutItemView:view atIndex:[self indexOfItemView:view]];
    }
}

- (void)layoutItemView:(UIView *)view atIndex:(NSInteger)index
{
    if (self.window) {
        CGPoint center = view.center;
        center.x = _scrollView.bounds.size.width * index + (_scrollView.bounds.size.width)/2;
        center.y = _scrollView.center.y;
        
        view.center = center;
        view.bounds = CGRectMake(0, 0, _scrollView.bounds.size.width, _scrollView.bounds.size.height);
    }
}

- (void)updateItemCount
{
    if (self.dataSource) {
        _numberOfItems = [_dataSource numberOfPagesInSwipeView:self];
    }
}

- (void)updateScrollViewDimensions  // update content size and frame
{
    CGSize contentSize = CGSizeMake(_scrollView.bounds.size.width * _numberOfItems, _scrollView.bounds.size.height);
    if (!CGSizeEqualToSize(_scrollView.contentSize, contentSize)) {
        _scrollView.contentSize = contentSize;
    }
    
    CGPoint contentOffset = CGPointMake(_scrollView.bounds.size.width*_currentIndex, 0);
    if (!CGPointEqualToPoint(_scrollView.contentOffset, contentOffset)) {
        _scrollView.contentOffset = contentOffset;
    }
    
    CGRect frame = self.bounds;
    if (CGRectEqualToRect(_scrollView.frame, frame)) {
        _scrollView.frame = frame;
    }
}



#pragma mark - View loading
- (void)reloadData
{
    for (UIView *view in self.visibleItemViews) {
        [view removeFromSuperview];
    }
    
    // reset all data
    _numberOfItems = 0;
    _itemViewsPool = [[NSMutableSet alloc] init];
    _itemViews = [[NSMutableDictionary alloc] init];
    [self setNeedsLayout];
}
- (void)reloadDataAtIndex:(NSInteger) index
{
}

- (void)loadUnloadViews
{
    // step1. caculate the indexs of visible item view
    CGFloat startIndex = floorf(_scrollOffset);
    NSInteger numberOfVisibleItem = ceilf(1 + (_scrollOffset - startIndex));
    
    NSMutableSet *visibleViewIndexs = [NSMutableSet setWithCapacity:numberOfVisibleItem];

    for (NSInteger i = 0; i < numberOfVisibleItem; ++i) {
        NSInteger visibleIndex = i + startIndex;
        [visibleViewIndexs addObject:@(visibleIndex)];
    }
    
    // step2. remove unvisible View
    for (NSNumber *index in [_itemViews allKeys]) {
        if (![visibleViewIndexs containsObject:index]) { // the view are not on the
            UIView *view = _itemViews[index];
            [self queueItemView:view];
            [view removeFromSuperview];
            [_itemViews removeObjectForKey:index];
        }
    }
    
    // step3. add visible view
    for (NSNumber *index in visibleViewIndexs) {
        if (!_itemViews[index] && index.integerValue >= 0 && index.integerValue < self.numberOfItems) {
            [self loadViewAtIndex:index.integerValue];
        }
    }
    
    
}

- (void)loadViewAtIndex:(NSInteger) index
{
    UIView *view = [self.dataSource swipeView:self viewForPageAtIndex:index resuingView:[self dequeueItemView]];
    if (view == nil) {
        view = [[UIView alloc] init];
    }
    
    
    _itemViews[@(index)] = view;  // insert visible view
    [self layoutItemView:view atIndex:index];
    view.userInteractionEnabled = YES;
    [_scrollView addSubview:view];
}

#pragma mark - View queing

- (void)queueItemView:(UIView *)view
{
    if (view)
    {
        [_itemViewsPool addObject:view];
    }
}

- (UIView *)dequeueItemView
{
    UIView *view = [_itemViewsPool anyObject];
    if (view)
    {
        [_itemViewsPool removeObject:view];
    }
    return view;
}

#pragma mark - View managment
- (NSArray *)indexesForVisibleItems
{
    return [[_itemViews allKeys] sortedArrayUsingSelector:@selector(compare:)];
}

- (NSArray *)visibleItemViews
{
    return [_itemViews objectsForKeys:[self indexesForVisibleItems] notFoundMarker:[NSNull null]];
}

- (NSInteger) indexOfItemView:(UIView *)view
{
    return ((NSNumber *)[_itemViews allKeysForObject:view].firstObject)? ((NSNumber *)[_itemViews allKeysForObject:view].firstObject).integerValue: NSNotFound;
}



#pragma mark - Item management
- (UIView *)viewForItemAtIndex:(NSInteger)index
{
    return nil;
}
- (void)scrollToIndex:(NSInteger) index duration:(NSTimeInterval)duration
{
    _startTime = [[NSDate date] timeIntervalSinceReferenceDate];
    _scrollDuration = duration;
    
    CGFloat numToScroll = index - _scrollOffset;
    CGFloat passPagesWidth = numToScroll * self.scrollView.bounds.size.width;
    _endOffset = self.scrollView.contentOffset.x + passPagesWidth;
    //
    [self startAnimation];
   
}

- (void)startAnimation
{
    if (_timer) {
        _timer = [NSTimer timerWithTimeInterval:1.0/60.0
                                         target:self
                                       selector:@selector(step)
                                       userInfo:nil
                                        repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
}

- (void)stopAnimation
{
    
}

- (void)step
{
    
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self didScroll];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self didScroll];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    [self didScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self didScroll];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [self didScroll];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self didScroll];
    NSLog(@"Current index is %ld", self.currentIndex);
}

@end
