//
//  GCMSection.h
//  GCMFormTableView
//
//  Created by Eduardo Arenas on 4/8/14.
//  Copyright (c) 2014 GameChanger. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCMSection : NSObject

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSAttributedString *header;
@property (nonatomic, strong) NSAttributedString *footer;
@property (nonatomic, strong) NSString *indexTitle;

- (id)initWithHeader:(NSAttributedString *)header
              footer:(NSAttributedString *)footer
       andIndexTitle:(NSString *)indexTitle;

@end
