XHardwareManager = XHardwareManager or {}

local XQualityManager = CS.XQualityManager.Instance


local XRenderQuality = {
    Lowest = 0,
    Low = 1,
    Middle = 2,
    High = 3,
    Highest = 4
}


--ios默认高档配置，其他需要指定的在这里写
local IOS_TABLE = 
{
   
    ["iPad11,1"] = XRenderQuality.Highest,
    ["iPad11,2"] = XRenderQuality.Highest,
    ["iPad11,3"] = XRenderQuality.Highest,
    ["iPad11,4"] = XRenderQuality.Highest,
    ["iPad8,1"] = XRenderQuality.Highest,
    ["iPad8,2"] = XRenderQuality.Highest,
    ["iPad8,3"] = XRenderQuality.Highest,
    ["iPad8,4"] = XRenderQuality.Highest,
    ["iPad8,5"] = XRenderQuality.Highest,
    ["iPad8,6"] = XRenderQuality.Highest,
    ["iPad8,7"] = XRenderQuality.Highest,
    ["iPad8,8"] = XRenderQuality.Highest,

    ["iPad7,1"] = XRenderQuality.Highest,
    ["iPad7,2"] = XRenderQuality.Highest,
    ["iPad7,3"] = XRenderQuality.Highest,
    ["iPad7,4"] = XRenderQuality.Highest,
    ["iPad7,5"] = XRenderQuality.Highest,
    ["iPad7,6"] = XRenderQuality.Highest,
    ["iPad7,7"] = XRenderQuality.Highest,

    ["iPad6,11"] = XRenderQuality.Highest,
    ["iPad6,12"] = XRenderQuality.Highest,

    ["iPad6,1"] = XRenderQuality.Highest,
    ["iPad6,2"] = XRenderQuality.Highest,
    ["iPad6,3"] = XRenderQuality.Highest,
    ["iPad6,4"] = XRenderQuality.Highest,
    ["iPad6,5"] = XRenderQuality.Highest,
    ["iPad6,6"] = XRenderQuality.Highest,
    ["iPad6,7"] = XRenderQuality.Highest,

    ["iPad5,1"] = XRenderQuality.Highest,
    ["iPad5,2"] = XRenderQuality.Highest,
    ["iPad5,3"] = XRenderQuality.Highest,
    ["iPad5,4"] = XRenderQuality.Highest,
    ["iPad5,5"] = XRenderQuality.Highest,

    ["iPad4,1"] = XRenderQuality.Highest,
    ["iPad4,2"] = XRenderQuality.Highest,
    ["iPad4,3"] = XRenderQuality.Highest,
    ["iPad4,7"] = XRenderQuality.Highest,
    ["iPad4,8"] = XRenderQuality.Highest,
    ["iPad4,9"] = XRenderQuality.Highest,

    ["iPad3,1"] = XRenderQuality.Highest,
    ["iPad3,2"] = XRenderQuality.Highest,
    ["iPad3,3"] = XRenderQuality.Highest,
    ["iPad3,4"] = XRenderQuality.Highest,
    ["iPad3,5"] = XRenderQuality.Highest,
    ["iPad3,6"] = XRenderQuality.Highest,


   

    ["iPhone1,1"] = XRenderQuality.Low,
    ["iPhone1,2"] = XRenderQuality.Low,
    ["iPhone2,1"] = XRenderQuality.Low,
    ["iPhone3,1"] = XRenderQuality.Low,
    ["iPhone3,2"] = XRenderQuality.Low,
    ["iPhone3,3"] = XRenderQuality.Low,
    ["iPhone4,1"] = XRenderQuality.Low,

    ["iPhone5,1"] = XRenderQuality.Low,
    ["iPhone5,2"] = XRenderQuality.Low,
    ["iPhone5,3"] = XRenderQuality.Low,
    ["iPhone5,4"] = XRenderQuality.Low,

    ["iPhone6,1"] = XRenderQuality.Low,
    ["iPhone6,2"] = XRenderQuality.Low,

    ["iPhone7,2"] = XRenderQuality.Middle,
    ["iPhone7,1"] = XRenderQuality.Middle,

    --iphone 6s
    ["iPhone8,1"] = XRenderQuality.Middle,
    ["iPhone8,2"] = XRenderQuality.Middle,
    ["iPhone8,4"] = XRenderQuality.High,

    --iphone 7
    ["iPhone9,1"] = XRenderQuality.High,
    ["iPhone9,2"] = XRenderQuality.High,
    ["iPhone9,3"] = XRenderQuality.High,
    ["iPhone9,4"] = XRenderQuality.High,

    --iphone 8
    ["iPhone10,1"] = XRenderQuality.High,
    ["iPhone10,4"] = XRenderQuality.High,

    --iphone 8 plus
    ["iPhone10,2"] = XRenderQuality.High,
    ["iPhone10,5"] = XRenderQuality.High,

    --iphone x
    ["iPhone10,3"] = XRenderQuality.High,
    ["iPhone10,6"] = XRenderQuality.High,

    --iphone xr
    ["iPhone11,8"] = XRenderQuality.Highest,

    --iphone xs
    ["iPhone11,2"] = XRenderQuality.High,

    --iphone xs max
    ["iPhone11,6"] = XRenderQuality.High,

    --???
    ["iPhone11,4"] = XRenderQuality.Highest,
    ["iPhone11,1"] = XRenderQuality.Highest,
    ["iPhone11,3"] = XRenderQuality.Highest,
    ["iPhone11,5"] = XRenderQuality.Highest,
    ["iPhone11,7"] = XRenderQuality.Highest,
    ["iPhone11,9"] = XRenderQuality.Highest,

    ["iPhone12,1"] = XRenderQuality.Highest,
    ["iPhone12,2"] = XRenderQuality.Highest,
    ["iPhone12,3"] = XRenderQuality.Highest,
    ["iPhone12,4"] = XRenderQuality.Highest,
    ["iPhone12,5"] = XRenderQuality.Highest,
    ["iPhone12,6"] = XRenderQuality.Highest,
    ["iPhone12,7"] = XRenderQuality.Highest,
    ["iPhone12,8"] = XRenderQuality.Highest,
    ["iPhone12,9"] = XRenderQuality.Highest,
    
}

