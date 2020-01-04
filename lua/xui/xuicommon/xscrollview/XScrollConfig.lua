XScrollConfig = XScrollConfig or {}

XScrollConfig.HORIZONTAL = 0
XScrollConfig.VERTICAL = 1

-- 位置曲线关键帧
XScrollConfig.POSITION_KEY_FRAMES = {
    {time = 0, value = 0, tangentMode = 34, inTangent = 0, outTangent = 0},
    {time = 0.1, value = 0, tangentMode = 34, inTangent = 0.625, outTangent = 0.625},
    {time = 0.5, value = 0.5, tangentMode = 34, inTangent = 1.25, outTangent = 1.25},
    {time = 0.9, value = 1, tangentMode = 34, inTangent = 0.625, outTangent = 0.625},
    {time = 1, value = 1, tangentMode = 34, inTangent = 0, outTangent = 0},
}

XScrollConfig.SCALE_KEY_FRAMES = {
    {time = 0, value = 0, tangentMode = 34, inTangent = 1.8, outTangent = 1.8},
    {time = 0.5, value = 1, tangentMode = 34, inTangent = 0, outTangent = 0},
    {time = 1, value = 0, tangentMode = 34, inTangent = -1.8, outTangent = -1.8},
}

XScrollConfig.ALPHA_KEY_FRAMES = {
    {time = 0, value = 0, tangentMode = 0, inTangent = 0, outTangent = 0},
    {time = 0.1, value = 0.3, tangentMode = 0, inTangent = 2.536, outTangent = 2.536},
    {time = 0.3, value = 0.6, tangentMode = 0, inTangent = 2.877, outTangent = 2.877},
    {time = 0.5, value = 1, tangentMode = 0, inTangent = 0.104, outTangent = 0.104},
    {time = 0.7, value = 0.6, tangentMode = 0, inTangent = -3.06, outTangent = -3.06},
    {time = 0.9, value = 0.3, tangentMode = 0, inTangent = -2.547, outTangent = -2.547},
    {time = 1, value = 0, tangentMode = 0, inTangent = 0, outTangent = 0},
}