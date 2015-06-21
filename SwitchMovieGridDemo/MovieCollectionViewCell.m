//
//  MovieCollectionViewCell.m
//  SwitchMovieGridDemo
//
//  Created by Igor Pesin on 6/20/15.
//  Copyright (c) 2015 Igor Pesin. All rights reserved.
//

#import "MovieCollectionViewCell.h"

static NSString *placeholderImage = @"image-placeholder";

@interface MovieCollectionViewCell()
@property (nonatomic) UIImageView *imageView;
@end

@implementation MovieCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:placeholderImage]];
        [self.contentView addSubview:self.imageView];
    }
    
    return self;
}

- (void)setMovieImage:(UIImage *)movieImage {
    _movieImage = movieImage;
    
    if (!movieImage) {
        _imageView.image = [UIImage imageNamed:placeholderImage];
    }
    else {
        _imageView.image = movieImage;
    }
}

@end
