//
//  GCMSection.m
//  GCMFormTableView
//
//  Created by Eduardo Arenas on 4/8/14.
//  Copyright (c) 2014 GameChanger. All rights reserved.
//

#import "GCMSection.h"

@implementation GCMSection

- (id)initWithHeader:(NSAttributedString *)header
             footer:(NSAttributedString *)footer
      andIndexTitle:(NSString *)indexTitle {
  self = [super init];
  if ( self ) {
    self.items = [[NSMutableArray alloc] init];
    self.header = header;
    self.footer = footer;
    self.indexTitle = indexTitle;
  }
  return self;
}

@end
