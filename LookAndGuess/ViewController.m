//
//  ViewController.m
//  LookAndGuess
//
//  Created by 邹前立 on 2017/2/22.
//  Copyright © 2017年 邹前立. All rights reserved.
//

#import "ViewController.h"
#import "IdiomModel.h"
@interface ViewController ()
// 模型数组
@property (nonatomic,strong) NSArray *questions;
// 背景图片
@property (weak, nonatomic) IBOutlet UIImageView *backgroundPic;
// 序号
@property (nonatomic,assign) NSInteger index;
// 得分
@property (weak, nonatomic) IBOutlet UIButton *score;
// 第几张图片
@property (weak, nonatomic) IBOutlet UILabel *number;
// 提示文字
@property (weak, nonatomic) IBOutlet UILabel *tip;
// 图片控件
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
// 大图？
@property (nonatomic,assign) BOOL isBigPic;
@property (weak, nonatomic) IBOutlet UIView *answer;
@property (weak, nonatomic) IBOutlet UIView *answerOptions;
// 存放选择的答案选项 数组
@property (nonatomic,strong) NSMutableArray *saveAnswer;
// 最终答案 字符串
@property (nonatomic,strong) NSString *finalAnswer;
// 存放要显示的答案 数组
@property (nonatomic,strong) NSMutableArray *showAnswer;

// 下一题
- (IBAction)nextQuestion:(id)sender;

// 缩放图片
- (IBAction)scalePic;
- (IBAction)nextQuestion;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.index = 0;
    // 设置初始图片 1
