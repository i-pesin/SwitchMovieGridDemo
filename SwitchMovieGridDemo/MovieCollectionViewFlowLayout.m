//
//  MovieCollectionViewFlowLayout.m
//  SwitchMovieGridDemo
//
//  Created by Igor Pesin on 6/20/15.
//  Copyright (c) 2015 Igor Pesin. All rights reserved.
//

#import "MovieCollectionViewFlowLayout.h"

NSUInteger const kMoviewItemHeigth = 100;

static NSUInteger itemsPerRow;

@implementation MovieCollectionViewFlowLayout

- (id)init {
    if (self = [super init]) {
        self.itemSize = CGSizeMake(kMoviewItemHeigth, kMoviewItemHeigth);
        
        CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
        itemsPerRow = truncf(screenWidth / kMoviewItemHeigth);
        self.minimumInteritemSpacing = (screenWidth - kMoviewItemHeigth * itemsPerRow) / (itemsPerRow + 1);
        self.minimumLineSpacing = self.minimumInteritemSpacing;
    }
    
    return self;
}

- (NSUInteger)numberOfImagesPerRow {
    return itemsPerRow;
}

@end
