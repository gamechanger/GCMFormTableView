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
#import "GCMItemSelectSearchDataSource.h"
#import "GCMSection.h"
#import "GCMItem.h"

NSString *const kGCMItemSelectImageKey = @"image";
NSString *const kGCMItemSelectDisabledItemKey = @"disabledItem";
NSString *const kGCMItemSelectActionItemKey = @"actionItem";
NSString *const kGCMItemSelectDetailTextKey = @"detailText";

NSUInteger const kGCItemSelectHeaderLabelTag = 1000;
NSUInteger const kGCItemSelectFooterLabelTag = 2000;

@interface GCMItemSelectTableViewDataSource () <GCMItemSelectSearchDataSourceDelegate>

@property (nonatomic, strong) NSMutableArray *sections;

@end

@implementation GCMItemSelectTableViewDataSource

- (id)init {
  self = [super init];
  if ( self ) {
    _sections = [[NSMutableArray alloc] init];
  }
  return self;
}

#pragma mark - Data manipulation

- (void)clear {
  [_sections removeAllObjects];
}

- (void)addSectionWithAttributedHeaderTitle:(NSAttributedString *)headerTitle
                      attributedFooterTitle:(NSAttributedString *)footerTitle
                              andIndexTitle:(NSString *)indexTitle {
  GCMSection *newSection = [[GCMSection alloc] initWithHeader:headerTitle
                                                       footer:footerTitle
                                                andIndexTitle:indexTitle];
  [self.sections addObject:newSection];
}

- (void)addSectionWithAttributedHeaderTitle:(NSAttributedString *)headerTitle
                   andAttributedFooterTitle:(NSAttributedString *)footerTitle {
  [self addSectionWithAttributedHeaderTitle:headerTitle
                      attributedFooterTitle:footerTitle
                              andIndexTitle:nil];
}

- (void)addSectionWithHeaderTitle:(NSString *)headerTitle
                      footerTitle:(NSString *)footerTitle
                    andIndexTitle:(NSString *)indexTitle {
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
                      attributedFooterTitle:attrFooter
                              andIndexTitle:indexTitle
   ];
}

- (void)addSectionWithHeaderTitle:(NSString *)headerTitle andFooterTitle:(NSString *)footerTitle {
  [self addSectionWithHeaderTitle:headerTitle footerTitle:footerTitle andIndexTitle:nil];
}

