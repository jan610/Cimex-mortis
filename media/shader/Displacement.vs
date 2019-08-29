uniform sampler2D texture2;

attribute mediump vec2 uv;
attribute highp vec3 position;
attribute mediump vec3 normal;

varying mediump vec2 uvVarying;
varying highp vec3 posVarying;
varying mediump mat3 TBNVarying;
varying mediump vec3 lightVarying;

uniform mat4 agk_World;
uniform mat4 agk_ViewProj;
uniform mat3 agk_WorldNormal;
uniform vec2 agk_NormalScale;
uniform vec4 uvBounds0;
uniform float pulseFrequenzy;
uniform float pulseAmplitude;
uniform float agk_time;

mediump vec3 GetVSLighting( mediump vec3 normal, highp vec3 pos );

void main()
{
	uvVarying = uv * uvBounds0.xy + uvBounds0.zw;
	vec4 pos = agk_World * vec4(position,1);
	vec3 norm = normalize(agk_WorldNormal * normal);

	float mask = texture2DLod(texture2, uvVarying, 0.0).a;
	float offset = uvVarying.x * uvVarying.y + 0.5;
    const float TAU = 6.28318530718;
    float time = sin(agk_time / pulseFrequenzy * TAU) * 0.5 + 0.5;
	pos.xyz += norm * time * pulseAmplitude * offset * mask;
	
	posVarying = pos.xyz;
	gl_Position = agk_ViewProj * pos;
	normalVarying = norm;
	lightVarying = GetVSLighting( norm, posVarying );
	
	mediump vec3 tangent;
	if ( abs(normal.y) > 0.999 ) tangent = vec3( normal.y,0.0,0.0 );
	else tangent = normalize( vec3(-normal.z, 0.0, normal.x) );
    mediump vec3 norm = normalize(agk_WorldNormal * normal);
    mediump vec3 tang = normalize(agk_WorldNormal * tangent);
    mediump vec3 bino = normalize(cross(tang, norm));
	TBNVarying = mat3( tang, bino, norm );
}