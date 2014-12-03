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

@end

@protocol DTVTableViewDataSource <NSObject>

- (NSInteger)numberOfRowsInTableView:(DTVTableView *)tableView;

- (UITableViewCell *)tableView:(DTVTableView *)tableView cellForRow:(NSInteger)row convertView:(UITableViewCell *)convertView;;
@optional
- (NSInteger)tableView:(DTVTableView *)tableView itemViewTypeForRow:(NSInteger)row;

- (NSInteger)numberOfViewTypesInTableView:(DTVTableView *)tableView;

@end
