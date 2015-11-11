//
//  GCMItemSelectTableViewCell.m
//  Pods
//
//  Created by Eduardo Arenas on 4/3/14.
//
//

#import "GCMItemSelectTableViewCell.h"
#import "GCMDeviceInfo.h"
#import "NSAttributedString+GameChangerMedia.h"
#import "GCMItemSelectTableViewDataSource.h"
#import "GCMItemSelectItem.h"

#define kGCCheckAccesoryWidth (IOS7_OR_GREATER ? 24.f : 10.f)
#define kGCDetailTextWidth 55.f
#define kCGImageDimension 44.f
#define kGCCellDividerHeight 35.f / 2
#define kGCCellDividerBorderTag 1000

@interface GCMItemSelectTableViewCell ()

@property (nonatomic, strong) UIView *topDivider;
@property (nonatomic, strong) UIView *bottomDivider;

@end

@implementation GCMItemSelectTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    self.cellInsets = [GCMItemSelectTableViewCell defaultInsets];
    self.textLabel.numberOfLines = 0;
    self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  CGFloat originY = self.cellInsets.top;
  
  if ( self.useCellDivider ) {
    CGRect topDividerFrame = CGRectMake(0.f, 0.f, self.frame.size.width, kGCCellDividerHeight);
    self.topDivider.frame = topDividerFrame;
    CGRect topDividerBorderFrame = CGRectMake(0.f, kGCCellDividerHeight, topDividerFrame.size.width, 1.f);
    [self.topDivider viewWithTag:kGCCellDividerBorderTag].frame = topDividerBorderFrame;
    
    CGFloat labelHeight = [GCMItemSelectTableViewCell cellHeightForAttributedText:self.textLabel.attributedText
                                                                    withCellWidth:self.frame.size.width
                                                                        isChecked:self.isChecked
                                                                    hasDetailtext:self.detailTextLabel.text != nil
                                                                         hasImage:self.imageView.image != nil
                                                                  usesCellDivider:self.useCellDivider
                                                                      usingInsets:self.cellInsets];
    CGRect bottomDividerFrame = CGRectMake(0.f, labelHeight - kGCCellDividerHeight, self.frame.size.width, kGCCellDividerHeight);
    self.bottomDivider.frame = bottomDividerFrame;
    CGRect bottomDividerBorderFrame = CGRectMake(0.f, 0.f, bottomDividerFrame.size.width, 1.f);
    [self.bottomDivider viewWithTag:kGCCellDividerBorderTag].frame = bottomDividerBorderFrame;
    
    originY += self.useCellDivider ? kGCCellDividerHeight : 0.f;
  }
  
  CGFloat labelWidth = [GCMItemSelectTableViewCell maxLabelWidthForCellWithWidth:self.frame.size.width
                                                                          insets:self.cellInsets
                                                                       isChecked:self.isChecked
                                                                   hasDetailtext:self.detailTextLabel.text != nil
                                                                        hasImage:self.imageView.image != nil];
  CGFloat originX = self.cellInsets.left + (self.imageView.image ? kCGImageDimension : 0.f);
  CGFloat labelHeight = [GCMItemSelectTableViewCell labelHeightForAttributedText:self.textLabel.attributedText
                                                                  withLabelWidth:labelWidth];
  self.textLabel.frame = CGRectMake(originX, originY, labelWidth, labelHeight);
  
  if ( self.detailTextLabel.text ) {
    CGFloat detailOriginX = self.textLabel.frame.origin.x + self.textLabel.frame.size.width;
    CGFloat detailLabelHeight = [GCMItemSelectTableViewCell labelHeightForAttributedText:self.detailTextLabel.attributedText
                                                                          withLabelWidth:kGCDetailTextWidth];
    self.detailTextLabel.frame = CGRectMake(detailOriginX, originY, kGCDetailTextWidth, detailLabelHeight);
  }
}

- (void)setUseCellDivider:(BOOL)useCellDivider {
  if ( _useCellDivider != useCellDivider ) {
    _useCellDivider = useCellDivider;
    [self manageCellDividers];
  }
}

