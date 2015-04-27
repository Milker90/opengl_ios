//
//  OpenglView.m
//  opengl
//
//  Created by iaccepted on 15/4/9.
//  Copyright (c) 2015年 iaccepted. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "OpenglView.h"
#import <glm/glm.hpp>
#import <glm/gtc/matrix_transform.hpp>
#import <glm/gtc/type_ptr.hpp>
#import <assimp/scene.h>
#import <assimp/Importer.hpp>
#import <assimp/postprocess.h>
#import <iostream>

using namespace std;

#import "program.h"
#include "camera.h"
#include "assimpModel.h"


@interface OpenglView() {
    Camera camera;
    //objModel objmodel;
    Model assimpmodel;
}

@end

@implementation OpenglView

+ (Class) layerClass {
    return [CAEAGLLayer class];
}



- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        [self becomeFirstResponder];
        [self setupLayer];
        [self setupContext];
        [self setupNormalFrambuffer];
        [self setupData];
        [self initNormalProgram];
        [self initDepthProgram];
        [self setupDisplayLink];
    }
    return self;
}

- (void)setupLayer {
    _eaglLayer = (CAEAGLLayer *)self.layer;
    _eaglLayer.opaque = YES;
}

- (void)setupContext {
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if (!_context) {
        NSLog(@"Failed to initialize Opengl ES 2.0 context");
        exit(-1);
    }
    
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"Failed to set current Opengl context");
        exit(-1);
    }
    glEnable(GL_DEPTH_TEST);
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
}

-(void)setupNormalFrambuffer
{
    GLuint _framebuffer, _colorRenderBuffer, _depthRenderBuffer;
    glGenFramebuffers(1, &_framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
    
    glGenRenderbuffers(1, &_depthRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, self.frame.size.width, self.frame.size.height);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderBuffer);
    
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
}

- (void)setupDisplayLink {
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

-(void)renderNormal
{
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    GLuint modelViewProjectionLocation, normalMatrixLocation;
    float aspect = self.frame.size.width / self.frame.size.height;
    
    modelViewProjectionLocation = glGetUniformLocation(_normalProgram, "modelViewProjection");
    normalMatrixLocation = glGetUniformLocation(_normalProgram, "normalMatrix");
    
    glm::mat4 model, view, projection, modelView, modelViewProjection, normalMatrix;
    
    model = glm::rotate(model, glm::radians(-90.0f),  glm::vec3(1.0f, 0.0f, 0.0f));
    model = glm::translate(model, glm::vec3(0.0f, 0.0f, -0.75f));
    model = glm::scale(model, glm::vec3(0.006f, 0.006f, 0.006f));
    view = camera.getView();
    projection = glm::perspective(glm::radians(45.0f), aspect, 0.1f, 100.0f);
    
    modelView = view * model;
    modelViewProjection = projection * modelView;
    normalMatrix = glm::transpose(glm::inverse(modelView));
    
    glUniformMatrix4fv(normalMatrixLocation, 1, GL_FALSE, glm::value_ptr(normalMatrix));
    glUniformMatrix4fv(modelViewProjectionLocation, 1, GL_FALSE, glm::value_ptr(modelViewProjection));
    
    assimpmodel.draw(_normalProgram);
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

-(void)renderDepth
{
    
}

- (void)render
{
    glUseProgram(_normalProgram);
    [self setLight];
    [self renderNormal];
}

-(void)initNormalProgram
{
    const char *vpath = [self getPath:@"vshader" :@"glsl"];
    const char *fpath = [self getPath:@"fshader" :@"glsl"];
    
    Program program;
    program.initProgram(vpath, fpath);
    _normalProgram = program.getProgram();

}

-(void)initDepthProgram
{
    const char *vpath = [self getPath:@"vdepth" :@"glsl"];
    const char *fpath = [self getPath:@"fdepth" :@"glsl"];
    
    Program program;
    program.initProgram(vpath, fpath);
    _depthProgram = program.getProgram();
}

- (void)setupData {
    const char *path = [self getPath:@"box/newest" : @"obj"];
    assimpmodel.loadModel(path);
    assimpmodel.bindVertexData();
    assimpmodel.bindTexturesData();
}

- (const char *)getPath:(NSString *)filename :(NSString *)type {
    NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:type];
    const char *pathString = [path UTF8String];
    return pathString;
}

- (void)setLight {
    
    GLuint lightColor, lightDirection;
    lightColor = glGetUniformLocation(_normalProgram, "light.color");
    lightDirection = glGetUniformLocation(_normalProgram, "light.direction");
    
    glUniform3f(lightColor, 1.0, 1.0, 1.0);
    glUniform3f(lightDirection, 1.0f, 1.0f, 1.0f);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint current = [touch locationInView:self];
    CGPoint previous = [touch previousLocationInView:self];
    
    float diffx = current.x - previous.x;
    float diffy = current.y - previous.y;
    
    if(diffx > 0.0f) {
        camera.progressKeyBoard(RIGHT);
    } else {
        camera.progressKeyBoard(LEFT);
    }
    
    if(diffy > 0.0f) {
        camera.progressKeyBoard(BACK);
    } else {
        camera.progressKeyBoard(FRONT);
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void) motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        camera = Camera();
    }
}

- (void)dealloc {
}
@end
