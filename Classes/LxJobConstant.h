//
//  LxJobConstant.h
//  iOSPriorityJobQueue
//
//  Created by lixin on 10/28/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#ifndef iOSPriorityJobQueue_LxJobConstant_h
#define iOSPriorityJobQueue_LxJobConstant_h


#define dispatch_on_main_block(A) if ([NSThread isMainThread]) {\
    A();\
} else {\
    dispatch_async(dispatch_get_main_queue(), A);\
}

#endif
