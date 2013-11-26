//
//  GCMFormTableViewDataSource+Testing.h
//  GameChanger
//
//  Created by Jerry Hsu on 11/4/13.
//  Copyright (c) 2013 GameChanger. All rights reserved.
//

#import "GCMFormTableViewDataSource.h"

@interface GCMFormTableViewDataSource (Testing)

- (NSIndexPath *)indexPathForRowConfigAfterRowConfigAtIndexPath:(NSIndexPath *)indexPath thatMatchesPredicate:(NSPredicate *)predicate;

@end
