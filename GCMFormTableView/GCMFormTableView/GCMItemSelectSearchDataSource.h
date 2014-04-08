//
//  GCMItemSelectSearchDataSource.h
//  GCMFormTableView
//
//  Created by Eduardo Arenas on 4/7/14.
//  Copyright (c) 2014 GameChanger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GCMItemSelectSearchDataSource : NSObject <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate>

- (id)initWithSections:(NSArray *)sections;

@end

@protocol GCMItemSelectSearchDataSourceDelegate <NSObject>

@end