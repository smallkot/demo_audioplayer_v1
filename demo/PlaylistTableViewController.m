//
//  PlaylistTableViewController.m
//  demo_music
//
//  Created by Smallkot on 18.06.15.
//  Copyright (c) 2015 smallkot. All rights reserved.
//

#import "PlaylistTableViewController.h"
#import "TrackCell.h"

@interface PlaylistTableViewController ()
    @property long count_tracks;
    @property (strong, nonatomic) NSArray *wordsOfInput;
    @property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@end

@implementation PlaylistTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *pathToFile = [[NSBundle mainBundle] pathForResource:@"playlist" ofType:@"txt"];
    NSString *sourceOfInput = [NSString stringWithContentsOfFile:pathToFile encoding:NSUTF8StringEncoding error:nil];
    _wordsOfInput = [sourceOfInput componentsSeparatedByString: @"\n" ];
    _count_tracks = _wordsOfInput.count;
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *createMusic = [NSHomeDirectory() stringByAppendingString:@"/Music"];
    [fm createDirectoryAtPath:createMusic withIntermediateDirectories:YES attributes:nil error:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _count_tracks;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TrackCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TrackCell"];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSURL*url = [NSURL URLWithString:_wordsOfInput[indexPath.row]];
    NSString *fileName = url.pathComponents[url.pathComponents.count-1];
    NSString *path = [NSHomeDirectory() stringByAppendingString:@"/Music"];
    NSString *music_path = [path stringByAppendingPathComponent:fileName];
    
    [cell.LoadingIndicator startAnimating];
    
    if([fm fileExistsAtPath:music_path] == NO)
    {
        cell.TrackLabel.text = @"Loading";
        cell.LoadingIndicator.hidden = NO;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData* data = [[NSData alloc] initWithContentsOfURL:url];
            [data writeToFile:music_path atomically:YES];
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [cell.LoadingIndicator stopAnimating];
                cell.TrackLabel.text = fileName;
                cell.LoadingIndicator.hidden = YES;
            });
        });
    }
    else
    {
        [cell.LoadingIndicator stopAnimating];
        cell.LoadingIndicator.hidden = YES;
        cell.TrackLabel.text = fileName;
    }
    
    return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    TrackCell *cell = (TrackCell*)[tableView cellForRowAtIndexPath:indexPath];
    NSString *fileSoundName = [[cell TrackLabel] text];

    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[self urlSoundFromDirectory:@"/Music" fileSound:fileSoundName] error:nil];
    [self.audioPlayer play];
}

- (NSURL*) urlSoundFromDirectory:(NSString*)directory fileSound:(NSString*) fileSound
{
    NSString *path = [NSHomeDirectory() stringByAppendingString:directory];
    NSString *music_path = [path stringByAppendingPathComponent:fileSound];
    NSURL *url = [NSURL fileURLWithPath:music_path];
    return url;
}

@end