//    self.imageView.image =[UIImage imageNamed:[NSString stringWithFormat:@"%ld.png",self.index]];
    self.imageView.image = [UIImage imageNamed:@"0.jpg"];
    self.imageView.layer.borderColor = [[UIColor grayColor] CGColor];
    self.imageView.layer.borderWidth = 8;
    
    // 添加手势点击缩放图片(与放大按钮调用相同的方法)
    [self.imageView setUserInteractionEnabled:YES];
    [self.imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scalePic)]];
    
    // 添加按钮
    [self setButtons:self.index];
}
#pragma mark - 设置答案按钮、答案选项按钮
- (void) setButtons:(NSInteger)index
{
    self.saveAnswer = [[NSMutableArray alloc] init]; // 初始化
    self.showAnswer = [[NSMutableArray alloc] init]; // 初始化
    self.finalAnswer = [[NSMutableString alloc] init]; // 初始化
    // 清除上一次添加的按钮
    for (UIView *view in self.answer.subviews) {
        [view removeFromSuperview];
    }
    for (UIView *view in self.answerOptions.subviews) {
        [view removeFromSuperview];
    }
    // 获取模型
    IdiomModel *model=self.questions[self.index];
    // 获取答案长度、答案选项长度
    NSInteger answerLength = [model.answer length];
    NSInteger answerOptionsLength = [model.options count];
    
    int margin = 20; // 间距    int answerMargin = 20;
    int w = 60;      // 宽、高相等
    int offsetX = ([[UIScreen mainScreen] bounds].size.width - w*answerLength-(margin*(answerLength-1)))/2; // X方向偏移量 整体居中
    for (int i=0; i<answerLength; i++) {
        UIButton *bt = [[UIButton alloc] initWithFrame:CGRectMake(offsetX+i*(w+margin), 0, w, w)];
        [bt addTarget:self action:@selector(quitChooseAnswerWithAnswerLength:) forControlEvents:UIControlEventTouchUpInside];// 绑定事件 事件处理方法  点击可以取消答案显示
        bt.backgroundColor = [UIColor whiteColor];
        [bt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.answer addSubview:bt];
    }
    
    margin = 8;  // 间距    int answerOptionsMargin = 8;
    int OW = 50;     // 宽、高相等
    int OoffsetX = margin; // X方向偏移量
    int __block OoffsetY = margin; // Y方向偏移量
    int __block lineNumber = 0;
    
    for (int i=0; i<answerOptionsLength; i++) {
        OoffsetX = i%7*(OW+margin)+margin;
        
        // 代码块
        typedef void (^CreateButtonsBlock) (int);
        CreateButtonsBlock createButtons = ^(int j){
            if(i%7 == 0)
            {
                OoffsetY = lineNumber * (OW+margin) + margin;
                UIButton *bt = [[UIButton alloc] initWithFrame:CGRectMake(OoffsetX, OoffsetY, OW, OW)];
                [bt addTarget:self action:@selector(chooseAnswer:withModel:) forControlEvents:UIControlEventTouchUpInside]; // 绑定事件 事件处理方法 点击可以显示答案
                bt.backgroundColor = [UIColor grayColor];
                [bt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                NSArray *answerOptions = model.options;
                [bt setTitle:answerOptions[i] forState:UIControlStateNormal];
                [self.answerOptions addSubview:bt];
                
                //            createButtons(i);
                lineNumber++;
            }else if(i%7 != 0){
                
                UIButton *bt = [[UIButton alloc] initWithFrame:CGRectMake(OoffsetX, OoffsetY, OW, OW)];
                [bt addTarget:self action:@selector(chooseAnswer:withModel:) forControlEvents:UIControlEventTouchUpInside]; // 绑定事件 事件处理方法
                bt.backgroundColor = [UIColor grayColor];
                [bt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                NSArray *answerOptions = model.options;
                [bt setTitle:answerOptions[i] forState:UIControlStateNormal];
                
                [self.answerOptions addSubview:bt];
                //            createButtons(i);
            }
        };
        // 调用代码块 创建按钮（代码块中的内容直接可以创建按钮）
        createButtons(i);
        
    }
    
}

#pragma mark - 选择答案
- (void) chooseAnswer:(id) sender withModel:(IdiomModel *)model
{
    // 获取模型
     model=self.questions[self.index];
    // 获取答案长度
    NSInteger answerLength = [model.answer length];
    // 获取按钮上面的文字
    NSString *answer = [sender titleForState:UIControlStateNormal];
    [self.saveAnswer addObject:answer]; // 要保存
    [self.showAnswer addObject:answer]; // 要显示
    
    [sender setHidden:YES]; // 隐藏按钮
    [self showAnswerWithAnswerLength:answerLength andModel:model]; // 显示答案
    
}
#pragma mark - 显示答案
- (void) showAnswerWithAnswerLength:(NSInteger) answerLength andModel:(IdiomModel *) model
{
//    if (self.saveAnswer.count == answerLength) {
//        [self.showAnswer arrayByAddingObjectsFromArray:self.saveAnswer]; // 从保存结果 赋值
//    }
    // 处理 答案显示按钮 的内容
    NSArray *subButtons = self.answer.subviews;
    if (self.showAnswer.count <= answerLength) {
        for (int i=0; i<self.showAnswer.count; i++) {
            if ([subButtons[i] isKindOfClass:[UIButton class]]) {
                NSString *answer = [self.showAnswer objectAtIndex:i];
                [subButtons[i] setTitle:answer forState:UIControlStateNormal];
                [subButtons[i] setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            }
        }
        // 长度相等 不能再选了
        if(self.showAnswer.count == answerLength){
            [self.answerOptions setUserInteractionEnabled:NO];
            [self yesOrNoWithAnswerLength:answerLength andModel:model]; // 判断结果
            
        }
    }
}
//[self.showAnswer removeAllObjects];
//[self.answerOptions setUserInteractionEnabled:YES];
#pragma mark - 取消答案（每次删除最后一个）
- (void) quitChooseAnswerWithAnswerLength:(NSInteger) answerLength
{
    if (self.showAnswer.count > 0) {
        // 答案 最后一个替换为空
        NSString *lastObject = [self.showAnswer lastObject];
        // 删除要把self.finalAnswer置为空，它最终会从self.savaAnswer遍历出来
        self.finalAnswer = @"";
        // 存储答案的 数组 移除最后一个元素
        NSArray *subButtons = self.answer.subviews;
        [self.showAnswer removeLastObject];
        [self.saveAnswer removeLastObject]; // 判断时 条件
//        [subButtons[self.showAnswer.count] setTitle:@"" forState:UIControlStateNormal]; // "删除"
        [subButtons[self.showAnswer.count] setTitleColor:[UIColor redColor] forState:UIControlStateNormal]; // “删除”
        [self.answerOptions setUserInteractionEnabled:YES];
        // options 中的按钮 重新显示(有相同内容的按钮 怎么处理？)
        for (int i=0; i<[self.answerOptions.subviews count]; i++) {
            NSArray *optionsArray = self.answerOptions.subviews;
            UIButton *optionsBt = optionsArray[i];
            NSString *optinosStr = [optionsBt titleForState:UIControlStateNormal];
            if ([lastObject isEqualToString:optinosStr]) {
                [optionsBt setHidden:NO];
            }
        }
    }else{
        [self.answerOptions setUserInteractionEnabled:YES];
    }
}
#pragma mark - 取消全部答案（一次性清除）
- (void) quitChooseAllAnswerWithAnswerLength:(NSInteger) answerLength
{
    NSLog(@"pre clearAll");
//    NSArray *subButtons = self.answer.subviews;
    [self.showAnswer removeAllObjects];
    [self.saveAnswer removeAllObjects]; // 判断时 条件
    self.finalAnswer = @"";
    if (self.showAnswer.count == 0) {
        [self.answerOptions setUserInteractionEnabled:YES];
        NSLog(@"clearAll");
//        [subButtons[self.showAnswer.count] setTitle:@"" forState:UIControlStateNormal];
    }
}
#pragma mark - 判断正确 错误
- (void) yesOrNoWithAnswerLength:(NSInteger) answerLength andModel:(IdiomModel *) model
{
    
    // 比较数组的长度 和答案的长度是否相等
    if ( [self.saveAnswer count] == answerLength) {
        // 相等时 遍历saveAnswer保存在finalAnswer
        for (NSString *answer in self.saveAnswer) {
            self.finalAnswer = [self.finalAnswer stringByAppendingString:answer];
        }
        
        NSLog(@"finalAnswer (%@)",self.finalAnswer);
    
        // 获取 得分
        int score = [[self.score currentTitle] intValue];
        // 最终答案 和 答案内容是否一样
        if ([self.finalAnswer isEqualToString:model.answer]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"您真棒👏" message:@"恭喜您，答对了" delegate:nil cancelButtonTitle:@"实力说话" otherButtonTitles:nil, nil];
            [alert show];
           
            [self nextQuestion]; // 自动下一题
            // TODO 加分
            score += 10000;
            [self.score setTitle:[NSString stringWithFormat:@"%@",[NSNumber numberWithInt:score]] forState:UIControlStateNormal];
        }else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"继续加油😎" message:@"坚持就是胜利" delegate:nil cancelButtonTitle:@"再试试" otherButtonTitles:nil, nil];
            [alert show];
            // TODO 减分
            score -= 1000;
            [self.score setTitle:[NSString stringWithFormat:@"%@",[NSNumber numberWithInt:score]] forState:UIControlStateNormal];
        }
    }
}

