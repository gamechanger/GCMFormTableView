//
//  GCMFormTableViewDataSource.h
//  GameChanger
//
//  Created by Jerry Hsu on 10/30/13.
//  Copyright (c) 2013 GameChanger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCMFormSectionConfig.h"
#import "GCMFormRowConfig.h"

@class GCMFormTableViewDataSource;

typedef void (^GCMFormTableViewOnChangeBlock)(NSString *key, GCMFormTableViewDataSource *dataSource);
typedef void (^GCMFormTableViewCompletionBlock)(NSString *key, GCMFormTableViewDataSource *dataSource);
typedef BOOL (^GCMFormTableViewValidationBlock)(NSDictionary *values);

@interface GCMFormTableViewDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>

// TODO: This sucks, but the tableView property sucked so we're doubling down and we will
// refactor this out in 4.14 bug sweep or this comment will be deleted.
@property (nonatomic, weak) UIViewController *parentController;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, copy) GCMFormTableViewOnChangeBlock onChangeBlock;
@property (nonatomic, copy) GCMFormTableViewCompletionBlock completionBlock;

/// Executes validationBlock with values. If validationBlock is nil, then only validates whether required
/// values are present.
@property (nonatomic, assign, readonly) BOOL dataIsValid;
@property (nonatomic, copy) GCMFormTableViewValidationBlock validationBlock;

- (NSDictionary *)values;
- (NSArray *)allRowConfigs;

- (void)addSectionConfig:(GCMFormSectionConfig *)sectionConfig;
- (void)addRowConfig:(GCMFormRowConfig *)rowConfig;
/// key/value pairs will be added to the returned values. If value is nil, then key will be removed from hiddenData.
- (void)setHiddenKey:(NSString *)key value:(id)value;
- (GCMFormRowConfig *)rowConfigWithKey:(NSString *)key;
- (void)replaceRowConfigWithKey:(NSString *)key withRowConfig:(GCMFormRowConfig *)newRowConfig;
- (void)replaceRowConfigAtIndexPath:(NSIndexPath *)indexPath withRowConfig:(GCMFormRowConfig *)newRowConfig;
- (NSIndexPath *)indexPathForRowConfigWithKey:(NSString *)key;

/// Scroll to cell with firstResponder (if there is one).
- (void)centerTableViewOnActiveCell;

@end
