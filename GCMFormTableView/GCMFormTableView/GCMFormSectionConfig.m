#import "GCMFormSectionConfig.h"
#import "GCMFormSectionConfig+Protected.h"

NSString *kGCMFormSectionHeaderReuseId = @"sectionHeader";
NSString *kGCMFormSectionFooterReuseId = @"sectionFooter";

@interface GCMFormSectionConfig ()

@property (nonatomic, strong) NSMutableArray *rowConfigs;

@end

@implementation GCMFormSectionConfig

- (id)init {
  self = [self initWithTitle:nil];
  return self;
}

- (id)initWithTitle:(NSString *)title {
  self = [self initWithTitle:title footerTitle:nil];
  return self;
}

- (id)initWithTitle:(NSString *)title footerTitle:(NSString *)footerTitle {
  self = [super init];
  if ( self ) {
    _title = title;
    _footerTitle = footerTitle;
    _rowConfigs = [[NSMutableArray alloc] init];
  }
  return self;
}

- (NSArray *)rows {
  return [self.rowConfigs copy];
}

- (void)addRowConfig:(GCMFormRowConfig *)rowConfig {
  [self.rowConfigs addObject:rowConfig];
}

- (void)replaceRowConfigAtIndex:(NSInteger)row withRowConfig:(GCMFormRowConfig *)rowConfig {
  [self.rowConfigs replaceObjectAtIndex:row withObject:rowConfig];
}

- (UIView *)makeHeaderViewForTableView:(UITableView *)tableView {
  if ( self.title ) {
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kGCMFormSectionHeaderReuseId];
    headerView.textLabel.text = self.title;
    headerView.textLabel.font = [UIFont systemFontOfSize:16.f];
    return headerView;
  } else {
    return nil;
  }
}

- (UIView *)makeFooterViewForTableView:(UITableView *)tableView {
  if ( self.footerTitle ) {
    UITableViewHeaderFooterView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kGCMFormSectionHeaderReuseId];
    footerView.textLabel.text = self.footerTitle;
    footerView.textLabel.font = [UIFont systemFontOfSize:16.f];
    footerView.textLabel.textColor = [GCPalette grayMediumDark];
    footerView.textLabel.numberOfLines = 0;
    return footerView;
  } else {
    return nil;
  }
}

@end
