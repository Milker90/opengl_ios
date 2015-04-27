//
//  Program.h
//  opengl
//
//  Created by iaccepted on 15/4/10.
//  Copyright (c) 2015年 iaccepted. All rights reserved.
//

#ifndef __opengl__Program__
#define __opengl__Program__

#import <OpenGLES/ES2/gl.h>

class Program
{
private:
    GLuint program;
    GLuint vshader;
    GLuint fshader;
    
public:
    Program();
    void initProgram(const char *, const char *);
    GLuint getProgram();
};

#endif /* defined(__opengl__Program__) */
