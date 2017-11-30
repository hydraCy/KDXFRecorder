//
//  ClockInViewController.m
//  ReadDemo
//
//  Created by 蔡宇 on 2017/11/21.
//  Copyright © 2017年 蔡宇. All rights reserved.
//

#import "ClockInViewController.h"
#import <iflyMSC/iflyMSC.h>
#import "BlackCue.h"
#import "XHVoiceRecordHUD.h"
#import "ISRDataHelper.h"
#import "Record.h"
#import <AudioToolbox/AudioSession.h>
#import "PcmPlayer.h"
#import "lame.h"
#import "AudioComposition.h"

@interface ClockInViewController ()<IFlySpeechRecognizerDelegate,UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,AVAudioPlayerDelegate,UIGestureRecognizerDelegate>

@property(nonatomic,strong)UITextView *contantTextView;
@property(nonatomic,strong)UILabel *remarkLabel;
@property(nonatomic,strong)UILabel *numberLabel;
@property (nonatomic, strong) IFlySpeechRecognizer *iFlySpeechRecognizer;
@property(nonatomic,strong) UIButton *recordButton;
@property(nonatomic,strong) UIButton *saveButton;
@property (nonatomic, strong) NSMutableString *curResult;//the results of current session
@property (nonatomic, strong, readwrite) XHVoiceRecordHUD *voiceRecordHUD;
@property (nonatomic, strong) PcmPlayer *audioPlayer;


@property(nonatomic,strong)NSMutableArray *voiceUrlArr;
@property(nonatomic,strong)NSString *tempVoiceUrl; //pcm临时路径
@property(nonatomic,strong)NSString *tempMp3Url; //mp3临时路径

@property(nonatomic,strong)UIView *recordView;
@property(nonatomic,strong)UIButton *playBtn;
@property(nonatomic,strong)UILabel *recordSecondLabel;
@property(nonatomic,strong)UILabel *recordRemarkLabel;

@property(nonatomic,strong) AVAudioPlayer *avPlayer;


@end

@implementation ClockInViewController

