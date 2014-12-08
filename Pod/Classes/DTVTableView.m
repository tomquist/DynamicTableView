//
//  DTVTableView.m
//  DynamicTableView
//
//  Created by Tom Quist on 03.11.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "DTVTableView.h"

NSUInteger DTVMaxReusableViewCount = 3;

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


@interface DTVTableViewItemHolder : NSObject
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, strong) UIView *view;
@property(nonatomic, copy) NSString *reuseIdentifier;
@end

@implementation DTVTableViewItemHolder

- (instancetype)reuseWithView:(UIView *)view row:(NSInteger)row reuseIdentifier:(NSString *)reuseIdentifier {
    _view = view;
    _row = row;
    _reuseIdentifier = reuseIdentifier;
    return self;
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
    NSMutableDictionary *_cellRegistry;
    NSMutableDictionary *_reusableCells;
    NSMutableArray *_reusableItemHolders;
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
    _cellRegistry = [[NSMutableDictionary alloc] init];
    _reusableCells = [[NSMutableDictionary alloc] init];
    _reusableItemHolders = [[NSMutableArray alloc] init];
}

- (id<DTVTableViewDelegate>)delegate {
    id delegate = [super delegate];
    if ([delegate isKindOfClass:[DTVMessageInterceptor class]]) {
        DTVMessageInterceptor *messageInterceptor = (DTVMessageInterceptor *)delegate;
        delegate = messageInterceptor.receiver;
    }
    return delegate;
}

- (void)setDelegate:(id<DTVTableViewDelegate>)delegate {
    [super setDelegate:nil];
    _delegateInterceptor.receiver = delegate;
    [super setDelegate:(id<UIScrollViewDelegate>)_delegateInterceptor];
}

- (void)setDataSource:(id<DTVTableViewDataSource>)dataSource {
    _dataSource = dataSource;
    [self reloadData];
}

- (void)registerClass:(Class)viewClass forViewReuseIdentifier:(NSString *)reuseIdentifier {
    _cellRegistry[reuseIdentifier] = viewClass;
    _reusableCells[reuseIdentifier] = [NSMutableArray array];
}

- (DTVTableViewItemHolder *)dequeueItemHolder {
    DTVTableViewItemHolder *itemHolder = [_reusableItemHolders lastObject];
    if (itemHolder != nil) {
        [_reusableItemHolders removeLastObject];
    } else {
        itemHolder = [[DTVTableViewItemHolder alloc] init];
    }
    return itemHolder;
}

- (void)enqueueReusableItemHolder:(DTVTableViewItemHolder *)itemHolder {
    [_reusableItemHolders addObject:itemHolder];
}

- (void)enqueueReusableView:(UIView *)view forReuseIdentifier:(NSString *)reuseIdentifier {
    NSMutableArray * array = _reusableCells[reuseIdentifier];
    [array addObject:view];
}

- (UIView *)dequeueReusableViewWithIdentifier:(NSString *)reuseIdentifier forRow:(NSInteger)row {
    if (reuseIdentifier == nil) {
        return nil;
    }
    UIView *view = nil;
    NSMutableArray *reusableViews = _reusableCells[reuseIdentifier];
    if (reusableViews != nil) {
        view = [reusableViews lastObject];
        if (view != nil) {
            [reusableViews removeLastObject];
            return view;
        }
        Class viewClass = _cellRegistry[reuseIdentifier];
        view = [(UIView *) [viewClass alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 0)];
    }
    return view;
}

- (DTVTableViewItemHolder *)itemHolderForRow:(NSInteger)row onYPosition:(CGFloat)yPosition {
    NSString *reuseIdentifier = nil;
    if ([self.dataSource respondsToSelector:@selector(tableView:reuseIdentifierForRow:)]) {
        reuseIdentifier = [self.dataSource tableView:self reuseIdentifierForRow:row];
    }
    UIView *reusableView = [self dequeueReusableViewWithIdentifier:reuseIdentifier forRow:row];
    if (reusableView != nil) {
        CGRect f = reusableView.frame;
        f.origin = CGPointMake(0, yPosition);
        f.size.width = self.bounds.size.width;
        reusableView.frame = f;
    }
    UIView *view = [self.dataSource tableView:self cellForRow:row reuseView:reusableView];
    CGRect f = view.frame;
    f.origin = CGPointMake(0, yPosition);
    f.size.width = self.bounds.size.width;
    view.frame = f;
    
    DTVTableViewItemHolder *itemHolder = [[self dequeueItemHolder] reuseWithView:view row:row reuseIdentifier:reuseIdentifier];
    return itemHolder;
}

