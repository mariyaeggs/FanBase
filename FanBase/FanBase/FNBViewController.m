//
//  FNBViewController.m
//  FanBase
//
//  Created by Mariya Eggensperger on 4/6/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import "FNBViewController.h"
#import "FNBCollectionViewCell.h"
#import "FNBTableViewCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "FNBFirebaseClient.h"
#import <Firebase/Firebase.h>

@interface FNBViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic,strong) NSArray *imageArray; //-->currently colors
@property (nonatomic, strong) NSArray *genres;
@property (nonatomic, strong) NSArray *genresForComparison;
@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary;
@property (nonatomic) NSInteger section;

//Dictionary is in the format:
//NSDictionary *sampleDictionary = @{
//                                       @"Genre" : @[@{@"Artist":@"ArtistImageURL"}]
//                                       };
@property (nonatomic, strong) NSMutableDictionary *content;


@end

@implementation FNBViewController

-(void)loadView
{
    [super loadView];
    self.section = -1;
    const NSInteger numberOfTableViewRows = 1;
    const NSInteger numberOfCollectionViewCells = 20;
    
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:numberOfTableViewRows];
    
    for (NSInteger tableViewRow = 0; tableViewRow < numberOfTableViewRows; tableViewRow++)
    {
        NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:numberOfCollectionViewCells];
        
        for (NSInteger collectionViewItem = 0; collectionViewItem < numberOfCollectionViewCells; collectionViewItem++)
        {
            //don't need this yet
        }
        
        [mutableArray addObject:imageArray];
    }
    
    self.imageArray = [NSArray arrayWithArray:mutableArray];
    
    self.contentOffsetDictionary = [NSMutableDictionary dictionary];

    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    self.content = [NSMutableDictionary new];
    
    self.genres = @[@"Pop", @"Hip Hop", @"Country", @"EDM/Dance", @"Indie", @"Rock", @"Latino", @"Soul", @"Folk & American", @"Jazz", @"Classical", @"Comedy", @"Metal", @"K-Pop", @"Reggae", @"Punk", @"Funk", @"Blues"];
    [self.genres sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

    
    //Calls on data in firebase
    Firebase *ref = [[Firebase alloc] initWithUrl:@"https://fanbaseflatiron.firebaseio.com/artists"];
   
    NSLog(@"%llu", dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)));

    // Block reads artist data in firebase
    [ref observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        
        //Compiles a dictionary in specific format
        for (NSString *artistName in snapshot.value) {
            
            NSDictionary *artistInfo = snapshot.value[artistName];
            NSArray *images = artistInfo[@"images"];
            NSDictionary *firstImage = images.firstObject;
            NSString *imageURL = firstImage[@"url"];
            
            NSArray *genres = artistInfo[@"genres"];
            
            NSString *artistGenre;
            for (NSString *genre in genres) {
                NSPredicate *genrePredicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[c] %@", genre];
                NSArray *filteredGenres = [self.genres filteredArrayUsingPredicate:genrePredicate];
                if (filteredGenres.count > 0) {
                    artistGenre = filteredGenres[0];
                    break;
                }
            }
            
            NSLog(@"\n\nartistName: %@\nimageURL: %@\nartistGenre: %@\n\n",artistName,imageURL, artistGenre);
            
            if (artistGenre != nil) {
                if ([self.content objectForKey:artistGenre]) {
                    
                    NSMutableArray *contentObjects = self.content[artistGenre];
                    NSMutableArray *artistNames = contentObjects[0];
                    NSMutableDictionary *artistNameAndImageURL = contentObjects[1];
                    
                    [artistNameAndImageURL setValue:imageURL forKey:artistName];
                    [artistNames addObject:artistName];
                    NSLog(@"\n\nself.content artistName: %@\n\n",artistName);
                    
                } else {
                    
                    NSMutableArray *contentObjects = [NSMutableArray new];
                    NSMutableArray *artistNames = [NSMutableArray new];
                    NSMutableDictionary *artistNameAndImageURL = [NSMutableDictionary new];
                    
                    [artistNameAndImageURL setValue:imageURL forKey:artistName];
                    [artistNames addObject:artistName];
                    NSLog(@"\n\nFIRST TIME\nself.content artistName: %@\n\n",artistName);
                    
                    [contentObjects addObject:artistNames];
                    [contentObjects addObject:artistNameAndImageURL];
                    
                    [self.content setObject:contentObjects forKey:artistGenre];
                
                }
            }
            
            
         
        }

        NSLog(@"about to reloadtdata");
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.tableView reloadData];
            NSLog(@"%llu", dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)));
        }];
            
    } withCancelBlock:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
}
-(BOOL)prefersStatusBarHidden {
    
    return YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Count all keys (genres) in content dictionary
    // to establish number of sections needed in tableview
    return self.genres.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.genres.count > 0) {
        return self.genres[section];
    }

    return @"";
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"\n\n\nTableView cell: %li\n\n\n",indexPath.row);
    static NSString *CellIdentifier = @"CellIdentifier";
    
    FNBTableViewCell *cell = (FNBTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
//    NSString *genre = self.genres[indexPath.row];
//    NSDictionary *artists = [self.content objectForKey:genre];
//    NSArray *artistsArray = [artists allKeys];
//    [artistsArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
//    NSLog(@"\n\nartistsArray: %@\n\n", artistsArray);
//    cell.artists = artistsArray;
    
    if (!cell)
    {
        cell = [[FNBTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(FNBTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setCollectionViewDataSourceDelegate:self indexPath:indexPath];
    NSInteger index = cell.collectionView.tag;
    
    CGFloat horizontalOffset = [self.contentOffsetDictionary[[@(index) stringValue]] floatValue];
    [cell.collectionView setContentOffset:CGPointMake(horizontalOffset, 0)];
    
    [cell.collectionView registerClass:[FNBCollectionViewCell class] forCellWithReuseIdentifier:CollectionViewCellIdentifier];
    
}

#pragma mark - UITableViewDelegate Methods

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 200;
}

#pragma mark - UICollectionViewDataSource Methods

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
//    self.section++;
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSLog(@"\n\n\nCollectionView section: %li\n\n\n",section);
    UIView *view = [collectionView superview];
    FNBTableViewCell *cell = (FNBTableViewCell *)[view superview];
    NSIndexPath *ip = [self.tableView indexPathForCell:cell];
    NSInteger tableViewSection = ip.section;
    NSString *genre = self.genres[tableViewSection];
    NSArray *artistContent = self.content[genre];
    NSArray *artistNames = artistContent[0];
    
    return artistNames.count;
    
//
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    FNBCollectionViewCell *cell = (FNBCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];

    UIView *view = [collectionView superview];
    FNBTableViewCell *tableViewCell = (FNBTableViewCell *)[view superview];
    NSIndexPath *ip = [self.tableView indexPathForCell:tableViewCell];
    NSInteger tableViewSection = ip.section;
    NSString *genre = self.genres[tableViewSection];
    NSArray *artistContent = self.content[genre];
    NSArray *artistNames = artistContent[0];
    cell.artist = artistNames[indexPath.item];
    
    return cell;
}

#pragma mark - UIScrollViewDelegate Methods

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (![scrollView isKindOfClass:[UICollectionView class]]) return;
    
    CGFloat horizontalOffset = scrollView.contentOffset.x;
    
    UICollectionView *collectionView = (UICollectionView *)scrollView;
    NSInteger index = collectionView.tag;
    self.contentOffsetDictionary[[@(index) stringValue]] = @(horizontalOffset);
}

//Filters array by genre(s)
- (NSArray *)filterArtistsArray:(NSDictionary *)artistDictionary ByGenre:(NSString *)genreInput {
    NSMutableArray *genreArray = [NSMutableArray new];
    for (NSString *artistName in artistDictionary) {
        NSDictionary *artistValues = [artistDictionary objectForKey:artistName];
        for (NSString *genre in artistValues[@"genres"]) {
            if ([genre containsString:genreInput]) {
                [genreArray addObject:artistValues];

                NSLog(@"%@", artistName);
                break;
            }
        }
    }
    return genreArray;
}

@end
