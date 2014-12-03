//
//  DTVTableView.m
//  DynamicTableView
//
//  Created by Tom Quist on 03.11.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "DTVTableView.h"

@interface DTVMessageInterceptor : NSObject

@property (nonatomic, assign) id receiver;
@property (nonatomic, assign) id middleMan;
@end

@implementation DTVMessageInterceptor

- (id)forwardingTargetForSelector:(SEL)aSelector {
    id ret;
    if ([_middleMan respondsToSelector:aSelector]) {
        ret = _middleMan;
    } else  if ([_receiver respondsToSelector:aSelector]) {
        ret = _receiver;
    } else {
        ret = [super forwardingTargetForSelector:aSelector];
    }
    return ret;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    BOOL ret;
    if ([[_middleMan superclass] instancesRespondToSelector:aSelector]) {
        ret = FALSE;
    } else if ([_middleMan respondsToSelector:aSelector] || [_receiver respondsToSelector:aSelector]) {
        ret = TRUE;
    } else {
        ret = [super respondsToSelector:aSelector];
    }
    return ret;
}

@end

@interface DTVTableView () <UIScrollViewDelegate> {
    NSInteger _numberOfRows;
    NSInteger _topVisibleRow;
    NSInteger _bottomVisibleRow;
    CGFloat _topVisibleY;
    CGFloat _bottomVisibleY;
    CGFloat _scrollPosition;
    NSMutableArray *_currentViews;
    
    CGFloat _lastKnownAverageHeight;
    
    BOOL _scrolling;
}

@property (nonatomic, retain) DTVMessageInterceptor *delegateInterceptor;

@end

@implementation DTVTableView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    _delegateInterceptor = [[DTVMessageInterceptor alloc] init];
    _delegateInterceptor.middleMan = self;
    [super setDelegate:(id<UIScrollViewDelegate>)_delegateInterceptor];
    
    _topVisibleRow = 0;
    _topVisibleY = 0;
    _currentViews = [[NSMutableArray alloc] initWithCapacity:20];
}

- (id<UITableViewDelegate>)delegate {
    id delegate = [super delegate];
    if ([delegate isKindOfClass:[DTVMessageInterceptor class]]) {
        DTVMessageInterceptor *messageInterceptor = (DTVMessageInterceptor *)delegate;
        delegate = messageInterceptor.receiver;
    }
    return delegate;
}

- (void)setDelegate:(id<UITableViewDelegate>)delegate {
    [super setDelegate:nil];
    _delegateInterceptor.receiver = delegate;
    [super setDelegate:(id<UIScrollViewDelegate>)_delegateInterceptor];
}

- (void)setDataSource:(id<DTVTableViewDataSource>)dataSource {
    _dataSource = dataSource;
    [self reloadData];
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
}

- (void)reloadData {
    _numberOfRows = [self.dataSource numberOfRowsInTableView:self];
    CGFloat y = 0;
    NSInteger row = 0;
    _lastKnownAverageHeight = 44;

    for (UIView *v in _currentViews) {
        [v removeFromSuperview];
    }
    
    [_currentViews removeAllObjects];
    NSInteger i = 0;
    CGFloat heightSum = 0;
    while (y < self.bounds.size.height) {
        UIView *v = [self.dataSource tableView:self cellForRow:row convertView:nil];
        [_currentViews addObject:v];
        CGRect f = v.frame;
        f.origin = CGPointMake(0, y);
        f.size.width = self.bounds.size.width;
        v.frame = f;
        
        [v layoutIfNeeded];
        
        f = v.frame;
        
        [self addSubview:v];
        heightSum += f.size.height;
        y += f.size.height;
        _bottomVisibleRow = row;
        row++;
        i++;
        _bottomVisibleY = y;
    }
    _lastKnownAverageHeight = heightSum / i;
    self.contentSize = CGSizeMake(self.frame.size.width, _lastKnownAverageHeight * _numberOfRows);
}

