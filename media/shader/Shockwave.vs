attribute highp vec3 position;
attribute mediump vec3 normal;
attribute mediump vec2 uv;
 
varying highp vec3 posVarying;
varying mediump vec2 uvVarying;
 
uniform highp mat3 agk_WorldNormal;
uniform highp mat4 agk_World;
uniform highp mat4 agk_ViewProj;
uniform mediump vec4 uvBounds0;
 
void main()
{ 
    uvVarying = uv * uvBounds0.xy + uvBounds0.zw;
    highp vec4 pos = agk_World * vec4(position,1.0);
    gl_Position = agk_ViewProj * pos;
    mediump vec3 norm = normalize(agk_WorldNormal * normal);
    posVarying = pos.xyz;
}
