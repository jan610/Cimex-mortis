attribute highp vec3 position;
attribute mediump vec3 normal;
attribute mediump vec2 uv;

varying highp vec3 posVarying;
varying mediump vec3 normalVarying;
varying mediump vec2 uvVarying;
varying mediump vec3 lightVarying;

uniform highp mat3 agk_WorldNormal;
uniform highp mat4 agk_World;
uniform highp mat4 agk_ViewProj;
uniform mediump vec4 uvBounds0;
uniform vec3 agk_CameraPos;

uniform vec3 start;
uniform vec3 end;
uniform float thickness;

mediump vec3 GetVSLighting( mediump vec3 normal, highp vec3 pos );

void main()
{
    uvVarying = uv * uvBounds0.xy + uvBounds0.zw;
	vec4 pos = vec4(mix(start,end, step(0.5,uv.x)), 1.0);
	pos.xyz += cross(normalize(agk_CameraPos-pos.xyz), normalize(end-start)) * thickness * uv.y;
	gl_Position = agk_ViewProj * pos;
	mediump vec3 norm = normalize(agk_WorldNormal * normal);
	posVarying = pos.xyz;
    normalVarying = norm;
    lightVarying = GetVSLighting( norm, posVarying );
}