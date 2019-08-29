attribute highp vec2 uv;
attribute highp vec3 position;
attribute mediump vec3 normal;

varying highp vec2 uvVarying;
varying highp vec3 posVarying;
varying mediump mat3 TBNVarying;
varying mediump vec3 lightVarying;

mediump vec3 GetVSLighting( mediump vec3 normal, highp vec3 pos );

uniform highp mat3 agk_WorldNormal;
uniform highp mat4 agk_World;
uniform highp mat4 agk_ViewProj;
uniform highp vec4 uvBounds0;

void main()
{
    uvVarying = uv * uvBounds0.xy + uvBounds0.zw;
    highp vec4 pos = agk_World * vec4(position,1.0);
    gl_Position = agk_ViewProj * pos;
	mediump vec3 tangent;
	if ( abs(normal.y) > 0.999 ) tangent = vec3( normal.y,0.0,0.0 );
	else tangent = normalize( vec3(-normal.z, 0.0, normal.x) );
    mediump vec3 norm = normalize(agk_WorldNormal * normal);
    mediump vec3 tang = normalize(agk_WorldNormal * tangent);
    mediump vec3 bino = normalize(cross(tang, norm));
	TBNVarying = mat3( tang, bino, norm );
    posVarying = pos.xyz;
	lightVarying = GetVSLighting( norm, posVarying );
}