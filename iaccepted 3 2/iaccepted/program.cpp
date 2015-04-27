//
//  Program.cpp
//  opengl
//
//  Created by iaccepted on 15/4/10.
//  Copyright (c) 2015年 iaccepted. All rights reserved.
//

#include "program.h"
#include "rshader.h"
#include <iostream>

using namespace std;

Program::Program()
{
}


void Program::initProgram(const char *vpath, const char *fpath)
{
    
    const char *vsource = readShader(vpath);
    vshader = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vshader, 1, &vsource, NULL);
    delete[] vsource;
    glCompileShader(vshader);
    
    GLint status;
    GLchar info[512];
    glGetShaderiv(vshader, GL_COMPILE_STATUS, &status);
    if ( !status)
    {
        glGetShaderInfoLog(vshader, sizeof(info), NULL, info);
        cerr << "Failed to compile vertex shader : " << info << endl;
        exit(-1);
    }
    
    const char *fsource = readShader(fpath);
    fshader = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fshader, 1, &fsource, NULL);
    delete[] fsource;
    glCompileShader(fshader);
    
    glGetShaderiv(fshader, GL_COMPILE_STATUS, &status);
    if(!status)
    {
        glGetShaderInfoLog(fshader, sizeof(info), NULL, info);
        cerr << "Failed to compile fragment shader : " << info << endl;
        exit(-1);
    }
    
    program = glCreateProgram();
    glAttachShader(program, vshader);
    glAttachShader(program, fshader);
    glBindAttribLocation(program, 0, "vposition");
    glBindAttribLocation(program, 1, "vnormal");
    glBindAttribLocation(program, 2, "textcoord");
    glLinkProgram(program);
    
    glGetProgramiv(program, GL_LINK_STATUS, &status);
    if(!status)
    {
        glGetProgramInfoLog(program, sizeof(info), NULL, info);
        cerr << "Failed to link program : " << info << endl;
        exit(-1);
    }
}

GLuint Program::getProgram() {
    return  program;
}