-(NSMutableArray *)voiceUrlArr{
    if (!_voiceUrlArr) {
        _voiceUrlArr = [[NSMutableArray alloc]init];
    }
    return _voiceUrlArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"打卡笔记";
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    [self getRecordId];
    
    self.curResult = [[NSMutableString alloc]init];
    [self creatUI];
    
    //创建语音识别对象
    _iFlySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
    //设置识别参数
    //设置为听写模式
    [_iFlySpeechRecognizer setParameter: @"iat" forKey: [IFlySpeechConstant IFLY_DOMAIN]];
    //asr_audio_path 是录音文件名，设置value为nil或者为空取消保存，默认保存目录在Library/cache下。
    _iFlySpeechRecognizer.delegate = self;
    [_iFlySpeechRecognizer setParameter:@"iat.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
    [_iFlySpeechRecognizer setParameter:@"16000" forKey:[IFlySpeechConstant SAMPLE_RATE]];
    [_iFlySpeechRecognizer setParameter:@"1" forKey:[IFlySpeechConstant ASR_PTT]];
    //Set result type
    [_iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
    
}

-(void)creatUI{
    
    self.contantTextView = [[UITextView alloc]init];
    self.contantTextView.backgroundColor = [UIColor whiteColor];
    self.contantTextView.layer.borderColor  = getColor(@"9b9b9b").CGColor;
    self.contantTextView.layer.borderWidth = 0.5;
    self.contantTextView.font = [UIFont systemFontOfSize:14.0];
    self.contantTextView.textColor = getColor(@"333333");
    self.contantTextView.delegate = self;
    [self.view addSubview:self.contantTextView];
    [self.contantTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(100);
        make.left.equalTo(self.view).offset(22);
        make.height.mas_equalTo(120);
    }];
    
    self.remarkLabel = [[UILabel alloc]init];
    self.remarkLabel.text = @"长按说出或手动输入您的想法";
    self.remarkLabel.textColor = getColor(@"999999");
    self.remarkLabel.font = [UIFont systemFontOfSize:14.0];
    [self.contantTextView addSubview:self.remarkLabel];
    [self.remarkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contantTextView).offset(5);
        make.top.equalTo(self.contantTextView).offset(7);
    }];
    
    self.numberLabel = [[UILabel alloc]init];
    self.numberLabel.text = @"0/500";
    self.numberLabel.textColor = getColor(@"999999");
    self.numberLabel.textAlignment = 2;
    self.numberLabel.font = [UIFont systemFontOfSize:14.0];
    [self.contantTextView addSubview:self.numberLabel];
    [self.numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-32);
        make.top.equalTo(self.contantTextView).offset(97);
    }];
    
    @weakify(self)
    [RACObserve(self.contantTextView,text)subscribeNext:^(NSString *  _Nullable x) {
        @strongify(self)
        if (x.length == 0) {
            self.remarkLabel.hidden = NO;
            self.numberLabel.text = @"0/500";
        }else{
            self.remarkLabel.hidden = YES;
            self.numberLabel.text = [NSString stringWithFormat:@"%ld/500",x.length];
        }
        NSLog(@"RACObserve%@-+--%@",x,self.curResult);

    }];
    
    [[self.contantTextView rac_textSignal]subscribeNext:^(NSString * _Nullable x) {
        @strongify(self)
        self.curResult = [[NSMutableString alloc]initWithString:x];
        if (x.length == 0) {
            self.remarkLabel.hidden = NO;
            self.numberLabel.text = @"0/500";
        }else{
            self.remarkLabel.hidden = YES;
            self.numberLabel.text = [NSString stringWithFormat:@"%ld/500",x.length];
        }
        NSLog(@"rac_textSignal%@-+--%@",x,self.curResult);

    }];
    
    self.recordView = [[UIView alloc]init];
    self.recordView.backgroundColor = [UIColor whiteColor];
    self.recordView.hidden = YES;
    [self.view addSubview:self.recordView];
    [self.recordView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.contantTextView.mas_bottom);
        make.height.mas_equalTo(66);
    }];
    
    self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playBtn.backgroundColor = getColor(@"ffd900");
    self.playBtn.layer.cornerRadius = 5;
    [self.playBtn setImage:[UIImage imageNamed:@"ReceiverVoiceNodePlaying003"] forState:UIControlStateNormal];
    
    [[self.playBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(__kindof UIControl * _Nullable x) {
        
        if (self.voiceUrlArr.count > 1) {
            [self playWithNsString:self.recordData.voiceUrl];

        }else{
        NSError *error = nil;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
        _audioPlayer = [[PcmPlayer alloc] initWithFilePath:self.tempMp3Url sampleRate:16000];
        [_audioPlayer play];
        }
    }];
    [self.recordView addSubview:self.playBtn];
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.recordView);
        make.top.equalTo(self.recordView).offset(15);
        make.left.equalTo(self.view).offset(22);
        make.height.mas_equalTo(36);
    }];
    
    
    self.recordSecondLabel = [[UILabel alloc]init];
    self.recordSecondLabel.font = [UIFont systemFontOfSize:14.0];
    self.recordSecondLabel.textColor = getColor(@"919191");
    [self.recordView addSubview:self.recordSecondLabel];
    [self.recordSecondLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.playBtn.mas_right).offset(8);
        make.centerY.equalTo(self.recordView);
    }];
    
    self.recordRemarkLabel = [[UILabel alloc]init];
    self.recordRemarkLabel.text = @"多次讲话，自动拼接";
    self.recordRemarkLabel.font = [UIFont systemFontOfSize:12.0];
    self.recordRemarkLabel.textColor = getColor(@"4a4a4a");
    [self.recordView addSubview:self.recordRemarkLabel];
    [self.recordRemarkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.recordView);
        make.right.equalTo(self.recordView).offset(-22);
    }];
    
    self.recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.recordButton setBackgroundImage:[UIImage imageNamed:@"speech-btn"] forState:UIControlStateNormal];
    [self.recordButton setBackgroundImage:[UIImage imageNamed:@"speech-btn-click"] forState:UIControlStateHighlighted];
    self.recordButton.layer.cornerRadius = 50;
    [self.view addSubview:self.recordButton];
    [self.recordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom).offset(-50);
        make.size.mas_equalTo(CGSizeMake(80, 80));
    }];
    [self.recordButton addTarget:self action:@selector(holdDownButtonTouchDown) forControlEvents:UIControlEventTouchDown];
    [self.recordButton addTarget:self action:@selector(holdDownButtonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
    [self.recordButton addTarget:self action:@selector(holdDownButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [self.recordButton addTarget:self action:@selector(holdDownDragOutside) forControlEvents:UIControlEventTouchDragExit];
    [self.recordButton addTarget:self action:@selector(holdDownDragInside) forControlEvents:UIControlEventTouchDragEnter];
    
    self.saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.saveButton setBackgroundImage:[UIImage imageNamed:@"Publish-btn"] forState:UIControlStateNormal];
    self.saveButton.layer.cornerRadius = 34;
    [self.view addSubview:self.saveButton];
    [self.saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.recordButton);
        make.right.equalTo(self.view).offset(-28);
        make.size.mas_equalTo(CGSizeMake(58,58));
    }];
    
    [[self.saveButton rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(__kindof UIControl * _Nullable x) {
        self.recordData.contentStr = self.contantTextView.text;
        [DataCache addData:self.recordData];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}- (XHVoiceRecordHUD *)voiceRecordHUD {
    if (!_voiceRecordHUD) {
        _voiceRecordHUD = [[XHVoiceRecordHUD alloc] initWithFrame:CGRectMake(0, 0, 140, 140)];
    }
    return _voiceRecordHUD;
}

/**
 *  当录音按钮被按下所触发的事件，这时候是开始录音
 */
- (void)holdDownButtonTouchDown {
    [self.voiceRecordHUD startRecordingHUDAtView:self.view];
    [_iFlySpeechRecognizer startListening];

}
/**
 *  当手指在录音按钮范围之外离开屏幕所触发的事件，这时候是取消录音
 */
- (void)holdDownButtonTouchUpOutside {
    
    [_iFlySpeechRecognizer cancel];

    [self.voiceRecordHUD cancelRecordCompled:^(BOOL fnished) {
        self.voiceRecordHUD = nil;
    }];
}
/**
 *  当手指在录音按钮范围之内离开屏幕所触发的事件，这时候是完成录音
 */
- (void)holdDownButtonTouchUpInside {
    
    [_iFlySpeechRecognizer stopListening];

    [self.voiceRecordHUD cancelRecordCompled:^(BOOL fnished) {
        self.voiceRecordHUD = nil;
    }];
}
/**
 *  当手指滑动到录音按钮的范围之外所触发的事件
 */
- (void)holdDownDragOutside {
    
    
    [self.voiceRecordHUD resaueRecord];
}
/**
 *  当手指滑动到录音按钮的范围之内所触发的事件
 */
- (void)holdDownDragInside {
    
    [self.voiceRecordHUD pauseRecord];
}

- (void) onResults:(NSArray *) results isLast:(BOOL)isLast{
    NSMutableString *result = [[NSMutableString alloc] init];
    NSMutableString * resultString = [[NSMutableString alloc]init];
    NSDictionary *dic = results[0];
    
    for (NSString *key in dic) {
        
        [result appendFormat:@"%@",key];
        
        NSString * resultFromJson =  [ISRDataHelper stringFromJson:result];
        [resultString appendString:resultFromJson];
        
        NSLog(@"本次识别结果%@",resultString);
        
    }
    if (isLast) {
        
        NSLog(@"result is:%@",self.curResult);
    }
    
    [self.curResult appendString:resultString];
}
//识别会话结束返回代理
- (void)onError: (IFlySpeechError *) error{
    NSLog(@"error=%d",[error errorCode]);
    
    
    if (error.errorCode ==0 ) {
        
        if (self.curResult.length==0 || [self.curResult hasPrefix:@"nomatch"]) {
            [BlackCue showCenterText:@"无结果"];
        }
        else
        {
            [BlackCue showCenterText:@"识别成功"];
            self.contantTextView.text = self.curResult;

        }
    }
    else
    {
      
    }
    
    NSString *voicePath = [self dirCache];
    
    NSString *urlStr=[NSString stringWithFormat:@"%@/iat.pcm",voicePath];
    NSLog(@"单段语音路径%@",urlStr);
    self.tempVoiceUrl = urlStr;
   
    [self audio_PCMtoMP3];
}
//停止录音回调
- (void) onEndOfSpeech{
//    [BlackCue showCapText:@"停止"];
}
//开始录音回调
- (void) onBeginOfSpeech{
//    [BlackCue showCapText:@"开始"];

}
//音量回调函数
- (void) onVolumeChanged: (int)volume{
    self.voiceRecordHUD.peakPower = volume;
}
//会话取消回调
- (void) onCancel{
//    [BlackCue showCapText:@"取消"];

}

//当前时间作为recordId
-(void)getRecordId{
    
    self.recordData = [[Record alloc]init];
    //获取当前日期
    NSDate *currentDate = [NSDate date];
    // 实例化日期格式
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设置日期格式
    [dateFormatter setDateFormat:@"YYYYMMddHHmmss"];
    
    // 实例化日期格式
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
    //设置日期格式
    [dateFormatter1 setDateFormat:@"YYYY-MM-dd"];
    NSString *currentDateStr1 = [dateFormatter1 stringFromDate:currentDate];
    self.recordData.recordTime = currentDateStr1;
    
    //将日期转换成字符串输出
    NSString *currentDateStr = [dateFormatter stringFromDate:currentDate];
    self.recordData.recordId = currentDateStr;
}

- (float)audioSoundDuration:(NSURL *)fileUrl{
    NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey: @YES};
    AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:fileUrl options:options];
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
    return audioDurationSeconds;
}

//取消删除文件(音频,图片)
-(void)deleteFile{
    
    NSString * DocumentsPath = [self dirDoc];
    
    //文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    for (NSString *voiceStr in self.voiceUrlArr) {
        BOOL res=[fileManager removeItemAtPath:voiceStr error:nil];
        
        if (res) {
            
            NSLog(@"文件删除成功");
            
        }else
            
            NSLog(@"文件删除失败");
        
        NSLog(@"文件是否存在: %@",[fileManager isExecutableFileAtPath:voiceStr]?@"YES":@"NO");
    }
    
    
    
    
}

