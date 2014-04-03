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