function XHardwareManager.CheckIOS()

    local iosName = CS.UnityEngine.SystemInfo.deviceModel

    if not iosName or iosName == "" then
        XLog.Debug("IOS Model name is nil")
        return XRenderQuality.High
    end

    XLog.Debug("IOS Model name:" .. iosName)

    local quality = IOS_TABLE[iosName]

    if not quality then
        return XRenderQuality.High
    end

    return quality

end

--设置硬件相关分辨率
function XHardwareManager.SetHardwareResolution()
    local model = CS.UnityEngine.SystemInfo.deviceModel
    if not model then
        XQualityManager:SetHardwareScale(1)
        return
    end

    if model then

        --iphone x 设置一个0.9分辨率进去
        if model == "iPhone10,3" or model == "iPhone10,6" or model == "iPhone11,6" then
            XQualityManager:SetHardwareScale(0.9)
            return
        end
        
    end


    XQualityManager:SetHardwareScale(1)
end


function XHardwareManager.CheckAndroid()
    return XHardwareManager.CheckGpuAndroid(CS.UnityEngine.SystemInfo.graphicsDeviceName)
end

function XHardwareManager.CheckGpuAdreno(tokens)
    local seriesNum = 0
    for i = 1, #tokens do
        seriesNum = tonumber(tokens[i])
        if seriesNum then

            if seriesNum == 540 then
                --835
                return XRenderQuality.High
            end

            if seriesNum == 618 then
                --855+
                return XRenderQuality.High
            end

            if seriesNum == 616 then
                --710
                return XRenderQuality.High
            end

            if seriesNum < 400 then
                return XRenderQuality.Lowest
            elseif seriesNum <= 509 then
                return XRenderQuality.Lowest
            elseif seriesNum < 510  then
                return XRenderQuality.Low
            elseif seriesNum < 600 then
                return XRenderQuality.Middle
            else
                
                if seriesNum >= 600 and seriesNum < 700 then

                    if seriesNum <= 627 then
                        --616
                        return XRenderQuality.Middle
                    else
                        if seriesNum >= 640 then
                            --640
                            return XRenderQuality.Highest
                        else
                            --630
                            return XRenderQuality.High
                        end
                        
                    end

                elseif seriesNum >= 700 and seriesNum < 800 then
                    --700系列都是高端
                    return XRenderQuality.Middle

                else
                    --800
                    if seriesNum <= 900 then

                        if seriesNum <= 806 then
                            --800 ~ 806
                            return XRenderQuality.Middle
                        else 

                            if seriesNum >= 820 then
                                --820以上为最高端
                                return XRenderQuality.Middle
                            else
                                --806~820
                                return XRenderQuality.Middle
                            end
                            
                        end

                    else
                        --未知系列默认返回高端机
                        return XRenderQuality.Middle
                    end

                    --默认返回中端机
                    return XRenderQuality.Middle
                end

            end
        end
    end
    
    XLog.Warning("XHardwareManager.CheckGpuAdreno: Getting quality fail, unknow device.")
    return XRenderQuality.Middle
end

