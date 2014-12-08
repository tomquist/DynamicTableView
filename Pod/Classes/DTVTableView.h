//
//  DTVTableView.h
//  DynamicTableView
//
//  Created by Tom Quist on 03.11.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DTVTableViewDataSource;

@protocol DTVTableViewDelegate <UIScrollViewDelegate>

@end

@interface DTVTableView : UIScrollView

@property (nonatomic, assign) id <DTVTableViewDataSource> dataSource;
@property (nonatomic, assign) id <DTVTableViewDelegate> delegate;

- (void)registerClass:(Class)viewClass forViewReuseIdentifier:(NSString *)reuseIdentifier;

@end

@protocol DTVTableViewDataSource <NSObject>

- (NSInteger)numberOfRowsInTableView:(DTVTableView *)tableView;

- (UIView *)tableView:(DTVTableView *)tableView cellForRow:(NSInteger)row reuseView:(UIView *)reuseableView;
@optional
- (NSString *)tableView:(DTVTableView *)tableView reuseIdentifierForRow:(NSInteger)row;

@end
