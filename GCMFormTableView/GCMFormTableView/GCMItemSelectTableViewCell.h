//
//  GCMItemSelectTableViewCell.h
//  Pods
//
//  Created by Eduardo Arenas on 4/3/14.
//
//

#import <UIKit/UIKit.h>

@class GCMItem;

@interface GCMItemSelectTableViewCell : UITableViewCell

@property (nonatomic) UIEdgeInsets cellInsets;
@property (nonatomic) BOOL isChecked;

- (void)setContentForItem:(GCMItem *)item;

+ (UIEdgeInsets)defaultInsets;

+ (CGFloat)cellHeightForAttributedText:(NSAttributedString *)attrText
                         withCellWidth:(CGFloat)cellWidth
                             isChecked:(BOOL)checked
                         hasDetailtext:(BOOL)detailText
                              hasImage:(BOOL)image
                           usingInsets:(UIEdgeInsets)insets;

@end
