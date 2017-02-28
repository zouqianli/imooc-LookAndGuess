//
//  IdiomModel.h
//  LookAndGuess
//
//  Created by 邹前立 on 2017/2/22.
//  Copyright © 2017年 邹前立. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IdiomModel : NSObject
// 1.答案
@property(copy,nonatomic)NSString *answer;
// 3.提示
@property(copy,nonatomic)NSString *title;
// 4.选项们
@property(strong,nonatomic)NSArray *options;

@end
