//#import <Kiwi.h>
//#import "GCMFormRowConfig.h"
//#import "GCMFormTableViewDataSource.h"
//#import "GCMFormTableViewDataSource+Testing.h"
//#import "GCMFormSectionConfig.h"
//#import "GCCreateTeamStubRowConfig.h"
//
//
//SPEC_BEGIN(GCMFormTableViewDataSourceTests)
//
//describe(@"GCMFormTableViewDataSource", ^{
//  describe(@"values", ^{
//    it(@"consolidates values from multiple sections", ^{
//      GCMFormTableViewDataSource *dataSource = [[GCMFormTableViewDataSource alloc] init];
//      [dataSource addSectionConfig:[[GCMFormSectionConfig alloc] initWithTitle: @"foo"]];
//      [dataSource addRowConfig:[[GCCreateTeamStubRowConfig alloc] initWithKey:@"one" andValue:@"1"]];
//      [dataSource addSectionConfig:[[GCMFormSectionConfig alloc] initWithTitle:@"bar"]];
//      [dataSource addRowConfig:[[GCCreateTeamStubRowConfig alloc] initWithKey:@"two" andValue:@"2"]];
//      [[[dataSource values] should] equal:@{
//        @"one": @"1",
//        @"two": @"2"
//      }];
//    });
//    it(@"handles multiple values in one section", ^{
//      GCMFormTableViewDataSource *dataSource = [[GCMFormTableViewDataSource alloc] init];
//      [dataSource addSectionConfig:[[GCMFormSectionConfig alloc] initWithTitle: @"foo"]];
//      [dataSource addRowConfig:[[GCCreateTeamStubRowConfig alloc] initWithKey:@"one" andValue:@"1"]];
//      [dataSource addRowConfig:[[GCCreateTeamStubRowConfig alloc] initWithKey:@"two" andValue:@"2"]];
//      [[[dataSource values] should] equal:@{
//          @"one": @"1",
//          @"two": @"2"
//      }];
//    });
//    it(@"handles unset values by omitting them from the result", ^{
//      GCMFormTableViewDataSource *dataSource = [[GCMFormTableViewDataSource alloc] init];
//      [dataSource addSectionConfig:[[GCMFormSectionConfig alloc] initWithTitle: @"foo"]];
//      [dataSource addRowConfig:[[GCCreateTeamStubRowConfig alloc] initWithKey:@"one" andValue:@"1"]];
//      [dataSource addRowConfig:[[GCCreateTeamStubRowConfig alloc] initWithKey:@"two" andValue:nil]];
//      [[[dataSource values] should] equal:@{
//          @"one": @"1",
//      }];
//    });
//  });
//  describe(@"dataIsValid", ^{
//    __block GCMFormTableViewDataSource *dataSource;
//    __block GCMFormRowConfig *rowConfig1;
//    __block GCMFormRowConfig *rowConfig2;
//
//    beforeEach(^{
//      dataSource = [[GCMFormTableViewDataSource alloc] init];
//      rowConfig1 =  [[GCCreateTeamStubRowConfig alloc] initWithKey:@"one" andValue:nil];
//      rowConfig2 =  [[GCCreateTeamStubRowConfig alloc] initWithKey:@"two" andValue:nil];
//      [dataSource addRowConfig:rowConfig1];
//      [dataSource addRowConfig:rowConfig2];
//    });
//
//    context(@"no validation block and no required fields", ^{
//      it(@"returns YES", ^{
//        [[theValue(dataSource.dataIsValid) should] beYes];
//      });
//    });
//    context(@"validation block and no required fields", ^{
//      it(@"returns YES when the validation block evaluates to YES", ^{
//        dataSource.validationBlock = ^BOOL (NSDictionary *values) {
//          return YES;
//        };
//        [[theValue(dataSource.dataIsValid) should] beYes];
//      });
//      it(@"returns NO when the validation block evaluates to NO", ^{
//        dataSource.validationBlock = ^BOOL (NSDictionary *values) {
//          return NO;
//        };
//        [[theValue(dataSource.dataIsValid) should] beNo];
//      });
//    });
//    context(@"required fields and no validation block", ^{
//      beforeEach(^{
//        rowConfig1.required = YES;
//        rowConfig2.required = YES;
//      });
//      it(@"returns YES when the required fields are set", ^{
//        rowConfig1.value = @"1";
//        rowConfig2.value = @"2";
//        [[theValue(dataSource.dataIsValid) should] beYes];
//      });
//      it(@"returns NO when at least one required field is unset", ^{
//        rowConfig1.value = @"1";
//        [[theValue(dataSource.dataIsValid) should] beNo];
//      });
//      it(@"returns NO when at least one required field is set to the empty string", ^{
//        // this can happen when a value once existed and then was deleted
//        rowConfig1.value = @"1";
//        rowConfig2.value = @"";
//        [[theValue(dataSource.dataIsValid) should] beNo];
//      });
//    });
//    context(@"required fields and validation block", ^{
//      beforeEach(^{
//        rowConfig1.required = YES;
//        rowConfig2.required = YES;
//      });
//
//      it(@"returns YES when the required fields are set and the validation block returns YES", ^{
//        dataSource.validationBlock = ^BOOL (NSDictionary *values) {
//          return YES;
//        };
//        rowConfig1.value = @"1";
//        rowConfig2.value = @"2";
//        [[theValue(dataSource.dataIsValid) should] beYes];
//      });
//      it(@"returns NO when the validation block returns NO", ^{
//        dataSource.validationBlock = ^BOOL (NSDictionary *values) {
//          return NO;
//        };
//        rowConfig1.value = @"1";
//        rowConfig2.value = @"2";
//        [[theValue(dataSource.dataIsValid) should] beNo];
//      });
//      it(@"returns NO when a required field is unset", ^{
//        dataSource.validationBlock = ^BOOL (NSDictionary *values) {
//          return YES;
//        };
//        rowConfig1.value = @"1";
//        [[theValue(dataSource.dataIsValid) should] beNo];
//      });
//      it(@"returns NO when a required field is set to the empty string", ^{
//        // this can happen when a value once existed and then was deleted
//        dataSource.validationBlock = ^BOOL (NSDictionary *values) {
//          return YES;
//        };
//        rowConfig1.value = @"1";
//        rowConfig2.value = @"";
//        [[theValue(dataSource.dataIsValid) should] beNo];
//      });
//      it(@"returns NO when a required field is set to whitespace", ^{
//        // this can happen when a value once existed and then was deleted
//        dataSource.validationBlock = ^BOOL (NSDictionary *values) {
//          return YES;
//        };
//        rowConfig1.value = @"1";
//        rowConfig2.value = @" ";
//        [[theValue(dataSource.dataIsValid) should] beNo];
//      });
//      it(@"returns NO when a required field is set to whitespace", ^{
//        // this can happen when a value once existed and then was deleted
//        dataSource.validationBlock = ^BOOL (NSDictionary *values) {
//          return YES;
//        };
//        rowConfig1.value = @"1";
//        rowConfig2.value = @" ";
//        [[theValue(dataSource.dataIsValid) should] beNo];
//      });
//    });
//  });
//  describe(@"predicate search", ^{
//    __block GCMFormTableViewDataSource *dataSource;
//    __block NSPredicate *predicate;
//    beforeEach(^{
//      dataSource = [[GCMFormTableViewDataSource alloc] init];
//      [dataSource addSectionConfig:[[GCMFormSectionConfig alloc] init]];
//      [dataSource addRowConfig:[[GCCreateTeamStubRowConfig alloc] initWithKey:@"0.0" andValue:@"a.a"]];
//      [dataSource addRowConfig:[[GCCreateTeamStubRowConfig alloc] initWithKey:@"0.1" andValue:@"a.b"]];
//      [dataSource addSectionConfig:[[GCMFormSectionConfig alloc] init]];
//      [dataSource addRowConfig:[[GCCreateTeamStubRowConfig alloc] initWithKey:@"1.0" andValue:@"b.a"]];
//      [dataSource addRowConfig:[[GCCreateTeamStubRowConfig alloc] initWithKey:@"1.1" andValue:@"b.b"]];
//      predicate = [NSPredicate predicateWithBlock:^BOOL(GCMFormRowConfig *rowConfig, NSDictionary *bindings) {
//        return [rowConfig.key isEqualToString:@"1.1"];
//      }];
//    });
//    it(@"finds target cell when searching from the beginning (startIndexPath is nil)", ^{
//      NSIndexPath *indexPath = [dataSource indexPathForRowConfigAfterRowConfigAtIndexPath:nil thatMatchesPredicate:predicate];
//      [[indexPath should] equal:[NSIndexPath indexPathForRow:1 inSection:1]];
//    });
//    it(@"finds target cell when searching from an earlier section", ^{
//      NSIndexPath *indexPath = [dataSource indexPathForRowConfigAfterRowConfigAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
//                                                                     thatMatchesPredicate:predicate];
//      [[indexPath should] equal:[NSIndexPath indexPathForRow:1 inSection:1]];
//    });
//    it(@"finds target cell when searching from non-existant row in an earlier section", ^{
//      NSIndexPath *indexPath = [dataSource indexPathForRowConfigAfterRowConfigAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]
//                                                                     thatMatchesPredicate:predicate];
//      [[indexPath should] equal:[NSIndexPath indexPathForRow:1 inSection:1]];
//    });
//    it(@"finds target cell when searching from same section", ^{
//      NSIndexPath *indexPath = [dataSource indexPathForRowConfigAfterRowConfigAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]
//                                                                     thatMatchesPredicate:predicate];
//      [[indexPath should] equal:[NSIndexPath indexPathForRow:1 inSection:1]];
//    });
//    it(@"doesn't find target cell when searching from itself", ^{
//      NSIndexPath *indexPath = [dataSource indexPathForRowConfigAfterRowConfigAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]
//                                                                     thatMatchesPredicate:predicate];
//      [[indexPath should] beNil];
//    });
//    it(@"doesn't find target cell when searching from a non-existing path", ^{
//      NSIndexPath *indexPath = [dataSource indexPathForRowConfigAfterRowConfigAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]
//                                                                     thatMatchesPredicate:predicate];
//      [[indexPath should] beNil];
//    });
//    it(@"doesn't find anything cell when searching from the beginning for a missing key", ^{
//      NSIndexPath *indexPath = [dataSource indexPathForRowConfigAfterRowConfigAtIndexPath:nil
//                                                                     thatMatchesPredicate:[NSPredicate predicateWithBlock:^BOOL(GCMFormRowConfig *rowConfig, NSDictionary *bindings) {
//        return [rowConfig.key isEqualToString:@"3.0"];
//      }]];
//      [[indexPath should] beNil];
//    });
//  });
//});
//
//SPEC_END
