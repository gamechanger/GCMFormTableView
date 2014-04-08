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

- (id)initWithSections:(NSArray *)sections andSelectedItem:(GCMItem *)selected {
  self = [super init];
  if ( self ) {
    self.selectedItem = selected;
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
    
    NSMutableOrderedSet *intersection = [[NSMutableOrderedSet alloc] init];
    for ( NSString *searchTerm in searchTerms ) {
      if ( ! [searchTerm isEqualToString:@""] && ! [searchTerm isEqualToString:@" "] ) {
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"attributedString.string contains[c] %@", searchTerm];
        NSOrderedSet *partialResult = [NSOrderedSet orderedSetWithArray:[self.consolidatedItems filteredArrayUsingPredicate:resultPredicate]];
        if ( partialResult.count == 0 ) {
          self.searchResults = [NSArray array];
          return;
        }
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
  GCMItem *item = self.searchResults[indexPath.row];
  [cell setContentForItem:item];  
  cell.isChecked = [item isEqual:self.selectedItem];
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self.delegate didSelectItem:self.searchResults[indexPath.row]];
}

#pragma mark - UISearchDisplay

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
  [self filterItemsForSearchString:searchString];
  return YES;
}

@end
