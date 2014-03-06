//
//  GCMItemSelectViewControllerTests.m
//  GameChanger
//
//  Created by Jerry Hsu on 11/8/13.
//  Copyright (c) 2013 GameChanger. All rights reserved.
//

#import <Kiwi.h>
#import "GCMItemSelectViewController.h"
#import "GCMItemSelectTableViewDataSource.h"

@interface GCMItemSelectViewController (TestAccess)

- (void)confirmationTapped:(UIBarButtonItem *)button;

@end

SPEC_BEGIN(GCMItemSelectViewControllerTests)

describe(@"GCMItemSelectViewController", ^{
  __block GCMItemSelectViewController *controller;
  beforeEach(^{
    controller = [[GCMItemSelectViewController alloc] init];
    [controller.dataSource addItem:@"Item 0.0" withUserInfo:@"0.0"];
    [controller.dataSource addItem:@"Item 0.1" withUserInfo:@"0.1"];
  });
  context(@"default case", ^{
    beforeEach(^{
      [controller viewWillAppear:YES];
    });
    it(@"does not add a confirmation button", ^{
      [[controller.navigationItem.rightBarButtonItem should] beNil];
    });
    context(@"data reporting", ^{
      __block NSObject<GCMItemSelectViewControllerDelegate> *delegateObject;
      beforeEach(^{
        delegateObject = [KWMock mockForProtocol:@protocol(GCMItemSelectViewControllerDelegate)];
        controller.delegate = delegateObject;
        [controller viewWillAppear:YES];
      });
      it(@"reports first item selected", ^{
        [[[delegateObject should] receive] selectedItemInItemSelectViewController:controller andConfirmedSelection:NO];
        [controller.dataSource tableView:nil didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [[controller.dataSource.selectedIndexPath should] equal:[NSIndexPath indexPathForRow:0 inSection:0]];
      });
      it(@"reports second item selected", ^{
        [[[delegateObject should] receive] selectedItemInItemSelectViewController:controller andConfirmedSelection:NO];
        [controller.dataSource tableView:nil didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        [[controller.dataSource.selectedIndexPath should] equal:[NSIndexPath indexPathForRow:1 inSection:0]];
      });
    });
    context(@"data reporting with confirmation required", ^{
      __block NSObject<GCMItemSelectViewControllerDelegate> *delegateObject;
      beforeEach(^{
        delegateObject = [KWMock mockForProtocol:@protocol(GCMItemSelectViewControllerDelegate)];
        controller.delegate = delegateObject;
        controller.requireSelectionConfirmation = YES;
        [controller viewWillAppear:YES];
      });
      afterEach(^{
        delegateObject = nil;
      });
      it(@"reports first item selected", ^{
        [[[delegateObject should] receive] selectedItemInItemSelectViewController:controller andConfirmedSelection:NO];
        [controller.dataSource tableView:nil didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [[controller.dataSource.selectedIndexPath should] equal:[NSIndexPath indexPathForRow:0 inSection:0]];
      });
      it(@"reports second item selected", ^{
        [[[delegateObject should] receive] selectedItemInItemSelectViewController:controller andConfirmedSelection:NO];
        [controller.dataSource tableView:nil didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        [[controller.dataSource.selectedIndexPath should] equal:[NSIndexPath indexPathForRow:1 inSection:0]];
      });
      it(@"reports first item selected and confirmation tapped", ^{
        [[[delegateObject should] receive] selectedItemInItemSelectViewController:controller andConfirmedSelection:NO];
        [[[delegateObject should] receive] selectedItemInItemSelectViewController:controller andConfirmedSelection:YES];
        [controller.dataSource tableView:nil didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [[controller.dataSource.selectedIndexPath should] equal:[NSIndexPath indexPathForRow:0 inSection:0]];
        [controller confirmationTapped:nil];
        [[controller.dataSource.selectedIndexPath should] equal:[NSIndexPath indexPathForRow:0 inSection:0]];
      });
    });
  });
  context(@"confirmation required", ^{
    __block UIBarButtonItem *confirmationButton;
    beforeEach(^{
      controller.requireSelectionConfirmation = YES;
      [controller viewWillAppear:YES];
      confirmationButton = controller.navigationItem.rightBarButtonItem;
    });
    it(@"does add a confirmation button", ^{
      [[confirmationButton should] beNonNil];
    });
    it(@"does add a confirmation button with title 'Next'", ^{
      [[confirmationButton.title should] equal:@"Next"];
    });
    it(@"starts with confirmation button disabled", ^{
      [[theValue(confirmationButton.enabled) should] equal:theValue(NO)];
    });
    it(@"changes confirmation button to enabled after selection", ^{
      controller.dataSource.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
      [[theValue(confirmationButton.enabled) should] equal:theValue(YES)];
    });
    it(@"changes confirmation button to disabled after selection cleared", ^{
      controller.dataSource.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
      [[theValue(confirmationButton.enabled) should] equal:theValue(YES)];
      controller.dataSource.selectedIndexPath = nil;
      [[theValue(confirmationButton.enabled) should] equal:theValue(NO)];
    });
  });
  context(@"confirmation required and selection at launch", ^{
    __block UIBarButtonItem *confirmationButton;
    beforeEach(^{
      controller.requireSelectionConfirmation = YES;
      controller.dataSource.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
      [controller viewWillAppear:YES];
      confirmationButton = controller.navigationItem.rightBarButtonItem;
    });
    it(@"does add a confirmation button", ^{
      [[confirmationButton should] beNonNil];
    });
    it(@"starts with confirmation button enabled", ^{
      [[theValue(confirmationButton.enabled) should] equal:theValue(YES)];
    });
    it(@"changes confirmation button to disabled after selection cleared", ^{
      controller.dataSource.selectedIndexPath = nil;
      [[theValue(confirmationButton.enabled) should] equal:theValue(NO)];
    });
  });
  context(@"confirmation required and title set at launch", ^{
    __block UIBarButtonItem *confirmationButton;
    beforeEach(^{
      controller.requireSelectionConfirmation = YES;
      controller.confirmationTitle = @"Finish";
      [controller viewWillAppear:YES];
      confirmationButton = controller.navigationItem.rightBarButtonItem;
    });
    it(@"does add a confirmation button", ^{
      [[confirmationButton should] beNonNil];
    });
    it(@"does add a confirmation button with title 'Finish'", ^{
      [[confirmationButton.title should] equal:@"Finish"];
    });
    it(@"starts with confirmation button disabled", ^{
      [[theValue(confirmationButton.enabled) should] equal:theValue(NO)];
    });
    it(@"changes confirmation button title if changed after launch", ^{
      controller.confirmationTitle = @"Something Else";
      [[controller.navigationItem.rightBarButtonItem.title should] equal:@"Something Else"];
    });
  });
});

SPEC_END
