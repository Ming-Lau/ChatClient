//
//  ViewController.m
//  群聊客户端
//
//  Created by 刘明 on 16/8/1.
//  Copyright © 2016年 LM. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncSocket.h"

@interface ViewController ()<GCDAsyncSocketDelegate,UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)GCDAsyncSocket * clientSocket;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UITextField *text;
@property (nonatomic,strong)NSMutableArray * textArray;
- (IBAction)btnClick:(id)sender;

@end

@implementation ViewController
-(NSMutableArray *)textArray
{
    if (_textArray == nil) {
        _textArray = [NSMutableArray array];
    }
    return _textArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    GCDAsyncSocket * clientSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    self.clientSocket = clientSocket;
    NSError * error = nil;
    [clientSocket connectToHost:@"172.16.12.216" onPort:5200 error:&error];
    
}
-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"与服务器链接成功");
    [sock readDataWithTimeout:-1 tag:0];
}
-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"与服务器断开链接");
}
#pragma mark 接收消息
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString* str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",str);
    if (str) {
        [self.textArray addObject:str];
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
           [self.table reloadData];
        }];
        
    }

    [sock readDataWithTimeout:-1 tag:0];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.textArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* ident = @"cell";
    UITableViewCell * cell =[tableView dequeueReusableCellWithIdentifier:ident];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident];
    }
    if (self.textArray.count != 0) {
       cell.textLabel.text = self.textArray[indexPath.row];
    }
    cell.backgroundColor = [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1];
    return cell;
}
- (IBAction)btnClick:(id)sender {
    NSString * tempStr = self.text.text;
    if (tempStr.length == 0) {
        return;
    }
    NSString * str = [NSString stringWithFormat:@"%@\n",tempStr];
    [self.clientSocket writeData:[str dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    [self.textArray addObject:str];
    self.text.text = @"";
    [self.table reloadData];
}

@end
