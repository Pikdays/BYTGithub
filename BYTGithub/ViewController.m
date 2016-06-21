//
//  ViewController.m
//  BYTGithub
//
//  Created by Pikdays on 15/4/16.
//  License
//  Copyright (c) 2015年 Pikdays. All rights reserved.
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "ViewController.h"
#import "TFHpple.h"

typedef NS_ENUM(NSUInteger, ProgramLanguage) {
    ProgramLanguage_OC,
    ProgramLanguage_Swift,
};

static NSString *const kBaseURLString = @"https://github.com";

@interface ViewController () <NSXMLParserDelegate> {
    ProgramLanguage language;
    int star;
}

@end

@implementation ViewController

#pragma mark - 配置参数

- (void)config {
    language = ProgramLanguage_OC; // 设置编程语言
    star = 5000; // 设置收藏数目
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // 配置参数
    [self config];

    // 从网络上加载数据
    [self loadDataFromWebRequest];
}

#pragma mark - 加载请求

- (void)loadDataFromWebRequest {
    NSURL *requestUrl;
    NSString *tempString = @"";
    int pageNumber = 0;    // 共多少页

    for (int i = 1; i < 300; i++) {
        if (i == 1) {
            requestUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/search?utf8=%%E2%%9C%%93&q=language%%3A%@+stars%%3A%%3E%d&type=Repositories&ref=advsearch&l=%@&l=", kBaseURLString, [self getLanguageName], star, [self getLanguageName]]];
        } else {
            requestUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/search?l=&p=%d&q=language%%3A%@+stars%%3A%%3E%d&ref=advsearch&type=Repositories&utf8=%%E2%%9C%%93", kBaseURLString, i, [self getLanguageName], star]];
        }

        NSData *data = [NSData dataWithContentsOfURL:requestUrl];
        TFHpple *doc = [[TFHpple alloc] initWithHTMLData:data];
        NSArray *elements = [doc searchWithXPathQuery:@"//a"];
        if (elements.count > 0) {
            NSLog(@"第%i页\trequestUrl:%@\n", i, requestUrl);

            for (TFHppleElement *element in elements) {
                NSString *hrefStr = element.attributes[@"href"];
                if (hrefStr.length > 1) {
                    NSString *tt = [hrefStr substringFromIndex:1];
                    if (tt.length > 0 && [tt isEqualToString:element.text]) {
                        // 库链接
                        tempString = [tempString stringByAppendingString:[NSString stringWithFormat:@"git clone %@/%@.git; ", kBaseURLString, element.text]];
                    }
                }
            }
            // 写入文件
            [self writeToFile:tempString];
        } else {
            i--;
        }

        if (i == 1) {
            NSArray *elements2 = [doc searchWithXPathQuery:@"//span[@class='counter']"];
            if (elements2.count > 0) {
                int count = [[elements2[0] text] intValue];
                pageNumber = (count % 10 == 0 ? (count / 10) : (count / 10 + 1));
            }
        } else if (pageNumber == i) {
            [[[UIAlertView alloc] initWithTitle:@"请求完成" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil] show];
            return;
        }

        sleep(2);
    }
}

// 获取语言名字
- (NSString *)getLanguageName {
    NSString *languageName = @"";
    switch (language) {
        case ProgramLanguage_OC: {
            languageName = @"Objective-C";
        }
            break;
        case ProgramLanguage_Swift: {
            languageName = @"Swift";
        }
            break;
    }

    return languageName;
}

// 将字符串写入文件中
- (void)writeToFile:(NSString *)str {
    NSString *documentDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *filePath = [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_star>=%d_Repositories.txt", [self getLanguageName], star]];

    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    }

    [str writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];

    NSLog(@"%@文件路径：%@\n\n", [self getLanguageName], filePath);
}

@end













