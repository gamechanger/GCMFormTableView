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
#import "GCMItem.h"

#define kGCCheckAccesoryWidth (IOS7_OR_GREATER ? 24.f : 10.f)
#define kGCDetailTextWidth 55.f
#define kGCInnerSpace 10.f
#define kCGImageDimension 44.f

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
  
  CGFloat labelWidth = [GCMItemSelectTableViewCell maxLabelWidthForCellWithWidth:self.frame.size.width
                                                                          insets:self.cellInsets
                                                                       isChecked:self.isChecked
                                                                   hasDetailtext:self.detailTextLabel.text != nil
                                                                        hasImage:self.imageView.image != nil];
  CGFloat originX = self.cellInsets.left + (self.imageView.image ? kCGImageDimension + kGCInnerSpace : 0.f);
  CGFloat labelHeight = [GCMItemSelectTableViewCell labelHeightForAttributedText:self.textLabel.attributedText
                                                                  withLabelWidth:labelWidth];
  self.textLabel.frame = CGRectMake(originX, self.cellInsets.top, labelWidth, labelHeight);
  
  if ( self.detailTextLabel.text ) {
    CGFloat detailOriginX = self.textLabel.frame.origin.x + self.textLabel.frame.size.width + kGCInnerSpace;
    CGFloat detailLabelHeight = [GCMItemSelectTableViewCell labelHeightForAttributedText:self.detailTextLabel.attributedText
                                                                          withLabelWidth:kGCDetailTextWidth];
    self.detailTextLabel.frame = CGRectMake(detailOriginX, self.cellInsets.top, kGCDetailTextWidth, detailLabelHeight);
  }
}

- (void)setIsChecked:(BOOL)isChecked {
  if (_isChecked != isChecked) {
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

- (void)setContentForItem:(GCMItem *)item {
  self.textLabel.attributedText = item.attributedString;
  NSDictionary *config = item.config;
  self.imageView.image = config[kGCMItemSelectImageKey];
  if ( config[kGCMItemSelectDisabledItemKey] ) {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.alpha = 0.5;
  } else {
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
    self.contentView.alpha = 1.0;
  }
  if ( config[kGCMItemDetailTextKey] ) {
    self.detailTextLabel.attributedText = [self defaultAttributedDetailString:config[kGCMItemDetailTextKey]];
  } else {
    self.detailTextLabel.attributedText = nil;
  }
}

- (NSAttributedString *)defaultAttributedDetailString:(NSString *)detailString {
  NSMutableAttributedString *attributedDetail = [[NSMutableAttributedString alloc] initWithString:detailString];
  [attributedDetail addAttributeForTextColor:[UIColor colorWithRed:146.f/255.f green:146.f/255.f blue:146.f/255.f alpha:1.000]];
  [attributedDetail addAttributeForFont:[UIFont systemFontOfSize:15.0]];
  [attributedDetail addAttributeForTextAlignment:NSTextAlignmentRight lineBreakMode:NSLineBreakByWordWrapping];
  return attributedDetail;
}


#pragma mark - Static methods

+ (UIEdgeInsets)defaultInsets {
  return UIEdgeInsetsMake(11.f, 20.f, 11.f, 20.f);
}

+ (CGFloat)maxLabelWidthForCellWithWidth:(CGFloat)cellWidth
                                  insets:(UIEdgeInsets)insets
                               isChecked:(BOOL)checked
                           hasDetailtext:(BOOL)detailText
                                hasImage:(BOOL)image {
  
  CGFloat maxWidth = cellWidth - insets.left - insets.right;
  maxWidth -= checked ? kGCCheckAccesoryWidth : 0.f;
  maxWidth -= detailText ? kGCDetailTextWidth + kGCInnerSpace : 0.f;
  maxWidth -= image ? kCGImageDimension + kGCInnerSpace : 0.f;
  return maxWidth;
}

+ (CGFloat)cellHeightForAttributedText:(NSAttributedString *)attrText
                         withCellWidth:(CGFloat)cellWidth
                             isChecked:(BOOL)checked
                         hasDetailtext:(BOOL)detailText
                              hasImage:(BOOL)image
                           usingInsets:(UIEdgeInsets)insets {
  
  CGFloat labelWidth = [self maxLabelWidthForCellWithWidth:cellWidth
                                                    insets:insets
                                                 isChecked:checked
                                             hasDetailtext:detailText
                                                  hasImage:image];
  
  return [self labelHeightForAttributedText:attrText withLabelWidth:labelWidth] + insets.top + insets.bottom;
}

+ (CGFloat)labelHeightForAttributedText:(NSAttributedString *)attrText
                         withLabelWidth:(CGFloat)labelWidth {
  return MAX(22.f, [attrText integralHeightGivenWidth:labelWidth]);
}

@end