- (void)manageCellDividers {
  if ( _useCellDivider ) {
    if ( ! self.topDivider ) {
      self.topDivider = [[UIView alloc] initWithFrame:CGRectZero];
      self.topDivider.backgroundColor = [self dividerGray];
      UIView *topDividerBorder = [[UIView alloc] initWithFrame:CGRectZero];
      topDividerBorder.tag = kGCCellDividerBorderTag;
      topDividerBorder.backgroundColor = [self borderGray];
      [self.topDivider addSubview:topDividerBorder];
      [self addSubview:self.topDivider];
    }
    if ( ! self.bottomDivider ) {
      self.bottomDivider = [[UIView alloc] initWithFrame:CGRectZero];
      self.bottomDivider.backgroundColor = [self dividerGray];
      UIView *bottomDividerBorder = [[UIView alloc] initWithFrame:CGRectZero];
      bottomDividerBorder.tag = kGCCellDividerBorderTag;
      bottomDividerBorder.backgroundColor = [self borderGray];
      [self.bottomDivider addSubview:bottomDividerBorder];
      [self addSubview:self.bottomDivider];
    }
  } else {
    [self.topDivider removeFromSuperview];
    self.topDivider = nil;
    [self.bottomDivider removeFromSuperview];
    self.bottomDivider = nil;
  }
}

- (void)setIsChecked:(BOOL)isChecked {
  if ( _isChecked != isChecked ) {
    _isChecked = isChecked;
    [self configureCheckmark];
  }
}

- (void)configureCheckmark {
  if ( self.isChecked ) {
    self.accessoryType = UITableViewCellAccessoryCheckmark;
    self.accessoryView = nil;
  } else {
    self.accessoryType = UITableViewCellAccessoryNone;
    self.accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, kGCCheckAccesoryWidth, 1.0)];
  }
}

- (void)setContentForItem:(GCMItemSelectItem *)item {
  self.textLabel.attributedText = item.attributedString;
  self.imageView.image = item.image;
  if ( item.disabled ) {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.alpha = 0.5;
  } else {
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
    self.contentView.alpha = 1.0;
  }
  if ( item.detailText ) {
    self.detailTextLabel.attributedText = [self defaultAttributedDetailString:item.detailText];
  } else {
    self.detailTextLabel.attributedText = nil;
  }
  self.useCellDivider = item.useCellDivider;
}

- (NSAttributedString *)defaultAttributedDetailString:(NSString *)detailString {
  NSMutableAttributedString *attributedDetail = [[NSMutableAttributedString alloc] initWithString:detailString];
  [attributedDetail addAttributeForTextColor:[UIColor colorWithRed:146.f/255.f green:146.f/255.f blue:146.f/255.f alpha:1.000]];
  [attributedDetail addAttributeForFont:[UIFont systemFontOfSize:15.0]];
  [attributedDetail addAttributeForTextAlignment:NSTextAlignmentRight lineBreakMode:NSLineBreakByWordWrapping];
  return attributedDetail;
}

- (UIColor *)dividerGray {
  return [UIColor colorWithRed:235.f / 255.f
                         green:235.f / 255.f
                          blue:241.f / 255.f
                         alpha:1.f];
}

- (UIColor *)borderGray {
  return [UIColor colorWithRed:220.f / 255.f
                         green:220.f / 255.f
                          blue:223.f / 255.f
                         alpha:1.f];
}

#pragma mark - Static methods

+ (UIEdgeInsets)defaultInsets {
  return UIEdgeInsetsMake(11.f, 15.f, 11.f, [GCMDeviceInfo iPad] ? 35.f : 20.f);
}

+ (CGFloat)maxLabelWidthForCellWithWidth:(CGFloat)cellWidth
                                  insets:(UIEdgeInsets)insets
                               isChecked:(BOOL)checked
                           hasDetailtext:(BOOL)detailText
                                hasImage:(BOOL)image {
  CGFloat maxWidth = cellWidth - insets.left - insets.right;
  maxWidth -= checked ? kGCCheckAccesoryWidth : 0.f;
  maxWidth -= detailText ? kGCDetailTextWidth : 0.f;
  maxWidth -= image ? kCGImageDimension : 0.f;
  return maxWidth;
}

+ (CGFloat)cellHeightForAttributedText:(NSAttributedString *)attrText
                         withCellWidth:(CGFloat)cellWidth
                             isChecked:(BOOL)checked
                         hasDetailtext:(BOOL)detailText
                              hasImage:(BOOL)image
                       usesCellDivider:(BOOL)divider
                           usingInsets:(UIEdgeInsets)insets {
  
  CGFloat labelWidth = [self maxLabelWidthForCellWithWidth:cellWidth
                                                    insets:insets
                                                 isChecked:checked
                                             hasDetailtext:detailText
                                                  hasImage:image];
  
  return [self labelHeightForAttributedText:attrText withLabelWidth:labelWidth] + insets.top + insets.bottom + (divider ? kGCCellDividerHeight * 2 : 0.f);
}

+ (CGFloat)labelHeightForAttributedText:(NSAttributedString *)attrText
                         withLabelWidth:(CGFloat)labelWidth {
  return MAX(22.f, [attrText integralHeightGivenWidth:labelWidth]);
}

@end
