//
//  GCMItemSelectSection.m
//  GCMFormTableView
//
//  Created by Eduardo Arenas on 4/8/14.
//  Copyright (c) 2014 GameChanger. All rights reserved.
//

#import "GCMItemSelectSection.h"

@implementation GCMItemSelectSection

- (instancetype)init {
  return [self initWithHeader:nil footer:nil indexTitle:nil andSeparatorHeight:0.f];
}

- (instancetype)initWithHeader:(NSAttributedString *)header
              footer:(NSAttributedString *)footer
          indexTitle:(NSString *)indexTitle
  andSeparatorHeight:(CGFloat)height {
  self = [super init];
  if ( self ) {
    _items = [[NSMutableArray alloc] init];
    _header = header;
    _footer = footer;
    _indexTitle = indexTitle;
    _separatorHeight = height;
  }
  return self;
}

@end