- (void)reloadData {
    _numberOfRows = [self.dataSource numberOfRowsInTableView:self];
    CGFloat y = 0;
    NSInteger row = 0;
    _lastKnownAverageHeight = 44;
    
    for (DTVTableViewItemHolder *itemHolder in _currentViews) {
        [self prepareItemHolderForRemoval:itemHolder];
    }
    
    [_currentViews removeAllObjects];
    NSInteger count = 0;
    CGFloat heightSum = 0;
    NSInteger rowCount = [self.dataSource numberOfRowsInTableView:self];
    while (y < self.bounds.size.height && row < rowCount) {
        DTVTableViewItemHolder *itemHolder = [self itemHolderForRow:row onYPosition:y];
        [_currentViews addObject:itemHolder];
        
        [self addSubview:itemHolder.view];
        CGRect viewFrame = itemHolder.view.frame;
        heightSum += viewFrame.size.height;
        y += viewFrame.size.height;
        _bottomVisibleRow = row;
        row++;
        count++;
        _bottomVisibleY = y;
    }
    _lastKnownAverageHeight = heightSum / count;
    self.contentSize = CGSizeMake(self.frame.size.width, _lastKnownAverageHeight * _numberOfRows);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.contentSize.width != self.bounds.size.width) {
        NSInteger count = 0;
        CGFloat heightSum = 0;
        CGFloat y = _topVisibleY;
        for (DTVTableViewItemHolder *itemHolder in _currentViews) {
            UIView *view = itemHolder.view;
            CGRect frame = view.frame;
            frame.origin.y = y;
            frame.size.width = self.bounds.size.width;
            view.frame = frame;
            frame.size = [view sizeThatFits:frame.size];
            frame.size.width = self.bounds.size.width;
            view.frame = frame;
            y += frame.size.height;
            count++;
            
            heightSum += frame.size.height;
            _bottomVisibleY = CGRectGetMaxY(frame);
        }
        if (count > 0) {
            _lastKnownAverageHeight = _bottomVisibleY / count;
            self.contentSize = CGSizeMake(self.frame.size.width, _lastKnownAverageHeight * _numberOfRows);
        }
        [self scrollViewDidScroll:self];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_scrolling) return;
    _scrolling = TRUE;
    CGFloat scrollY = scrollView.contentOffset.y;
    
    if ([_currentViews count] == 0 && _numberOfRows > 0) {
        self.contentSize = CGSizeMake(self.frame.size.width, _lastKnownAverageHeight * _numberOfRows);
        _topVisibleRow = (NSInteger) ceilf(scrollY / _lastKnownAverageHeight);
        _topVisibleY = _topVisibleRow * _lastKnownAverageHeight;
        
        //NSLog(@"Adding row %i", _topVisibleRow);
        DTVTableViewItemHolder *itemHolder = [self itemHolderForRow:_topVisibleRow onYPosition:_topVisibleY];
        UIView *view = itemHolder.view;
        CGRect f = view.frame;
        view.frame = f;
        [self insertSubview:view atIndex:0];
        
        [_currentViews insertObject:itemHolder atIndex:0];
        
        _bottomVisibleRow = _topVisibleRow;
        _bottomVisibleY = f.origin.y + f.size.height;
    }
    
    // Remove non-visible views from top
    DTVTableViewItemHolder *firstItemHolder = [_currentViews firstObject];
    BOOL removedItemsFromTop = FALSE;
    while (firstItemHolder != nil && scrollY > CGRectGetMaxY(firstItemHolder.view.frame)) {
        _topVisibleRow++;
        _topVisibleY = CGRectGetMaxY(firstItemHolder.view.frame);
        [self prepareItemHolderForRemoval:firstItemHolder];
        [_currentViews removeObjectAtIndex:0];
        
        firstItemHolder = [_currentViews firstObject];
        removedItemsFromTop = TRUE;
    }
    
    BOOL moveContent = FALSE;
    
    // Fill up remaining space on top
    while (firstItemHolder != nil && scrollY < firstItemHolder.view.frame.origin.y && _topVisibleRow > 0 && _topVisibleRow <= _numberOfRows) {
        _topVisibleRow--;
        
        DTVTableViewItemHolder *itemHolder = [self itemHolderForRow:_topVisibleRow onYPosition:_topVisibleY];
        UIView *view = itemHolder.view;
        CGRect f = view.frame;
        _topVisibleY -= f.size.height;
        
        f.origin.y = _topVisibleY;
        view.frame = f;
        [self insertSubview:view atIndex:0];
        
        [_currentViews insertObject:itemHolder atIndex:0];
        
        firstItemHolder = itemHolder;
        if (_topVisibleY < _lastKnownAverageHeight * _topVisibleRow || (_topVisibleRow == 0 && _topVisibleY > 0)) {
            moveContent = TRUE;
        }
    }
    
    if (_topVisibleRow > _numberOfRows * 2) {
        moveContent = TRUE;
    }
    
    // Remove non-visible views from bottom
    DTVTableViewItemHolder *lastItemHolder = [_currentViews lastObject];
    while (lastItemHolder != nil && lastItemHolder.view.frame.origin.y > scrollY + self.bounds.size.height) {
        _bottomVisibleRow--;
        _bottomVisibleY = lastItemHolder.view.frame.origin.y;
        [self prepareItemHolderForRemoval:lastItemHolder];
        [_currentViews removeLastObject];
        
        lastItemHolder = [_currentViews lastObject];
    }
    
    // Fill up remaining space on bottom
    while (lastItemHolder != nil && CGRectGetMaxY(lastItemHolder.view.frame) < scrollY + self.bounds.size.height && _bottomVisibleRow < _numberOfRows - 1 && _bottomVisibleRow >= -1) {
        _bottomVisibleRow++;
        
        DTVTableViewItemHolder *itemHolder = [self itemHolderForRow:_bottomVisibleRow onYPosition:_bottomVisibleY];
        UIView *view = itemHolder.view;
        _bottomVisibleY = CGRectGetMaxY(view.frame);
        [self insertSubview:view atIndex:0];
        
        [_currentViews addObject:itemHolder];
        lastItemHolder = itemHolder;
        
        if (_bottomVisibleY > _lastKnownAverageHeight * _numberOfRows || (_bottomVisibleRow == _numberOfRows-1 && _bottomVisibleY < self.contentSize.height)) {
            moveContent = TRUE;
        }
    }
    
    
    if (moveContent) {
        [self updateContentSizeAndMoveContent];
    } else {
        self.contentOffset = CGPointMake(self.contentOffset.x, scrollY);
    }
    
    _scrolling = FALSE;
}

