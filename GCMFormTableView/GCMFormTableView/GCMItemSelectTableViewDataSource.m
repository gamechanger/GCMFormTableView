//
//  GCMItemSelectTableViewDataSource.m
//  GameChanger
//
//  Created by Jerry Hsu on 10/29/13.
//  Copyright (c) 2013 GameChanger. All rights reserved.
//

#import "GCMItemSelectTableViewDataSource.h"
#import "GCMDeviceInfo.h"
#import "NSAttributedString+GameChangerMedia.h"

NSString *const kGCMItemSelectImageKey = @"image";
NSString *const kGCMItemSelectDisabledItemKey = @"disabledItem";

@interface GCMItemSelectTableViewDataSource ()

@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, strong) NSMutableArray *sectionHeaderTitles;
@property (nonatomic, strong) NSMutableArray *sectionFooterTitles;
@property (nonatomic, strong) NSMutableDictionary *indexPathToTagMap;
@property (nonatomic, strong) NSMutableDictionary *indexPathToUserInfoMap;
@property (nonatomic, strong) NSMutableDictionary *indexPathToConfigMap;

@end

@implementation GCMItemSelectTableViewDataSource

- (id)init {
  self = [super init];
  if ( self ) {
    _sections = [[NSMutableArray alloc] init];
    _sectionHeaderTitles = [[NSMutableArray alloc] init];
    _sectionFooterTitles = [[NSMutableArray alloc] init];
    _indexPathToTagMap = [[NSMutableDictionary alloc] init];
    _indexPathToUserInfoMap = [[NSMutableDictionary alloc] init];
    _indexPathToConfigMap = [[NSMutableDictionary alloc] init];
  }
  return self;
}

#pragma mark - Data manipulation

- (void)clear {
  [_sections removeAllObjects];
  [_sectionHeaderTitles removeAllObjects];
  [_sectionFooterTitles removeAllObjects];
  [_indexPathToConfigMap removeAllObjects];
  [_indexPathToTagMap removeAllObjects];
  [_indexPathToUserInfoMap removeAllObjects];
}

- (void)addSectionWithAttributedHeaderTitle:(NSAttributedString *)headerTitle
                   andAttributedFooterTitle:(NSAttributedString *)footerTitle {
  [self.sectionHeaderTitles addObject:(headerTitle ? headerTitle : [NSNull null])];
  [self.sectionFooterTitles addObject:(footerTitle ? footerTitle : [NSNull null])];
  [self.sections addObject:[[NSMutableArray alloc] init]];
}

- (void)addSectionWithHeaderTitle:(NSString *)headerTitle andFooterTitle:(NSString *)footerTitle {
  NSMutableAttributedString *attrHeader = nil;
  if ( headerTitle ) {
    attrHeader = [[NSMutableAttributedString alloc] initWithString:headerTitle
                                                        attributes:[self defaultHeaderFooterTextAttributes]];
  }
  NSMutableAttributedString *attrFooter = nil;
  if ( footerTitle ) {
    attrFooter = [[NSMutableAttributedString alloc] initWithString:footerTitle
                                                        attributes:[self defaultHeaderFooterTextAttributes]];
  }

  [self addSectionWithAttributedHeaderTitle:attrHeader
                   andAttributedFooterTitle:attrFooter];
}

- (void)setAttributedFooterTitle:(NSAttributedString *)footerTitle forSection:(NSUInteger)section {
  NSAssert(section < [self.sectionFooterTitles count], @"Section is not valid");
  self.sectionFooterTitles[section] = footerTitle;
}

- (void)setFooterTitle:(NSString *)footerTitle forSection:(NSUInteger)section {
  NSMutableAttributedString *attrFooter = nil;
  attrFooter = [[NSMutableAttributedString alloc] initWithString:footerTitle
                                                      attributes:[self defaultHeaderFooterTextAttributes]];
  [self setAttributedFooterTitle:attrFooter forSection:section];
}

- (void)addSectionBreak {
  [self addSectionWithHeaderTitle:nil andFooterTitle:nil];
}

- (BOOL)hasItems {
  for ( NSArray *section in self.sections ) {
    if ( section.count > 0 ) {
      return YES;
    }
  }
  return NO;
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
  NSAssert([self.sections count] <= 1, @"selectedIndex cannot be used with multiple sections");
  if ( selectedIndex == NSNotFound ) {
    self.selectedIndexPath = nil;
  } else {
    self.selectedIndexPath = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
  }
}

