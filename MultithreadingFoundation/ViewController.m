//
//  ViewController.m
//  MultithreadingFoundation
//
//  Created by 纵昂 on 2021/6/8.
//  浅谈系列-多线程基础

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
/*
 一、概念
 1、进程：进程是指系统中正在运行的一个应用程序,每个进程都是相对独立的运行在各自受保护的内存空间内。
 2、线程：一个进程要执行任务至少要有一条线程,进程的任务都在线程中执行.(单条线程是串行执行任务的,同一时间段,一条线程只能执行一个任务
一个程序可以对应多个进程,一个进程也可以对应多条线程)
 3、多线程：在一个进程内，同时开启多条线程，这样就可以在同一时间在不同的线程执行不同的任务，相当于并行执行任务，这就是多线程。
 A、那么是不是线程越多越好呢？
 并不是线程越多越好，同一时间CPU只能处理一条线程，CPU要完成多线程操作是在快速的切换不同的线程执行任务，只要足够快，就给人同时执行的假象，但是如果线程非常多，每条线程被调度的频率就会降低，效率反而低下，可能因此造成卡顿。
 B、回到iOS程序，程序开始运行会默认开启一条线程，就是主线程，也称UI线程。
 主线程主要是管理界面显示，刷新UI，处理各种UI事件,因此,不要把耗时耗性能操作方法到主线程,保持界面流畅,耗时操作可以开启子线程来做,做完了再回到主线程刷新UI
 
 */
    
#pragma mark - NSThreas简单使用
//    获取当前线程
    NSThread * current = [NSThread currentThread];
//    开启一条子线程(block)
    NSThread * threadBlock = [[NSThread alloc]initWithBlock:^{
        NSLog(@"1子线程开始工作");
//        子线程工作
        NSLog(@"1子线程结束工作");
//      block调用完之后，线程就算没有被释放，也不能再使用，相当于废弃了
    }];
//    启动
    [threadBlock start];
    
//    开启一条子线程(target)
    NSThread *threadTarget = [[NSThread alloc] initWithTarget:self selector:@selector(doSomeThing) object:nil];
//    启动
    [threadTarget start];
    
    
#pragma mark - GCD
/*
 GCD相关术语
 同步(sync)，异步(async) ：主要影响能不能开启新的线程
 1、同步：在当前线程执行任务，不开新线程
 2、异步：在新线程执行任务，可以开新线程
 如果是在主队列中执行任务，异步也不会开启新线程，而是在主线程执行任务
 并发,串行：执行任务的方式
 1、并发：多任务同时执行
 2、串行：一个一个任务按顺序执行
 总结：同步函数任何情况下都不会开启子线程；异步函数无论是在并发队列，串行队列都可以开启子线程(除了执行主队列任务不会开启子线程)
 
 队列
 //主队列
 dispatch_queue_t queue = dispatch_get_main_queue();
 //串行队列
 dispatch_queue_t queue1 = dispatch_queue_create("myqueue-SERIAL", DISPATCH_QUEUE_SERIAL);
 //并发队列
 dispatch_queue_t queue2 = dispatch_queue_create("myqueue-CONCURRENT", DISPATCH_QUEUE_CONCURRENT);
 //全局队列
 dispatch_queue_t queue3 = dispatch_get_global_queue(0, 0);

 
 */
  

//    主队列
    dispatch_queue_t queue = dispatch_get_main_queue(); //
//    同步函数
//    1. 在主线程调用同步(sync)函数，使用当前队列(主队列)，死锁
//    dispatch_sync(queue, ^{    //这种情况下会出现死锁
//        NSLog(@"同步函数执行任务2");
//        NSLog(@"同步函数执行任务4");
//    });
//    异步函数
    dispatch_async(queue, ^{  // 死锁 解决方法很简单，使用异步函数就行了
        NSLog(@"异步函数执行任务2");
        NSLog(@"异步函数执行任务4");
    });
    