- (void)setAttributedFooterTitle:(NSAttributedString *)footerTitle forSection:(NSUInteger)sectionIndex {
  NSAssert(sectionIndex < self.sections.count, @"Section is not valid");
  GCMSection *section = self.sections[sectionIndex];
  section.footer = footerTitle;
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
  for ( GCMSection *section in self.sections ) {
    if ( section.items.count > 0 ) {
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

- (void)setSelectedIndexPath:(NSIndexPath *)selectedIndexPath {
  _selectedIndexPath = selectedIndexPath;
  _searchDataSource.selectedItem = [self selectedItem];
}

- (GCMItem *)selectedItem {
  NSIndexPath *selectedIndexPath = [self selectedIndexPath];
  if ( selectedIndexPath.section >= self.sections.count ) {
    return nil;
  }
  GCMSection *section = self.sections[selectedIndexPath.section];
  if ( selectedIndexPath.row >= section.items.count ) {
    return nil;
  }
  GCMItem *item = section.items[selectedIndexPath.row];
  return item;
}

- (GCMItemSelectSearchDataSource *)searchDataSource {
  if ( ! _searchDataSource ) {
    _searchDataSource = [[GCMItemSelectSearchDataSource alloc] initWithSections:self.sections andSelectedItem:[self selectedItem]];
    _searchDataSource.delegate = self;
  }
  return _searchDataSource;
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
  GCMItem *item = [[GCMItem alloc] initWithAttributedString:itemName ? itemName : [[NSAttributedString alloc] initWithString:@""]
                                                        tag:tag
                                                   userInfo:userInfo
                                                  andConfig:config];
  GCMSection *currentSection = self.sections.lastObject;
  [currentSection.items addObject:item];
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
  if ( indexPath.section >= self.sections.count ) {
    return nil;
  }
  GCMSection *section = self.sections[indexPath.section];
  if ( indexPath.row >= section.items.count ) {
    return nil;
  }
  GCMItem *item = section.items[indexPath.row];
  return item.attributedString;
}

- (NSInteger)tagForItemAtIndexPath:(NSIndexPath *)indexPath {
  if ( indexPath.section >= self.sections.count ) {
    return 0;
  }
  GCMSection *section = self.sections[indexPath.section];
  if ( indexPath.row >= section.items.count ) {
    return 0;
  }
  GCMItem *item = section.items[indexPath.row];
  return item.tag;
}

- (NSIndexPath *)indexPathForItem:(GCMItem *)prItem {
  for ( int i = 0; i < self.sections.count; i++ ) {
    GCMSection *section = self.sections[i];
    for ( int j = 0; j < section.items.count; j++) {
      GCMItem *item = section.items[j];
      if ( [item isEqual:prItem] ) {
        return [NSIndexPath indexPathForRow:j inSection:i];
      }
    }
  }
  return nil;
}

- (NSIndexPath *)indexPathForItemWithTag:(NSInteger)tag {
  for ( int i = 0; i < self.sections.count; i++ ) {
    GCMSection *section = self.sections[i];
    for ( int j = 0; j < section.items.count; j++) {
      GCMItem *item = section.items[j];
      if ( item.tag == tag ) {
        return [NSIndexPath indexPathForRow:j inSection:i];
      }
    }
  }
  return nil;
}

- (id)userInfoForItemAtIndexPath:(NSIndexPath *)indexPath {
  if ( indexPath.section >= self.sections.count ) {
    return nil;
  }
  GCMSection *section = self.sections[indexPath.section];
  if ( indexPath.row >= section.items.count ) {
    return nil;
  }
  GCMItem *item = section.items[indexPath.row];
  return item.userInfo;
}

- (NSIndexPath *)indexPathForItemWithUserInfo:(id)userInfo {
  for ( int i = 0; i < self.sections.count; i++ ) {
    GCMSection *section = self.sections[i];
    for ( int j = 0; j < section.items.count; j++) {
      GCMItem *item = section.items[j];
      if ( [item.userInfo isEqual:userInfo] ) {
        return [NSIndexPath indexPathForRow:j inSection:i];
      }
    }
  }
  return nil;
}

- (BOOL)containsItemWithUserInfo:(id)userInfo {
  return [self indexPathForItemWithUserInfo:userInfo] != nil;
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
  GCMSection *itemSection = self.sections[section];
  return itemSection.items.count;
}

- (CGFloat)horizontalHeaderFooterPadding {
  return PRE_IOS7 && (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 40.f : 10.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  GCMSection *itemSection = self.sections[section];
  if ( itemSection.header ) {
    if ( self.useDefaultHeaders ) {
      return UITableViewAutomaticDimension;
    }
    CGFloat height = [itemSection.header integralHeightGivenWidth:tableView.bounds.size.width - [self horizontalHeaderFooterPadding] * 2.0];
    return height + 20.0;
  } else {
    return 0.0;
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
  GCMSection *itemSection = self.sections[section];
  if ( itemSection.footer ) {
    CGFloat height = [itemSection.footer integralHeightGivenWidth:tableView.bounds.size.width - [self horizontalHeaderFooterPadding] * 2.0];
    return height + (IOS7_OR_GREATER ? 20.0 : 40.0);
  } else {
    return 0.0;
  }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  GCMSection *itemSection = self.sections[section];
  if ( self.useDefaultHeaders ) {
    return nil;
  }
  if ( itemSection.header ) {
    CGFloat height = [itemSection.header integralHeightGivenWidth:tableView.bounds.size.width];
    
    CGFloat xInset = [self horizontalHeaderFooterPadding];
    CGFloat yInset = 10.0f;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, tableView.frame.size.width, height + yInset * 2)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(xInset, yInset, headerView.frame.size.width - xInset * 2, headerView.frame.size.height - yInset * 2)];
    label.backgroundColor = [UIColor clearColor];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    label.numberOfLines = 0;
    label.attributedText = itemSection.header;
    label.tag = kGCItemSelectHeaderLabelTag;
    [headerView addSubview:label];
    return headerView;
  } else {
    return nil;
  }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  GCMSection *itemSection = self.sections[section];
  if ( itemSection.header ) {
    return itemSection.header.string;
  }
  return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
  GCMSection *itemSection = self.sections[section];
  if ( itemSection.footer ) {
    CGFloat height = [itemSection.footer integralHeightGivenWidth:tableView.bounds.size.width];
    
    CGFloat xInset = [self horizontalHeaderFooterPadding];
    CGFloat yInset = 10.0f;
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, tableView.frame.size.width, height + yInset * 2)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(xInset, yInset, footerView.frame.size.width - xInset * 2.00f, footerView.frame.size.height - yInset * 2)];
    label.backgroundColor = [UIColor clearColor];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    label.numberOfLines = 0;
    label.attributedText = itemSection.footer;
    label.tag = kGCItemSelectFooterLabelTag;
    [footerView addSubview:label];
    return footerView;
  } else {
    return nil;
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  GCMSection *itemSection = self.sections[indexPath.section];
  GCMItem *item = itemSection.items[indexPath.row];
  NSIndexPath *indexPathCopy = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
  BOOL checked = [self.selectedIndexPath isEqual:indexPathCopy];
  NSDictionary *config = item.config;
  BOOL hasDetailtext = config[kGCMItemSelectDetailTextKey] != nil;
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
  GCMSection *itemSection = self.sections[indexPath.section];
  GCMItem *item = itemSection.items[indexPath.row];
  [cell setContentForItem:item];
  
  cell.isChecked = [self.selectedIndexPath isEqual:indexPath];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  GCMSection *itemSection = self.sections[indexPath.section];
  GCMItem *item = itemSection.items[indexPath.row];
  NSDictionary *config = item.config;
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

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
  NSMutableArray *indexTitles = [[NSMutableArray alloc] initWithCapacity:self.sections.count];
  for ( GCMSection *section in self.sections ) {
    if ( section.indexTitle ) {
    [indexTitles addObject:section.indexTitle];
    }
  }
  return indexTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
  for ( int i = 0; i < self.sections.count; i++ ) {
    GCMSection *section = self.sections[i];
    if ( [section.indexTitle isEqualToString:title] ) {
      return i;
    }
  }
  return 0;
}

#pragma mark - GCMItemSelectSearchDataSourceDelegate

- (void)didSelectItem:(GCMItem *)item {
  NSIndexPath *selectedIndexPath = [self indexPathForItem:item];
  [self tableView:nil didSelectRowAtIndexPath:selectedIndexPath];
}

@end
