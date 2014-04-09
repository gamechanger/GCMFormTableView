//
//  GCMItemSelectSearchDataSource.h
//  GCMFormTableView
//
//  Created by Eduardo Arenas on 4/7/14.
//  Copyright (c) 2014 GameChanger. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GCMItemSelectItem;

@protocol GCMItemSelectSearchDataSourceDelegate <NSObject>
- (void)didSelectItem:(GCMItemSelectItem *)item;
@end


@interface GCMItemSelectSearchDataSource : NSObject <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate>

@property (nonatomic, assign) id<GCMItemSelectSearchDataSourceDelegate> delegate;
@property (nonatomic, strong) GCMItemSelectItem *selectedItem;

- (id)initWithSections:(NSArray *)sections andSelectedItem:(GCMItemSelectItem *)selected;
@end
