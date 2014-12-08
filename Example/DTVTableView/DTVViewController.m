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
    [self.tableView registerClass:[UILabel class] forViewReuseIdentifier:@"view"];
    self.tableView.dataSource = self;

}


- (NSInteger)numberOfRowsInTableView:(DTVTableView *)tableView {
    return 500;
}

- (NSString *)tableView:(DTVTableView *)tableView reuseIdentifierForRow:(NSInteger)row {
    return @"view";
}

- (UIView *)tableView:(DTVTableView *)tableView cellForRow:(NSInteger)row reuseView:(UIView *)reuseableView {
    CGFloat red = row % 3 / 3.f;
    CGFloat green = row % 5 / 5.f;
    CGFloat blue = row % 6 / 6.f;
    UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:1];
    reuseableView.backgroundColor = color;
    /*CGRect frame = reuseableView.frame;
    frame.size.width = tableView.bounds.size.width;
    frame.size.height = (NSInteger)((arc4random() % (row+1))+ 10);
    reuseableView.frame = frame;*/
    UILabel *label = (UILabel *)reuseableView;
    label.textAlignment = NSTextAlignmentCenter;
    label.text = [NSString stringWithFormat:@"%d", row];
   //label.font = [UIFont systemFontOfSize:((arc4random() % (row+1))+ 10)];
    label.font = [UIFont systemFontOfSize:row];
    [label sizeToFit];
    /*if (row % 10 == 0) {
     ret.frame = CGRectMake(0, 0, tableView.frame.size.width, 400);
     }*/
    
    return reuseableView;
}

@end
