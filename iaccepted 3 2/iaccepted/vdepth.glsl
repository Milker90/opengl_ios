attribute highp vec3 vposition;
attribute vec3 vnormal;
attribute vec2 textcoord;

uniform highp mat4 MVP;

void main()
{
    gl_Position = MVP * vec4(vposition, 1.0);
}