//
//  DTVViewController.m
//  DTVTableView
//
//  Created by Tom Quist on 12/02/2014.
//  Copyright (c) 2014 Tom Quist. All rights reserved.
//

#import "DTVViewController.h"
#import <DTVTableView/DTVTableView.h>

@interface DTVViewController () <DTVTableViewDataSource>
@property (weak, nonatomic) IBOutlet DTVTableView *tableView;

@end

@implementation DTVViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.dataSource = self;

}


- (NSInteger)numberOfRowsInTableView:(DTVTableView *)tableView {
    return 500;
}

- (UITableViewCell *)tableView:(DTVTableView *)tableView cellForRow:(NSInteger)row convertView:(UITableViewCell *)convertView {
    UITableViewCell *ret = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    CGFloat red = row % 3 / 3.f;
    CGFloat green = row % 5 / 5.f;
    CGFloat blue = row % 6 / 6.f;
    UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:1];
    ret.backgroundColor = color;
    ret.frame = CGRectMake(0, 0, tableView.frame.size.width, (NSInteger)((arc4random() % (row+1))));
    /*if (row % 10 == 0) {
     ret.frame = CGRectMake(0, 0, tableView.frame.size.width, 400);
     }*/
    
    return ret;
}

@end
