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
#import "GCMItemSelectSection.h"
#import "GCMItemSelectItem.h"

#define kGCHeaderTopInset ([GCMDeviceInfo iPad] ? 30.f : 10.f)
#define kGCHeaderBottomInset ([GCMDeviceInfo iPad] ? 15.f : 10.f)
#define kGCImageDimension 30.f

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

- (void)addSection:(GCMItemSelectSection *)section {
  [self.sections addObject:section];
}

- (void)addSectionWithConfigurationBlock:(SectionBuilderBlock)block {
  NSParameterAssert(block);
  GCMItemSelectSection *section = [[GCMItemSelectSection alloc] init];
  block(section);
  [self addSection:section];
}

- (void)addSectionWithAttributedHeaderTitle:(NSAttributedString *)headerTitle
                      attributedFooterTitle:(NSAttributedString *)footerTitle
                              andIndexTitle:(NSString *)indexTitle {
  GCMItemSelectSection *newSection = [[GCMItemSelectSection alloc] initWithHeader:headerTitle
                                                                           footer:footerTitle
                                                                       indexTitle:indexTitle
                                                               andSeparatorHeight:self.sections.count == 0 ? 0.f : 24.f];
  [self addSection:newSection];
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
                              andIndexTitle:indexTitle];
}

- (void)addSectionWithHeaderTitle:(NSString *)headerTitle andFooterTitle:(NSString *)footerTitle {
  [self addSectionWithHeaderTitle:headerTitle footerTitle:footerTitle andIndexTitle:nil];
}

- (void)setAttributedFooterTitle:(NSAttributedString *)footerTitle forSection:(NSUInteger)sectionIndex {
  NSAssert(sectionIndex < self.sections.count, @"Section is not valid");
  GCMItemSelectSection *section = self.sections[sectionIndex];
  section.footer = footerTitle;
}

- (void)setFooterTitle:(NSString *)footerTitle forSection:(NSUInteger)section {
  NSMutableAttributedString *attrFooter = nil;
  attrFooter = [[NSMutableAttributedString alloc] initWithString:footerTitle
                                                      attributes:[self defaultHeaderFooterTextAttributes]];
  [self setAttributedFooterTitle:attrFooter forSection:section];
}

- (void)addSectionBreak {
  [self addSectionBreakWithHeight:24.f];
}

- (void)addSectionBreakWithHeight:(CGFloat)height {
  [self addSectionWithConfigurationBlock:^(GCMItemSelectSection *section) {
    section.separatorHeight = height;
  }];
}