function XHardwareManager.CheckGpuPowerVR(tokens)
    -- local tag = "XHardwareManager.CheckGpuPowerVR "
    -- -- XLog.Debug(tag .. "Begin")
    for i = 1, #tokens do
        local token = tokens[i]
        
        if token == "sgx" then
            -- XLog.Debug(tag .. "sgx")
            return XRenderQuality.Lowest
        end

        if token == "furian" then
            -- XLog.Debug(tag .. "furian")
            return XRenderQuality.Lowest
        end

        local quality = XHardwareManager.GetQualityByPowerVRSeriesNum(token)
        if quality then
            return quality
        end
    end
    XLog.Warning("XHardwareManager.CheckGpuAdreno: Getting quality fail, unknow device.")
    return XRenderQuality.Lowest
end

function XHardwareManager.GetQualityByPowerVRSeriesNum(token)
    -- local tag = "XHardwareManager.GetQualityByPowerVRSeriesNum "
    -- XLog.Debug(tag .. "token = " .. token)
    -- Precheck

    local char1 = string.byte(token, 1)
    local gByte = string.byte('g', 1)
    local isGSeries = char1 == gByte
    if not isGSeries then
        -- XLog.Debug(tag .. "isGSeries = false or nil, continue")
        return XRenderQuality.Low
    end

    -- Getting series number
    local seriesNum = -1
    local char2 = string.byte(token, 2)
    local isNumberStartAt2 = char2 >= string.byte('0', 1) and char2 <= string.byte('9', 1)
    if isNumberStartAt2 then
        seriesNum = tonumber(string.sub(token, 2))
    else
        seriesNum = tonumber(string.sub(token, 1))
    end
    
    if not seriesNum then
        -- XLog.Debug(tag .. "series number = nil")
        return XRenderQuality.Low
    end
    -- XLog.Debug(tag .. "series number = " .. seriesNum)

    -- Return by series number
    if seriesNum > 0 then
        if seriesNum >= 9400 then
            -- XLog.Debug(tag .. "seriesNum >= 9400")
            return XRenderQuality.Middle
        elseif seriesNum >= 8300 then
            -- XLog.Debug(tag .. "seriesNum >= 8300")
            return XRenderQuality.Low
        else -- redmi 6 GE8320 Huawei Y5 2018 GE8100
            -- XLog.Debug(tag .. "else")
            return XRenderQuality.Lowest
        end
    end
end

function XHardwareManager.GetMaliSeriesNumByToken(token, flag)
    -- local tag = "XHardwareManager.GetMaliSeriesNumByToken"
    -- XLog.Debug(tag .. "token = " .. token .. ", flag = " .. tostring(flag))
    local mpIndex = string.LastIndexOf(token, "mp")
    if mpIndex > 1 then
        -- XLog.Debug(tag .. "mpIndex > 1")
        -- 't/g' + number + mp
        local startIndex = 1
        if flag then
            startIndex = 2
        else
            startIndex = 1
        end
        token = string.sub(token, startIndex, mpIndex - startIndex)
        -- XLog.Debug(tag .. "token = " .. token)
    else
        -- 't/g' + number
        if flag then
            token = string.sub(token, 2)
        end
        -- XLog.Debug(tag .. "token = " .. token)
    end
    
    local result = tonumber(token)
    -- if result then
    --     XLog.Debug(tag .. "tonumber(token) = " .. result)
    -- else
    --     XLog.Debug(tag .. "tonumber(token) = nil")
    -- end
    return result
end

function XHardwareManager.GetQualityByMaliSeriesNum(seriesNum, gFlag, tFlag)

    -- local tag = "XHardwareManager.GetQualityByMaliSeriesNum : "
    -- XLog.Debug("mali series number = " .. seriesNum)

    if seriesNum <= 0 then
        return XRenderQuality.Middle
    end

    -- G series
    if gFlag then
        -- XLog.Debug("Mali G series " .. seriesNum)
        if seriesNum >= 76 then
            -- XLog.Debug("seriesNum >= 76")
            return XRenderQuality.High
        elseif seriesNum >= 72 then -- MP value
            -- XLog.Debug("seriesNum >= 72")
            --G72
            return XRenderQuality.Middle
        elseif seriesNum >= 71 then -- MP value
            return XRenderQuality.Middle
        elseif seriesNum >= 52 then
            --kirin 810
            return XRenderQuality.High
        else -- huawei Lite G51 G71
            return XRenderQuality.Middle
        end
    end
    
    -- T series Opengl ES 3.1
    if tFlag then
        -- XLog.Debug("Mali T series " .. seriesNum)
        if seriesNum >= 780 then -- MTK MP NightMare
            -- XLog.Debug("seriesNum >= 780")
            return XRenderQuality.Middle
        else -- 720 760
            return XRenderQuality.Low
        end
    end

    -- Other series
    -- XLog.Debug(tag .. "Mali other series name: " .. seriesNum)
    if seriesNum < 600 and seriesNum >= 200 then
        -- XLog.Debug("seriesNum < 600 and seriesNum >= 200")
        return XRenderQuality.Low
    else
        -- XLog.Debug(tag .. "else")
        return XRenderQuality.Middle
    end
