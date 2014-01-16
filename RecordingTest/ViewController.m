//
//  ViewController.m
//  RecordingTest
//
//  Created by SDT-1 on 2014. 1. 16..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController () <UITableViewDelegate, UITableViewDataSource, AVAudioRecorderDelegate>
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UILabel *status;

@end

@implementation ViewController {
    AVAudioRecorder *recorder;
    NSMutableArray *recordingFiles;
}

//도큐먼트 폴더의 파일의 경로
- (NSString *)getPullPath:(NSString *)fileName {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [documentPath stringByAppendingPathComponent:fileName];
}

//녹음 시작
- (void)startRecording {
    NSDate *date = [NSDate date];
    NSString *filePath = [self getPullPath:[NSString stringWithFormat:@"%@.caf", [date description]]];
    
    NSLog(@"recording path: %@", filePath);
    
    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    [setting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [setting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    
    __autoreleasing NSError *error;
    recorder = [[AVAudioRecorder alloc] initWithURL:url settings:setting error:&error];
    recorder.delegate = self;
    if ([recorder prepareToRecord]) {
        self.status.text = [NSString stringWithFormat:@"Recording : %@",[[url path] lastPathComponent]];
        //10초간 녹음
        [recorder recordForDuration:10];
    }
}

//녹음된 파일 목록을 테이블에
- (void)updateRecordedFiles {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    __autoreleasing NSError *error = nil;
    
    recordingFiles = [[NSMutableArray alloc] initWithArray:[fm contentsOfDirectoryAtPath:documentPath error:&error]];
    [self.table reloadData];
}

//녹음 중지
- (void)stopRecording {
    [recorder stop];
    [self updateRecordedFiles];
}

- (IBAction)toggleRecording:(id)sender {
    if ([recorder isRecording]) {
        [self stopRecording];
        ((UIBarButtonItem *) sender).title = @"Record";
    }else {
        [self startRecording];
        ((UIBarButtonItem *)sender).title = @"Stop";
    }
}

//AVAudioRecorder Delegate 메소드 - 녹음이 끝나면
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    self.status.text = @"녹음 완료";
    [self updateRecordedFiles];
}
// 녹음 중 오류나면
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    self.status.text = [NSString stringWithFormat:@"녹음 중 오류 : %@", [error description]];
}

#pragma mark Table
#define CELL_ID @"CELL_ID"

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [recordingFiles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID forIndexPath:indexPath];
    cell.textLabel.text = [recordingFiles objectAtIndex:indexPath.row];
    
    return cell;
}

//녹음된 파일 삭제
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *fileName = [recordingFiles objectAtIndex:indexPath.row];
    NSString *fullPath = [self getPullPath:fileName];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    __autoreleasing NSError *error = nil;
    BOOL ret = [fm removeItemAtPath:fullPath error:&error];
    //TODO 에러체크
    if (NO == ret) {
        NSLog(@"error : %@", [error localizedDescription]);
    }
    
    [recordingFiles removeObjectAtIndex:indexPath.row];
    [self.table deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]  withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
