#import <UIKit/UIKit.h>
#import "GCMFormRowConfig.h"

extern NSString *kGCMFormSectionHeaderReuseId;
extern NSString *kGCMFormSectionFooterReuseId;

@interface GCMFormSectionConfig : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, readonly) NSArray *rows;
@property (nonatomic, strong) NSString *footerTitle;

- (id)initWithTitle:(NSString *)title;
- (id)initWithTitle:(NSString *)title footerTitle:(NSString *)footerTitle;
- (UIView *)makeHeaderViewForTableView:(UITableView *)tableView;
- (UIView *)makeFooterViewForTableView:(UITableView *)tableView;

@end
