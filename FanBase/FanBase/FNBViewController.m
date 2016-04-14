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
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFImageDownloader.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "FNBFirebaseClient.h"
#import <Firebase.h>
// this is to segue to artistMainPage
#import "FNBArtistMainPageTableViewController.h"

@interface FNBViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic,strong) NSArray *imageArray; //-->currently colors

@property (nonatomic, strong) NSArray *genres;
@property (nonatomic, strong) NSArray *genresForComparison;
@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary;
@property (nonatomic) NSInteger section;

@property (nonatomic, strong) AFImageDownloader *imageDownloader;

@property (strong, nonatomic) NSString *selectedArtist;

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
    
    self.imageDownloader = [AFImageDownloader defaultInstance];
    
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
    self.selectedArtist = @"";
    
    UISearchController *searchController =[[UISearchController alloc]initWithSearchResultsController:nil];
    searchController.dimsBackgroundDuringPresentation = NO;
    //searchController.searchResultsUpdater = self;
    //searchController.delegate = self;
    searchController.searchBar.frame = CGRectMake(0, 0, 320, 44);
    self.tableView.tableHeaderView = searchController.searchBar;
    
    //Dismiss keyboard 
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    

    
}
-(BOOL)array:(NSArray *)array caseInsensitiveContainsString:(NSString *)string
{
    for(NSString *arrayString in array) {
        if([arrayString localizedCaseInsensitiveContainsString:string]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.content = [NSMutableDictionary new];
    
    self.genres = @[@"Pop", @"Hip Hop", @"Country", @"EDM/Dance", @"Rock", @"Latino", @"Soul", @"Folk & American", @"Jazz", @"Classical", @"Comedy", @"Metal", @"K-Pop", @"Reggae", @"Punk", @"Funk", @"Blues"];
    [self.genres sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    
    //Calls on data in firebase
    Firebase *ref = [[Firebase alloc] initWithUrl:@"https://fanbaseflatiron.firebaseio.com/artists"];
    
    //NSLog(@"%llu", dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)));
    
    // Block reads artist data in firebase
    [ref observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        
        NSLog(@"start");
        
        // seems like repeated access of snapshot.value is painfully slow.
        // so... we're going to stash it in a variable and use that instead.
        NSDictionary *snapshotValue = snapshot.value;
        
            //Compiles a dictionary in specific format
            for (NSString *artistName in snapshotValue) {
                
                NSDictionary *artistInfo = snapshotValue[artistName];
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
                
//                NSLog(@"\n\nartistName: %@\nimageURL: %@\nartistGenre: %@\n\n",artistName,imageURL, artistGenre);
                
                if (artistGenre != nil) {
                    if ([self.content objectForKey:artistGenre]) {
                        
                        NSMutableArray *contentObjects = self.content[artistGenre];
                        NSMutableArray *artistNames = contentObjects[0];
                        NSMutableDictionary *artistNameAndImageURL = contentObjects[1];
                        
                        [artistNameAndImageURL setValue:imageURL forKey:artistName];
                        [artistNames addObject:artistName];
//                        NSLog(@"\n\nself.content artistName: %@\n\n",artistName);
                        
                    } else {
                        
                        NSMutableArray *contentObjects = [NSMutableArray new];
                        NSMutableArray *artistNames = [NSMutableArray new];
                        NSMutableDictionary *artistNameAndImageURL = [NSMutableDictionary new];
                        
                        [artistNameAndImageURL setValue:imageURL forKey:artistName];
                        [artistNames addObject:artistName];
//                        NSLog(@"\n\nFIRST TIME\nself.content artistName: %@\n\n",artistName);
                        
                        [contentObjects addObject:artistNames];
                        [contentObjects addObject:artistNameAndImageURL];
                        
                        [self.content setObject:contentObjects forKey:artistGenre];
                        
                        }
                    }
                
            }
        
        NSLog(@"end");
        
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
    [cell.collectionView setContentOffset:CGPointMake(horizontalOffset, 0) animated:NO];
    
    [cell.collectionView registerClass:[FNBCollectionViewCell class] forCellWithReuseIdentifier:CollectionViewCellIdentifier];

    
}

#pragma mark - UITableViewDelegate Methods

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *tappedTableViewCell = (UITableViewCell *)collectionView.superview.superview;
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForCell:tappedTableViewCell];

    NSInteger tableViewSection = selectedIndexPath.section;
    NSString *genre = self.genres[tableViewSection];
    NSArray *artistContent = self.content[genre];
    NSArray *artistNames = artistContent[0];
    NSString *artistName = artistNames[indexPath.item];
    NSLog(@"this is the section %li ", selectedIndexPath.section);
    NSLog(@"you selected: %@", artistName);
    self.selectedArtist = artistName;
    [self performSegueWithIdentifier:@"discoverPageSegue" sender:self];
}

//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    NSLog(@"HIII");
//    NSLog(@"you selected this section %li and this row %li", indexPath.section, indexPath.row);
//}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 200;
}




#pragma mark - UICollectionViewDataSource Methods

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
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
    NSString *artistName = artistNames[indexPath.item];
    cell.artist = artistName;
    
    NSDictionary *artistImages = artistContent[1];
    NSString *artistImageURL = artistImages[artistName];
//    NSLog(@"this is the artist URL: %@", artistImageURL);
    
    cell.image = nil;
    
    
    //Set Image for URL
//    cell.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:artistImageURL]]];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:artistImageURL]];
    [self.imageDownloader downloadImageForURLRequest:urlRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *responseObject) {
        // need to double-check that this cell is still supposed to be showing the image for the artist we just received.
        // if cells are reused, this check will fail.
        if([cell.artist isEqualToString:artistName]) {
            cell.image = responseObject;
        }
    } failure:nil];
    
    cell.clipsToBounds = YES;
    
    
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

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    UINavigationController *nextNavController = [segue destinationViewController];
//    FNBArtistMainPageTableViewController *nextVC = [nextNavController viewControllers][0];
//    nextVC.receivedArtistName = self.selectedArtist;
    FNBArtistMainPageTableViewController *nextVC = segue.destinationViewController;
    nextVC.receivedArtistName = self.selectedArtist;
}

@end
