//
//  UserDetailsViewController.m
//  FirebaseGettingUserInfo
//
//  Created by Andy Novak on 3/29/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//

#import "FNBUserDetailsViewController.h"
//#import <AFNetworking/AFNetworking.h>
//#import "FNBSpotifySearch.h"

@interface FNBUserDetailsViewController()
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *label3;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *addArtistButton;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;

@property (weak, nonatomic) IBOutlet UIButton *deleteArtistButton;
@property (weak, nonatomic) IBOutlet UITextField *addArtistField;

@end


@implementation FNBUserDetailsViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.label1.text = @"1";
    self.label2.text = @"2";
    self.label3.text = @"3";
    
    
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    // initialize user for this ViewController
    // If the user is a guest, it will have these properties
    self.currentUser = [[FNBUser alloc] init];
    
    
    // check if user is Guest or Authentic User
    [FNBFirebaseClient checkOnceIfUserIsAuthenticatedWithCompletionBlock:^(BOOL isAuthenticUser) {
        if (isAuthenticUser) {
            NSLog(@"you are an auth user");
            //Set the properties of this user
            [FNBFirebaseClient setPropertiesOfLoggedInUserToUser:self.currentUser withCompletionBlock:^(BOOL updateHappened) {
                if (updateHappened) {
                    self.label1.text = self.currentUser.email;
                    self.label2.text = self.currentUser.userID;
                    
                    // get all artists in the artistsDictionary
                    NSMutableString *allArtistsString = [NSMutableString new];
                    for (NSString *artist in [self.currentUser.artistsDictionary allKeys]) {
                        [allArtistsString appendString:artist];
                    }
                    self.label3.text = allArtistsString;
                }
            }];

        }
        else {
            NSLog(@"GUEST");
            self.titleLabel.text = @"YOU ARE A GUEST";
            self.addArtistButton.enabled = NO;
            self.deleteArtistButton.enabled = NO;
        }
    }];
    
    }

- (IBAction)logoutTapped:(id)sender {
    [FNBFirebaseClient logoutUser];
    [self performSegueWithIdentifier:@"LogoutSegue" sender:nil];
}



- (IBAction)addSpotifyArtistTapped:(id)sender {
    NSString *inputtedArtistName = self.addArtistField.text;
    
    [FNBSpotifySearch getArrayOfMatchingArtistsFromSearch:inputtedArtistName withCompletionBlock:^(BOOL gotMatchingArtists, NSArray *matchingArtistsArray) {
        if (gotMatchingArtists) {
            // make an alert
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select Artist" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            
            // if there are matching Artists
            if (matchingArtistsArray.count > 0) {
                // add every matched artist to alert
                for (NSDictionary *artist in matchingArtistsArray) {
                    UIAlertAction *artistButton = [UIAlertAction actionWithTitle:artist[@"name"] style:UIAlertActionStyleDefault
                                                                         handler:^(UIAlertAction * action) {
                                                                             [self addArtist:artist];
                                                                         }];
                    [alert addAction:artistButton];
                }
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive
                                                               handler:^(UIAlertAction * action) {}];
                [alert addAction:cancel];
            }
            // if matchingArtistsArray has no entries
            else {
                UIAlertAction *noMatchingArtistsButton = [UIAlertAction actionWithTitle:@"No Matching Artists Found" style:UIAlertActionStyleDestructive
                                                               handler:^(UIAlertAction * action) {}];
                [alert addAction:noMatchingArtistsButton];
            }
            
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        else {
            NSLog(@"got nothing");
            return;
        }
    }];
}

- (void) addArtist:(NSDictionary *)artist {
    NSLog(@"You selected %@", artist);
    [FNBFirebaseClient addCurrentUser:self.currentUser andArtistToEachOthersDatabases:artist];
}
//- (IBAction)getArrayOfArtistsTapped:(id)sender {
//    [FNBFirebaseClient getArrayOfAllArtistsInDatabaseWithCompletionBlock:^(BOOL completed, NSArray *artistsArray) {
//        if (completed) {
//            NSLog(@"in block. Here is the array: %@", artistsArray);
//        }
//    }];
//}

