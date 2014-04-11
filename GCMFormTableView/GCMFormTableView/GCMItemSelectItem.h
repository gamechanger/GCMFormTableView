//
//  GCMItemSelectItem.h
//  GCMFormTableView
//
//  Created by Eduardo Arenas on 4/8/14.
//  Copyright (c) 2014 GameChanger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GCMItemSelectItem : NSObject

@property (nonatomic, strong) NSAttributedString *attributedString;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic) NSString *detailText;
@property (nonatomic) NSInteger tag;
@property (nonatomic, strong) id userInfo;
@property (nonatomic) BOOL disabled;
@property (nonatomic) BOOL useCellDivider;
@property (nonatomic) BOOL actionItem;

@property (nonatomic, strong) NSDictionary *config;

- (id)initWithString:(NSString *)str;
- (id)initWithAttributedString:(NSAttributedString *)attrStr;

+ (NSAttributedString *)defaultItemAttributedStringForString:(NSString *)title;

@end