-(NSString *)dirDoc{
    
    //[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSLog(@"app_home_doc: %@",documentsDirectory);
    
    return documentsDirectory;
}

//获取Cache目录
-(NSString *)dirCache{
    
    NSArray *cacPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    
    NSString *cachePath = [cacPath objectAtIndex:0];
    
    NSLog(@"app_home_lib_cache: %@",cachePath);
    return cachePath;
}

//录音文件转码
- (void)audio_PCMtoMP3
{
    NSString *recorderSavePath = self.tempVoiceUrl;
    
    //获取当前日期
    NSDate *currentDate = [NSDate date];
    // 实例化日期格式
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设置日期格式
    [dateFormatter setDateFormat:@"YYYYMMddHHmmss"];
    //将日期转换成字符串输出
    NSString *currentDateStr = [dateFormatter   stringFromDate:currentDate];
    NSString *mp3FileName = [NSString stringWithFormat:@"%@-%@",self.recordData.recordId,currentDateStr];
    mp3FileName = [mp3FileName stringByAppendingString:@".mp3"];
    NSString * DocumentsPath = [self dirDoc];

    NSString *mp3FilePath = [DocumentsPath stringByAppendingPathComponent:mp3FileName];
    
    @try {
        int read, write;
        
        FILE *pcm = fopen([recorderSavePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 7500);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = (int)fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
        NSLog(@"MP3生成成功: %@",mp3FilePath);
        self.tempMp3Url = mp3FilePath;
        [self.voiceUrlArr addObject:[NSURL fileURLWithPath:mp3FilePath]];
    }
    
    if (self.voiceUrlArr.count > 1) {
        [self getFinalUrl];
    }else{
        CGFloat second = [self audioSoundDuration:[NSURL fileURLWithPath:self.tempMp3Url]];
        NSLog(@"播放时长%f",second);
        [self changeRecordViewWithSecond:second];
        self.recordData.voiceUrl = mp3FileName;
        self.recordData.voiceTime = (NSInteger)second;
    }
}

-(void)getFinalUrl{
    NSString * DocumentsPath = [self dirDoc];
    NSString *str = [NSString stringWithFormat:@"/%@-voice.m4a",self.recordData.recordId];
    //得到选择后沙盒中图片的完整路径
    NSString * filePath = [[NSString alloc]initWithFormat:@"%@%@",DocumentsPath,str];
    
    NSLog(@"音频数组%@",self.voiceUrlArr);
    
    //文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //把刚刚图片转换的data对象拷贝至沙盒中 并保存为image.png
    [fileManager createDirectoryAtPath:DocumentsPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    BOOL res=[fileManager removeItemAtPath:filePath error:nil];
    
    if (res) {
        
        NSLog(@"文件删除成功");
    }else
        NSLog(@"文件删除失败");
    
    [AudioComposition sourceURLs:self.voiceUrlArr composeToURL:[NSURL fileURLWithPath:filePath] completed:^(NSError *error) {
        CGFloat second = [self audioSoundDuration:[NSURL fileURLWithPath:filePath]];
        NSLog(@"播放时长%f",second);
        [self changeRecordViewWithSecond:second];
        self.recordData.voiceUrl = str;
        self.recordData.voiceTime = (NSInteger)second;
    }];
}

-(void)changeRecordViewWithSecond:(CGFloat)second{
    self.recordView.hidden = NO;
    self.recordSecondLabel.text = [NSString stringWithFormat:@"%.2f''",second];
    
    NSInteger length = (NSInteger)second;
    if (length >=45) {
          length = 45;
    }else if(length <=5){
        length = 5;
    };
    
    [self.playBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(length * 10);
    }];
    
}

-(void)playWithNsString:(NSString *)url{
    
    NSString * DocumentsPath = [self dirDoc];
    
    NSString *mp3FilePath = [DocumentsPath stringByAppendingPathComponent:url];
    NSURL *fileURL = [[NSURL alloc]initFileURLWithPath:mp3FilePath];
    NSLog(@"%@",fileURL);
    // 2.创建 AVAudioPlayer 对象
    self.avPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:fileURL error:nil];
    // 4.设置循环播放
    
    self.avPlayer.numberOfLoops = 0;
    self.avPlayer.delegate = self;
    // 5.开始播放
    [self.avPlayer play];
}

@end
