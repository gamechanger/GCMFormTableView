#import <Kiwi.h>
#import "GCMItemSelectTableViewDataSource.h"
#import "GCMItemSelectItem.h"

SPEC_BEGIN(GCMItemSelectTableViewDataSourceTests)

describe(@"GCMItemSelectTableViewDataSource", ^{
  __block GCMItemSelectTableViewDataSource *dataSource;
  beforeEach(^{
    dataSource = [[GCMItemSelectTableViewDataSource alloc] init];
  });

  describe(@"hasItems", ^{
    it(@"returns NO if there are no sections", ^{
      [[theValue(dataSource.hasItems) should] equal:theValue(NO)];
    });
    it(@"returns NO if all sections have no items", ^{
      [dataSource addSectionBreak];
      [[theValue(dataSource.hasItems) should] equal:theValue(NO)];
    });
    it(@"returns YES if there's at least one item", ^{
      [dataSource addSectionBreak];
      [dataSource addItemWithName:@"something" tag:216 andUserInfo:@"info"];
      [[theValue(dataSource.hasItems) should] equal:theValue(YES)];
    });
    it(@"automatically adds a section for first addItem: but not second", ^{
      [dataSource addItemWithName:@"Test" tag:0 andUserInfo:nil];
      [[theValue([dataSource numberOfSectionsInTableView:nil]) should] equal:theValue(1)];
      [dataSource addItemWithName:@"Test 2" tag:0 andUserInfo:nil];
      [[theValue([dataSource numberOfSectionsInTableView:nil]) should] equal:theValue(1)];
    });
    it(@"stores section information for addSectionBreak",^{
      [dataSource addSectionBreak];
      [[theValue([dataSource numberOfSectionsInTableView:nil]) should] equal:theValue(1)];
      [[[dataSource tableView:nil viewForHeaderInSection:0] should] beNil];
      [[[dataSource tableView:nil viewForFooterInSection:0] should] beNil];
    });
    it(@"modifies section information for setFooterTitle:forSection:",^{
      [dataSource addSectionBreak];
      [[theValue([dataSource numberOfSectionsInTableView:nil]) should] equal:theValue(1)];
      [[[dataSource tableView:nil viewForHeaderInSection:0] should] beNil];
      [[[dataSource tableView:nil viewForFooterInSection:0] should] beNil];
      [dataSource setFooterTitle:@"Test Footer" forSection:0];
      UITableViewHeaderFooterView *footerView = (id) [dataSource tableView:nil viewForFooterInSection:0];
      UILabel *label = (UILabel *)[footerView viewWithTag:kGCItemSelectFooterLabelTag];
      [[label.text should] equal:@"Test Footer"];
    });
    it(@"stores items in multiple sections", ^{
      [dataSource addSectionBreak];
      [dataSource addItemWithName:@"0.0" andUserInfo:nil];
      [dataSource addSectionBreak];
      [dataSource addItemWithName:@"1.0" andUserInfo:nil];
      [dataSource addItemWithName:@"1.1" andUserInfo:nil];
      [dataSource addSectionBreak];
      [dataSource addItemWithName:@"2.0" andUserInfo:nil];

      [[theValue([dataSource numberOfSectionsInTableView:nil]) should] equal:theValue(3)];
      [[theValue([dataSource tableView:nil numberOfRowsInSection:0]) should] equal:theValue(1)];
      [[theValue([dataSource tableView:nil numberOfRowsInSection:1]) should] equal:theValue(2)];
      [[theValue([dataSource tableView:nil numberOfRowsInSection:2]) should] equal:theValue(1)];
    });
  });
  describe(@"section information populated by addSectionWithHeaderTitle:", ^{
    beforeEach(^{
      [dataSource addSectionWithHeaderTitle:@"Header 1" andFooterTitle:nil];
      [dataSource addSectionWithHeaderTitle:nil andFooterTitle:@"Footer 2"];
      [dataSource addSectionWithHeaderTitle:@"Header 3" andFooterTitle:@"Footer 3"];
    });
    it(@"has the correct number of sections",^{
      [[theValue([dataSource numberOfSectionsInTableView:nil]) should] equal:theValue(3)];
    });
    it(@"has the correct data for section 0",^{
      UIView *headerView = [dataSource tableView:nil viewForHeaderInSection:0];
      UIView *footerView = [dataSource tableView:nil viewForFooterInSection:0];
      UILabel *label = (UILabel *)[headerView viewWithTag:kGCItemSelectHeaderLabelTag];
      [[label.text should] equal:@"Header 1"];
      [footerView shouldBeNil];
    });
    it(@"has the correct data for section 1",^{
      UIView *headerView = [dataSource tableView:nil viewForHeaderInSection:1];
      UIView *footerView = [dataSource tableView:nil viewForFooterInSection:1];
      [headerView shouldBeNil];
      UILabel *label = (UILabel *)[footerView viewWithTag:kGCItemSelectFooterLabelTag];
      [[label.text should] equal:@"Footer 2"];
    });
    it(@"has the correct data for header of section 2",^{
      UIView *headerView = [dataSource tableView:nil viewForHeaderInSection:2];
      UILabel *label = (UILabel *)[headerView viewWithTag:kGCItemSelectHeaderLabelTag];
      [[label.text should] equal:@"Header 3"];
    });
    it(@"has the correct data for footer of section 2",^{
      UIView *footerView = [dataSource tableView:nil viewForFooterInSection:2];
      UILabel *label = (UILabel *)[footerView viewWithTag:kGCItemSelectFooterLabelTag];
      [[label.text should] equal:@"Footer 3"];
    });
  });
  describe(@"section information populated by addSectionWithAttributedHeaderTitle:attributedFooterTitle:andIndexTitle:", ^{
    beforeEach(^{
      [dataSource addSectionWithHeaderTitle:@"Header 1" footerTitle:nil andIndexTitle:nil];
      [dataSource addSectionWithHeaderTitle:nil footerTitle:@"Footer 2" andIndexTitle:nil];
      [dataSource addSectionWithHeaderTitle:nil footerTitle:nil andIndexTitle:@"Index 3"];
      [dataSource addSectionWithHeaderTitle:@"Header 4" footerTitle:@"Footer 4" andIndexTitle:@"Index 4"];
    });
    it(@"has the correct number of sections",^{
      [[theValue([dataSource numberOfSectionsInTableView:nil]) should] equal:theValue(4)];
    });
    it(@"has the correct index titles array", ^{
      NSArray* indexTitles = [dataSource sectionIndexTitlesForTableView:nil];
      [[theValue(indexTitles.count) should] equal:theValue(2)];
      [[theValue([indexTitles containsObject:@"Index 3"]) should] equal:theValue(YES)];
      [[theValue([indexTitles containsObject:@"Index 4"]) should] equal:theValue(YES)];
      [[theValue([indexTitles containsObject:[NSNull null]]) should] equal:theValue(NO)];
    });
    it(@"has the correct data for section 0",^{
      UIView *headerView = [dataSource tableView:nil viewForHeaderInSection:0];
      UIView *footerView = [dataSource tableView:nil viewForFooterInSection:0];
      UILabel *label = (UILabel *)[headerView viewWithTag:kGCItemSelectHeaderLabelTag];
      [[label.text should] equal:@"Header 1"];
      [footerView shouldBeNil];
    });
    it(@"has the correct data for section 1",^{
      UIView *headerView = [dataSource tableView:nil viewForHeaderInSection:1];
      UIView *footerView = [dataSource tableView:nil viewForFooterInSection:1];
      [headerView shouldBeNil];
      UILabel *label = (UILabel *)[footerView viewWithTag:kGCItemSelectFooterLabelTag];
      [[label.text should] equal:@"Footer 2"];
    });
    it(@"has the correct data for section 2",^{
      UIView *headerView = [dataSource tableView:nil viewForHeaderInSection:2];
      UIView *footerView = [dataSource tableView:nil viewForFooterInSection:2];
      [headerView shouldBeNil];
      [footerView shouldBeNil];
    });
    it(@"returns correct index for section 2", ^{
      NSArray* indexTitles = [dataSource sectionIndexTitlesForTableView:nil];
      NSString* indexTitle = @"Index 3";
      NSInteger section = [dataSource tableView:nil
                    sectionForSectionIndexTitle:indexTitle
                                        atIndex:[indexTitles indexOfObject:indexTitle]];
      [[theValue(section) should] equal:theValue(2)];
    });
    it(@"has the correct data for section 3",^{
      UIView *headerView = [dataSource tableView:nil viewForHeaderInSection:3];
      UIView *footerView = [dataSource tableView:nil viewForFooterInSection:3];
      UILabel *label = (UILabel *)[headerView viewWithTag:kGCItemSelectHeaderLabelTag];
      [[label.text should] equal:@"Header 4"];
      label = (UILabel *)[footerView viewWithTag:kGCItemSelectFooterLabelTag];
      [[label.text should] equal:@"Footer 4"];
    });
    it(@"returns correct index for section 3", ^{
      NSArray* indexTitles = [dataSource sectionIndexTitlesForTableView:nil];
      NSString* indexTitle = @"Index 4";
      NSInteger section = [dataSource tableView:nil
                    sectionForSectionIndexTitle:indexTitle
                                        atIndex:[indexTitles indexOfObject:indexTitle]];
      [[theValue(section) should] equal:theValue(3)];
    });
  });

  describe(@"populated dataSource", ^{
    beforeEach(^{
      [dataSource addItemWithName:@"Item 0.0" tag:1 andUserInfo:@"0.0"];
      [dataSource addItemWithName:@"Item 0.1" tag:2 andUserInfo:@"0.1"];
      [dataSource addItemWithName:@"Item 0.2" tag:3 andUserInfo:@"0.2"];
      [dataSource addSectionBreak];
      [dataSource addItemWithName:@"Item 1.0" tag:4 andUserInfo:@"1.0"];
      [dataSource addItemWithName:@"Item 1.1" tag:5 andUserInfo:@"1.1"];
      [dataSource addSectionBreak];
      [dataSource addSectionBreak];
      [dataSource addItemWithName:@"Item 3.0" tag:1 andUserInfo:nil];
      [dataSource addItemWithName:@"Item 3.1" tag:1 andUserInfo:@"3.1"];
      [dataSource addItemWithName:@"Item 3.2" tag:6 andUserInfo:@"0.2"];
    });
    it(@"has itemAtIndexPath: return nil for non-existant indexPath", ^{
      [[[dataSource itemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]] should] beNil];
      [[[dataSource itemAtIndexPath:[NSIndexPath indexPathForRow:NSNotFound inSection:NSNotFound]] should] beNil];
      [[[dataSource itemAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:3]] should] beNil];
    });
    it(@"has itemAtIndexPath: return correct item for various indexPaths",^{
      [[[dataSource itemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] should] equal:@"Item 0.0"];
      [[[dataSource itemAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]] should] equal:@"Item 0.2"];
      [[[dataSource itemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]] should] equal:@"Item 3.0"];
      [[[dataSource itemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:3]] should] equal:@"Item 3.1"];
    });
    it(@"has tagForItemAtIndexPath: return correct tags for various indexPaths",^{
      [[theValue([dataSource tagForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]) should] equal:theValue(1)];
      [[theValue([dataSource tagForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]]) should] equal:theValue(0)];
      [[theValue([dataSource tagForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]]) should] equal:theValue(4)];
      [[theValue([dataSource tagForItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]]) should] equal:theValue(5)];
      [[theValue([dataSource tagForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]]) should] equal:theValue(1)];
      [[theValue([dataSource tagForItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:3]]) should] equal:theValue(1)];
    });
    it(@"has userInfoForItemAtIndexPath: return correct values for various indexPaths",^{
      [[[dataSource userInfoForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] should] equal:@"0.0"];
      [[[dataSource userInfoForItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]] should] equal:@"1.1"];
      [[[dataSource userInfoForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]] should] beNil];
      [[[dataSource userInfoForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]] should] beNil];
      [[[dataSource userInfoForItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:3]] should] equal:@"3.1"];
    });
    it(@"determines if dataSource containsItemWithUserInfo:",^{
      [[theValue([dataSource containsItemWithUserInfo:@"0.0"]) should] equal:theValue(YES)];
      [[theValue([dataSource containsItemWithUserInfo:@"0.2"]) should] equal:theValue(YES)];
      [[theValue([dataSource containsItemWithUserInfo:@"3.1"]) should] equal:theValue(YES)];
      [[theValue([dataSource containsItemWithUserInfo:@"2.0"]) should] equal:theValue(NO)];
      [[theValue([dataSource containsItemWithUserInfo:nil]) should] equal:theValue(NO)];
      [[theValue([dataSource containsItemWithUserInfo:[NSNull null]]) should] equal:theValue(NO)];
    });
    it(@"finds indexPathForItemWithTag:4",^{
      [[[dataSource indexPathForItemWithTag:4] should] equal:[NSIndexPath indexPathForRow:0 inSection:1]];
    });
    it(@"finds indexPathForItemWithUserInfo:'3.1'",^{
      [[[dataSource indexPathForItemWithUserInfo:@"3.1"] should] equal:[NSIndexPath indexPathForRow:1 inSection:3]];
    });
    context(@"when cleared", ^{
      beforeAll(^{
        [dataSource clear];
      });
      
      it(@"contains no content", ^{
        [[theValue(dataSource.hasItems) should] equal:theValue(NO)];
      });
      
    });
  });
  describe(@"single section list", ^{
    beforeEach(^{
      [dataSource addItemWithName:@"Item 0" tag:0 andUserInfo:nil];
      [dataSource addItemWithName:@"Item 1" tag:0 andUserInfo:nil];
      [dataSource addItemWithName:@"Item 2" tag:0 andUserInfo:nil];
      [dataSource addItemWithName:@"Item 3" tag:0 andUserInfo:nil];
    });
    it(@"allows setting selectedIndex", ^{
      [[theBlock(^{
        dataSource.selectedIndex = 0;
      }) shouldNot] raise];
    });
    it(@"allows reading selectedIndex", ^{
      [[theBlock(^{
        [dataSource selectedIndex];
      }) shouldNot] raise];
    });
    it(@"maps selectedIndex to selectedIndexPath correctly", ^{
      dataSource.selectedIndex = 1;
      [[dataSource.selectedIndexPath should] equal:[NSIndexPath indexPathForRow:1 inSection:0]];
      dataSource.selectedIndex = NSNotFound;
      [[dataSource.selectedIndexPath should] beNil];
    });
    it(@"maps selectedIndexPath to selectedIndex correctly", ^{
      dataSource.selectedIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
      [[theValue(dataSource.selectedIndex) should] equal:theValue(2)];
      dataSource.selectedIndexPath = nil;
      [[theValue(dataSource.selectedIndex) should] equal:theValue(NSNotFound)];
    });
    describe(@"multiple section list", ^{
      beforeEach(^{
        [dataSource addItemWithName:@"Item 0.0" tag:0 andUserInfo:nil];
        [dataSource addItemWithName:@"Item 0.1" tag:0 andUserInfo:nil];
        [dataSource addItemWithName:@"Item 0.2" tag:0 andUserInfo:nil];
        [dataSource addItemWithName:@"Item 0.3" tag:0 andUserInfo:nil];
        [dataSource addSectionBreak];
        [dataSource addItemWithName:@"Item 1.0" tag:0 andUserInfo:nil];
      });
      it(@"asserts setting selectedIndex", ^{
        [[theBlock(^{
          dataSource.selectedIndex = 0;
        }) should] raise];
      });
      it(@"assert reading selectedIndex", ^{
        [[theBlock(^{
          [dataSource selectedIndex];
        }) should] raise];
      });
    });
  });

  describe(@"actionItems", ^{
    __block KWMock *delegateMock;
    beforeEach(^{
      delegateMock = [KWMock nullMockForProtocol:@protocol(GCMItemSelectTableViewDelegate)];
      dataSource.delegate = (id) delegateMock;
      GCMItemSelectItem *item = [[GCMItemSelectItem alloc] initWithString:@"Skip This Step"];
      item.actionItem = YES;
      item.tag = 1;
      item.userInfo = @2;
      [dataSource addItem:item];
    });
    it(@"calls the delegate method when the item is tapped", ^{
      [[[delegateMock should] receive] didSelectActionWithTag:1 andUserInfo:@2 fromItemSelectDataSource:dataSource];
      [dataSource tableView:nil didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    });
  });
});

SPEC_END
