//
//  ViewController.m
//  Caseffmpeg
//
//  Created by xxx on 2018/11/22.
//  Copyright © 2018 Mr.H. All rights reserved.
//

#import "ViewController.h"
#import "ffmpeg.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    /** 视频转图片 */
        NSString *commandStr = @"/Users/xxx/Desktop/1111.mp4";
    
            NSString *docDir = @"/Users/xxx/Desktop/111111";
           NSString *aaa = [NSString stringWithFormat:@"%@/%%05d.jpg",docDir];
    
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                char *movie = (char *)[commandStr UTF8String];
                char *outPic = (char *)[aaa UTF8String];
                char* a[] = {
                    "ffmpeg",
                    "-i",
                    movie,
                    "-r",
                    "5",
                    outPic
                };
                ffmpeg_main(6, a);
            });
}

@end