end

function XHardwareManager.CheckGpuMali(tokens)
    -- local tag = "XHardwareManager.CheckGpuMali "
    -- XLog.Debug("check gpu mali " .. tag .. " #tokens = " .. #tokens)
    -- Format : arm mali 'g/t'number
    for i = 2, #tokens do
        local token = tokens[i]

        -- Getting flags
        local firstCharByte = string.byte(token, 1)
        local tByte = string.byte('t', 1)
        local gByte = string.byte('g', 1)
        local tFlag = firstCharByte == tByte
        local gFlag = firstCharByte == gByte
        local flag = tFlag or gFlag

        -- Getting series number
        local seriesNum = XHardwareManager.GetMaliSeriesNumByToken(token, flag)
        if not seriesNum then
            goto continue
        end
        -- XLog.Debug(tag .. "seriesNum = " .. seriesNum)

        -- Getting quality
        local quality = XHardwareManager.GetQualityByMaliSeriesNum(seriesNum, gFlag, tFlag)
        if quality then
            -- XLog.Debug(tag .. "quality = " .. quality)
            return quality
        end

        ::continue::
    end

    XLog.Error("XHardwareManager.CheckGpuMali: Getting quality fail, unknow device.")
    return XRenderQuality.Middle
end

function XHardwareManager.CheckGpuTegra(tokens)
    -- local tag = "XHardwareManager.CheckGpuTegra "
    for i = 1, #tokens do
        local text = tokens[i]
        if text == "k1" then
            -- XLog.Debug(tag .. "text == \"k1\"")
            return XRenderQuality.Lowest
        end
        if text == "x1" then
            -- XLog.Debug(tag .. "text == \"x1\"")
            return XRenderQuality.Low
        end
    end
    -- XLog.Debug(tag .. "else")
    XLog.Error("XHardwareManager.CheckGpuTegra: Getting quality fail, unknow device.")
    return XRenderQuality.Middle
end

function XHardwareManager.CheckGpuAndroid(gpuName)

    XQualityManager.IsSimulator = false
    
    if not gpuName or gpuName == "" then
        XLog.Error("XHardwareManager.CheckGpuAndroid: Getting quality fail, gpuName is nil.")
        return XRenderQuality.Middle
    end
    
    -- XLog.Debug("XHardwareManager.CheckGpuAndroid : " .. gpuName)
    
    -- Pretreatment
    gpuName = string.lower(gpuName)
    local separators = { '\t', '\r', '\n', '+', '-', ':' }
    for i = 1, #separators do
        gpuName = string.gsub(gpuName, separators[i], ' ')
    end
    local tokens = string.Split(gpuName, ' ')
    local tokenLength = #tokens
    if not tokens or tokenLength == 0 then
        XLog.Error("XHardwareManager.CheckGpuAndroid: Split gpu name fail.")
        return XRenderQuality.Middle
    end

    local token1 = tokens[1]
    local token2 = nil
    if tokenLength >= 2 then
        token2 = tokens[2]
    end

    local cpuName = string.lower(CS.UnityEngine.SystemInfo.processorType or "")

    -- XLog.Debug("XHardwareManager.CheckGpuAndroid : " .. cpuName)
    

    local deviceModel = CS.UnityEngine.SystemInfo.deviceModel

    if deviceModel and deviceModel ~= "" then
        deviceModel = string.lower(deviceModel)
    end

    --检查模拟器
    if string.match(gpuName, "direct3d") or string.match(gpuName, "geforce") or string.match(gpuName, "gtx")
      or string.match(cpuName, "intel") or string.match(cpuName, "amd") or string.match(cpuName, "intel") or string.match(gpuName, "mumu") or string.match(gpuName, "nvidia") or string.match(deviceModel, "mumu") then
        XLog.Debug("XHardwareManager.SetAndroidSimulator")
        XQualityManager.IsSimulator = true
        return XRenderQuality.Highest
    end

    --检查手机
    if string.match(token1, "vivante") then
        return XRenderQuality.Middle
    elseif token1 == "adreno" then
        return XHardwareManager.CheckGpuAdreno(tokens)
    elseif token1 == "powervr" or token1 == "imagination" or token1 == "sgx" or token1 == "rogue" then
        return XHardwareManager.CheckGpuPowerVR(tokens)
    elseif token1 == "arm" or token1 == "mali" or (tokenLength > 1 and token2 and token2 == "mali") then
        return XHardwareManager.CheckGpuMali(tokens)
    elseif token1 == "tegra" then
        return XHardwareManager.CheckGpuTegra(tokens)
    end

    XLog.Error("XHardwareManager.CheckGpuAndroid: Getting quality fail, unknow device, gpu name = \"" .. gpuName .. "\"." .. " cpuName=" .. cpuName)

    return XRenderQuality.Middle
end