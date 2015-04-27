//
//  OpenglView.h
//  opengl
//
//  Created by iaccepted on 15/4/9.
//  Copyright (c) 2015年 iaccepted. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface OpenglView : UIView {
    CAEAGLLayer *_eaglLayer;
    EAGLContext *_context;
}

@property(nonatomic)GLuint normalProgram;
@property(nonatomic)GLuint depthProgram;
@end
