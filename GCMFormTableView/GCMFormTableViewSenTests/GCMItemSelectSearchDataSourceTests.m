#import <Kiwi.h>
#import "GCMItemSelectSearchDataSource.h"
#import "GCMItemSelectSection.h"
#import "GCMItemSelectItem.h"

SPEC_BEGIN(GCMItemSelectSearchDataSourceTests)

describe(@"GCMItemSelectSearchDataSource", ^{
  __block GCMItemSelectSearchDataSource *dataSource;
  beforeEach(^{
    
    NSMutableArray *sections = [[NSMutableArray alloc] init];
    
    GCMItemSelectSection *section1 = [[GCMItemSelectSection alloc] init];
    NSAttributedString *item1 = [[NSAttributedString alloc] initWithString:@"abcd"];
    [section1.items addObject:[[GCMItemSelectItem alloc] initWithAttributedString:item1]];
    NSAttributedString *item2 = [[NSAttributedString alloc] initWithString:@"cdef"];
    [section1.items addObject:[[GCMItemSelectItem alloc] initWithAttributedString:item2]];
    [sections addObject:section1];
    
    GCMItemSelectSection *section2 = [[GCMItemSelectSection alloc] init];
    NSAttributedString *item3 = [[NSAttributedString alloc] initWithString:@"ghij"];
    [section2.items addObject:[[GCMItemSelectItem alloc] initWithAttributedString:item3]];
    [sections addObject:section2];
    
    dataSource = [[GCMItemSelectSearchDataSource alloc] initWithSections:sections
                                                         andSelectedItem:nil];
  });
  describe(@"information gets filtered correctly for one word", ^{
    describe(@"when it has only one result", ^{
      beforeEach(^{
        [dataSource searchDisplayController:nil shouldReloadTableForSearchString:@"bc"];
      });
      it(@"has the correct number of rows",^{
        [[theValue([dataSource tableView:nil numberOfRowsInSection:0]) should] equal:theValue(1)];
      });
      it(@"creates the correct cells", ^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        UITableViewCell *cell = [dataSource tableView:nil cellForRowAtIndexPath:indexPath];
        [[cell.textLabel.text should] equal:@"abcd"];
      });
    });
    describe(@"when it has multiple results", ^{
      beforeEach(^{
        [dataSource searchDisplayController:nil shouldReloadTableForSearchString:@"cd"];
      });
      it(@"has the correct number of rows",^{
        [[theValue([dataSource tableView:nil numberOfRowsInSection:0]) should] equal:theValue(2)];
      });
      it(@"creates the correct cells", ^{
        NSIndexPath *indexPath0 = [NSIndexPath indexPathForRow:0 inSection:0];
        NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:1 inSection:0];
        UITableViewCell *cell0 = [dataSource tableView:nil cellForRowAtIndexPath:indexPath0];
        UITableViewCell *cell1 = [dataSource tableView:nil cellForRowAtIndexPath:indexPath1];
        [[cell0.textLabel.text should] equal:@"abcd"];
        [[cell1.textLabel.text should] equal:@"cdef"];
      });
    });
    describe(@"when it has no results", ^{
      beforeEach(^{
        [dataSource searchDisplayController:nil shouldReloadTableForSearchString:@"xy"];
      });
      it(@"has the correct number of rows",^{
        [[theValue([dataSource tableView:nil numberOfRowsInSection:0]) should] equal:theValue(0)];
      });
    });
  });
  
  describe(@"information gets filtered correctly for multiple words", ^{
    describe(@"when it has only one result", ^{
      beforeEach(^{
        [dataSource searchDisplayController:nil shouldReloadTableForSearchString:@"hi ij"];
      });
      it(@"has the correct number of rows",^{
        [[theValue([dataSource tableView:nil numberOfRowsInSection:0]) should] equal:theValue(1)];
      });
      it(@"creates the correct cells", ^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        UITableViewCell *cell = [dataSource tableView:nil cellForRowAtIndexPath:indexPath];
        [[cell.textLabel.text should] equal:@"ghij"];
      });
    });
    describe(@"when it has multiple results", ^{
      beforeEach(^{
        [dataSource searchDisplayController:nil shouldReloadTableForSearchString:@"c d"];
      });
      it(@"has the correct number of rows",^{
        [[theValue([dataSource tableView:nil numberOfRowsInSection:0]) should] equal:theValue(2)];
      });
      it(@"creates the correct cells", ^{
        NSIndexPath *indexPath0 = [NSIndexPath indexPathForRow:0 inSection:0];
        NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:1 inSection:0];
        UITableViewCell *cell0 = [dataSource tableView:nil cellForRowAtIndexPath:indexPath0];
        UITableViewCell *cell1 = [dataSource tableView:nil cellForRowAtIndexPath:indexPath1];
        [[cell0.textLabel.text should] equal:@"abcd"];
        [[cell1.textLabel.text should] equal:@"cdef"];
      });
    });
    describe(@"when it has no results for one of the words", ^{
      beforeEach(^{
        [dataSource searchDisplayController:nil shouldReloadTableForSearchString:@"ab xy"];
      });
      it(@"has the correct number of rows",^{
        [[theValue([dataSource tableView:nil numberOfRowsInSection:0]) should] equal:theValue(0)];
      });
    });
  });
});

SPEC_END
