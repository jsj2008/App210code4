//
//  MyCloset7ViewController.m
//  MyAimerApp
//
//  Created by yanglee on 15/6/17.
//  Copyright (c) 2015年 aimer. All rights reserved.
//

#import "MyCloset7ViewController.h"
#import "MyButton.h"
#import "ZHPickView.h"

@interface MyCloset7ViewController ()<ZHPickViewDelegate,ServiceDelegate>
{
    IBOutlet UIScrollView *myScrollV;
    MainpageServ *mainSev;
    MybespeakInfo *bespeakInfo;
    
    MyButton *btn1;
    MyButton *btn2;
    NSMutableArray *arrstoreid;

    NSString *selectStore;
    NSString *selecttime;

}



@end

@implementation MyCloset7ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"预约测体"];
    [self createBackBtnWithType:0];
    
    selectStore = @"";
    selecttime = @"";
    arrstoreid = [[NSMutableArray alloc] initWithCapacity:0];
    
    mainSev = [[MainpageServ alloc] init];
    mainSev.delegate = self;
    [mainSev getbespeak];
    [SBPublicAlert showMBProgressHUD:@"正在请求···" andWhereView:self.view states:NO];

    
    [myScrollV addSubview:[self createCellView:@[@"门店",@"时间"]]];
}


