//
//  ViewController.m
//  SwitchMovieGridDemo
//
//  Created by Igor Pesin on 6/20/15.
//  Copyright (c) 2015 Igor Pesin. All rights reserved.
//

#import "MovieGridViewController.h"
#import "MovieCollectionViewCell.h"
#import "ActivityIndicatorCollectionViewCell.h"
#import "EmptyCell.h"
#import "MovieImagesSource.h"
#import "MovieCollectionViewFlowLayout.h"

static NSUInteger const kActivityCellHeigth = 50;

@interface MovieGridViewController ()

@end

@implementation MovieGridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerClass:[MovieCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([MovieCollectionViewCell class])];
    [self.collectionView registerClass:[ActivityIndicatorCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([ActivityIndicatorCollectionViewCell class])];
    [self.collectionView registerClass:[EmptyCell class] forCellWithReuseIdentifier:NSStringFromClass([EmptyCell class])];
    self.collectionView.dataSource = self;
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    self.navigationItem.title = @"MOVIES";
    self.navigationController.navigationBar.barTintColor = [UIColor blueColor];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    BOOL isIphone6Plus = CGRectGetHeight([UIScreen mainScreen].bounds) > 667.0f;
    [MovieImagesSource sharedImageSource].batchSize = isIphone6Plus ? 28 : 15;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNewImagesReadyToDownload) name:kNewBatchOfImagesReadyToDownload object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self numberOfItemsInCollectionView];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell;
    
    if (indexPath.item < [MovieImagesSource sharedImageSource].imagesCount) {
        cell = (MovieCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([MovieCollectionViewCell class]) forIndexPath:indexPath];
        
        UIImage *movieImage = [[MovieImagesSource sharedImageSource] imageAtIndex:indexPath.item];
        [(MovieCollectionViewCell *)cell setMovieImage:movieImage];
        
        if (!movieImage) {
            [self downloadImageAtIndexPath:indexPath];
        }
    }
    else if ([self shouldShowActivityViewCellAtIndexPath:indexPath]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ActivityIndicatorCollectionViewCell class]) forIndexPath:indexPath];
    }
    else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([EmptyCell class]) forIndexPath:indexPath];
    }
    
    return cell;
}

#pragma mark - helper methods

- (NSUInteger)numberOfItemsInCollectionView {
    NSUInteger aditionalItemsCount = 0;
    
    //if the last row isn't filled, fill the gap with the empty cells to keep items layout
    NSUInteger itemsPerRow = [(MovieCollectionViewFlowLayout *)self.collectionViewLayout numberOfImagesPerRow];
    NSUInteger numberOfItemsInLastRow = [MovieImagesSource sharedImageSource].imagesCount % itemsPerRow;
    if (numberOfItemsInLastRow) {
        aditionalItemsCount = itemsPerRow - numberOfItemsInLastRow;
    }
    
    return [MovieImagesSource sharedImageSource].imagesCount + aditionalItemsCount + [MovieImagesSource sharedImageSource].hasMoreImagesToDownload;
}

- (BOOL)shouldShowActivityViewCellAtIndexPath:(NSIndexPath *)indexPath {
    return [MovieImagesSource sharedImageSource].hasMoreImagesToDownload && indexPath.item == [self numberOfItemsInCollectionView] - 1;
}

- (void)downloadImageAtIndexPath:(NSIndexPath *)indexPath {
    [[MovieImagesSource sharedImageSource] downloadImageAtIndex:indexPath.item completion:^(UIImage *image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            MovieCollectionViewCell *cell = (MovieCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            cell.movieImage = image;
        });
    }];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    NSUInteger itemSpacing = collectionViewLayout.minimumInteritemSpacing;
    return UIEdgeInsetsMake(itemSpacing, itemSpacing, itemSpacing, itemSpacing);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize itemSize = collectionViewLayout.itemSize;
    if ([self shouldShowActivityViewCellAtIndexPath:indexPath]) {
        itemSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 2 * collectionViewLayout.minimumInteritemSpacing, kActivityCellHeigth);
    }

    return itemSize;
}

#pragma mark - observer

- (void)onNewImagesReadyToDownload {
    if([[MovieImagesSource sharedImageSource] requestToDownloadNewBatchOfImages]) {
        [self.collectionView reloadData];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //check if collection view was scrolled to bottom
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (fabs(bottomEdge - scrollView.contentSize.height) < kActivityCellHeigth / 2) {
        [self onNewImagesReadyToDownload];
    }
}

@end