- (BOOL)hasItems {
  for ( GCMItemSelectSection *section in self.sections ) {
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

- (GCMItemSelectItem *)selectedItem {
  return [self getItemAtIndexPath:self.selectedIndexPath];
}

- (GCMItemSelectItem *)getItemAtIndexPath:(NSIndexPath *)indexPath {
  if ( ! indexPath ) {
    return nil;
  }
  if ( indexPath.section >= self.sections.count ) {
    return nil;
  }
  GCMItemSelectSection *section = self.sections[indexPath.section];
  if ( indexPath.row >= section.items.count ) {
    return nil;
  }
  GCMItemSelectItem *item = section.items[indexPath.row];
  return item;
}

- (NSString *)itemAtIndexPath:(NSIndexPath *)indexPath {
  return [[self attributedItemAtIndexPath:indexPath] string];
}

- (NSAttributedString *)attributedItemAtIndexPath:(NSIndexPath *)indexPath {
  GCMItemSelectItem *item = [self getItemAtIndexPath:indexPath];
  return item.attributedString;
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

- (void)addItem:(GCMItemSelectItem *)item {
  if ( [self.sections count] == 0 ) {
    [self addSectionWithHeaderTitle:nil andFooterTitle:nil];
  }
  GCMItemSelectSection *currentSection = self.sections.lastObject;
  [currentSection.items addObject:item];
}

- (void)addItemWithConfigurationBlock:(ItemBuilderBlock)block {
  NSParameterAssert(block);
  GCMItemSelectItem *item = [[GCMItemSelectItem alloc] init];
  block(item);
  [self addItem:item];
}

- (void)addItemWithName:(NSString *)itemName andTag:(NSInteger)tag {
  [self addItemWithName:itemName tag:tag andUserInfo:nil];
}

- (void)addItemWithName:(NSString *)itemName andUserInfo:(id)userInfo {
  [self addItemWithName:itemName tag:0 andUserInfo:userInfo];
}

- (void)addItemWithName:(NSString *)itemName tag:(NSInteger)tag andUserInfo:(id)userInfo {
  [self addItemWithAttributedName:[GCMItemSelectItem defaultItemAttributedStringForString:itemName] tag:tag andUserInfo:userInfo];
}

- (void)addItemWithAttributedName:(NSAttributedString *)itemName andTag:(NSInteger)tag {
  [self addItemWithAttributedName:itemName tag:tag andUserInfo:nil];
}

- (void)addItemWithAttributedName:(NSAttributedString *)itemName andUserInfo:(id)userInfo {
  [self addItemWithAttributedName:itemName tag:0 andUserInfo:userInfo];
}

- (void)addItemWithAttributedName:(NSAttributedString *)itemName tag:(NSInteger)tag andUserInfo:(id)userInfo {
  GCMItemSelectItem *item = [[GCMItemSelectItem alloc] initWithAttributedString:itemName];
  item.tag = tag;
  item.userInfo = userInfo;
  [self addItem:item];
}

- (NSInteger)tagForItemAtIndexPath:(NSIndexPath *)indexPath {
  GCMItemSelectItem *item = [self getItemAtIndexPath:indexPath];
  return item.tag;
}

- (NSIndexPath *)indexPathForItem:(GCMItemSelectItem *)prItem {
  for ( int i = 0; i < self.sections.count; i++ ) {
    GCMItemSelectSection *section = self.sections[i];
    for ( int j = 0; j < section.items.count; j++) {
      GCMItemSelectItem *item = section.items[j];
      if ( [item isEqual:prItem] ) {
        return [NSIndexPath indexPathForRow:j inSection:i];
      }
    }
  }
  return nil;
}

- (NSIndexPath *)indexPathForItemWithTag:(NSInteger)tag {
  for ( int i = 0; i < self.sections.count; i++ ) {
    GCMItemSelectSection *section = self.sections[i];
    for ( int j = 0; j < section.items.count; j++) {
      GCMItemSelectItem *item = section.items[j];
      if ( item.tag == tag ) {
        return [NSIndexPath indexPathForRow:j inSection:i];
      }
    }
  }
  return nil;
}

- (id)userInfoForItemAtIndexPath:(NSIndexPath *)indexPath {
  GCMItemSelectItem *item = [self getItemAtIndexPath:indexPath];
  return item.userInfo;
}

- (NSIndexPath *)indexPathForItemWithUserInfo:(id)userInfo {
  for ( int i = 0; i < self.sections.count; i++ ) {
    GCMItemSelectSection *section = self.sections[i];
    for ( int j = 0; j < section.items.count; j++) {
      GCMItemSelectItem *item = section.items[j];
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

- (void)handleSelectionAtIndexPath:(NSIndexPath *)indexPath onTableView:(UITableView *)tableView {
  GCMItemSelectSection *itemSection = self.sections[indexPath.section];
  GCMItemSelectItem *item = itemSection.items[indexPath.row];
  if ( item.disabled ) {
    return;
  }
  
  if ( item.actionItem ) {
    [self reportSelectedActionItemForIndexPath:indexPath];
  } else {
    if (![self.selectedIndexPath isEqual:indexPath] ) {
      if ( self.selectedIndexPath ) {
        GCMItemSelectTableViewCell *oldCell = (GCMItemSelectTableViewCell*)[tableView cellForRowAtIndexPath:self.selectedIndexPath];
        oldCell.isChecked = NO;
      }
      self.selectedIndexPath = indexPath;
      GCMItemSelectTableViewCell *newCell = (GCMItemSelectTableViewCell*)[tableView cellForRowAtIndexPath:self.selectedIndexPath];
      newCell.isChecked = YES;
    }
    [self reportSelectedIndexPath];
  }
}

#pragma mark - UITableView

static NSString* kCellReuseId = @"itemSelectCell";
static NSString* kHeaderReuseId = @"header";
static NSString* kFooterReuseId = @"footer";

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  GCMItemSelectSection *itemSection = self.sections[section];
  return itemSection.items.count;
}

- (CGFloat)horizontalHeaderFooterPadding {
  return PRE_IOS7 && [GCMDeviceInfo iPad] ? 40.f : 15.f;
}

- (CGFloat)customHeaderHeightForHeader:(NSAttributedString *)header andWidth:(CGFloat)width {
  CGFloat height = [header integralHeightGivenWidth:width];
  return height + kGCHeaderTopInset + kGCHeaderBottomInset;
}

- (CGFloat)contentWidthForTableView:(UITableView *)tableView {
  return tableView.bounds.size.width - [self horizontalHeaderFooterPadding] * 2.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  GCMItemSelectSection *itemSection = self.sections[section];
  if ( itemSection.header ) {
    if ( self.useDefaultHeaders ) {
      return 24.f;
    } else {
      return [self customHeaderHeightForHeader:itemSection.header andWidth:[self contentWidthForTableView:tableView]];
    }
  } else {
    return itemSection.separatorHeight;
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
  GCMItemSelectSection *itemSection = self.sections[section];
  if ( itemSection.footer ) {
    if ( itemSection.useTextViewFooter ) {
      CGFloat xInset = 10.f;
      CGFloat tvWidth = tableView.frame.size.width - xInset * 2.00f;
      
      UITextView *tv = [[UITextView alloc] initWithFrame:CGRectMake(xInset, 5.f, tvWidth, 0)];
      tv.attributedText = itemSection.footer;
      tv.editable = NO;
      tv.dataDetectorTypes = UIDataDetectorTypeLink;
      CGSize size = [tv sizeThatFits:CGSizeMake(tvWidth, CGFLOAT_MAX)];
      CGRect frame = tv.frame;
      frame.size = CGSizeMake(tvWidth, size.height);
      tv.frame = frame;
      
      return tv.frame.size.height + 30;
      
    } else {
      CGFloat height = [itemSection.footer integralHeightGivenWidth:[self contentWidthForTableView:tableView]];
      return height + (IOS7_OR_GREATER ? 20.f : 40.f) + (itemSection.useTextViewFooter ? 10.f : 0.f);
    }
  } else {
    return 0.01f;
  }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  GCMItemSelectSection *itemSection = self.sections[section];
  
  if ( itemSection.header ) {
    if ( self.useDefaultHeaders ) {
      UITableViewHeaderFooterView *headerView = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0.f, 0.f, tableView.frame.size.width, 24.f)];
      headerView.backgroundColor = [UIColor colorWithWhite:240.f/255.f alpha:1.f];
      UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15.f, 0.f, headerView.frame.size.width, headerView.frame.size.height)];
      label.backgroundColor = [UIColor clearColor];
      label.text = itemSection.header.string;
      label.font = [UIFont boldSystemFontOfSize:14.0];
      [headerView addSubview:label];
      return headerView;
    } else {
      CGFloat height = [self customHeaderHeightForHeader:itemSection.header andWidth:[self contentWidthForTableView:tableView]];
      
      CGFloat xInset = [self horizontalHeaderFooterPadding];
      
      UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, tableView.frame.size.width, height)];
      UIImageView *iv = nil;
      if ( itemSection.image ) {
        iv = [[UIImageView alloc] initWithImage:itemSection.image];
        iv.frame = CGRectMake(xInset, 0, kGCImageDimension, kGCImageDimension);
        [headerView addSubview:iv];
        xInset += iv.frame.size.width + 10.f;
      }
      
      UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(xInset,
                                                                 kGCHeaderTopInset,
                                                                 headerView.frame.size.width - xInset * 2,
                                                                 height - kGCHeaderTopInset - kGCHeaderBottomInset)];
      label.backgroundColor = [UIColor clearColor];
      label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
      label.numberOfLines = 0;
      label.attributedText = itemSection.header;
      label.tag = kGCItemSelectHeaderLabelTag;
      [headerView addSubview:label];
      iv.center = CGPointMake(iv.center.x, label.center.y);
      return headerView;
    }
  } else {
    return nil;
  }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
  GCMItemSelectSection *itemSection = self.sections[section];
  if ( itemSection.footer ) {
    if ( itemSection.useTextViewFooter ) {
      CGFloat xInset = 10.f;
      CGFloat tvWidth = tableView.frame.size.width - xInset * 2.00f;
      
      UITextView *tv = [[UITextView alloc] initWithFrame:CGRectMake(xInset, 5.f, tvWidth, 0)];
      tv.backgroundColor = [UIColor clearColor];
      tv.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
      tv.attributedText = itemSection.footer;
      tv.tag = kGCItemSelectFooterLabelTag;
      tv.editable = NO;
      tv.dataDetectorTypes = UIDataDetectorTypeLink;
      CGSize size = [tv sizeThatFits:CGSizeMake(tvWidth, CGFLOAT_MAX)];
      CGRect frame = tv.frame;
      frame.size = CGSizeMake(tvWidth, size.height);
      tv.frame = frame;
      
      CGFloat height = tv.frame.size.height + 30;
      
      UITableViewHeaderFooterView *footerView = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0.f, 0.f, tableView.frame.size.width, height)];
      footerView.backgroundColor = [UIColor clearColor];
      [footerView addSubview:tv];
      return footerView;
    } else {
      CGFloat height = [itemSection.footer integralHeightGivenWidth:tableView.bounds.size.width];
      
      CGFloat xInset = [self horizontalHeaderFooterPadding];
      CGFloat yInset = 10.0f;
      UITableViewHeaderFooterView *footerView = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0.f, 0.f, tableView.frame.size.width, height + yInset * 2)];
      UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(xInset, yInset, footerView.frame.size.width - xInset * 2.00f, footerView.frame.size.height - yInset * 2)];
      label.backgroundColor = [UIColor clearColor];
      label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
      label.numberOfLines = 0;
      label.attributedText = itemSection.footer;
      label.tag = kGCItemSelectFooterLabelTag;
      [footerView addSubview:label];
      footerView.backgroundView = [UIView new];
      return footerView;
    }
  } else {
    return nil;
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  GCMItemSelectSection *itemSection = self.sections[indexPath.section];
  GCMItemSelectItem *item = itemSection.items[indexPath.row];
  NSIndexPath *indexPathCopy = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
  return [GCMItemSelectTableViewCell cellHeightForAttributedText:[self attributedItemAtIndexPath:indexPathCopy]
                                                   withCellWidth:tableView.bounds.size.width
                                                       isChecked:[self.selectedIndexPath isEqual:indexPathCopy]
                                                   hasDetailtext:item.detailText != nil
                                                        hasImage:item.image != nil
                                                 usesCellDivider:item.useCellDivider
                                                     usingInsets:[GCMItemSelectTableViewCell defaultInsets]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  GCMItemSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseId];
  if ( cell == nil ) {
    cell = [[GCMItemSelectTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kCellReuseId];
  }
  GCMItemSelectSection *itemSection = self.sections[indexPath.section];
  GCMItemSelectItem *item = itemSection.items[indexPath.row];
  [cell setContentForItem:item];
  
  cell.isChecked = [self.selectedIndexPath isEqual:indexPath];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self handleSelectionAtIndexPath:indexPath onTableView:tableView];
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
  for ( GCMItemSelectSection *section in self.sections ) {
    if ( section.indexTitle ) {
      [indexTitles addObject:section.indexTitle];
    }
  }
  return indexTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
  for ( int i = 0; i < self.sections.count; i++ ) {
    GCMItemSelectSection *section = self.sections[i];
    if ( [section.indexTitle isEqualToString:title] ) {
      return i;
    }
  }
  return 0;
}

#pragma mark - GCMItemSelectSearchDataSourceDelegate

- (void)didSelectItem:(GCMItemSelectItem *)item {
  NSIndexPath *selectedIndexPath = [self indexPathForItem:item];
  [self handleSelectionAtIndexPath:selectedIndexPath onTableView:nil];
}


@end
