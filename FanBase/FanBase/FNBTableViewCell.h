//
//  FNBTableViewCell.h
//  FanBase
//
//  Created by Mariya Eggensperger on 4/6/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FNBIndexedCollectionView : UICollectionView

@property (nonatomic, strong) NSIndexPath *indexPath;

@end

static NSString *CollectionViewCellIdentifier = @"Cell";

@interface FNBTableViewCell : UITableViewCell

@property (nonatomic, strong) FNBIndexedCollectionView *collectionView;

- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath;

@end

