attribute highp vec2 uv;
attribute highp vec3 position;
attribute mediump vec3 normal;

varying highp vec2 uvVarying;
varying highp vec3 posVarying;
varying mediump mat3 TBNVarying;
varying mediump vec3 lightVarying;

mediump vec3 GetVSLighting( mediump vec3 normal, highp vec3 pos );

uniform highp mat4 agk_ViewProj;
uniform highp mat3 agk_WorldNormal;
uniform highp vec4 uvBounds0;

attribute highp vec4 boneweights;
attribute mediump vec4 boneindices;
uniform highp vec4 agk_bonequats1[30];
uniform highp vec4 agk_bonequats2[30];

highp vec3 transformDQ( highp vec3 p, highp vec4 q1, highp vec4 q2 )
{
    p += 2.0 * cross( q1.xyz, cross(q1.xyz, p) + q1.w*p );
    p += 2.0 * (q1.w*q2.xyz - q2.w*q1.xyz + cross(q1.xyz,q2.xyz));
    return p;
}

void main()
{ 
    highp vec4 q1 = agk_bonequats1[ int(boneindices.x) ] * boneweights.x;
    q1 += agk_bonequats1[ int(boneindices.y) ] * boneweights.y;
    q1 += agk_bonequats1[ int(boneindices.z) ] * boneweights.z;
    q1 += agk_bonequats1[ int(boneindices.w) ] * boneweights.w;
    highp vec4 q2 = agk_bonequats2[ int(boneindices.x) ] * boneweights.x;
    q2 += agk_bonequats2[ int(boneindices.y) ] * boneweights.y;
    q2 += agk_bonequats2[ int(boneindices.z) ] * boneweights.z;
    q2 += agk_bonequats2[ int(boneindices.w) ] * boneweights.w;
    highp float len = 1.0/length(q1);
    q1 *= len;
    q2 = (q2 - q1*dot(q1,q2)) * len;
    vec4 pos = vec4( transformDQ(position,q1,q2), 1.0 );
	
    uvVarying = uv * uvBounds0.xy + uvBounds0.zw;
	posVarying = pos.xyz;
	gl_Position = agk_ViewProj * pos;
    mediump vec3 tangent;
    if ( abs(normal.y) > 0.999 ) tangent = vec3( normal.y,0.0,0.0 );
    else tangent = normalize( vec3(-normal.z, 0.0, normal.x) );
    mediump vec3 norm = normal + 2.0*cross( q1.xyz, cross(q1.xyz,normal) + q1.w*normal );
    mediump vec3 tang = tangent + 2.0*cross( q1.xyz, cross(q1.xyz,tangent) + q1.w*tangent );
    mediump vec3 bino = normalize(cross(tang, norm));
	TBNVarying = mat3( tang, bino, norm );
    lightVarying = GetVSLighting( norm, posVarying );
}