- (void)fillViewFromCurrentTop {
    
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_scrolling) return;
    _scrolling = TRUE;
    CGFloat scrollY = scrollView.contentOffset.y;
    
    if ([_currentViews count] == 0 && _numberOfRows > 0) {
        self.contentSize = CGSizeMake(self.frame.size.width, _lastKnownAverageHeight * _numberOfRows);
        _topVisibleRow = ceilf(scrollY / _lastKnownAverageHeight);
        _topVisibleY = _topVisibleRow * _lastKnownAverageHeight;
        
        //NSLog(@"Adding row %i", _topVisibleRow);
        UIView *v = [self.dataSource tableView:self cellForRow:_topVisibleRow convertView:nil];
        CGRect f = v.frame;
        f.size.width = self.bounds.size.width;
        f.origin.y = _topVisibleY;
        v.frame = f;
        
        [v layoutIfNeeded];
        
        f = v.frame;
        v.frame = f;
        [self insertSubview:v atIndex:0];
        
        [_currentViews insertObject:v atIndex:0];
        
        _bottomVisibleRow = _topVisibleRow;
        _bottomVisibleY = f.origin.y + f.size.height;
    }
    
    // Remove non-visible views from top
    UIView *firstView = nil;
    if ([_currentViews count] > 0) {
        firstView = _currentViews[0];
    }
    while (firstView != nil && scrollY > firstView.frame.origin.y + firstView.frame.size.height) {
        _topVisibleRow++;
        _topVisibleY += firstView.frame.size.height;
        [firstView removeFromSuperview];
        [_currentViews removeObjectAtIndex:0];
        
        if ([_currentViews count] > 0) {
            firstView = _currentViews[0];
        } else {
            firstView = nil;
        }
    }
    
    BOOL moveContent = FALSE;
    
    // Fill up remaining space on top
    while (firstView != nil && scrollY < firstView.frame.origin.y && _topVisibleRow > 0) {
        _topVisibleRow--;
        UIView *v = [self.dataSource tableView:self cellForRow:_topVisibleRow convertView:nil];
        CGRect f = v.frame;
        f.size.width = self.bounds.size.width;
        v.frame = f;
        
        [v layoutIfNeeded];
        
        _topVisibleY -= f.size.height;
        
        f = v.frame;
        f.origin.y = _topVisibleY;
        v.frame = f;
        [self insertSubview:v atIndex:0];
        
        [_currentViews insertObject:v atIndex:0];
        
        firstView = v;
        if (_topVisibleY < _lastKnownAverageHeight * _topVisibleRow || (_topVisibleRow == 0 && _topVisibleY > 0)) {
            moveContent = TRUE;
        }
    }
    
    // Remove non-visible views from bottom
    UIView *lastView = [_currentViews lastObject];
    while (lastView != nil && lastView.frame.origin.y > scrollY + self.bounds.size.height) {
        _bottomVisibleRow--;
        _bottomVisibleY -= lastView.frame.size.height;
        [lastView removeFromSuperview];
        [_currentViews removeLastObject];

        lastView = [_currentViews lastObject];
    }
    
    // Fill up remaining space on bottom
    while (lastView != nil && lastView.frame.origin.y + lastView.frame.size.height < scrollY + self.bounds.size.height && _bottomVisibleRow < _numberOfRows - 1) {
        _bottomVisibleRow++;
        UIView *v = [self.dataSource tableView:self cellForRow:_bottomVisibleRow convertView:nil];
        CGRect f = v.frame;
        f.size.width = self.bounds.size.width;
        v.frame = f;
        
        [v layoutIfNeeded];
        
        _bottomVisibleY += f.size.height;
        
        f = v.frame;
        f.origin.y = _bottomVisibleY - f.size.height;
        v.frame = f;
        [self insertSubview:v atIndex:0];
        
        [_currentViews addObject:v];
        lastView = v;
        
        if (_bottomVisibleY > _lastKnownAverageHeight * _numberOfRows || (_bottomVisibleRow == _numberOfRows-1 && _bottomVisibleY < self.contentSize.height)) {
            moveContent = TRUE;
        }
    }

    // Update content size
    CGFloat heightSum = 0;
    NSInteger count = 0;
    for (UIView *v in _currentViews) {
        heightSum += v.frame.size.height;
        count++;
    }
    CGFloat averageHeight = (NSInteger)(heightSum / count);
    
    if (moveContent) {
        _lastKnownAverageHeight = averageHeight;
        
        CGFloat firstIntraY = scrollY - firstView.frame.origin.y;
        CGFloat newFirstY = _topVisibleRow * averageHeight;
        CGFloat moveBy = (newFirstY + firstIntraY) - scrollY;
        if (moveBy != 0.f) {
            _topVisibleY += moveBy;
            _bottomVisibleY += moveBy;
            for (UIView *v in _currentViews) {
                CGRect f = v.frame;
                f.origin.y += moveBy;
                v.frame = f;
            }
        }
        self.contentSize = CGSizeMake(self.frame.size.width, averageHeight * _numberOfRows);
        self.contentOffset = CGPointMake(self.contentOffset.x, firstIntraY + averageHeight * _topVisibleRow);
        _topVisibleY = averageHeight * _topVisibleRow;
    } else {
        self.contentOffset = CGPointMake(self.contentOffset.x, scrollY);
    }
    
    _scrolling = FALSE;
}

@end
