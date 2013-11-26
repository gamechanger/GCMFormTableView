#import <UIKit/UIKit.h>

typedef enum GCEnabledState {
  GCStateEnabled,
  GCStateDisabled
} GCEnabledState;

@protocol GCMFormRowConfigDelegate;

@interface GCMFormRowConfig : NSObject

@property (nonatomic, weak) id<GCMFormRowConfigDelegate> delegate;
/// Used by makeCellForUITableView:forIndexPath: to create the cell.  Should be overridden by subclasses to return a useful value.
@property (nonatomic, readonly) NSString *cellReuseId;
@property (nonatomic, strong) NSString *key;
/// Subclasses should assign updates from user interaction directly to value so that KVO triggers validation.
@property (nonatomic, strong) id value;
@property (nonatomic, assign) BOOL required;
/// Defaults to NO. Subclasses should override if they can gain firstResponder aka textField.
@property (nonatomic, readonly) BOOL isEditable;
/// Defaults to YES. Used by rebuildCell: to call configureCell:forEnabledState: for styling.
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, strong) NSString *placeholderText;
/// Defaults to 44.0;
@property (nonatomic, assign) CGFloat rowHeight;

/// Manually set label width
@property (nonatomic, assign) CGFloat labelWidth;

// Determines if the label width is autocalculated (ignoring any manually specified value)
@property (nonatomic, assign) BOOL autocalculateLabelWidth;

/// Base implementation will use cellReuseId to create a cell and call rebuildCell: to configure the cell.
- (UITableViewCell *)makeCellForUITableView:(UITableView *)tableView forIndexPath:(NSIndexPath *)indexPath;
/// Base implementation calls configureContentsForCell: and then configureCell:forEnabledState:.
- (void)rebuildCell:(UITableViewCell *)cell;
/// Subclasses should override this to setup the contents of the cell.
- (void)configureContentsForCell:(UITableViewCell *)cell;
/// Base implementation sets alpha and changes cell selectionStyle.
- (void)configureCell:(UITableViewCell *)cell forEnabledState:(GCEnabledState)state;
- (void)didTapCell:(UITableViewCell *)cell;

- (CGRect)contentFrameForCell:(UITableViewCell *)cell;

/// Get the correct width for the label in the cell, auto-calculating it if
/// autocalculateLabelWidth is YES (the default), otherwise using a manually
/// specified value.
- (CGFloat)labelWidthFromCell:(UITableViewCell *)cell;


- (void)askDelegateToPushViewController:(UIViewController *)controller;
- (void)askDelegateToPopViewController;
- (void)askDelegateToReportAction;

@end

@protocol GCMFormRowConfigDelegate <NSObject>

@optional
- (void)formRowConfigBeganEditing:(GCMFormRowConfig *)rowConfig;
- (void)formRowConfigEndedEditing:(GCMFormRowConfig *)rowConfig;
- (void)formRowConfig:(GCMFormRowConfig *)rowConfig wantsToPushViewController:(UIViewController *)controller;
- (void)formRowConfigWantsToPopViewController:(GCMFormRowConfig *)rowConfig;
- (void)formRowConfigReportsAction:(GCMFormRowConfig *)rowConfig;

@end
