//
//  GCMItemSelectItem.m
//  GCMFormTableView
//
//  Created by Eduardo Arenas on 4/8/14.
//  Copyright (c) 2014 GameChanger. All rights reserved.
//

#import "GCMItemSelectItem.h"

@implementation GCMItemSelectItem

- (id)initWithAttributedString:(NSAttributedString *)attrStr
                           tag:(NSInteger)tag
                      userInfo:(id)userInfo
                     andConfig:(NSDictionary *)config {
  self = [super init];
  if ( self ) {
    _attributedString = attrStr;
    _tag = tag;
    _userInfo = userInfo;
    _config = config;
  }
  return self;
}

- (BOOL)isEqual:(id)object
{
  if ( ! [object isKindOfClass:self.class] ) {
    return NO;
  }
  GCMItemSelectItem *item = (GCMItemSelectItem *)object;
  return ((! self.attributedString && ! item.attributedString) || [self.attributedString isEqualToAttributedString:item.attributedString])
  && self.tag == item.tag
  && ((! self.userInfo && ! item.userInfo) || [self.userInfo isEqual:item.userInfo])
  && ((! self.config && ! item.config) || [self.config isEqualToDictionary:item.config]);
}

- (NSUInteger)hash {
  NSUInteger result = 1;
  NSUInteger prime = 31;
  
  result = prime * result + [self.attributedString hash];
  result = prime * result + self.tag;
  result = prime * result + [self.userInfo hash];
  result = prime * result + [self.config hash];
  
  return result;
}

@end
