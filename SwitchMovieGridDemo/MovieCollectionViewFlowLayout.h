//
//  MovieCollectionViewFlowLayout.h
//  SwitchMovieGridDemo
//
//  Created by Igor Pesin on 6/20/15.
//  Copyright (c) 2015 Igor Pesin. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSUInteger const kMoviewItemHeigth;

@interface MovieCollectionViewFlowLayout : UICollectionViewFlowLayout

- (NSUInteger)numberOfImagesPerRow;

@end
