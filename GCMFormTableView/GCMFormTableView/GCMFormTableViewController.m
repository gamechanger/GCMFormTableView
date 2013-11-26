//
//  GCMFormTableViewController.m
//  GameChanger
//
//  Created by Jerry Hsu on 10/30/13.
//  Copyright (c) 2013 GameChanger. All rights reserved.
//

#import "GCMFormTableViewController.h"

NSString *kGCMFormTableViewControllerTagKey = @"controllerTag";;
NSString *kGCMFormTableViewControllerUserInfoKey = @"controllerUserInfo";
NSString *kGCMFormTableViewControllerResultKey = @"controllerResult";
NSString *kGCMFormTableViewDataKey = @"data";
NSString *kGCMFormTableViewActionKey = @"action";
NSString *kGCMFormTableViewActionTagKey = @"action.tag";

@interface GCMFormTableViewController () <UITableViewDelegate>

@property (nonatomic, strong, readwrite) UITableView *tableView;

@end

@implementation GCMFormTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    _confirmationTitle = @"Next";
    _cancellationTitle = @"Cancel";
  }
  return self;
}

- (void)dealloc {
  [self.dataSource removeObserver:self forKeyPath:@"dataIsValid"];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.tableView.frame = self.view.bounds;
  [self.view addSubview:self.tableView];

  [self addConfirmationButton];
}

- (void)registerKeyboardNotificationHandlers {
  [[NSNotificationCenter defaultCenter] addObserver: self
                                           selector: @selector(handleKeyboardWillAppear:)
                                               name: UIKeyboardWillShowNotification
                                             object: nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(handleKeyboardDidAppear:)
                                               name:UIKeyboardDidShowNotification
                                             object:nil];
  [[NSNotificationCenter defaultCenter] addObserver: self
                                           selector: @selector(handleKeyboardWillDisappear:)
                                               name: UIKeyboardWillHideNotification
                                             object: nil];
}
- (void)deregisterKeyboardNotificationHandlers {
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIKeyboardWillShowNotification
                                                object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIKeyboardDidShowNotification
                                                object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver: self
                                                  name: UIKeyboardWillHideNotification
                                                object: nil];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self.tableView reloadData];
  if ( self.tableView.contentOffset.y + self.tableView.bounds.size.height > self.tableView.contentSize.height ) {
    self.tableView.contentOffset = CGPointMake(self.tableView.contentOffset.x,
                                               MAX(0.0, self.tableView.contentSize.height - self.tableView.bounds.size.height));
  }
  if ( PRE_IOS7 ) {
    [self resetContentInsetsOfView:self.tableView];
  }
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self registerKeyboardNotificationHandlers];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [self deregisterKeyboardNotificationHandlers];
}

- (void)handleKeyboardWillAppear:(NSNotification *)notification {
  [self animateView:self.tableView toMatchKeyboardNotification:notification];
}

- (void)handleKeyboardDidAppear:(NSNotification *)notification {
  [self.dataSource centerTableViewOnActiveCell];
}

- (void)handleKeyboardWillDisappear:(NSNotification *)notification {
  [self animateView:self.tableView toMatchKeyboardNotification:notification];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  [self updateConfirmationButtonState];
}

- (UITableView *)tableView {
  if ( _tableView ) {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
  }
  return _tableView;
}

- (void)setDataSource:(GCMFormTableViewDataSource *)dataSource {
  if ( _dataSource != dataSource ) {
    [_dataSource removeObserver:self forKeyPath:@"dataIsValid"];
    _dataSource = dataSource;
    [dataSource addObserver:self forKeyPath:@"dataIsValid" options:NSKeyValueObservingOptionNew context: nil];
    dataSource.parentController = self;
    dataSource.tableView = self.tableView;
    self.tableView.dataSource = dataSource;
    self.tableView.delegate = dataSource;

    __weak GCMFormTableViewController *weakSelf = self;
    dataSource.completionBlock = ^(NSString *key, GCMFormTableViewDataSource *dataSource) {
      [weakSelf handleActionWithKey:key];
    };

    [self.tableView reloadData];
  }
}

- (void)setConfirmationTitle:(NSString *)confirmationTitle {
  if ( [_confirmationTitle isEqualToString: confirmationTitle] ) {
    return;
  }
  _confirmationTitle = confirmationTitle;
  [self addConfirmationButton];
}

- (void)setShowCancelButton:(BOOL)showCancelButton {
  if ( _showCancelButton == showCancelButton ) {
    return;
  }
  _showCancelButton = showCancelButton;
  [self updateCancelButton];
}

- (void)updateCancelButton {
  // Clear the existing button
  self.navigationItem.leftBarButtonItem = nil;
  
  // Add a new button if appropriate
  if ( self.showCancelButton ) {
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:self.cancellationTitle
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self action:@selector(cancellationTapped:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
  }
}

- (void)addConfirmationButton {
  UIBarButtonItem *confirmationButton = [[UIBarButtonItem alloc] initWithTitle:self.confirmationTitle
                                                                         style:UIBarButtonItemStyleDone
                                                                        target:self
                                                                        action:@selector(confirmationTapped:)];
  self.navigationItem.rightBarButtonItem = confirmationButton;
  [self updateConfirmationButtonState];
}

- (void)updateConfirmationButtonState {
  self.navigationItem.rightBarButtonItem.enabled = self.dataSource.dataIsValid;
}

- (void)confirmationTapped:(UIBarButtonItem *)button {
  [self submitForm];
}

- (void)submitForm {
  [self reportResult:kGCMFormTableViewResultConfirmed];
}

- (void)cancellationTapped:(UIBarButtonItem *)button {
  [self reportResult:kGCMFormTableViewResultCancel];
}

- (void)handleActionWithKey:(NSString *)key {
  GCMFormTableViewDataSource *dataSource = self.dataSource;
  GCActionButtonRowConfig *actionConfig = (id)[dataSource rowConfigWithKey:key];
  [self reportResult:kGCMFormTableViewResultUser + actionConfig.tag];
}

- (void)reportResult:(GCMFormTableViewResult)result {
  GCMFormTableViewDataSource *dataSource = self.dataSource;
  NSMutableDictionary *info = [@{kGCMFormTableViewControllerResultKey : @(result),
                                 kGCMFormTableViewControllerTagKey : @(self.tag)} mutableCopy];
  
  if ( result != kGCMFormTableViewResultCancel ) {
    info[kGCMFormTableViewDataKey] = dataSource.values;
  }
  
  if ( self.userInfo ) {
    info[kGCMFormTableViewControllerUserInfoKey] = self.userInfo;
  }
  [self.delegate formTableViewController:self reportsResult:result andInfo:info];
}

- (BOOL)disablesAutomaticKeyboardDismissal {
  return NO;
}

@end
