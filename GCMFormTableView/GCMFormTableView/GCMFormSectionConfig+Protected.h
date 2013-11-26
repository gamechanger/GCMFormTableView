//
//  GCMFormSectionConfig+Protected.h
//  GameChanger
//
//  Created by Jerry Hsu on 10/31/13.
//  Copyright (c) 2013 GameChanger. All rights reserved.
//

#import "GCMFormSectionConfig.h"

@interface GCMFormSectionConfig ()

- (void)addRowConfig:(GCMFormRowConfig *)rowConfig;
- (void)replaceRowConfigAtIndex:(NSInteger)row withRowConfig:(GCMFormRowConfig *)rowConfig;

@end