- (void)updateContentSizeAndMoveContent {
    CGFloat heightSum = 0;
    NSInteger count = 0;
    if ([[NSSet setWithArray:_currentViews] count] != _currentViews.count) {
        NSLog(@"Double entries");
    }
    for (DTVTableViewItemHolder *v in _currentViews) {
        heightSum += v.view.frame.size.height;
        count++;
    }
    CGFloat averageHeight = _lastKnownAverageHeight;
    if (count > 0) {
        averageHeight = (heightSum / count);
    } else if (averageHeight == 0) {
        averageHeight = 44;
    }
    _lastKnownAverageHeight = averageHeight;
    
    DTVTableViewItemHolder *firstItemHolder = _currentViews.firstObject;
    
    CGFloat firstY = firstItemHolder.view.frame.origin.y;
    CGFloat scrollY = self.contentOffset.y;
    CGFloat distanceToScrollY = scrollY - firstItemHolder.view.frame.origin.y;
    CGFloat newFirstY = _topVisibleRow * averageHeight;
    CGFloat moveBy = newFirstY - firstY; //(newFirstY + distanceToScrollY) - scrollY;
    if (moveBy != 0.f) {
        _topVisibleY += moveBy;
        _bottomVisibleY += moveBy;
        for (DTVTableViewItemHolder *v in _currentViews) {
            CGRect f = v.view.frame;
            f.origin.y += moveBy;
            v.view.frame = f;
        }
    }
    self.contentSize = CGSizeMake(self.bounds.size.width, averageHeight * _numberOfRows);
    self.contentOffset = CGPointMake(self.contentOffset.x, newFirstY + distanceToScrollY);
    _topVisibleY = averageHeight * _topVisibleRow;
    if (CGRectGetMaxY([_currentViews.lastObject view].frame) > self.contentSize.height) {
        NSLog(@"Last view must be within content size");
    }
}

- (void)prepareItemHolderForRemoval:(DTVTableViewItemHolder *)itemHolder {
    if (itemHolder.reuseIdentifier.length > 0) {
        [self enqueueReusableView:itemHolder.view forReuseIdentifier:itemHolder.reuseIdentifier];
    }
    [itemHolder.view removeFromSuperview];
    itemHolder.view = nil;
    [self enqueueReusableItemHolder:itemHolder];
}

@end
