//
//  MovieCollectionViewFlowLayout.m
//  SwitchMovieGridDemo
//
//  Created by Igor Pesin on 6/20/15.
//  Copyright (c) 2015 Igor Pesin. All rights reserved.
//

#import "MovieCollectionViewFlowLayout.h"

NSUInteger const kMoviewItemHeigth = 100;

@implementation MovieCollectionViewFlowLayout

- (id)init {
    if (self = [super init]) {
        self.itemSize = CGSizeMake(kMoviewItemHeigth, kMoviewItemHeigth);
    }
    
    return self;
}

@end
