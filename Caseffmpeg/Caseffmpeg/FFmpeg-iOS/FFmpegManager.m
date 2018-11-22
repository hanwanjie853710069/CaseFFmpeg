//
//  FFmpegManager.m
//  ZJHVideoProcessing
//
//  Created by ZhangJingHao2345 on 2018/1/29.
//  Copyright © 2018年 ZhangJingHao2345. All rights reserved.
//

#import "FFmpegManager.h"
#import "ffmpeg.h"

@interface FFmpegManager ()

@property (nonatomic, assign) BOOL isRuning;
@property (nonatomic, assign) BOOL isBegin;
@property (nonatomic, assign) long long fileDuration;
@property (nonatomic, copy) void (^processBlock)(float process);
@property (nonatomic, copy) void (^completionBlock)(NSError *error);

@end

@implementation FFmpegManager

+ (FFmpegManager *)sharedManager {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

// 转换视频
- (void)converWithInputPath:(NSString *)inputPath
                 outputPath:(NSString *)outpath
               processBlock:(void (^)(float process))processBlock
            completionBlock:(void (^)(NSError *error))completionBlock {
    self.processBlock = processBlock;
    self.completionBlock = completionBlock;
    self.isBegin = NO;
    
    // ffmpeg语法，可根据需求自行更改
    // !#$ 为分割标记符，也可以使用空格代替
//    NSString *commandStr = [NSString stringWithFormat:@"ffmpeg!#$-ss!#$00:00:00!#$-i!#$%@!#$-b:v!#$2000K!#$-y!#$%@", inputPath, outpath];
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *aaa = [NSString stringWithFormat:@"%@/%%05d.jpg",docDir];

    
    NSString *commandStr = [NSString stringWithFormat:@"ffmpeg -i %@ -r 5 %@", inputPath,aaa];
    
    // 放在子线程运行
    [[[NSThread alloc] initWithTarget:self selector:@selector(runCmd:) object:commandStr] start];
}

// 执行指令
- (void)runCmd:(NSString *)commandStr{
    // 判断转换状态
    if (self.isRuning) {
        NSLog(@"正在转换,稍后重试");
    }
    self.isRuning = YES;
    
//    // 根据 !#$ 将指令分割为指令数组
    NSArray *argv_array = [commandStr componentsSeparatedByString:(@" ")];
    // 将OC对象转换为对应的C对象
    int argc = (int)argv_array.count;
    char** argv = (char**)malloc(sizeof(char*)*argc);
    for(int i=0; i < argc; i++) {
        argv[i] = (char*)malloc(sizeof(char)*1024);
        strcpy(argv[i],[[argv_array objectAtIndex:i] UTF8String]);
    }

    // 打印日志
    NSString *finalCommand = @"ffmpeg 运行参数:";
    for (NSString *temp in argv_array) {
        finalCommand = [finalCommand stringByAppendingFormat:@"%@\n",temp];
    }
    NSLog(@"%@",finalCommand);

    // 传入指令数及指令数组
    ffmpeg_main(argc,argv);
    
    // 线程已杀死,下方的代码不会执行
//    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
//   NSString *aaa = [NSString stringWithFormat:@"%@/%%05d.jpg",docDir];
    
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        char *movie = (char *)[commandStr UTF8String];
//        char *outPic = (char *)[aaa UTF8String];
//        char* a[] = {
//            "ffmpeg",
//            "-i",
//            movie,
//            "-r",
//            "5",
//            outPic
//        };
//        ffmpeg_main(6, a);
//    });
}

// 设置总时长
+ (void)setDuration:(long long)time {
    [FFmpegManager sharedManager].fileDuration = time;
}

// 设置当前时间
+ (void)setCurrentTime:(long long)time {
    FFmpegManager *mgr = [FFmpegManager sharedManager];
    mgr.isBegin = YES;
    
    if (mgr.processBlock && mgr.fileDuration) {
        float process = time/(mgr.fileDuration * 1.00);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            mgr.processBlock(process);
        });
    }
}

// 转换停止
+ (void)stopRuning {
    nb_filtergraphs = 0;
    nb_output_files = 0;
    nb_output_streams = 0;
    nb_input_files = 0;
    nb_input_streams = 0;
    FFmpegManager *mgr = [FFmpegManager sharedManager];
    NSError *error = nil;
    // 判断是否开始过
    if (!mgr.isBegin) {
        // 没开始过就设置失败
        error = [NSError errorWithDomain:@"转换失败,请检查源文件的编码格式!"
                                    code:0
                                userInfo:nil];
    }
    if (mgr.completionBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            mgr.completionBlock(error);
        });
    }
    
    mgr.isRuning = NO;
}

@end
