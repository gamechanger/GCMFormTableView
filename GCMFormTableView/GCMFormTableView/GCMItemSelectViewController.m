//
//  GCMItemSelectViewController.m
//  GameChanger
//
//  Created by Jerry Hsu on 10/28/13.
//  Copyright (c) 2013 GameChanger. All rights reserved.
//

#import "GCMItemSelectViewController.h"
#import "GCMDeviceInfo.h"

static NSString *kDataSourceSelectedIndexPathKey = @"selectedIndexPath";

@interface GCMItemSelectViewController () <GCMItemSelectTableViewDelegate> {
  GCMItemSelectTableViewDataSource *_dataSource;
}

@end

@implementation GCMItemSelectViewController

- (id)init {
  return [self initWithTableViewStyle:UITableViewStyleGrouped];
}

- (id)initWithTableViewStyle:(UITableViewStyle)tableViewStyle {
  self = [super initWithNibName:nil bundle:nil];
  if ( self ) {
    _tableViewStyle = tableViewStyle;
    _confirmationTitle = @"Next";
    _cancellationTitle = @"Cancel";
  }
  return self;
}

- (void)dealloc {
  [_dataSource removeObserver:self forKeyPath:kDataSourceSelectedIndexPathKey];
}

- (void)loadView {
  self.view = [[UITableView alloc] initWithFrame:CGRectZero style:self.tableViewStyle];
}

- (UITableView *)tableView {
  return (UITableView *) self.view;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.tableView.delegate = self.dataSource;
  self.tableView.dataSource = self.dataSource;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  if ( self.requireSelectionConfirmation ) {
    [self addConfirmationButton];
  }
  [self scrollSelectedPathToVisibleAnimated:NO];
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  [self scrollSelectedPathToVisibleAnimated:NO];
}

- (void)scrollSelectedPathToVisibleAnimated:(BOOL)animated {
 [self.tableView reloadData];
  NSIndexPath *selectedIndexPath = self.dataSource.selectedIndexPath;
  if ( selectedIndexPath && [self.dataSource itemAtIndexPath:selectedIndexPath] ) {
    [self.tableView scrollToRowAtIndexPath:selectedIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:animated];
  }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  [self updateConfirmationButtonState];
}

- (GCMItemSelectTableViewDataSource *)dataSource {
  if ( _dataSource == nil ) {
    _dataSource = [[GCMItemSelectTableViewDataSource alloc] init];
    _dataSource.delegate = self;
    [_dataSource addObserver:self forKeyPath:kDataSourceSelectedIndexPathKey options:NSKeyValueObservingOptionNew context:nil];
  }
  return _dataSource;
}

- (void)setDataSource:(GCMItemSelectTableViewDataSource *)dataSource {
  if ( _dataSource == dataSource ) {
    return;
  }
  [_dataSource removeObserver:self forKeyPath:kDataSourceSelectedIndexPathKey];
  _dataSource.delegate = nil;
  _dataSource = dataSource;
  dataSource.delegate = self;
  [dataSource addObserver:self forKeyPath:kDataSourceSelectedIndexPathKey options:NSKeyValueObservingOptionNew context:nil];
  self.tableView.dataSource = dataSource;
  self.tableView.delegate = dataSource;
  [self.tableView reloadData];
}

- (void)setConfirmationTitle:(NSString *)confirmationTitle {
  if ( [_confirmationTitle isEqualToString: confirmationTitle] ) {
    return;
  }
  _confirmationTitle = confirmationTitle;
  if ( self.requireSelectionConfirmation ) {
    [self addConfirmationButton];
  }
}

- (void)setRequireSelectionConfirmation:(BOOL)requireSelectionConfirmation {
  if ( _requireSelectionConfirmation == requireSelectionConfirmation ) {
    return;
  }
  _requireSelectionConfirmation = requireSelectionConfirmation;
  if ( requireSelectionConfirmation ) {
    [self addConfirmationButton];
  } else {
    self.navigationItem.rightBarButtonItem = nil;
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
  self.navigationItem.rightBarButtonItem.enabled = (self.dataSource.selectedIndexPath != nil);
}

- (void)confirmationTapped:(UIBarButtonItem *)button {
  [self reportSelectedItemWithConfirmation:YES];
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

- (void)cancellationTapped:(UIBarButtonItem *)button {
  if ( [self.delegate respondsToSelector:@selector(cancelledItemSelectViewController:)] ) {
    [self.delegate cancelledItemSelectViewController:self];
  }
}

- (void)didSelectItemSelectDataSource:(GCMItemSelectTableViewDataSource *)dataSource {
  if ( self.requireSelectionConfirmation ) {
    [self updateConfirmationButtonState];
  }
  [self reportSelectedItem];
}

- (void)didSelectActionWithTag:(NSInteger)tag andUserInfo:(id)userInfo fromItemSelectDataSource:(GCMItemSelectTableViewDataSource *)dataSource {
  if ( [self.delegate respondsToSelector:@selector(selectedActionWithTag:andUserInfo:inItemSelectViewController:)] ) {
    [self.delegate selectedActionWithTag:tag andUserInfo:userInfo inItemSelectViewController:self];
  }
}

- (void)reportSelectedItem {
  [self reportSelectedItemWithConfirmation:NO];
}

- (void)reportSelectedItemWithConfirmation:(BOOL)confirmation {
  [self.delegate selectedItemInItemSelectViewController:self andConfirmedSelection:confirmation];
}

@end