#pragma mark - 放大/缩小图片
- (IBAction)scalePic{
    // UIImageView 颜色 边框 宽
    self.imageView.layer.borderColor = [[UIColor greenColor] CGColor];
    self.imageView.layer.borderWidth = 5;
    CGFloat w = [self.imageView frame].size.width;
    // 屏幕宽、高、“中心点”
    CGFloat sw = [[UIScreen mainScreen] bounds].size.width;
    CGFloat sh = [[UIScreen mainScreen] bounds].size.height;
    CGPoint sc = CGPointMake(sw/2, sh/2+50);

    [UIView beginAnimations:nil context:nil]; // 开始动画
    [UIView setAnimationDuration:0.5];        // 设置动画时长
    // 为self.view的子控件设置透明度数组
    NSArray *subViews = self.view.subviews;
    if (!self.isBigPic) {
        // 提到最前面
        [self.view bringSubviewToFront:self.imageView];
        // 放大前为self.view非UIImageView的子控件设置透明度
        for (UIView *view in subViews) {
            if ([view isKindOfClass:[UIImageView class]]) {
                continue;
            }
            view.alpha = 0.6;
        }
        // 放大
        self.imageView.transform = CGAffineTransformMakeScale(sw/w,sw/w);
        // 移动
        self.imageView.center = sc;
        self.isBigPic = true;
        
    }else{
        // 为self.view的子控件设置透明度
        for (UIView *view in subViews)
        {
            view.alpha = 1.0;
        }
        // 缩小(还原)
        self.imageView.transform = CGAffineTransformMakeScale(1, 1);
        // 移动
//        self.imageView.center = c;
        self.imageView.center = CGPointMake(207, 280);
        self.isBigPic = false;
    }
    [UIView commitAnimations]; // 结束动画
}