- (NSUInteger)selectedIndex {
  NSAssert([self.sections count] <= 1, @"selectedIndex cannot be used with multiple sections");
  if ( self.selectedIndexPath ) {
    return self.selectedIndexPath.row;
  } else {
    return NSNotFound;
  }
}

- (NSInteger)tagForSelectedItem {
  NSIndexPath *selectedIndexPath = self.selectedIndexPath;
  if ( selectedIndexPath ) {
    return [self tagForItemAtIndexPath:selectedIndexPath];
  } else {
    return 0;
  }
}

- (id)userInfoForSelectedItem {
  NSIndexPath *selectedIndexPath = self.selectedIndexPath;
  if ( selectedIndexPath ) {
    return [self userInfoForItemAtIndexPath:selectedIndexPath];
  } else {
    return nil;
  }
}

- (void)addItem:(NSString *)itemName withTag:(NSInteger)tag andUserInfo:(id)userInfo {
  [self addItem:itemName andConfig:nil withTag:tag andUserInfo:userInfo];
}

- (void)addItem:(NSString *)itemName withTag:(NSInteger)tag {
  [self addItem:itemName andConfig:nil withTag:tag andUserInfo:nil];
}

- (void)addItem:(NSString *)itemName withUserInfo:(id)userInfo {
  [self addItem:itemName andConfig:nil withTag:0 andUserInfo:userInfo];
}

- (void)addItem:(NSString *)itemName andConfig:(NSDictionary *)config withTag:(NSInteger)tag andUserInfo:(id)userInfo {
  [self addAttributedItem:[self defaultAttributedStringForString:itemName] andConfig:config withTag:tag andUserInfo:userInfo];
}

- (void)addAttributedItem:(NSAttributedString *)itemName withTag:(NSInteger)tag andUserInfo:(id)userInfo {
  [self addAttributedItem:itemName andConfig:nil withTag:tag andUserInfo:userInfo];
}

- (void)addAttributedItem:(NSAttributedString *)itemName withTag:(NSInteger)tag {
  [self addAttributedItem:itemName andConfig:nil withTag:tag andUserInfo:nil];
}

- (void)addAttributedItem:(NSAttributedString *)itemName withUserInfo:(id)userInfo {
  [self addAttributedItem:itemName andConfig:nil withTag:0 andUserInfo:userInfo];
}

- (void)addAttributedItem:(NSAttributedString *)itemName andConfig:(NSDictionary *)config withTag:(NSInteger)tag andUserInfo:(id)userInfo {
  if ( [self.sections count] == 0 ) {
    [self addSectionBreak];
  }
  NSInteger section = [self.sections count] - 1;
  NSInteger row = [self.sections[section] count];
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
  [self.sections[section] addObject:(itemName ? itemName : [[NSAttributedString alloc] initWithString:@""])];
  self.indexPathToTagMap[indexPath] = @(tag);
  if ( userInfo ) {
    self.indexPathToUserInfoMap[indexPath] = userInfo;
  }
  if ( config ) {
    self.indexPathToConfigMap[indexPath] = config;
  }
}

- (NSAttributedString *)defaultAttributedStringForString:(NSString *)title {
  NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:title];
  [attributedTitle addAttributeForTextColor:[UIColor blackColor]];
  [attributedTitle addAttributeForFont:[UIFont systemFontOfSize:18.0]];
  [attributedTitle addAttributeForTextAlignment:NSTextAlignmentLeft lineBreakMode:NSLineBreakByWordWrapping];
  return attributedTitle;
}

- (NSString *)itemAtIndexPath:(NSIndexPath *)indexPath {
  return [[self attributedItemAtIndexPath:indexPath] string];
}

- (NSAttributedString *)attributedItemAtIndexPath:(NSIndexPath *)indexPath {
  NSInteger section = indexPath.section;
  NSInteger row = indexPath.row;
  if ( section >= [self.sections count] ) {
    return nil;
  }
  NSArray *rows = self.sections[section];
  if ( row >= [rows count] ) {
    return nil;
  }
  return rows[row];
}

- (NSInteger)tagForItemAtIndexPath:(NSIndexPath *)indexPath {
  return [self.indexPathToTagMap[indexPath] integerValue];
}

- (NSIndexPath *)indexPathForItemWithTag:(NSInteger)tag {
  __block NSIndexPath *foundPath = nil;
  NSNumber *targetTag = @(tag);
  [self.indexPathToTagMap enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath, NSNumber *testTag, BOOL *stop) {
    if ( [targetTag isEqualToNumber:testTag] ) {
      foundPath = indexPath;
      *stop = YES;
    }
  }];
  return foundPath;
}

