//
//  GCMItemSelectItem.h
//  GCMFormTableView
//
//  Created by Eduardo Arenas on 4/8/14.
//  Copyright (c) 2014 GameChanger. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCMItemSelectItem : NSObject

@property (nonatomic, strong) NSAttributedString *attributedString;
@property (nonatomic) NSInteger tag;
@property (nonatomic, strong) id userInfo;
@property (nonatomic, strong) NSDictionary *config;

- (id)initWithAttributedString:(NSAttributedString *)attrStr
                           tag:(NSInteger)tag
                      userInfo:(id)userInfo
                     andConfig:(NSDictionary *)config;

@end