//- (IBAction)pressOnce:(id)sender {
//    NSArray *classical = @[ @"James Horner", @"Gyorgy Ligeti", @"James Rhodes ", @"George Frideric Handel ", @"Giuseppe Verde ", @"Claude Debussy ", @"Howard Shore", @"Johannes Brahms ", @"Aaron Copland ", @"Richard Wagner ", @"Ludwig van Beethoven ", @"Nico Muhly ", @"Hans Zimmer ", @"Charles Ives ", @"Sergei Prokofiev", @"Arvo Part", @"Wolfgan Amadeus Motzart ", @"John Adams", @"Steve Reich", @"Frederic Chopin ", @"Franz Joseph Haydn", @"Erik Satie ", @"Bela Bartok", @"Ennio Morricone ", @"Franz Schubert ", @"Max Richter ", @"Johann Sebastian Bach", @"John Williams ", @"Claudio Monteverdi ", @"Igor Stravinsky" ];
//    NSArray *jazz = @[@"Art Blakey", @"Chic Cores ", @"Diana Krall ", @"Herbie Hancock", @"Sonny Rollins ", @"Miles Davis ", @"Keith Jarret ", @"John Coltrane ", @"Ella Fitzgerald", @"Benny Goodman", @"Bill Evans ", @"Norah Jones ", @"Mary Lou Williams ", @"Art Tatum ", @"Thelonious Monk", @"Frank Sinatra", @"Duke Ellington", @"Charles Mingus ", @"Louis Armstrong", @"Sarah Vaughan", @"Coleman Hawkins ", @"Kurt Elling", @"Max Roach", @"Nat King Cole ", @"Count Basie", @"Dizzy GIllespie", @"Charlie Parker ", @"Dave Brubeck", @"Billie Hoiday ", @"Lester Young"];
//    NSArray *folk = @[ @"Hozier", @"Joni Mitchell ", @"Hurray For The Rif Raff ", @"Jason Isbell ", @"Chris Thile ", @"Woody Guthrie", @"Joan Baez ", @"Ryan Adams ", @"Rhiannon Giddens ", @"The Lumineers ", @"Bob Dylan", @"William Fitzsimmons", @"Jonah Tolchin", @"Ben Howard ", @"Townes Van Zandt ", @"Vance Joy", @"Aoife O'Donovan", @"Elizabeth Cotten", @"Kaleo ", @"Father John Misty", @"Fantastic Negrito", @"Carolina Chocolate Drops ", @"Mumford & Sons ", @"Of Monsters and Men", @"Iron & Wine", @"The Barr Brothers ", @"Robert Ellis ", @"Ray LaMontagne", @"Pete Seeger ", @"Vashti Bunyan", @"Emmylou Harris", @"Crooked Still", @"Nick Drake ", @"Marissa Nadler ", @"Shakey Graves ", @"Odetta" ];
//    NSArray *soul = @[ @"Sam Cooke", @"Jill Scott", @"Erykah Badu", @"Stevie Wonder", @"The Isley Brothers ", @"Issac Hayes ", @"Curtis Mayfield ", @"Donny Hathaway", @"The Temptations ", @"Smokey Robinson and the Miracles ", @"Aretha Frankline", @"Raphael Saadiq", @"Etta James ", @"Teddy Pendergrass ", @"Ben E. King", @"The Jackson 5", @"James Brown", @"Angie Stone ", @"Otis Reddng", @"Wilson Pickett", @"The Supremes ", @"Sharon Jones & The Dap Kings", @"Ray Charles ", @"Aloe Blacc ", @"Bobby Womack", @"Gladys Kinights and The Pips ", @"Marvin Gaye", @"Maxwell ", @"D'Angelo", @"Al Green "];
//    NSArray *freshFinds = @[@"Nude", @"The Last Artful, Dodgr", @"Roseau", @"Connie Constance ", @"Bonzai", @"Crater ", @"SiR", @"Forever ", @"Inner Oceans ", @"Childbirth", @"Murlo", @"Jay Prince"] ;
//    NSArray *latino = @[ @"Alejandro Fernandez ", @"Enrique Iglesias ", @"Danny Romero", @"Wisin & Yandel ", @"Carlos Vives ", @"Prince Royce ", @"Romeo Santos ", @"Ricardo Arjona ", @"Mana", @"Zoe", @"Ricky Martin", @"Jesse & Joy", @"Pitul", @"Juan Magan", @"Daddy Yankee", @"Calle 13", @"Antonio Carlos Jobim", @"David Bisbal", @"Marc Anthony", @"Don Omar", @"Alejandro Sanz", @"Thalia", @"Michel Telo", @"Shakira ", @"Juan Luis Guerra ", @"Juanes ", @"Pablo Alboran", @"Chayanne", @"Gloria Estefan "];
//    NSArray *rock = @[ @"Rage Against the Machine", @"Thirty Seconds to Mars ", @"Deftones ", @"Volbeat", @"My Chemical Romance ", @"Muse", @"System of a Down", @"Oasis", @"Marilyn Manson", @"Foo Fighters ", @"Nickelback", @"The Offspring", @"The Smashing Pumpkins", @"Incubus", @"Red Hot Chilli Peppers ", @"AC/DC ", @"Papa Roach", @"Pearl Jam ", @"Metallica", @"Guns N' Roses ", @"Nirvana", @"Linkin Park", @"Nine Inch Nails", @"Rise Against ", @"Queens of the Stone Age ", @"Green Day", @"Three Days Grace ", @"Fall Out Boy", @"blink-182 ", @"Kings of Leon" ];
//    NSArray *indie = @[@"Two Door Cinema Club", @"Arcade Fire", @"Bastille", @"Walk The Moon", @"Death Cab for Cutie", @"The National", @"The xx", @"R.E.M.", @"The Killers", @"The Black Keys", @"Passion Pit", @"Radiohead", @"The White Stripes", @"Florence", @"Vampire Weekend", @"alt J", @"The Shins", @"The Strokes", @"Modest Mouse", @"The Cure", @"Pixies", @"Imagine Dragons", @"Phoenix", @"Weezer", @"The Smiths", @"Bon Iver", @"The 1975", @"Beck", @"Arctic Monkeys", @"Foster the People"];
//    NSArray *rNb = @[ @"Justin Timberlake", @"Usher ", @"August Alsina", @"Whitney Houston", @"Destiny Child", @"Jason Derulo", @"John Legend ", @"Anita Baker ", @"TLC", @"Robin Thicke", @"SWV", @"Chris Brown", @"Ciara ", @"Janet Jackson", @"Bobby Brown", @"Jodeci", @"Boyz II Men", @"mEeli Sande ", @"Trey Songz ", @"Babyface ", @"Janelle Monae", @"aMxwell ", @"R Kelley ", @"Toni Braxton", @"Brandy", @"Mary J. Blige", @"Alicia Keys ", @"Blackstreet ", @"Beyonce ", @"NeYo", @"Michael Jackson" ];
//    NSArray *edm = @[ @"David Guetta", @"Sven Vath", @"Zedd ", @"Steve Aoki", @"Kaskade ", @"Calvin Harris ", @"Dada Life ", @"Martin Garrix ", @"Shrillex ", @"Disclosure ", @"Hardwell ", @"Above & Beyond ", @"Tiesto", @"Avicii", @"Armin van Buuren", @"Dillion Francis ", @"Don Diablo", @"Alesso", @"Carl Cox"];
//    NSArray *country = @[@"Reba McEntire", @"Patsy Cline", @"Luke Bryan", @"Shania Twain", @"Lady Antebellum", @"Carrie Underwood", @"Dolly Parton", @"Lefty Frizzel ", @"Adam Sanders ", @"Waylon Jennings", @"Johnny Cash", @"Randy Travis ", @"Toby Keith", @"Brooks & Dunn", @"Brad Paisley", @"Tammy Wynette ", @"George Strait", @"Tim McGraw", @"Cole Swindell", @"Miranda Lambert", @"Kenny Chesney", @"Keith Urban", @"Bill Monroe", @"Loretta Lynn", @"Willie Nelson", @"George Jones ", @"Thomas Rhett", @"Vince Gill", @"Blake Shelton", @"Alan Jackson", @"Hank Williams ", @"Merle Haggard "];
//    NSArray *hipHop = @[@"Dr. Dre", @"Big Sean", @"MC Lyte ", @"Rick Ross ", @"Cypress Hill", @"Big Daddy Kane", @"Future ", @"Eminem", @"A$AP Rocky", @"Kanye West ", @"Kendrick Lemar", @"Lil Wayne", @"EPMD ", @"T.I.", @"Nas", @"A Tribe Called Quest ", @"JAY Z ", @"Snoop Dogg", @"Wu-Tang Clan", @"N.W.A. ", @"WIz Khalifa ", @"De Le Soul", @"LL Cool J", @"KRS-One", @"Run D.M.C.", @"Busta Rhymes ", @"Gang Starr ", @"2Pac ", @"Drake", @"Missy Elliot ", @"The Notorious B.I.G."];
//    NSArray *pop = @[@"Calvin Harris", @"Pink", @"Christina Agullera", @"Nicki Minaj", @"OneRepublic", @"Katy Perry ", @"Usher", @"One Direction ", @"Madonna", @"Pharrell Williams ", @"Lorde ", @"Justin Bieber ", @"Miley Cyrus ", @"Pitbull ", @"Ed Sheeran", @"Ariana Grande", @"Rihanna ", @"Sia", @"Jason Derulo ", @"Iggy Azalea", @"Jessie J", @"Maroon 5 ", @"Ellie Goulding", @"Justin Timberlake", @"Demi Lavato ", @"Bruno Mars", @"Beyonce ", @"Lady Gaga ", @"Britney Spears ", @"Sam Smith" ];
//    
//    //sheet 2 of google sheet document
//    NSArray *comedy = @[@"Patton Oswalt", @"Nick Swardson", @"Bill Hicks", @"Daniel Tosh", @"Joe Rogan", @"Chris Rock", @"Richard Pryor ", @"Jim Gaffigan", @"Lewis Black ", @"Jon Lajoie", @"Bo Burnham", @"Weird Al Yankovic", @"Steve Martin", @"The Lonely Island ", @"Louis C.K.", @"MItch Hedberg", @"Bill Burr ", @"Mike Birbiglia", @"Aziz Ansari", @"John Mulaney", @"Kevin Hart", @"Whitney Cummings ", @"Margaret Cho", @"Tenacious D", @"Dane Cook", @"Robin Williams", @"Amy Schumer ", @"Maria Bamford ", @"Marc Maron", @"Flight of the Conchords" ];
//    NSArray *metal = @[ @"At The Gates ", @"Mayhem", @"In Flames ", @"System of a Down", @"Magadeth", @"Kom", @"Sepultura", @"Slipknot", @"Rammstein", @"Iron Maiden", @"Morbid Angel", @"Metallica", @"Gojira", @"FIve Finger Death Punch", @"Mastodon", @"Helloween", @"Dream Theatre", @"Meshuggah", @"Motorhead ", @"Judas Priest ", @"Blind Gaurdian", @"Killswithch Engage ", @"Opeth", @"Hammerfall", @"Dimmu Borgir", @"Cradle of Filth", @"Nightwish", @"Slayer", @"Anthrax ", @"Black Sabbath" ];
//    NSArray *kPop = @[ @"TAEMIN", @"4Minute", @"BIGBANG", @"EXO", @"Girls' Generation", @"2NE1", @"Beast", @"SHINee", @"AKDONG MUSICIAN (AKMU)", @"Epik High", @"miss A", @"Hyuna", @"Ailee ", @"Super Junior ", @"Apink", @"IU", @"AOA", @"Tablo", @"BTOB", @"T-ara", @"Se7en", @"PSY", @"Trouble Maker", @"B1A4", @"Girls' Generation-TTS", @"Sangha Jung", @"KARA ", @"Primary", @"2PM", @"INFINITE-H"];
//    NSArray *reggae = @[@"Lee Scratch Perry ", @"Pepper", @"Steel Pulse", @"Gyptian", @"Jimmy Cliff ", @"Eek-A-Mouse", @"Culture", @"Busy Signal ", @"Inner Cirlce ", @"The Wailers ", @"Junior Murvin", @"Bob Marley & The Wailers ", @"Damien Marley", @"Tribal Seeds ", @"Rebelution", @"SOJA", @"Burning Spear", @"Collie Buddz ", @"Black Uhuru", @"Toots & The Maytals  ", @"Shaggy ", @"Wailing Soul", @"Anthony B", @"U-Roy", @"Ziggy Marley ", @"Sizzla ", @"UB40", @"Peter Tosh", @"Alborosie", @"Yellowman"];
//    NSArray *punk = @[@"Sleater-Kinney", @"The Bronx", @"Bad Religion", @"Gallows ", @"Against Me!", @"Sex Pistols ", @"Fucked Up", @"Black Flag", @"Streetlight Manifesto", @"Off With Their Heads ", @"Hot Water Music", @"Green Day", @"Converge", @"Rise Against", @"The Menzingers ", @"No Age ", @"NOFX ", @"Patti Smith", @"Sun 41 ", @"Gogol Bordello ", @"L7 ", @"Anti-Flag", @"The Distillers", @"The Clash", @"Alkaline Trio", @"Ramones ", @"Raised Fist ", @"Rancid ", @"Bad Brains", @"Strung Out "];
//    NSArray *funk = @[ @"The Bar-Kays", @"Zapp", @"Kool & The Gang", @"Prince ", @"Average White Band ", @"The Isley Brothers ", @"Bootsy Collins ", @"Cameo", @"Stevie Wonder ", @"War", @"Charles Wright & The Watts 103rd Street Rhythm Band", @"The Brand New Heavies ", @"Funkadelic ", @"Dyke and The Blazers ", @"Ohio Players ", @"The Meters ", @"Rick James ", @"CHIC", @"Commondores ", @"Mother's Finest", @"Jamiroquai", @"Rufus", @"Earth,Wind & Fire", @"Sly & The Family Stone ", @"Parliament", @"Curtis Mayfiled ", @"Con Funk Shun ", @"Tower of Power ", @"James Brown", @"The Gap Band ", @"Dazz Band " ];
//    NSArray *blues = @[ @"Mississippi John Hurt", @"Albert King ", @"Robert Johnson", @"Eric Clapton", @"Howlin' Wolf", @"Muddy Waters ", @"John Lee Hooker ", @"Sonny Boy Williamson II ", @"John Mayall ", @"Jimmy Reed ", @"Lead Belly ", @"B.B. King", @"The Derek Trucks Band ", @"Keb' Mo'", @"Robert Cray", @"Lightnin' Hopkins", @"Son House ", @"Elmore James ", @"Peter Green ", @"Bo Diddley", @"Freddie King ", @"Stevie Ray Vaughan", @"The Allman Brothers Band ", @"Skip James ", @"Joe Bonamassa", @"Blind Willie Johnson", @"Bessie Smith", @"Kenny Wayne Shepherd ", @"T-Bone Walker ", @"Buddy Guy"];
//    
//    
//    NSArray *arrayOfGenres = @[funk, blues];
//    for (NSArray *artistsArray in arrayOfGenres) {
//        [FNBFirebaseClient fillDatabaseWithArrayOfArtists:artistsArray];
//    }
////    [FNBFirebaseClient fillDatabaseWithArrayOfArtists:hipHop];
//}

@end
