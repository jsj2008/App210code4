//
//  NewMaginzeAViewController
//  MyAimerApp
//
//  Created by yanglee on 15/4/11.
//  Copyright (c) 2015年 aimer. All rights reserved.
//

#import "LBaseViewController.h"


//A表示竖版 ，B表示横版 

@interface NewMaginzeAViewController : LBaseViewController<UITableViewDataSource,UITableViewDelegate,ServiceDelegate>

@property(nonatomic,retain)NSString *strMaginzeId;
@property(nonatomic,retain)NSString *strname;


@property(nonatomic,assign)BOOL isFromHomePageAndShowSepBtn;  //是否来自首页，如果首页，就显示切换按钮。 如果不是就不显示


@end
