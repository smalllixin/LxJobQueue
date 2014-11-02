//
//  HeartExampleViewController.m
//  iOSPriorityJobQueue
//
//  Created by lixin on 11/2/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#import "HeartExampleViewController.h"
#import <CoreData+MagicalRecord.h>
#import "LxJobManager.h"
#import "HeartJob.h"
#import "Story.h"
#import "ExampleDataManager.h"

@interface HeartExampleViewController ()
@property (weak, nonatomic) IBOutlet UIButton *heartButton;
@property (weak, nonatomic) IBOutlet UILabel *heartCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *storyTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *sidLabel;
@property (nonatomic, strong) Story *story;
@end

@implementation HeartExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _story = [Story MR_findFirstByAttribute:@"sid" withValue:@"s001"];
    [self bindUI];
}

- (void)bindUI {
    _heartCountLabel.text = [_story.heartCount stringValue];
    _storyTitleLabel.text = _story.title;
    _sidLabel.text = _story.sid;
    if ([_story.meHearted boolValue]) {
        _heartButton.selected = NO;
    } else {
        _heartButton.selected = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnPressed:(id)sender {
    //JobQueue Show Time
    BOOL currentHearted = [_story.meHearted boolValue];
    HeartJob *job = [[HeartJob alloc] initWithAction:currentHearted?kHeartActionUnHeart:kHeartActionHeart storyId:_story.sid];
    [[LxJobManager sharedManager] addQueueJob:job toGroup:@"heart"];
    if (currentHearted) {
        [[ExampleDataManager sharedManager] unheartStory:_story];
    } else {
        [[ExampleDataManager sharedManager] heartStory:_story];
    }
    
    [self bindUI];//Now we can refresh UI immediately.
}

@end
