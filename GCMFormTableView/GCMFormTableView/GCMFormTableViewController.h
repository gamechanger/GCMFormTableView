//
//  GCMFormTableViewController.h
//  GameChanger
//
//  Created by Jerry Hsu on 10/30/13.
//  Copyright (c) 2013 GameChanger. All rights reserved.
//

#import "GCMFormTableViewDataSource.h"

extern NSString *kGCMFormTableViewControllerTagKey;
extern NSString *kGCMFormTableViewControllerUserInfoKey;
extern NSString *kGCMFormTableViewDataKey;
extern NSString *kGCMFormTableViewControllerResultKey;

typedef enum {
  kGCMFormTableViewResultCancel,
  kGCMFormTableViewResultConfirmed,
  kGCMFormTableViewResultUser // Info reported due to other cause like action button on form.
} GCMFormTableViewResult;

@protocol GCMFormTableViewControllerDelegate;

@interface GCMFormTableViewController : UIViewController

@property (nonatomic, weak) id<GCMFormTableViewControllerDelegate> delegate;
@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, strong) id userInfo;
@property (nonatomic, strong) GCMFormTableViewDataSource *dataSource;
@property (nonatomic, readonly) UITableView *tableView;

/// Defaults to @"Next";
@property (nonatomic, strong) NSString *confirmationTitle;
@property (nonatomic, strong) NSString *cancellationTitle;
@property (nonatomic, assign) BOOL showCancelButton;

/// For subclasses to override.
- (void)submitForm;

@end

@protocol GCMFormTableViewControllerDelegate <NSObject>

-(void) formTableViewController:(GCMFormTableViewController *)controller reportsResult:(GCMFormTableViewResult) result andInfo:(NSDictionary *)info;

@end

