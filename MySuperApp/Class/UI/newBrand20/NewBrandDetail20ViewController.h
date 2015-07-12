//
//  NewBrandDetail20ViewController.h
//  MyAimerApp
//
//  Created by yanglee on 15/4/24.
//  Copyright (c) 2015年 aimer. All rights reserved.
//

#import "LBaseViewController.h"
#import "NewSortInfo.h"
#import "NewSortParser.h"

#import "SGFocusImageFrame.h"
#import "SGFocusImageItem.h"

@interface NewBrandDetail20ViewController : LBaseViewController<UIScrollViewDelegate,ServiceDelegate,SGFocusImageFrameDelegate>


@property (weak, nonatomic) IBOutlet UIView *chaoliuxinpV1;
@property (weak, nonatomic) IBOutlet UIView *chanpinmuluV2;

@property(nonatomic,retain)NSString *brandname;

@end
