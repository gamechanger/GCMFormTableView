#import <Foundation/Foundation.h>
#import "KWMatcher.h"


@interface GCMFormTableViewDataSourceMatcher : KWMatcher

- (void)haveRequiredFields:(NSArray *)fields;
- (void)haveOptionalFields:(NSArray *)fields;
- (void)haveEnabledFields:(NSArray *)fields;
- (void)haveDisabledFields:(NSArray *)fields;

@end