#pragma mark - 下一张图片
- (IBAction)nextQuestion:(id)sender {
    
    [self nextQuestion];
    //    if (self.showAnswer.count == 0) {
    //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"想跳过吗" message:@"再想一想吧。。。没有那么难" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    //        [alert show];
    //        return;
    //    }

}

- (IBAction)nextQuestion
{
       self.index++; // 0-9  =>  1-10
    
    // 重置序号
    if (self.index == 13) {
        self.index = 0;
        // 设置图片 1
        self.imageView.image =[UIImage imageNamed:@"0.png"];
    };
    // 图片数量
    NSInteger picCount = [self.questions count];
    // 设置数字 2/10 => 10/10
    self.number.text = [NSString stringWithFormat:@"%ld/%ld",(self.index+1)%(picCount+1),picCount];
    // 获取模型
    IdiomModel *model=self.questions[self.index];
//    [self quitChooseAnswerWithAnswerLength:model.answer.length]; // 启用用户交互
[self.answerOptions setUserInteractionEnabled:YES];
    // 设置提示文字
    self.tip.text = model.title;
    // 设置图片 2-10
    self.imageView.image =[UIImage imageNamed:[NSString stringWithFormat:@"%ld.png",self.index]];
    
    // 添加按钮
    [self setButtons:self.index];
    
    
}

#pragma mark - 测试
// test
- (void) test
{
    // iPhone7屏幕宽高 375.000000 667.000000
    // iPhone6s屏幕宽高 414.000000 736.000000
    // iPhone7s屏幕宽高 414.000000 736.000000
    CGFloat sw = [[UIScreen mainScreen] bounds].size.width;
    CGFloat sh = [[UIScreen mainScreen] bounds].size.height;
    NSLog(@"sw = %f , sh = %f",sw,sh); //
    // 测试加载数据是否读取正确
    NSLog(@"%@",self.questions);
    
    /*
     正确获取到数据之后，如果想对标题、答案等进行赋值，可以通过如下方法: (1)获取对应的 model
     // 取出对应的 model，index 为 0 到 9
     IdiomModal *model=self.questions[self.index]; (2)进行对应的赋值
     给 title 赋值就可以通过 model.title 获取
     给 answer 赋值就可以通过 model.answer 获取
     想要获取 options 选项的个数可以通过 model.options.count
     */
    IdiomModel *model=self.questions[self.index];
    NSLog(@"answer=%@,title=%@",model.answer,model.title);
    
    int answerLength = (int)[model.answer length];
    NSLog(@"answerlength = %d",answerLength);
    
    NSInteger titleLength = [model.title length];
    NSLog(@"titleLength = %ld",titleLength);
    
    NSInteger optionsLength = [model.options count];
    NSLog(@"optionsLength = %ld",optionsLength);
    
    // 测试图片序号 文本内容的获取
    ++self.index;
    self.number.text = [NSString stringWithFormat:@"%ld/%ld",self.index,[self.questions count]];
    // 测试分数 获取 修改
    int s = [[self.score currentTitle] intValue];
    NSLog(@"得分s=%d",s);
    s += 1000;
    [self.score setTitle:[NSString stringWithFormat:@"%@",[NSNumber numberWithInt:s]] forState:UIControlStateNormal];
    int ss = [[self.score currentTitle] intValue];
    NSLog(@"得分ss=%d",ss);
    
}

#pragma mark - 重写questions get方法
// 重写模型数组的 get 方法，完成字典转模型操作
- (NSArray *)questions
{
    // 判断
    if (_questions == nil) {
        // 为空，加载plist文件
        NSString *path = [[NSBundle mainBundle] pathForResource:@"questions.plist" ofType:nil];
        // plist文件是数组类型，用数组保存
        NSArray *dictArray = [NSArray arrayWithContentsOfFile:path];
        
        // 创建可变数组，保存从dictArray遍历的数据
        NSMutableArray *mutArray = [[NSMutableArray alloc] init];
        
        // 循环字典转模型，将遍历出来的每一个元素，赋值给对应的模型的属性
        for (NSDictionary *dict in dictArray) {
            // 创建对象
            IdiomModel *model = [[IdiomModel alloc] init];
            // 赋值
            model.answer  = dict[@"answer"];
            model.title   = dict[@"title"];
            model.options = dict[@"options"];
            // 添加到可变数组
            [mutArray addObject:model];
        }
        // 循环完毕赋值给属性
        _questions = mutArray;
    }
    return _questions;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end


