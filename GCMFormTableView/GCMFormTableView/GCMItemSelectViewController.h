//
//  GCMItemSelectViewController.h
//  GameChanger
//
//  Created by Jerry Hsu on 10/28/13.
//  Copyright (c) 2013 GameChanger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCMItemSelectTableViewDataSource.h"

@protocol GCMItemSelectViewControllerDelegate;

@interface GCMItemSelectViewController : UIViewController
@property (nonatomic, readonly) UITableView *tableView;
@property (nonatomic, weak) id<GCMItemSelectViewControllerDelegate> delegate;
@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, strong) id userInfo;
@property (nonatomic, strong) GCMItemSelectTableViewDataSource *dataSource;

/// Defaults to NO. If YES, right bar button item is displayed with confirmationTitle. Button will be disabled if no item is selected.
@property (nonatomic, assign) BOOL requireSelectionConfirmation;
/// Defaults to @"Next";
@property (nonatomic, strong) NSString *confirmationTitle;

/// Defaults to @"Cancel";
@property (nonatomic, strong) NSString *cancellationTitle;
@property (nonatomic, assign) BOOL showCancelButton;

@end

@protocol GCMItemSelectViewControllerDelegate <NSObject>

- (void)selectedItemInItemSelectViewController:(GCMItemSelectViewController *)controller andConfirmedSelection:(BOOL)confirmed;
@optional
- (void)selectedActionWithTag:(NSInteger)tag andUserInfo:(id)userInfo inItemSelectViewController:(GCMItemSelectViewController *)controller;
- (void)cancelledItemSelectViewController:(GCMItemSelectViewController *)controller;

@end