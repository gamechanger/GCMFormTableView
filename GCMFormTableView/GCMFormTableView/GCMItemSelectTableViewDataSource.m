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
#import "GCMItemSelectTableViewCell.h"

NSString *const kGCMItemSelectImageKey = @"image";
NSString *const kGCMItemSelectDisabledItemKey = @"disabledItem";
NSString *const kGCMItemSelectActionItemKey = @"actionItem";
NSString *const kGCMItemDetailTextKey = @"detailText";

NSUInteger const kGCItemSelectHeaderLabelTag = 1000;
NSUInteger const kGCItemSelectFooterLabelTag = 2000;

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

- (NSAttributedString *)defaultAttributedDetailString:(NSString *)detailString {
  NSMutableAttributedString *attributedDetail = [[NSMutableAttributedString alloc] initWithString:detailString];
  [attributedDetail addAttributeForTextColor:[UIColor colorWithRed:146.f/255.f green:146.f/255.f blue:146.f/255.f alpha:1.000]];
  [attributedDetail addAttributeForFont:[UIFont systemFontOfSize:15.0]];
  [attributedDetail addAttributeForTextAlignment:NSTextAlignmentRight lineBreakMode:NSLineBreakByWordWrapping];
  return attributedDetail;
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

- (CGFloat)horizontalHeaderFooterPadding {
  return PRE_IOS7 && (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 40.f : 10.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  if ( self.sectionHeaderTitles[section] != [NSNull null] ) {
    NSAttributedString *headerTitle = self.sectionHeaderTitles[section];
    CGFloat height = [headerTitle integralHeightGivenWidth:tableView.bounds.size.width - [self horizontalHeaderFooterPadding] * 2.0];
    return height + 20.0;
  } else {
    return 0.0;
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
  if ( self.sectionFooterTitles[section] != [NSNull null] ) {
    NSAttributedString *footerTitle = self.sectionFooterTitles[section];
    CGFloat height = [footerTitle integralHeightGivenWidth:tableView.bounds.size.width - [self horizontalHeaderFooterPadding] * 2.0];
    
    return height + (IOS7_OR_GREATER ? 20.0 : 40.0);
  } else {
    return 0.0;
  }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  if ( self.sectionHeaderTitles[section] != [NSNull null] ) {
    NSAttributedString *headerTitle = self.sectionHeaderTitles[section];
    CGFloat height = [headerTitle integralHeightGivenWidth:tableView.bounds.size.width];
    
    CGFloat xInset = [self horizontalHeaderFooterPadding];
    CGFloat yInset = 10.0f;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, tableView.frame.size.width, height + yInset * 2)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(xInset, yInset, headerView.frame.size.width - xInset * 2, headerView.frame.size.height - yInset * 2)];
    label.backgroundColor = [UIColor clearColor];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    label.numberOfLines = 0;
    label.attributedText = self.sectionHeaderTitles[section];
    label.tag = kGCItemSelectHeaderLabelTag;
    [headerView addSubview:label];
    return headerView;
  } else {
    return nil;
  }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
  if ( self.sectionFooterTitles[section] != [NSNull null] ) {
    NSAttributedString *footerTitle = self.sectionFooterTitles[section];
    CGFloat height = [footerTitle integralHeightGivenWidth:tableView.bounds.size.width];
    
    CGFloat xInset = [self horizontalHeaderFooterPadding];
    CGFloat yInset = 10.0f;
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, tableView.frame.size.width, height + yInset * 2)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(xInset, yInset, footerView.frame.size.width - xInset * 2.00f, footerView.frame.size.height - yInset * 2)];
    label.backgroundColor = [UIColor clearColor];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    label.numberOfLines = 0;
    label.attributedText = footerTitle;
    label.tag = kGCItemSelectFooterLabelTag;
    [footerView addSubview:label];
    return footerView;
  } else {
    return nil;
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSIndexPath *indexPathCopy = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
  BOOL checked = [self.selectedIndexPath isEqual:indexPathCopy];
  NSDictionary *config = self.indexPathToConfigMap[indexPathCopy];
  BOOL hasDetailtext = config[kGCMItemDetailTextKey] != nil;
  BOOL hasImage = config[kGCMItemSelectImageKey] != nil;
  return [GCMItemSelectTableViewCell cellHeightForAttributedText:[self attributedItemAtIndexPath:indexPathCopy]
                                                   withCellWidth:tableView.bounds.size.width
                                                       isChecked:checked
                                                   hasDetailtext:hasDetailtext
                                                        hasImage:hasImage
                                                     usingInsets:[GCMItemSelectTableViewCell defaultInsets]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  GCMItemSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseId];
  if ( cell == nil ) {
    cell = [[GCMItemSelectTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kCellReuseId];
  }
  cell.textLabel.attributedText = [self attributedItemAtIndexPath:indexPath];
  NSDictionary *config = self.indexPathToConfigMap[indexPath];
  cell.imageView.image = config[kGCMItemSelectImageKey];
  if ( config[kGCMItemSelectDisabledItemKey] ) {
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.contentView.alpha = 0.5;
  }
  if ( config[kGCMItemDetailTextKey] ) {
    cell.detailTextLabel.attributedText = [self defaultAttributedDetailString:config[kGCMItemDetailTextKey]];
  }
  
  cell.isChecked = [self.selectedIndexPath isEqual:indexPath];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  NSDictionary *config = self.indexPathToConfigMap[indexPath];
  if ( config[kGCMItemSelectDisabledItemKey] ) {
    return;
  }
  
  if ( config[kGCMItemSelectActionItemKey] ) {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self reportSelectedActionItemForIndexPath:indexPath];
  } else {
    if ( ! [self.selectedIndexPath isEqual:indexPath] ) {
      if ( self.selectedIndexPath ) {
        GCMItemSelectTableViewCell *oldCell = (GCMItemSelectTableViewCell*)[tableView cellForRowAtIndexPath:self.selectedIndexPath];
        oldCell.isChecked = NO;
      }
      self.selectedIndexPath = indexPath;
      GCMItemSelectTableViewCell *newCell = (GCMItemSelectTableViewCell*)[tableView cellForRowAtIndexPath:self.selectedIndexPath];
      newCell.isChecked = YES;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self reportSelectedIndexPath];
  }
}

- (void)reportSelectedIndexPath {
  [self.delegate didSelectItemSelectDataSource:self];
}

- (void)reportSelectedActionItemForIndexPath:(NSIndexPath *)indexPath {
  if ( [self.delegate respondsToSelector:@selector(didSelectActionWithTag:andUserInfo:fromItemSelectDataSource:)] ) {
    [self.delegate didSelectActionWithTag:[self tagForItemAtIndexPath:indexPath]
                              andUserInfo:[self userInfoForItemAtIndexPath:indexPath]
                 fromItemSelectDataSource:self];
  }
}

@end
