
#import "GCMFormRowConfig.h"


@implementation GCMFormRowConfig

- (id)init {
  self = [super init];
  if ( self ) {
    _enabled = YES;
    _rowHeight = 44.0;
    _autocalculateLabelWidth = YES;
  }
  return self;
}

- (void)setLabelWidth:(CGFloat)labelWidth {
  _autocalculateLabelWidth = NO;
  _labelWidth = labelWidth;
}

- (CGFloat)labelWidthFromCell:(UITableViewCell *)cell {
  if (self.autocalculateLabelWidth) {
    // The default autocalculated width is half the width of the containing cell
    // (ignoring any other insets etc which may constrain the label's container)
    return (cell.bounds.size.width / 2.0) - [self contentFrameForCell:cell].origin.x;
  }
  return self.labelWidth;
}

- (BOOL)isEditable {
  return NO;
}

- (NSString *)cellReuseId {
  return nil;
}

- (UITableViewCell *)makeCellForUITableView:(UITableView *)tableView forIndexPath:(NSIndexPath *)indexPath {
  NSAssert(self.cellReuseId, @"cellReuseId must be overriden to return a non-nil value.");
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellReuseId forIndexPath:indexPath];
  [self rebuildCell:cell];
  return cell;
}

- (void)rebuildCell:(UITableViewCell *)cell {
  [self configureContentsForCell:cell];
  [self configureCell:cell forEnabledState:(self.enabled ? GCStateEnabled : GCStateDisabled)];
}

- (void)configureContentsForCell:(UITableViewCell *)cell {
  // Base implementation does nothing.
}

- (void)configureCell:(UITableViewCell *)cell forEnabledState:(GCEnabledState)state {
  if ( state == GCStateEnabled ) {
    cell.contentView.alpha = 1.0;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
  } else {
    // May need to set alpha of other cell items. Setting alpha of cell view itself doesn't work.
    cell.contentView.alpha = 0.5;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
  }
}

- (void)didTapCell:(UITableViewCell *)cell {
  // Base implementation does nothing.
}

- (void)askDelegateToPushViewController:(UIViewController *)controller {
  if ( [self.delegate respondsToSelector:@selector(formRowConfig:wantsToPushViewController:)] ) {
    [self.delegate formRowConfig:self
       wantsToPushViewController:controller];
  }
}

- (void)askDelegateToPopViewController {
  if ( [self.delegate respondsToSelector:@selector(formRowConfigWantsToPopViewController:)] ) {
    [self.delegate formRowConfigWantsToPopViewController:self];
  }
}

- (void)askDelegateToReportAction {
  if ( [self.delegate respondsToSelector:@selector(formRowConfigReportsAction:)] ) {
    [self.delegate formRowConfigReportsAction:self];
  }
}

- (CGRect)contentFrameForCell:(UITableViewCell *)cell {
  CGRect frame = cell.contentView.bounds;
  if ( [cell respondsToSelector:@selector(separatorInset)] ) {
    frame = UIEdgeInsetsInsetRect(frame, cell.separatorInset);
  }
  return frame;
}

@end
