//
//  ViewController.h
//  MultithreadingFoundation
//
//  Created by 纵昂 on 2021/6/8.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

/*
 那么是不是线程越多越好呢？
 并不是线程越多越好，同一时间CPU只能处理一条线程，CPU要完成多线程操作是在快速的切换不同的线程执行任务，只要足够快，就给人同时执行的假象，但是如果线程非常多，每条线程被调度的频率就会降低，效率反而低下，可能因此造成卡顿。
 
 */
@end

