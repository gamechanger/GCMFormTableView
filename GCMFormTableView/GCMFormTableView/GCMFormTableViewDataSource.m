//
//  GCMFormTableViewDataSource.m
//  GameChanger
//
//  Created by Jerry Hsu on 10/30/13.
//  Copyright (c) 2013 GameChanger. All rights reserved.
//

#import "GCMFormTableViewDataSource.h"
#import "NSString+GameChangerMedia.h"
#import "GCMFormSectionConfig+Protected.h"

@interface GCMFormTableViewDataSource () <GCMFormRowConfigDelegate>

@property (nonatomic, assign) BOOL dataValidationRanOnce;
@property (nonatomic, assign, readwrite) BOOL dataIsValid;
@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, strong) NSMutableDictionary *hiddenData;

@property (nonatomic, strong) NSIndexPath *firstResponderIndexPath;

@end

static NSString *kRowValueKey = @"value";

@implementation GCMFormTableViewDataSource

- (id)init {
  self = [super init];
  if ( self ) {
    _sections = [[NSMutableArray alloc] init];
    _hiddenData = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (void)dealloc {
  [self.sections enumerateObjectsUsingBlock:^(GCMFormSectionConfig *sectionConfig, NSUInteger idx, BOOL *stop) {
    [sectionConfig.rows enumerateObjectsUsingBlock:^(GCMFormRowConfig *rowConfig, NSUInteger idx, BOOL *stop) {
      rowConfig.delegate = nil;
      [rowConfig removeObserver:self forKeyPath:kRowValueKey];
    }];
  }];
}

// Only thing currently observed are @"value" property of GCMFormRowConfig objects.
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(GCMFormRowConfig *)rowConfig change:(NSDictionary *)change context:(void *)context {
  if ( ! [change[NSKeyValueChangeOldKey] isEqual:change[NSKeyValueChangeNewKey]] ) {
    [self executeOnChangeBlockForKey:rowConfig.key];
    [self recalculateDataIsValid];
  }
}

- (NSDictionary *)values {
  NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
  for ( GCMFormSectionConfig *section in _sections ) {
    for ( GCMFormRowConfig *row in section.rows ) {
      id value = row.value;
      if ( value ) {
        result[row.key] = value;
      }
    }
  }
  [result addEntriesFromDictionary:self.hiddenData];
  return result;
}

- (NSArray *)allRowConfigs {
  NSMutableArray *result = [[NSMutableArray alloc] init];
  for ( GCMFormSectionConfig *section in _sections ) {
    for ( GCMFormRowConfig *row in section.rows ) {
      [result addObject:row];
    }
  }
  return result;
}

- (BOOL)areRequiredValuesPresent {
  for ( GCMFormSectionConfig *section in _sections ) {
    for ( GCMFormRowConfig *row in section.rows ) {
      if ( row.required ) {
        if ( ! row.value ) {
          return NO;
        }
        if ( [row.value isKindOfClass:[NSString class]] ) {
          if ( [row.value isEmptyOrWhitespace] ) {
            return NO;
          }
        }
      }
    }
  }
  return YES;
}

- (void)setValidationBlock:(GCMFormTableViewValidationBlock)validationBlock {
  _validationBlock = validationBlock;
  [self recalculateDataIsValid];
}

- (void)executeOnChangeBlockForKey:(NSString *)key {
  if ( self.onChangeBlock ) {
    self.onChangeBlock(key, self);
  }
}

- (BOOL)dataIsValid {
  if ( ! self.dataValidationRanOnce ) {
    [self recalculateDataIsValid];
  }
  return _dataIsValid;
}

- (void)recalculateDataIsValid {
  self.dataValidationRanOnce = YES;
  if ( self.validationBlock ) {
    self.dataIsValid = self.validationBlock(self.values) && [self areRequiredValuesPresent];
  } else {
    self.dataIsValid = [self areRequiredValuesPresent];
  }
}

- (void)setTableView:(UITableView *)tableView {
  if ( _tableView == tableView ) {
    return;
  }
  _tableView = tableView;
  [self configureTableView:tableView];
}

#pragma mark - Configuration methods

- (void)addSectionConfig:(GCMFormSectionConfig *)sectionConfig {
  [self.sections addObject:sectionConfig];
}

- (void)addRowConfig:(GCMFormRowConfig *)rowConfig {
  if ( [self.sections count] == 0 ) {
    [self addSectionConfig:[[GCMFormSectionConfig alloc] initWithTitle:nil]];
  }
  GCMFormSectionConfig *sectionConfig = [self.sections lastObject];
  [sectionConfig addRowConfig:rowConfig];
  rowConfig.delegate = self;
  [rowConfig addObserver:self forKeyPath:kRowValueKey options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
}

- (void)setHiddenKey:(NSString *)key value:(id)value {
  if ( value ) {
    self.hiddenData[key] = value;
  } else {
    [self.hiddenData removeObjectForKey:key];
  }
}

- (GCMFormRowConfig *)rowConfigWithKey:(NSString *)key {
  NSIndexPath *indexPath = [self indexPathForRowConfigWithKey:key];
  if ( indexPath == nil ) {
    return nil;
  }
  return [self rowAtIndexPath:indexPath];
}

- (void)replaceRowConfigWithKey:(NSString *)key withRowConfig:(GCMFormRowConfig *)newRowConfig {
  NSIndexPath *indexPath = [self indexPathForRowConfigWithKey:key];
  NSAssert(indexPath.section != NSNotFound && indexPath.row != NSNotFound, @"replaceRowConfigWithKey:withRowConfig: couldn't find rowConfig with key %@", key);

  [self replaceRowConfigAtIndexPath:indexPath withRowConfig:newRowConfig];
  [newRowConfig rebuildCell:[self.tableView cellForRowAtIndexPath:indexPath]];
}

- (void)replaceRowConfigAtIndexPath:(NSIndexPath *)indexPath withRowConfig:(GCMFormRowConfig *)newRowConfig {
  // In the event of a non-existant indexPath, just do nothing.
  NSInteger section = indexPath.section;
  NSInteger row = indexPath.row;
  if ( section >= [self.sections count] ) {
    return;
  }
  GCMFormSectionConfig *sectionConfig = self.sections[section];
  NSArray *rows = sectionConfig.rows;
  if ( row >= [rows count] ) {
    return;
  }
  GCMFormRowConfig *oldRowConfig = rows[row];
  oldRowConfig.delegate = nil;
  [oldRowConfig removeObserver:self forKeyPath:kRowValueKey];
  [sectionConfig replaceRowConfigAtIndex:row withRowConfig:newRowConfig];
  newRowConfig.delegate = self;
  [newRowConfig addObserver:self forKeyPath:kRowValueKey options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
}

- (NSIndexPath *)indexPathForRowConfigAfterRowConfigAtIndexPath:(NSIndexPath *)indexPath thatMatchesPredicate:(NSPredicate *)predicate {
  NSInteger startSection = indexPath ? indexPath.section : -1;
  NSInteger startRow = indexPath ? indexPath.row : -1;
  __block NSInteger foundSection = NSNotFound;
  __block NSInteger foundRow = NSNotFound;

  [self.sections enumerateObjectsUsingBlock:^(GCMFormSectionConfig *sectionConfig, NSUInteger sectionIndex, BOOL *stop) {
    if ( (NSInteger)sectionIndex < startSection ) {
      return;
    }
    [sectionConfig.rows enumerateObjectsUsingBlock:^(GCMFormRowConfig *rowConfig, NSUInteger rowIndex, BOOL *stop) {
      if ( sectionIndex == startSection && (NSInteger)rowIndex <= startRow ) {
        return;
      }
      if ( [predicate evaluateWithObject:rowConfig] ) {
        foundSection = sectionIndex;
        foundRow = rowIndex;
        *stop = YES;
      }
    }];
    if ( foundSection != NSNotFound ) {
      *stop = YES;
    }
  }];
  if ( foundSection == NSNotFound ) {
    return nil;
  } else {
    return [NSIndexPath indexPathForRow:foundRow inSection:foundSection];
  }
}

- (NSIndexPath *)indexPathForRowConfigWithKey:(NSString *)key {
  return [self indexPathForRowConfigAfterRowConfigAtIndexPath:nil
                                         thatMatchesPredicate:[NSPredicate predicateWithBlock:^BOOL(GCMFormRowConfig *rowConfig, NSDictionary *bindings) {
    return [rowConfig.key isEqualToString:key];
  }]];
}

- (NSIndexPath *)indexPathForRowConfigFollowingRowConfigAtIndexPath:(NSIndexPath *)indexPath {
  NSInteger section = indexPath.section;
  NSInteger row = indexPath.row;
  NSIndexPath *testIndexPath = [NSIndexPath indexPathForRow:row+1 inSection:section];
  GCMFormRowConfig *rowConfig = [self rowAtIndexPath:testIndexPath];
  if ( rowConfig ) {
    return testIndexPath;
  }
  testIndexPath = [NSIndexPath indexPathForRow:0 inSection:section+1];
  rowConfig = [self rowAtIndexPath:testIndexPath];
  if ( rowConfig ) {
    return testIndexPath;
  }
  return nil;
}

#pragma mark - TableView methods

- (void)configureTableView:(UITableView *)tableView {
  [tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:kGCMFormSectionHeaderReuseId];
  [tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:kGCMFormSectionFooterReuseId];
  NSMutableSet *reuseIdentifiers = [[NSMutableSet alloc] init];
  [self.allRowConfigs enumerateObjectsUsingBlock:^(GCMFormRowConfig *config, NSUInteger idx, BOOL *stop) {
    [reuseIdentifiers addObject:config.cellReuseId];
  }];
  [reuseIdentifiers enumerateObjectsUsingBlock:^(NSString *reuseId, BOOL *stop) {
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseId];
  }];
}

- (GCMFormSectionConfig *)sectionAtIndex:(NSInteger)index {
  if ( index < [self.sections count] ) {
    return self.sections[index];
  } else {
    return nil;
  }
}

- (GCMFormRowConfig *)rowAtIndexPath:(NSIndexPath *)indexPath {
  GCMFormSectionConfig *sectionConfig = [self sectionAtIndex:indexPath.section];
  NSInteger rowIndex = indexPath.row;
  NSArray *rows = sectionConfig.rows;
  if ( rowIndex < [rows count] ) {
    return rows[rowIndex];
  } else {
    return nil;
  }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self sectionAtIndex:section].rows.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  GCMFormSectionConfig *sectionConfig = [self sectionAtIndex:section];
  if ( sectionConfig.title != nil ) {
    return 40.0;
  } else {
    return 0.0;
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
  GCMFormSectionConfig *sectionConfig = [self sectionAtIndex:section];
  if ( sectionConfig.footerTitle != nil ) {
    UITableViewHeaderFooterView *footerView = (UITableViewHeaderFooterView *)[sectionConfig makeFooterViewForTableView:tableView];
    return [sectionConfig.footerTitle heightForStringUsingWidth:self.tableView.bounds.size.width andFont:footerView.textLabel.font] + 30.f;
  } else {
    return 0.0;
  }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  GCMFormSectionConfig *sectionConfig = [self sectionAtIndex:section];
  return [sectionConfig makeHeaderViewForTableView:tableView];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
  GCMFormSectionConfig *sectionConfig = [self sectionAtIndex:section];
  return [sectionConfig makeFooterViewForTableView:tableView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  GCMFormRowConfig *rowConfig = [self rowAtIndexPath:indexPath];
  return rowConfig.rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  return [[self rowAtIndexPath:indexPath] makeCellForUITableView:tableView forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  GCMFormRowConfig *rowConfig = [self rowAtIndexPath:indexPath];
  if ( rowConfig.enabled ) {
    [rowConfig didTapCell:[tableView cellForRowAtIndexPath:indexPath]];
  }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
  [self.tableView endEditing:YES];
}

#pragma mark - GCMFormRowConfigDelegate

- (void)centerTableViewOnActiveCell {
  if ( self.firstResponderIndexPath ) {
    [self.tableView scrollToRowAtIndexPath:self.firstResponderIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
  }
}

- (void)formRowConfigBeganEditing:(GCMFormRowConfig *)rowConfig {
  // Make sure cell is visible
  NSIndexPath *indexPath = [self indexPathForRowConfigWithKey:rowConfig.key];
  if ( indexPath == nil ) {
    return;
  }
  self.firstResponderIndexPath = indexPath;
  [self centerTableViewOnActiveCell];
}

- (void)formRowConfigEndedEditing:(GCMFormRowConfig *)rowConfig {
  self.firstResponderIndexPath = nil;
  NSIndexPath *indexPath = [self indexPathForRowConfigWithKey:rowConfig.key];
  if ( indexPath == nil ) {
    return;
  }
  // Find next rowConfig that isEditable
  NSIndexPath *nextIndexPath = [self indexPathForRowConfigFollowingRowConfigAtIndexPath:indexPath];
  GCMFormRowConfig *nextRowConfig = [self rowAtIndexPath:nextIndexPath];
  if ( nextRowConfig.isEditable ) {
    [nextRowConfig didTapCell:[self.tableView cellForRowAtIndexPath:nextIndexPath]];
  }
}

- (void)formRowConfig:(GCMFormRowConfig *)rowConfig wantsToPushViewController:(UIViewController *)controller {
  [self.parentController.navigationController pushViewController:controller animated:YES];
}

- (void)formRowConfigWantsToPopViewController:(GCMFormRowConfig *)rowConfig {
  [self.parentController.navigationController popViewControllerAnimated:YES];
}

- (void)formRowConfigReportsAction:(GCMFormRowConfig *)rowConfig {
  if ( self.completionBlock ) {
    self.completionBlock(rowConfig.key, self);
  }
}

@end
