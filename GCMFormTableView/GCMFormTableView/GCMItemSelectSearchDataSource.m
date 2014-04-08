//
//  GCMItemSelectSearchDataSource.m
//  GCMFormTableView
//
//  Created by Eduardo Arenas on 4/7/14.
//  Copyright (c) 2014 GameChanger. All rights reserved.
//

#import "GCMItemSelectSearchDataSource.h"
#import "GCMItemSelectTableViewCell.h"
#import "GCMSection.h"
#import "GCMItem.h"

@interface GCMItemSelectSearchDataSource ()

@property (nonatomic, strong) NSMutableArray *consolidatedItems;
@property (nonatomic, strong) NSArray *searchResults;

@end

@implementation GCMItemSelectSearchDataSource

- (id)initWithSections:(NSArray *)sections {
  self = [super init];
  if ( self ) {
    _consolidatedItems = [[NSMutableArray alloc] init];
    [self consolidateSection:sections];
    [self filterItemsForSearchString:nil];
  }
  return self;
}

- (void)consolidateSection:(NSArray *)sections {
  for ( GCMSection *section in sections ) {
    [self.consolidatedItems addObjectsFromArray:section.items];
  }
}

- (void)filterItemsForSearchString:(NSString *)string {
  if ( ! string ) {
    self.searchResults = self.consolidatedItems.copy;
  } else {
    NSArray *searchTerms = [string componentsSeparatedByString:@" "];
    
    NSMutableArray *resultSets = [[NSMutableArray alloc] init];
    for ( NSString *searchTerm in searchTerms ) {
      NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"string contains[c] %@", searchTerm];
      NSOrderedSet *partialResult = [NSOrderedSet orderedSetWithArray:[self.consolidatedItems filteredArrayUsingPredicate:resultPredicate]];
      [resultSets addObject:partialResult];
    }
    
    NSMutableOrderedSet *intersection = [[NSMutableOrderedSet alloc] init];
    for (NSOrderedSet *partialResult in resultSets) {
      if ( partialResult.count ) {
        if ( ! intersection.count ) {
          [intersection addObjectsFromArray:partialResult.array];
        } else {
          [intersection intersectOrderedSet:partialResult];
        }
      }
    }
    self.searchResults = intersection.array;
  }
}

#pragma mark - UITableView

static NSString* kCellReuseId = @"searchResultCell";

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  GCMItemSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseId];
  if ( ! cell ) {
    cell = [[GCMItemSelectTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kCellReuseId];
  }
  cell.textLabel.attributedText = [self.searchResults objectAtIndex:indexPath.row];
//  NSDictionary *config = self.indexPathToConfigMap[indexPath];
//  cell.imageView.image = config[kGCMItemSelectImageKey];
//  if ( config[kGCMItemSelectDisabledItemKey] ) {
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    cell.contentView.alpha = 0.5;
//  } else {
//    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
//    cell.contentView.alpha = 1.0;
//  }
//  if ( config[kGCMItemDetailTextKey] ) {
//    cell.detailTextLabel.attributedText = [self defaultAttributedDetailString:config[kGCMItemDetailTextKey]];
//  } else {
//    cell.detailTextLabel.attributedText = nil;
//  }
//  
//  cell.isChecked = [self.selectedIndexPath isEqual:indexPath];
  return cell;
}

#pragma mark - UISearchDisplay

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
  [self filterItemsForSearchString:searchString];
  return YES;
}

@end
