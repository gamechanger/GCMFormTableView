//
//  GCMItemSelectTableViewCell.h
//  Pods
//
//  Created by Eduardo Arenas on 4/3/14.
//
//

#import <UIKit/UIKit.h>

@class GCMItemSelectItem;

@interface GCMItemSelectTableViewCell : UITableViewCell

@property (nonatomic) UIEdgeInsets cellInsets;
@property (nonatomic) BOOL useCellDivider;
@property (nonatomic) BOOL isChecked;

- (void)setContentForItem:(GCMItemSelectItem *)item;

+ (UIEdgeInsets)defaultInsets;

+ (CGFloat)cellHeightForAttributedText:(NSAttributedString *)attrText
                         withCellWidth:(CGFloat)cellWidth
                             isChecked:(BOOL)checked
                         hasDetailtext:(BOOL)detailText
                              hasImage:(BOOL)image
                      usesCellDivider:(BOOL)divider
                           usingInsets:(UIEdgeInsets)insets;

@end
