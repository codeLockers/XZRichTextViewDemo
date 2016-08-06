//
//  ViewController.m
//  XZRichTextViewDemo
//
//  Created by 徐章 on 16/7/27.
//  Copyright © 2016年 徐章. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITextViewDelegate>{

    UIFont *_textFont;
    UIColor *_textColor;
    BOOL _textIsBold;
    BOOL _textIsDeleting;
    NSMutableAttributedString *_locationStr;
    NSRange _newRange;
    NSString *_newStr;
}
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *textFontBtn;
@property (weak, nonatomic) IBOutlet UIButton *textColorBtn;
@property (weak, nonatomic) IBOutlet UIButton *textBoldBtn;
@property (weak, nonatomic) IBOutlet UIButton *textImageBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _textFont = [UIFont systemFontOfSize:15.0f];
    _textColor = [UIColor blackColor];
    _textIsBold = NO;
    _textIsDeleting = NO;
    _locationStr = nil;
    [self loadUI];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Load_UI
- (void)loadUI{

    [self loadTextView];
    [self.textFontBtn setTitle:@"字体 25.0f" forState:UIControlStateSelected];
    [self.textFontBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    
    [self.textColorBtn setTitle:@"颜色 Red" forState:UIControlStateSelected];
    [self.textColorBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    
    [self.textBoldBtn setTitle:@"粗细 YES" forState:UIControlStateSelected];
    [self.textBoldBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];

}

- (void)loadTextView{

    self.textView.layer.borderColor = [UIColor greenColor].CGColor;
    self.textView.layer.borderWidth = 1.0f;
    self.textView.delegate = self;
    self.textView.font = _textFont;
    self.textView.textColor = _textColor;
}

- (IBAction)textFontBtn_Pressed:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    _textFont = sender.selected ? [UIFont systemFontOfSize:25.0f] : [UIFont systemFontOfSize:15.0f];
}

- (IBAction)textColorBtn_Pressed:(UIButton *)sender {
    sender.selected = !sender.selected;
    _textColor = sender.selected ? [UIColor redColor] : [UIColor blackColor];
}

- (IBAction)textBoldBtn_Pressed:(UIButton *)sender {
    sender.selected = !sender.selected;
    _textIsBold = sender.selected;
}

- (IBAction)textImgeBtn_Pressed:(id)sender {
    
    [self appenReturn];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"image" ofType:@"jpg"];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
    image = [self scaleImage:image withSize:CGSizeMake(self.textView.bounds.size.width, (self.textView.bounds.size.width/image.size.height)*image.size.width)];
                                                       
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
    textAttachment.image = image;
    
    [self.textView.textStorage insertAttributedString:[NSAttributedString attributedStringWithAttachment:textAttachment]
                                          atIndex:self.textView.selectedRange.location];
    
    //Move selection location
    _textView.selectedRange = NSMakeRange(_textView.selectedRange.location + 1, _textView.selectedRange.length);
    _locationStr = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.attributedText];
    [self appenReturn];
}


- (UIImage *)scaleImage:(UIImage *)image withSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

-(void)appenReturn
{
    NSAttributedString * returnStr=[[NSAttributedString alloc]initWithString:@"\n"];
    NSMutableAttributedString * att=[[NSMutableAttributedString alloc]initWithAttributedString:_textView.attributedText];
    [att appendAttributedString:returnStr];
    self.textView.attributedText=att;
}

- (void)setStyle{

    _locationStr = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.attributedText];
    
    if (_textIsDeleting)
        return;
    
    NSDictionary *attDic = nil;
    if (_textIsBold) {
    
        attDic = @{
                   NSFontAttributeName:[UIFont boldSystemFontOfSize:_textFont.pointSize],
                   NSForegroundColorAttributeName:_textColor
                   };
    }else{
        attDic = @{
                   NSFontAttributeName:[UIFont systemFontOfSize:_textFont.pointSize],
                   NSForegroundColorAttributeName:_textColor
                   };
    }
    
    NSAttributedString *replaceStr = [[NSAttributedString alloc] initWithString:_newStr attributes:attDic];
    [_locationStr replaceCharactersInRange:_newRange withAttributedString:replaceStr];
    self.textView.attributedText = _locationStr;
    
    //这里需要把光标的位置重新设定
    self.textView.selectedRange=NSMakeRange(_newRange.location+_newRange.length, 0);
}

#pragma mark - UITextView_Delegate
- (void)textViewDidChange:(UITextView *)textView{

    NSInteger len = textView.attributedText.length - _locationStr.length;
    
    //正在删除
    if (len < 0)
        _textIsDeleting = YES;
    else{
        _textIsDeleting = NO;
        _newRange = NSMakeRange(self.textView.selectedRange.location - len, len);
        _newStr = [textView.text substringWithRange:_newRange];
    }
    
    [self setStyle];
}

/**
 *  点击图片触发代理事件
 */
- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange
{

    return NO;
}

/**
 *  点击链接，触发代理事件
 */
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{

    return YES;
}

@end
