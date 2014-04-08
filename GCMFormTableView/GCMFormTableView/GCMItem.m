//
//  GCMItem.m
//  GCMFormTableView
//
//  Created by Eduardo Arenas on 4/8/14.
//  Copyright (c) 2014 GameChanger. All rights reserved.
//

#import "GCMItem.h"

@implementation GCMItem

- (id)initWithAttributedString:(NSAttributedString *)attrStr
                           tag:(NSInteger)tag
                      userInfo:(id)userInfo
                     andConfig:(NSDictionary *)config {
  self = [super init];
  if ( self ) {
    self.attributedString = attrStr;
    self.tag = tag;
    self.userInfo = userInfo;
    self.config = config;
  }
  return self;
}

@end
