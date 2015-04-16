//
//  ViewController.m
//  BYTGithub
//
//  Created by 卢权 on 15/4/16.
//  Copyright (c) 2015年 卢权. All rights reserved.
//

#import "ViewController.h"
#import "TFHpple.h"

@interface ViewController () <NSXMLParserDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *baseURLString = @"https://github.com";
    
    NSURL *requestUrl;
    NSString *tempString = @"";
    
    int outTime = 10;

    for (int i = 1; i < 40; i++) {
        if (i == 1) {
            requestUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", baseURLString, @"search?utf8=%E2%9C%93&q=language%3AObjective-C+stars%3A%3E1000&type=Repositories&ref=advsearch&l=Objective-C"]];
            
        } else {
            requestUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/search?l=Objective-C&amp;p=%d&amp;q=language%%3AObjective-C+stars%%3A%%3E1000&amp;ref=advsearch&amp;type=Repositories&amp;utf8=%%E2%%9C%%93", baseURLString, i]];
        }

        NSData *data = [NSData dataWithContentsOfURL:requestUrl];
        TFHpple *doc = [[TFHpple alloc] initWithHTMLData:data];
        NSArray *elements = [doc searchWithXPathQuery:@"//a"];
        if (elements.count>0) {
            NSLog(@"第%i页:requestUrl:%@\n\n", i, requestUrl);

            for (TFHppleElement *element in elements) {
                NSString *hrefStr = element.attributes[@"href"];
                
                if ([[hrefStr substringFromIndex:1] isEqualToString:element.text]) {
                    
                    // 库链接
                    tempString = [tempString stringByAppendingString:[NSString stringWithFormat:@"git clone %@/%@.git; ", baseURLString,element.text]];
                }
            }
            NSLog(@"%@\n\n", [tempString substringWithRange:NSMakeRange(0, tempString.length-1)]);

            // 写入文件
            [self writeToFile:tempString];
        }

        // 共多少页
        NSArray *elements2 = [doc searchWithXPathQuery:@"//span[@class='counter']"];
        if (elements2.count>0) {
            TFHppleElement *counterElement = elements2[0];
            int pageNumber = [counterElement.text intValue];
            if ((pageNumber%10 == 0 ? (pageNumber/10): (pageNumber/10+1)) == i) {
                return;
            }
        }
        
        requestUrl = nil;
        
        sleep(outTime);
    }
}

// 将字符串写入文件中
- (void)writeToFile:(NSString *)str {
    NSString *documentDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *filePath = [documentDirectory stringByAppendingPathComponent:@"Repositories.txt"];

    if (![[NSFileManager defaultManager]fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager]createFileAtPath:filePath contents:nil attributes:nil];
    }
    
    [str writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    NSLog(@"文件路径：%@", filePath);

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end













