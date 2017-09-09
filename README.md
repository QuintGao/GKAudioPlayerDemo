# GKAudioPlayerDemo

##说明
   本Demo是根据[VLCKit](https://code.videolan.org/videolan/VLCKit)播放库写的仿网易云播放界面。
   
   主要实现的功能有：
    
    * 播放网络音频、歌曲
    * 歌词滚动、音量控制、歌曲切换
    * 设置循环类型、上一曲、下一曲、喜欢歌曲等
    * 锁屏控制（播放、暂停、喜欢、上一曲、下一曲、播放条拖动）
    * 耳机线控（播放、暂停、上一曲、下一曲、快进、快退）
    * 通知监听（插拔耳机、播放打断）
   
   不足：
    
    * 不能获取缓冲进度（播放库的问题）
    * 暂停后继续播放声音不准确（播放库的问题）
    * airplay暂未支持

   demo中的音乐文件来自百度音乐，仅供学习使用，请勿在商业中使用

## 部分功能的主要实现
1、歌词解析
```
+ (NSArray *)lyricParaseWithLyricString:(NSString *)lyricString {
    // 1. 以\n分割歌词
    NSArray *linesArray = [lyricString componentsSeparatedByString:@"\n"];

    // 2. 创建模型数组
    NSMutableArray *modelArray = [NSMutableArray new];

    // 3. 开始解析
    for (NSString *line in linesArray) {
        // 正则表达式 [00:01.78], \\ 转义,  @"\\[\\d{2}:\\d{2}.\\d{2}\\]"
        NSString *pattern = @"\\[[0-9][0-9]:[0-9][0-9].[0-9][0-9]\\]";

        NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
        // 进行匹配
        NSArray *matchesArray = [regular matchesInString:line options:NSMatchingReportProgress range:NSMakeRange(0, line.length)];

        // 方法二  [00:01.78]歌词
        NSString *content = [line componentsSeparatedByString:@"]"].lastObject;

        // 获取时间部分[00:00.00]
        for (NSTextCheckingResult *match in matchesArray) {
            NSString *timeStr = [line substringWithRange:match.range];
            // 去掉开头和结尾的[],得到时间00:00.00
            timeStr = [timeStr substringWithRange:NSMakeRange(1, 8)];
            // 分、秒、毫秒
            NSString *minStr = [timeStr substringWithRange:NSMakeRange(0, 2)];
            NSString *secStr = [timeStr substringWithRange:NSMakeRange(3, 2)];
            NSString *mseStr = [timeStr substringWithRange:NSMakeRange(6, 2)];

            // 转换成以毫秒秒为单位的时间 1秒 = 1000毫秒
            NSTimeInterval time = [minStr floatValue] * 60 * 1000 + [secStr floatValue] * 1000 + [mseStr floatValue];

            // 创建模型，赋值
            GKLyricModel *lyricModel = [GKLyricModel new];
            lyricModel.content      = content;
            lyricModel.msTime       = time;
            lyricModel.secTime      = time / 1000;
            lyricModel.timeString   = [GKTool timeStrWithMsTime:time];
            [modelArray addObject:lyricModel];
        }
    }

    // 数组根据时间进行排序 时间（time）
    // ascending: 是否升序
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"msTime" ascending:YES];

    return [modelArray sortedArrayUsingDescriptors:@[descriptor]];
}

```
2、歌词滚动
```
- (void)scrollLyricWithCurrentTime:(NSTimeInterval)currentTime {
    if (self.lyricList.count == 0) self.lyricIndex = 0;

    for (NSInteger i = 0; i < self.lyricList.count; i++) {
        GKLyricModel *currentLyric = self.lyricList[i];
        GKLyricModel *nextLyric = nil;
        if (i < self.lyricList.count - 1) {
            nextLyric = self.lyricList[i + 1];
        }
        if ((self.lyricIndex != i && currentTime >= currentLyric.msTime) && (!nextLyric || currentTime < nextLyric.msTime)) {
            self.lyricIndex = i;

            [self.lyricTable reloadData];
            [self.lyricTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:(self.lyricIndex + 5) inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        }
    }
}
```
3、锁屏功能控制
```
// 喜欢、上一曲
// 喜欢按钮
MPFeedbackCommand *likeCommand = commandCenter.likeCommand;
likeCommand.enabled        = YES;
likeCommand.active         = self.model.isLike;
likeCommand.localizedTitle = self.model.isLike ? @"取消喜欢" : @"喜欢";
[likeCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
    // 喜欢
    return MPRemoteCommandHandlerStatusSuccess;
}];
// 上一首
MPFeedbackCommand *dislikeCommand = commandCenter.dislikeCommand;
dislikeCommand.enabled = YES;
dislikeCommand.localizedTitle = @"上一首";
[dislikeCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {

    NSLog(@"上一首");

    [self playPrevMusic];

    return MPRemoteCommandHandlerStatusSuccess;
}];

// 拖动进度条
if ([UIDevice currentDevice].systemVersion.doubleValue >= 9.0) {
    [commandCenter.changePlaybackPositionCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {

            MPChangePlaybackPositionCommandEvent *positionEvent = (MPChangePlaybackPositionCommandEvent *)event;

            if (positionEvent.positionTime != self.positionTime) {
                self.positionTime = positionEvent.positionTime;

                self.currentTime = self.positionTime * 1000;

                kPlayer.progress = (float)self.currentTime / self.duration;
            }

        return MPRemoteCommandHandlerStatusSuccess;
    }];
}

```

## 部分界面截图