-(UIView *)createCellView:(NSArray*)subSortArray{
    
    NSInteger bgvH = 80;
//    NSInteger lineNum = 1; //每行的数量
    
    NSInteger ySP = 22;  //距离顶部的位置
    NSInteger SP = 30;  //间距
    NSInteger pW = (ScreenWidth-60);  //商品宽度
    NSInteger pH = 40;  //商品高度
    
    //行数
    NSInteger subSortbtnNum = [subSortArray count];//([subSortArray count]%lineNum == 0? [subSortArray count]/lineNum :[subSortArray count]/lineNum+1);
    
    UIView *bgv = [[UIView alloc] initWithFrame:CGRectMake(0, bgvH, ScreenWidth, subSortbtnNum*100)];
    [bgv setBackgroundColor:[UIColor clearColor]];
    
    
    
    btn1 = [MyButton buttonWithType:UIButtonTypeCustom];
    [btn1 setFrame:CGRectMake(SP , ySP, pW, pH)];
    [btn1 addTarget:self action:@selector(typeAction:) forControlEvents:UIControlEventTouchUpInside];
    [btn1 setTitleColor:[UIColor colorWithHexString:@"#888888"] forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor colorWithHexString:@"#c8002c"] forState:UIControlStateSelected];
    btn1.tag = 1;
    [btn1 setBackgroundImage:[UIImage imageNamed:@"sryc_laber_class_big_normal.png"] forState:UIControlStateNormal];
    [btn1 setBackgroundImage:[UIImage imageNamed:@"sryc_laber_class_big_select.png"] forState:UIControlStateSelected];
    [btn1 setBackgroundColor:[UIColor clearColor]];
    [btn1 setTitle:@"门店" forState:UIControlStateNormal];
    [bgv addSubview:btn1];
    
    
    btn2 = [MyButton buttonWithType:UIButtonTypeCustom];
    [btn2 setFrame:CGRectMake(SP , ySP + 1*(pH + ySP), pW, pH)];
    [btn2 addTarget:self action:@selector(typeAction:) forControlEvents:UIControlEventTouchUpInside];
    [btn2 setTitleColor:[UIColor colorWithHexString:@"#888888"] forState:UIControlStateNormal];
    [btn2 setTitleColor:[UIColor colorWithHexString:@"#c8002c"] forState:UIControlStateSelected];
    btn2.tag = 2;
    [btn2 setBackgroundImage:[UIImage imageNamed:@"sryc_laber_class_big_normal.png"] forState:UIControlStateNormal];
    [btn2 setBackgroundImage:[UIImage imageNamed:@"sryc_laber_class_big_select.png"] forState:UIControlStateSelected];
    [btn2 setBackgroundColor:[UIColor clearColor]];
    [btn2 setTitle:@"时间" forState:UIControlStateNormal];
    [bgv addSubview:btn2];
    
    
    NSInteger H = 2*ySP + (pH +ySP)* subSortbtnNum;
    
    UIButton *nextbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextbtn setFrame:CGRectMake(30,H,ScreenWidth-60,40)];
    [nextbtn addTarget:self action:@selector(nextBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [nextbtn setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
    [nextbtn setBackgroundImage:[UIImage imageNamed:@"big_btn_r_normal.png"] forState:UIControlStateNormal];
    [nextbtn setBackgroundImage:[UIImage imageNamed:@"big_btn_r_hover.png"] forState:UIControlStateHighlighted];
    
    [nextbtn setBackgroundColor:[UIColor clearColor]];
    [nextbtn setTitle:@"申请预约" forState:UIControlStateNormal];
    [bgv addSubview:nextbtn];
    
    H += 60;
    
    [bgv setFrame:CGRectMake(0, bgvH, ScreenWidth, H)];
    
    [myScrollV setContentSize:CGSizeMake(0, H+100)];
    
    return bgv;
}


-(void)typeAction:(id)sender{

    MyButton*btn = (MyButton*)sender;
    
    if (btn.tag == 1) {
        //支持自定义数组：
        NSMutableArray *arr = [[NSMutableArray alloc]initWithCapacity:0];
        for (MybespeakData *dara in bespeakInfo.stores) {
            [arr addObject:dara.name];
            [arrstoreid addObject:dara.aid];
        }
        
        btn1.selected = YES;
        
        NSArray *array= @[arr];
        ZHPickView* _pickview=[[ZHPickView alloc] initPickviewWithArray:array isHaveNavControler:NO];
        _pickview.delegate = self;
        _pickview.tag = btn.tag;
        [_pickview show];
    }
    else if (btn.tag == 2) {
        //支持自定义数组：
        
        //创建时间格式化实例对象
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        //设置时间格式
        [dateFormatter setDateFormat:@"yyyy年MM月dd日 HH:mm"];
        
        //将时间字符串转换成NSDate类型的时间。dateFromString方法。
        NSDate *tempDate = [NSDate date];
        ZHPickView *_pickview=[[ZHPickView alloc] initDatePickWithDate:tempDate datePickerMode:UIDatePickerModeDate isHaveNavControler:NO];
        _pickview.delegate = self;
        _pickview.tag = btn.tag;
        [_pickview show];
        
        btn2.selected = YES;
    }
}

-(void)toobarDonBtnHaveClick:(ZHPickView *)pickView resultString:(NSString *)resultString{
 
    if (pickView.tag == 1) {
        [btn1 setTitle:[NSString stringWithFormat:@"门店：%@",resultString] forState:UIControlStateNormal];
    }
    if (pickView.tag == 2) {
        selecttime = resultString;
        [btn2 setTitle:[NSString stringWithFormat:@"时间：%@",resultString] forState:UIControlStateNormal];
    }
    
}

-(void)toobarDonBtnHave:(ZHPickView *)pickView andIndex:(NSInteger)index{

    if (pickView.tag == 1) {
        selectStore = [arrstoreid objectAtIndex:index];
        NSLog(@"---%@",selectStore);
    }
}



-(void)nextBtnAction:(id)sener
{
    if ([selectStore isEqualToString:@""]) {
        
        [SBPublicAlert showMBProgressHUD:@"请您选择预约门店" andWhereView:self.view hiddenTime:AlertShowTime];
        return;
    }
    
    if ([selecttime isEqualToString:@""]) {
        [SBPublicAlert showMBProgressHUD:@"请您选择预约时间" andWhereView:self.view hiddenTime:AlertShowTime];
        return;
    }
    
    
    NSString *userid = [[NSUserDefaults standardUserDefaults] objectForKey:@"usersession"];
    
    [mainSev bespeakup:selectStore andTime:selecttime anduid:userid];
    [SBPublicAlert showMBProgressHUD:@"正在请求···" andWhereView:self.view states:NO];
    
}


#pragma mark--- Severvice
-(void)serviceStarted:(ServiceType)aHandle{
}

-(void)serviceFailed:(ServiceType)aHandle{
    [SBPublicAlert hideMBprogressHUD:self.view];
    
}

-(void)serviceFinished:(ServiceType)aHandle withmodel:(id)amodel{
    [SBPublicAlert hideMBprogressHUD:self.view];
    
    if(![amodel isKindOfClass:[LBaseModel class]])
    {
        switch ((NSUInteger)aHandle) {
            case Http_bespeak20_Tag:
            {
                bespeakInfo = [[[MybespeakParser alloc] init] parsebespeakInfo:amodel];
                
            }
                break;
                
            case Http_bespeakup20_Tag:
            {
                [MYCommentAlertView showMessage:@"恭喜您预约成功" target:nil];
            }
            default:
                break;
        }
    }
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
