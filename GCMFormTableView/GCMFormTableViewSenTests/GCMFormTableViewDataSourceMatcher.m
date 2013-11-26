#import "GCMFormTableViewDataSourceMatcher.h"
#import "GCMFormRowConfig.h"
#import "GCMFormTableViewDataSource.h"

@interface GCMFormTableViewDataSourceMatcher ()

@property (nonatomic, strong) NSArray *expectedFields;
@property (nonatomic, strong) NSPredicate *filter;
@property (nonatomic, strong) NSString *failureMessageForShould;
@property (nonatomic, strong) NSString *failureMessageForShouldNot;

@end

@implementation GCMFormTableViewDataSourceMatcher

+ (NSArray *)matcherStrings {
  return @[@"haveRequiredFields:", @"haveOptionalFields:", @"haveEnabledFields:", @"haveDisabledFields:"];
}

- (BOOL)evaluate {
  return [[NSSet setWithArray:self.actualFields] isEqualToSet:[NSSet setWithArray:self.expectedFields]];
}

- (NSArray *)actualFields {
  return [[[self.subject allRowConfigs] filteredArrayUsingPredicate:self.filter] valueForKey:@"key"];
}

- (void)haveRequiredFields:(NSArray *)fields {
  self.expectedFields = [fields copy];
  self.filter = [NSPredicate predicateWithBlock:^BOOL(GCMFormRowConfig *rowConfig, NSDictionary *bindings) {
    return rowConfig.required;
  }];
  self.failureMessageForShould = [NSString stringWithFormat:@"expected subject to have required fields [%@]"
                                                                " but had required fields [%@]",
                                                            [self.expectedFields componentsJoinedByString:@", "],
                                                            [[self actualFields] componentsJoinedByString:@", "]];
  self.failureMessageForShouldNot = [NSString stringWithFormat:@"expected subject not to have required fields [%@]",
                                                               [self.expectedFields componentsJoinedByString:@", "]];
}

- (void)haveOptionalFields:(NSArray *)fields {
  self.expectedFields = [fields copy];
  self.filter = [NSPredicate predicateWithBlock:^BOOL(GCMFormRowConfig *rowConfig, NSDictionary *bindings) {
    return !rowConfig.required;
  }];
  self.failureMessageForShould = [NSString stringWithFormat:@"expected subject to have optional fields [%@]"
                                                                " but had optional fields [%@]",
                                                            [self.expectedFields componentsJoinedByString:@", "],
                                                            [[self actualFields] componentsJoinedByString:@", "]];
  self.failureMessageForShouldNot = [NSString stringWithFormat:@"expected subject not to have optional fields [%@]",
                                                               [self.expectedFields componentsJoinedByString:@", "]];
}

- (void)haveEnabledFields:(NSArray *)fields {
  self.expectedFields = [fields copy];
  self.filter = [NSPredicate predicateWithBlock:^BOOL(GCMFormRowConfig *rowConfig, NSDictionary *bindings) {
    return rowConfig.enabled;
  }];
  self.failureMessageForShould = [NSString stringWithFormat:@"expected subject to have enabled fields [%@]"
                                                                " but had enabled fields [%@]",
                                                            [self.expectedFields componentsJoinedByString:@", "],
                                                            [[self actualFields] componentsJoinedByString:@", "]];
  self.failureMessageForShouldNot = [NSString stringWithFormat:@"expected subject not to have enabled fields [%@]",
                                                               [self.expectedFields componentsJoinedByString:@", "]];
}

- (void)haveDisabledFields:(NSArray *)fields{
  self.expectedFields = [fields copy];
  self.filter = [NSPredicate predicateWithBlock:^BOOL(GCMFormRowConfig *rowConfig, NSDictionary *bindings) {
    return !rowConfig.enabled;
  }];
  self.failureMessageForShould = [NSString stringWithFormat:@"expected subject to have disabled fields [%@]"
                                                                " but had disabled fields [%@]",
                                                            [self.expectedFields componentsJoinedByString:@", "],
                                                            [[self actualFields] componentsJoinedByString:@", "]];
  self.failureMessageForShouldNot = [NSString stringWithFormat:@"expected subject not to have disabled fields [%@]",
                                                               [self.expectedFields componentsJoinedByString:@", "]];
}

@end
