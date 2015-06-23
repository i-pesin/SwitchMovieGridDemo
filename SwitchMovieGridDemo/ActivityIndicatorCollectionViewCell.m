//
//  ActivityIndicatorCollectionViewCell.m
//  SwitchMovieGridDemo
//
//  Created by Igor Pesin on 6/21/15.
//  Copyright (c) 2015 Igor Pesin. All rights reserved.
//

#import "ActivityIndicatorCollectionViewCell.h"

@interface ActivityIndicatorCollectionViewCell()
@property(nonatomic, strong) UIActivityIndicatorView *activityView;
@end

@implementation ActivityIndicatorCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.activityView.center = self.contentView.center;
        [self.contentView addSubview:self.activityView];
        [self.activityView startAnimating];
    }
    
    return self;
}

- (void)onCellBecomeVisible:(BOOL)isVisible {
    if (isVisible) {
        [self.activityView startAnimating];
    }
    else {
        [self.activityView stopAnimating];
    }
}

@end
