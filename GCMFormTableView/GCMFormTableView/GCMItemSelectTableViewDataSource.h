//
//  GCMItemSelectTableViewDataSource.h
//  GameChanger
//
//  Created by Jerry Hsu on 10/29/13.
//  Copyright (c) 2013 GameChanger. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSUInteger const kGCItemSelectHeaderLabelTag;
extern NSUInteger const kGCItemSelectFooterLabelTag;

@protocol GCMItemSelectTableViewDelegate;
@class GCMItemSelectSearchDataSource;
@class GCMItemSelectSection;
@class GCMItemSelectItem;

typedef void(^SectionBuilderBlock)(GCMItemSelectSection *section);
typedef void(^ItemBuilderBlock)(GCMItemSelectItem *item);

@interface GCMItemSelectTableViewDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id<GCMItemSelectTableViewDelegate> delegate;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
/**
 * Convenience to assign and read from selectedIndexPath with a section of 0.
 * Asserts if there is more than one section in the dataSource.
 * Returns NSNotFound if selectedIndexPath is nil and will set selectedIndexPath to nil if assigned NSNotFound.
 */
@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, readonly) NSInteger tagForSelectedItem;
@property (nonatomic, readonly) id userInfoForSelectedItem;
@property (nonatomic, strong) id userInfo;
@property (nonatomic, readonly) BOOL hasItems;
@property (nonatomic) BOOL useDefaultHeaders;
@property (nonatomic, strong) GCMItemSelectSearchDataSource *searchDataSource;

- (void)addSection:(GCMItemSelectSection *)section;
- (void)addSectionWithConfigurationBlock:(SectionBuilderBlock)block;

/// Creates a new section. headerTitle or footerTitle may be nil
- (void)addSectionWithAttributedHeaderTitle:(NSAttributedString *)headerTitle
                      attributedFooterTitle:(NSAttributedString *)footerTitle
                              andIndexTitle:(NSString *)indexTitle;

- (void)addSectionWithAttributedHeaderTitle:(NSAttributedString *)headerTitle
                   andAttributedFooterTitle:(NSAttributedString *)footerTitle;

/// Creates a new section. headerTitle or footerTitle may be nil.
- (void)addSectionWithHeaderTitle:(NSString *)headerTitle
                      footerTitle:(NSString *)footerTitle
                    andIndexTitle:(NSString *)indexTitle;

- (void)addSectionWithHeaderTitle:(NSString *)headerTitle andFooterTitle:(NSString *)footerTitle;
/// Calls addSectionWithHeaderTitle:andFooterTitle: passing nil for both arguments.
- (void)addSectionBreak;
- (void)addSectionBreakWithHeight:(CGFloat)height;
- (void)setAttributedFooterTitle:(NSAttributedString *)footerTitle forSection:(NSUInteger)section;
- (void)setFooterTitle:(NSString *)footerTitle forSection:(NSUInteger)section;

/**
 * Adds item to current section
 */
- (void)addItem:(GCMItemSelectItem *)item;
- (void)addItemWithConfigurationBlock:(ItemBuilderBlock)block;

- (void)addItemWithName:(NSString *)itemName andTag:(NSInteger)tag;
- (void)addItemWithName:(NSString *)itemName andUserInfo:(id)userInfo;
- (void)addItemWithName:(NSString *)itemName tag:(NSInteger)tag andUserInfo:(id)userInfo;

- (void)addItemWithAttributedName:(NSAttributedString *)itemName andTag:(NSInteger)tag;
- (void)addItemWithAttributedName:(NSAttributedString *)itemName andUserInfo:(id)userInfo;
- (void)addItemWithAttributedName:(NSAttributedString *)itemName tag:(NSInteger)tag andUserInfo:(id)userInfo;

///
- (NSString *)itemAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)tagForItemAtIndexPath:(NSIndexPath *)indexPath;
/// If multiple items have the same tag, an arbitrary matching item will be returned.
- (NSIndexPath *)indexPathForItemWithTag:(NSInteger)tag;
- (id)userInfoForItemAtIndexPath:(NSIndexPath *)indexPath;
/// If multiple items have the same userInfo, an arbitrary matching item will be returned.
- (NSIndexPath *)indexPathForItemWithUserInfo:(id)userInfo;

- (BOOL)containsItemWithUserInfo:(id)userInfo;
- (NSDictionary *)defaultHeaderFooterTextAttributes;

/// Clears the datasource of all content
- (void)clear;
@end

@protocol GCMItemSelectTableViewDelegate <NSObject>

- (void)didSelectItemSelectDataSource:(GCMItemSelectTableViewDataSource *)dataSource;

@optional
- (void)didSelectActionWithTag:(NSInteger)tag andUserInfo:(id)userInfo fromItemSelectDataSource:(GCMItemSelectTableViewDataSource *)dataSource;

@end