- (id)userInfoForItemAtIndexPath:(NSIndexPath *)indexPath {
  return self.indexPathToUserInfoMap[indexPath];
}

- (NSIndexPath *)indexPathForItemWithUserInfo:(id)userInfo {
  __block NSIndexPath *foundPath = nil;
  [self.indexPathToUserInfoMap enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath, id testUserInfo, BOOL *stop) {
    if ( [userInfo isEqual:testUserInfo] ) {
      foundPath = indexPath;
      *stop = YES;
    }
  }];
  return foundPath;
}

- (BOOL)containsItemWithUserInfo:(id)userInfo {
  NSArray *userInfos = [self.indexPathToUserInfoMap allValues];
  return [userInfos containsObject:userInfo];
}


- (NSDictionary *)defaultHeaderFooterTextAttributes {
  NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
  [paragraphStyle setAlignment:NSTextAlignmentLeft];
  [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];

  return @{NSFontAttributeName : [UIFont systemFontOfSize:16.f],
           NSParagraphStyleAttributeName : paragraphStyle};
}

#pragma mark - UITableView

static NSString* kCellReuseId = @"itemSelectCell";
static NSString* kHeaderReuseId = @"header";
static NSString* kFooterReuseId = @"footer";

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self.sections[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  if ( self.sectionHeaderTitles[section] != [NSNull null] ) {
    return 40.0;
  } else {
    return 0.0;
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
  if ( self.sectionFooterTitles[section] != [NSNull null] ) {
    NSAttributedString *footerTitle = self.sectionFooterTitles[section];
    CGFloat height = [footerTitle integralHeightGivenWidth:tableView.bounds.size.width];
    
    return height + 40.0;
  } else {
    return 0.0;
  }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  if ( self.sectionHeaderTitles[section] != [NSNull null] ) {
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kHeaderReuseId];
    if ( headerView == nil ) {
      headerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:kHeaderReuseId];
    }
    headerView.textLabel.numberOfLines = 0;
    headerView.textLabel.attributedText = self.sectionHeaderTitles[section];
    return headerView;
  } else {
    return nil;
  }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
  if ( self.sectionFooterTitles[section] != [NSNull null] ) {
    UITableViewHeaderFooterView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kFooterReuseId];
    if ( footerView == nil ) {
      footerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:kFooterReuseId];
    }
    footerView.textLabel.numberOfLines = 0;
    footerView.textLabel.attributedText = self.sectionFooterTitles[section];
    return footerView;
  } else {
    return nil;
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  CGFloat tableWidth = tableView.bounds.size.width;
  CGFloat cellWidth;
  CGFloat inset = 20.0; // Initial left padding.
  inset += IOS7_OR_GREATER ? 38.0 : 24.0; // For accessoryView.
  cellWidth = tableWidth - inset;
  return MAX(44.0, [[self attributedItemAtIndexPath:indexPath] integralHeightGivenWidth:cellWidth] + 20.0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseId];
  if ( cell == nil ) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellReuseId];
  }
  cell.textLabel.attributedText = [self attributedItemAtIndexPath:indexPath];
  cell.textLabel.numberOfLines = 0;
  cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
  NSDictionary *config = self.indexPathToConfigMap[indexPath];
  cell.imageView.image = config[kGCMItemSelectImageKey];
  if ( config[kGCMItemSelectDisabledItemKey] ) {
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.contentView.alpha = 0.5;
  }

  BOOL checked = [self.selectedIndexPath isEqual:indexPath];
  [self configureCell:cell withCheckbox:checked];
  return cell;
}

- (void)configureCell:(UITableViewCell *)cell withCheckbox:(BOOL)checkbox {
  if ( checkbox ) {
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    cell.accessoryView = nil;
  } else {
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, IOS7_OR_GREATER ? 24.0 : 10.0, 1.0)];
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  NSDictionary *config = self.indexPathToConfigMap[indexPath];
  if ( config[kGCMItemSelectDisabledItemKey] ) {
    return;
  }

  if ( ! [self.selectedIndexPath isEqual:indexPath] ) {
    if ( self.selectedIndexPath ) {
      UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:self.selectedIndexPath];
      [self configureCell:oldCell withCheckbox:NO];
    }
    self.selectedIndexPath = indexPath;
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:self.selectedIndexPath];
    [self configureCell:newCell withCheckbox:YES];
  }
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  [self reportSelectedIndexPath];
}

- (void)reportSelectedIndexPath {
  [self.delegate didSelectItemSelectDataSource:self];
}

@end
