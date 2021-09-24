/**************************************************************************************/
/* Variables comunes */
/**************************************************************************************/

//Matrices de transformacion
float4x4 matWorld; //Matriz de transformacion World
float4x4 matWorldView; //Matriz World * View
float4x4 matWorldViewProj; //Matriz World * View * Projection
float4x4 matInverseTransposeWorld; //Matriz Transpose(Invert(World))

float3 eyePosition;

struct Light
{
    float3 position;
    float3 color;
};

Light lights[2];

float screenWidth, screenHeight, timer = 0.0;

static const int kernelRadius = 5;
static const int kernelSize = 25;
static const float kernel[kernelSize] =
{
    0.003765, 0.015019, 0.023792, 0.015019, 0.003765,
    0.015019, 0.059912, 0.094907, 0.059912, 0.015019,
    0.023792, 0.094907, 0.150342, 0.094907, 0.023792,
    0.015019, 0.059912, 0.094907, 0.059912, 0.015019,
    0.003765, 0.015019, 0.023792, 0.015019, 0.003765,
};


//Textura para DiffuseMap
texture texDiffuseMap;
sampler2D diffuseMap = sampler_state
{
    Texture = (texDiffuseMap);
    ADDRESSU = WRAP;
    ADDRESSV = WRAP;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = LINEAR;
};

//Textura para full screen quad
texture renderTarget;
sampler2D renderTargetSampler = sampler_state
{
    Texture = (renderTarget);
    ADDRESSU = WRAP;
    ADDRESSV = WRAP;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = LINEAR;
};










//Input del Vertex Shader
struct VS_INPUT_DEFAULT
{
    float4 Position : POSITION0;
    float3 Normal : NORMAL0;
    float2 TextureCoordinates : TEXCOORD0;
};

//Output del Vertex Shader
struct VS_OUTPUT_DEFAULT
{
    float4 Position : POSITION0;
    float3 Normal : NORMAL0;
    float2 TextureCoordinates : TEXCOORD0;
};

//Vertex Shader
VS_OUTPUT_DEFAULT VSDefault(VS_INPUT_DEFAULT input)
{
    VS_OUTPUT_DEFAULT output;

	// Enviamos la posicion transformada
    output.Position = mul(input.Position, matWorldViewProj);
    
    // Propagar las normales por la matriz normal
    output.Normal = mul(input.Normal, matInverseTransposeWorld);
    
	// Propagar coordenadas de textura
    output.TextureCoordinates = input.TextureCoordinates;

    return output;
}

//Pixel Shader
float4 PSDefault(VS_OUTPUT_DEFAULT input) : COLOR0
{
    return tex2D(diffuseMap, input.TextureCoordinates);
}

//Input del Vertex Shader
struct VS_INPUT_ROBOT
{
    float4 Position : POSITION0;
    float2 TextureCoordinates : TEXCOORD0;
};

//Output del Vertex Shader
struct VS_OUTPUT_ROBOT
{
    float4 Position : POSITION0;
    float2 TextureCoordinates : TEXCOORD0;
    float4 MeshPosition : TEXCOORD1;
};

// ejercicio 3: shaders
//Vertex Shader
VS_OUTPUT_ROBOT VSRobot(VS_INPUT_ROBOT input)
{
    VS_OUTPUT_ROBOT output;

	// Enviamos la posicion transformada
    output.Position = mul(input.Position, matWorldViewProj);
    
    output.MeshPosition = input.Position;
    
	// Propagar coordenadas de textura
    output.TextureCoordinates = input.TextureCoordinates;

    return output;
}

//Pixel Shader
float4 PSRobot(VS_OUTPUT_ROBOT input) : COLOR0
{
    float4 color = tex2D(diffuseMap, input.TextureCoordinates);
    return color;
}





//Input del Vertex Shader
struct VS_INPUT_POSTPROCESS
{
    float4 Position : POSITION0;
    float2 TextureCoordinates : TEXCOORD0;
};

//Output del Vertex Shader
struct VS_OUTPUT_POSTPROCESS
{
    float4 Position : POSITION0;
    float2 TextureCoordinates : TEXCOORD0;
};

//Vertex Shader
VS_OUTPUT_POSTPROCESS VSPostProcess(VS_INPUT_POSTPROCESS input)
{
    VS_OUTPUT_POSTPROCESS output;

	// Propagamos la posicion, ya que esta en espacio de pantalla
    output.Position = input.Position;

	// Propagar coordenadas de textura
    output.TextureCoordinates = input.TextureCoordinates;

    return output;
}
// ejercicio 4: post procesado
//Pixel Shader
float4 PSPostProcess(VS_OUTPUT_DEFAULT input) : COLOR0
{
    float4 color = tex2D(renderTargetSampler, input.TextureCoordinates);
    return color;
}






technique Default
{
    pass Pass_0
    {
        VertexShader = compile vs_3_0 VSDefault();
        PixelShader = compile ps_3_0 PSDefault();
    }
}

technique Robot
{
    pass Pass_0
    {
        VertexShader = compile vs_3_0 VSRobot();
        PixelShader = compile ps_3_0 PSRobot();
    }
}

technique PostProcess
{
    pass Pass_0
    {
        VertexShader = compile vs_3_0 VSPostProcess();
        PixelShader = compile ps_3_0 PSPostProcess();
    }
}