/*
 死锁问题(什么情况下会产生死锁)
 使用同步(sync)函数，在当前串行队列添加任务，会产生死锁。
 dispatch_get_main_queue() 主队列也是串行队列
 因为主线程在主队列执行viewDidLoad任务，viewDidLoad执行完毕，主队列才会执行下一个任务，就是同步函数。
 而viewDidLoad任务内部却要求同步函数里的“任务2”完成了之后才能执行“任务3”，“任务3”完成了viewDidLoad才可以完成，这样viewDidLoad永远无法完成，形成了死锁
 解决方法很简单，使用异步函数就行了
 */
    
// 2. 在异步函数(async)嵌套一个同步(sync)函数，使用同一个串行队列，死锁
//    串行队列
    dispatch_queue_t queue1 = dispatch_queue_create("myqueue-SERIAL", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue1, ^{
        NSLog(@"执行任务2");
//        dispatch_sync(queue1, ^{
//            NSLog(@"执行任务4");
//        });
        NSLog(@"执行任务5");
    });
/*
 同一个串行队列里有两任务： 1. 异步函数 2. 同步函数。
 就是说异步函数执行完之后，同步函数才可以开始执行。
 而异步函数内部执行顺序： 任务2 ->同步函数->任务5
 要完成异步函数的执行，就必须执行同步函数，而在队列里异步函数不完成执行，同步函数也执行不了，互相矛盾，死锁
 解决方法，不要使用同一个串行队列就可以
 */
#pragma mark - 队列组
#pragma mark - 队列组的使用
//    以下例子是，异步在子线程中执行任务1和任务2，再回到主线程执行任务3
//    创建队列组
      dispatch_group_t group = dispatch_group_create();
    
//    创建并发队列
      dispatch_queue_t queue4 = dispatch_queue_create("myqueue1", DISPATCH_QUEUE_CONCURRENT);
       
    dispatch_group_async(group, queue4, ^{
        NSLog(@"任务1");
    });
    
    dispatch_group_async(group, queue4, ^{
        NSLog(@"任务2");
    });
    
//    dispatch_group_notify(group, dispatch_get_main_queue, ^{
//           NSLog(@"任务3");
//    });
    
//    从子线程回到主线程
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//         执行耗时的异步操作...
          dispatch_async(dispatch_get_main_queue(), ^{
//             回到主线程，执行UI刷新操作
            });
    });

/*
 栅栏函数
 dispatch_barrier_async(dispatch_queue_t queue, dispatch_block_t block);
 在前面的任务执行结束后它才执行，而且它后面的任务等它执行完成之后才会执行
 */

#pragma mark - NSOperation
#pragma mark - NSOperation是个抽象类，并不具备封装操作的能力，必须使用它的子类
/*
 系统提供了两个NSOperation的子类供开发者使用
 NSInvocationOperation
 NSBlockOperation
 */

//    创建
//    1.配合operation开启子线程
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(doSomeThing) object:nil];

//    [operation start];//直接使用start，不会开启子线程，就在当前线程执行任务

    NSOperationQueue *queueNS = [[NSOperationQueue alloc] init];
       
     [queueNS addOperation:operation];
       
//    2.单独使用Block开启子线程
       NSOperationQueue *nsqueue = [[NSOperationQueue alloc] init];
        
       [nsqueue addOperationWithBlock:^{
           NSLog(@"在子线程工作- %@",[NSThread currentThread]);
       }];
//     设置最大并发数
       [nsqueue setMaxConcurrentOperationCount:3];
//     取消，暂停
       [nsqueue cancelAllOperations];//取消
       [nsqueue setSuspended:YES];//暂停
    
//     也可以调用operation的取消
       [operation cancel];

    
    
    
    
    
    
    
    
    
    
    
    
    
    

    
}

- (void)doSomeThing{
    NSLog(@"2子线程开始工作");
//    子线程工作
    
    NSLog(@"2子线程结束工作");
//  此方法调用完之后，线程就算没有被释放，也不能再使用，相当于废弃了
}


@end
