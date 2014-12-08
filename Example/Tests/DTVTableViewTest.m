//
//  DTVTableViewTest.m
//  DTVTableView
//
//  Created by Tom Quist on 03.12.14.
//  Copyright (c) 2014 Tom Quist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DTVTableView/DTVTableView.h>
#import <XCTest/XCTest.h>

@interface DTVTableViewTest : XCTestCase <DTVTableViewDataSource>

@property (nonatomic, strong) DTVTableView *tableView;
@property (nonatomic, copy) UIView *(^cellForRow)(DTVTableView *, NSInteger row, UIView *);
@property (nonatomic, assign) NSInteger numberOfRows;

@end

@implementation DTVTableViewTest



- (void)setUp {
    [super setUp];
    self.tableView = [[DTVTableView alloc] initWithFrame:CGRectMake(0, 0, 320, 300)];
}

- (void)tearDown {
    self.tableView = nil;
    [super tearDown];
}

- (void)testSingleRow {
    NSArray *cells = @[[[UITableViewCell alloc] init]];
    [cells[0] setFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 100)];
    self.numberOfRows = cells.count;
    self.cellForRow = ^UIView *(DTVTableView *tableView, NSInteger row, UIView *reusableView) {
        return cells[row];
    };
    self.tableView.dataSource = self;
    
    CGRect viewFrame = ((UIView *)cells[0]).frame;
    CGRect expectedFrame = CGRectMake(0, 0, 320, 100);
    XCTAssertEqualObjects(NSStringFromCGRect(viewFrame), NSStringFromCGRect(expectedFrame), "Frame of view should be correct");
}

- (void)testTwoRowsSameHeight {
    NSArray *cells = @[
                       [[UITableViewCell alloc] init],
                       [[UITableViewCell alloc] init]];
    [cells[0] setFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 100)];
    [cells[1] setFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 100)];
    self.numberOfRows = cells.count;
    self.cellForRow = ^UIView *(DTVTableView *tableView, NSInteger row, UIView *reusableView) {
        return cells[row];
    };
    self.tableView.dataSource = self;
    
    CGRect viewFrame = ((UIView *)cells[0]).frame;
    CGRect expectedFrame = CGRectMake(0, 0, 320, 100);
    XCTAssertEqualObjects(NSStringFromCGRect(viewFrame), NSStringFromCGRect(expectedFrame), "Frame of view should be correct");

    viewFrame = ((UIView *)cells[1]).frame;
    expectedFrame = CGRectMake(0, 100, 320, 100);
    XCTAssertEqualObjects(NSStringFromCGRect(viewFrame), NSStringFromCGRect(expectedFrame), "Frame of view should be correct");
}

- (void)testTwoRowsDifferentHeight {
    NSArray *cells = @[
                       [[UITableViewCell alloc] init],
                       [[UITableViewCell alloc] init]];
    [cells[0] setFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 50)];
    [cells[1] setFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 100)];
    self.numberOfRows = cells.count;
    self.cellForRow = ^UIView *(DTVTableView *tableView, NSInteger row, UIView *reusableView) {
        return cells[row];
    };
    self.tableView.dataSource = self;
    
    CGRect viewFrame = ((UIView *)cells[0]).frame;
    CGRect expectedFrame = CGRectMake(0, 0, 320, 50);
    XCTAssertEqualObjects(NSStringFromCGRect(viewFrame), NSStringFromCGRect(expectedFrame), "Frame of view should be correct");
    
    viewFrame = ((UIView *)cells[1]).frame;
    expectedFrame = CGRectMake(0, 50, 320, 100);
    XCTAssertEqualObjects(NSStringFromCGRect(viewFrame), NSStringFromCGRect(expectedFrame), "Frame of view should be correct");
}

- (void)testManyRowsSameHeight {
    NSMutableArray *cells = [NSMutableArray array];
    for (NSInteger i = 0; i<100; i++) {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        cell.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 100);
        [cells addObject:cell];
    }
    self.numberOfRows = cells.count;
    self.cellForRow = ^UIView *(DTVTableView *tableView, NSInteger row, UIView *reusableView) {
        return cells[row];
    };
    self.tableView.dataSource = self;

    __block NSInteger addedCells = 0;
    [cells enumerateObjectsUsingBlock:^(UITableViewCell *cell, NSUInteger idx, BOOL *stop) {
        if (cell.superview != nil)
        {
            addedCells++;
            CGRect viewFrame = ((UIView *)cells[idx]).frame;
            CGRect expectedFrame = CGRectMake(0, idx * 100, self.tableView.bounds.size.width, 100);
            XCTAssertEqualObjects(NSStringFromCGRect(viewFrame), NSStringFromCGRect(expectedFrame), "Frame of view should be correct");
        }
    }];
    XCTAssertEqual(addedCells, (int)ceilf(self.tableView.bounds.size.height/100), "Only visible cells should be added");
}

/*- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}*/

#pragma mark - DTVTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(DTVTableView *)tableView {
    return self.numberOfRows;
}

- (UIView *)tableView:(DTVTableView *)tableView cellForRow:(NSInteger)row reuseView:(UIView *)reuseableView {
    return self.cellForRow(tableView, row, reuseableView);
}

@end
