float luminance(float3 sourceColor)
{
    return 0.299 * sourceColor.r + 0.587 * sourceColor.g + 0.114 * sourceColor.b;
}
       
float3 karisAverage(float3 sourceColorA, float3 sourceColorB, float3 sourceColorC, float3 sourceColorD)
{
    float A = 1.0 / (1.0 + luminance(sourceColorA));
    float B = 1.0 / (1.0 + luminance(sourceColorB));
    float C = 1.0 / (1.0 + luminance(sourceColorC));
    float D = 1.0 / (1.0 + luminance(sourceColorD));
      	
    return (sourceColorA * A + sourceColorB * B + sourceColorC * C + sourceColorD * D) / (A + B + C + D);
}
    
float3 average(float3 sourceColorA, float3 sourceColorB, float3 sourceColorC, float3 sourceColorD)
{
    return (sourceColorA + sourceColorB + sourceColorC + sourceColorD) * 0.25;
}

