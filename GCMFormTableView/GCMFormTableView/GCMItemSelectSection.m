//
//  GCMItemSelectSection.m
//  GCMFormTableView
//
//  Created by Eduardo Arenas on 4/8/14.
//  Copyright (c) 2014 GameChanger. All rights reserved.
//

#import "GCMItemSelectSection.h"

@implementation GCMItemSelectSection

- (id)initWithHeader:(NSAttributedString *)header
             footer:(NSAttributedString *)footer
      andIndexTitle:(NSString *)indexTitle {
  self = [super init];
  if ( self ) {
    _items = [[NSMutableArray alloc] init];
    _header = header;
    _footer = footer;
    _indexTitle = indexTitle;
  }
  return self;
}

@end
