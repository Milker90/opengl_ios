//
//  rshader.cpp
//  opengl
//
//  Created by iaccepted on 15/4/10.
//  Copyright (c) 2015年 iaccepted. All rights reserved.
//
#include "rshader.h"
#include <iostream>

using namespace std;

const char *readShader(const char *path)
{
    FILE *file = fopen(path, "rb");
    if (!file) {
        cerr << "Failed to open file : " << path << "!" << endl;
        exit(-1);
    }
    
    fseek(file, 0, SEEK_END);
    unsigned long size = ftell(file);
    fseek(file, 0, SEEK_SET);
    
    char *buffer = new char[size + 1];
    fread(buffer, 1, size, file);
    fclose(file);
    buffer[size] = '\0';
    return const_cast<const char *> (buffer);
}

