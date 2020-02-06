XUiPanelGraphicsSet = XClass()

local XQualityManager = CS.XQualityManager.Instance

local function CopyCQualitySettings(luaQuality, cQuality)
    luaQuality.UseHdr = cQuality.UseHdr
    luaQuality.UseFxaa = cQuality.UseFxaa

    -- luaQuality.UseDistortion = cQuality.UseDistortion
    -- luaQuality.HighFrameRate = cQuality.HighFrameRate
    luaQuality.EffectLevel = cQuality:GetEffectLevel()
    luaQuality.GraphicsLevel = cQuality:GetGraphicsLevel()
    luaQuality.ShadowLevel = cQuality:GetShadowLevel()
    luaQuality.MirrorLevel = cQuality:GetMirrorLevel()
    luaQuality.ResolutionLevel = cQuality:GetResolutionLevel()

    luaQuality.DistortionLevel = cQuality:GetDistortionLevel()
    luaQuality.FrameRateLevel = cQuality:GetFrameRateLevel()

    luaQuality.BloomLevel = cQuality:GetBloomLevel()
end

local function GetCQualitySettings(luaQuality)
    local quality = CS.XQualitySettings()
    quality.UseHdr = luaQuality.UseHdr
    quality.UseFxaa = luaQuality.UseFxaa
    -- quality.UseDistortion = luaQuality.UseDistortion
    -- quality.HighFrameRate = luaQuality.HighFrameRate
    quality:SetEffectLevel(luaQuality.EffectLevel)
    quality:SetGraphicsLevel(luaQuality.GraphicsLevel)
    quality:SetShadowLevel(luaQuality.ShadowLevel)
    quality:SetMirrorLevel(luaQuality.MirrorLevel)
    quality:SetResolutionLevel(luaQuality.ResolutionLevel)
    quality:SetDistortionLevel(luaQuality.DistortionLevel)
    quality:SetFrameRateLevel(luaQuality.FrameRateLevel)

    quality:SetBloomLevel(luaQuality.BloomLevel)

    return quality
end

local function SetToggleEnable(tog, flag)
    if tog.interactable ~= flag then
        tog.interactable = flag
    end
end


function XUiPanelGraphicsSet:Ctor(ui,parent)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform

    self.Parent = parent
    self:InitAutoScript()

    self.QualitySettings = {
        UseHdr = true,
        UseFxaa = true,
        -- UseDistortion = true,
        -- HighFrameRate = true,

        DistortionLevel = nil,
        EffectLevel = nil,
        GraphicsLevel = nil,
        ShadowLevel = nil,
        MirrorLevel = nil,
        ResolutionLevel = nil,
        FrameRateLevel = nil,
        BloomLevel = nil
    }



    self.TogQualityGroup = {
        self.TogQuality_0, self.TogQuality_1, self.TogQuality_2, self.TogQuality_3, self.TogQuality_4, self.TogQuality_5,
    }

    self.TogGraphicsGroup = {
        self.TogGraphics_0, self.TogGraphics_1, self.TogGraphics_2, self.TogGraphics_3, self.TogGraphics_4,
    }

    self.TogEffectGroup = {
        self.TogEffect_0, self.TogEffect_1, self.TogEffect_2, self.TogEffect_3
    }

    self.TogShadowGroup = {
        self.TogShadow_0, self.TogShadow_1, self.TogShadow_2, self.TogShadow_3,
    }

    self.TogMirrorGroup = {
        self.TogMirror_0, self.TogMirror_1, self.TogMirror_2, self.TogMirror_3,
    }

    self.TogResolutionGroup = {
        self.TogResolution_0, self.TogResolution_1, self.TogResolution_2, self.TogResolution_3
    }

    self.TogFrameRateGroup = {
        self.TogFrameRate_0, self.TogFrameRate_1, self.TogFrameRate_2
    }

    self.TogBloom_0 = self.Transform:Find("SView /Viewport/PanelContent/BloomLevel/Array/TGroupBloom/TogBloom_0"):GetComponent("Toggle")
    self.TogBloom_1 = self.Transform:Find("SView /Viewport/PanelContent/BloomLevel/Array/TGroupBloom/TogBloom_1"):GetComponent("Toggle")
    self.TogBloom_2 = self.Transform:Find("SView /Viewport/PanelContent/BloomLevel/Array/TGroupBloom/TogBloom_2"):GetComponent("Toggle")

    self.TogBloomGroup = {
        self.TogBloom_0, self.TogBloom_1, self.TogBloom_2
    }


    self.TogDistortion_0 = self.Transform:Find("SView /Viewport/PanelContent/DistortionLevel/Array/TGroupResolution/TogDistortion_0"):GetComponent("Toggle")
    self.TogDistortion_1 = self.Transform:Find("SView /Viewport/PanelContent/DistortionLevel/Array/TGroupResolution/TogDistortion_1"):GetComponent("Toggle")
    self.TogDistortion_2 = self.Transform:Find("SView /Viewport/PanelContent/DistortionLevel/Array/TGroupResolution/TogDistortion_2"):GetComponent("Toggle")

    self.TogDistortionGroup = {
        self.TogDistortion_0, self.TogDistortion_1, self.TogDistortion_2
    }

    self.CurQualityLevel = nil
    self.Dirty = false

    self.TogHDR = self.TogHDR
    self.TogFxaa = self.TogFxaa
    -- self.TogDistortion = self.TogDistortion
    -- self.TogHighFrameRate = self.TogHighFrameRate
    self:RegisterClickEvent(self.TogHDR, function(isEnable)
        self.Dirty = true
        self:OnClickHDR(isEnable)
    end)

    self:RegisterClickEvent(self.TogFxaa, function(isEnable)
        self.Dirty = true
        self:OnClickFXAA(isEnable)
    end)

    -- self:RegisterClickEvent(self.TogDistortion, function(isEnable)
    --     self.Dirty = true
    --     -- self:OnClickDistortion(isEnable)
    -- end)

    -- self:RegisterClickEvent(self.TogHighFrameRate, function(isEnable)
    --     self.Dirty = true
    --     self:OnClickHighFrameRate(isEnable)
    -- end)
    self.lock = false;

    for index, tog in ipairs(self.TogDistortionGroup) do
        local qualityId = index - 1

        self:RegisterClickEvent(tog, function(open)

            -- if self.lock then return end
            if open then
                self.Dirty = true
                self:OnClickDistortionSettings(qualityId)
            end

            if self.CurQualityLevel ~= 0 then
                self.CurQualityLevel = 0
                self:OnClickQualitySettings(self.CurQualityLevel)
                self:UpdatePanel()
            end
        end)
    end


    for index, tog in ipairs(self.TogBloomGroup) do
        local qualityId = index - 1

        self:RegisterClickEvent(tog, function(open)

            -- if self.lock then return end
            if open then
                self.Dirty = true
                self:OnClickBloomSettings(qualityId)
            end

            if self.CurQualityLevel ~= 0 then
                self.CurQualityLevel = 0
                self:OnClickQualitySettings(self.CurQualityLevel)
                self:UpdatePanel()
            end
        end)
    end



    for index, tog in ipairs(self.TogQualityGroup) do
        local qualityId = index - 1

        self:RegisterClickEvent(tog, function(open)
            if self.lock then return end

            if open then
                self.Dirty = true
                self:OnClickQualitySettings(qualityId)
            end
        end)
    end

    for index, tog in ipairs(self.TogResolutionGroup) do
        local resolutionId = index - 1

        self:RegisterClickEvent(tog, function(open)

            -- if self.lock then return end
            if open then
                self.Dirty = true
                self:OnClickResolutionSettings(resolutionId)
            end

            if self.CurQualityLevel ~= 0 then
                self.CurQualityLevel = 0
                self:OnClickQualitySettings(self.CurQualityLevel)
                self:UpdatePanel()
            end
        end)
    end

    for index, tog in ipairs(self.TogFrameRateGroup) do
        local resolutionId = index - 1

        self:RegisterClickEvent(tog, function(open)

            -- if self.lock then return end
            if open then
                self.Dirty = true
                self:OnClickFrameRateSettings(resolutionId)
            end

            if self.CurQualityLevel ~= 0 then
                self.CurQualityLevel = 0
                self:OnClickQualitySettings(self.CurQualityLevel)
                self:UpdatePanel()
            end
        end)
    end


    for index, tog in ipairs(self.TogEffectGroup) do

        local effectId = index - 1
        self:RegisterClickEvent(tog, function(open)

            -- if self.lock then return end
            if open then
                self.Dirty = true
                self:OnClickEffectLevel(effectId)
            end

            if self.CurQualityLevel ~= 0 then
                self.CurQualityLevel = 0
                self:OnClickQualitySettings(self.CurQualityLevel)
                self:UpdatePanel()
            end

        end)
    end

    for index, tog in ipairs(self.TogShadowGroup) do

        local shadowId = index - 1
        self:RegisterClickEvent(tog, function(open)

            -- if self.lock then return end
            if open then
                self.Dirty = true
                self:OnClickShadowLevel(shadowId)
            end

            if self.CurQualityLevel ~= 0 then
                self.CurQualityLevel = 0
                self:OnClickQualitySettings(self.CurQualityLevel)
                self:UpdatePanel()
            end
        end)
    end

    for index, tog in ipairs(self.TogGraphicsGroup) do

        local graphicId = index - 1
        self:RegisterClickEvent(tog, function(open)

            -- if self.lock then return end
      
            if open then
                self.Dirty = true
                self:OnClickGraphicsLevel(graphicId)
            end

            if self.CurQualityLevel ~= 0 then
                self.CurQualityLevel = 0
                self:OnClickQualitySettings(self.CurQualityLevel)
                self:UpdatePanel()
            end
        end)
    end

    for index, tog in ipairs(self.TogMirrorGroup) do

        local mirrorId = index - 1
        self:RegisterClickEvent(tog, function(open)
            -- if self.lock then return end
            if open then
                self.Dirty = true
                self:OnClickMirrorLevel(mirrorId)
            end

            if self.CurQualityLevel ~= 0 then
                self.CurQualityLevel = 0
                self:OnClickQualitySettings(self.CurQualityLevel)
                self:UpdatePanel()
            end
        end)

    end

    local defaultLevel = XQualityManager:GetDefaultLevel() + 1

    for index, tog in ipairs(self.TogQualityGroup) do

        if index ~= 1 then
            local icon = tog.gameObject.transform:Find("Icon").gameObject

            if icon then
                icon:SetActive(index == defaultLevel)
            end
        end
    end


end

function XUiPanelGraphicsSet:OnClickFrameRateSettings(id)
    self.QualitySettings.FrameRateLevel = id
end

function XUiPanelGraphicsSet:OnClickResolutionSettings(id)
    self.QualitySettings.ResolutionLevel = id
end

function XUiPanelGraphicsSet:OnClickEffectLevel(id)
    self.QualitySettings.EffectLevel = id
end

function XUiPanelGraphicsSet:OnClickShadowLevel(id)
    self.QualitySettings.ShadowLevel = id
end

function XUiPanelGraphicsSet:OnClickGraphicsLevel(id)
    self.QualitySettings.GraphicsLevel = id
end

function XUiPanelGraphicsSet:OnClickMirrorLevel(id)
    self.QualitySettings.MirrorLevel = id
end

function XUiPanelGraphicsSet:OnClickDistortionSettings(id)
    self.QualitySettings.DistortionLevel = id
end

function XUiPanelGraphicsSet:OnClickBloomSettings(id)
    self.QualitySettings.BloomLevel = id
end

function XUiPanelGraphicsSet:OnClickQualitySettings(id)
    --检查其他配置
    if self.CurQualityLevel == 0 then
        self:SaveCustomQualitySettings()
    end

    self.CurQualityLevel = id
    self:UpdateByCurrentLevel()
end

function XUiPanelGraphicsSet:SaveCustomQualitySettings()
    if self.CurQualityLevel == 0 then
        local c = GetCQualitySettings(self.QualitySettings)
        XQualityManager:SaveCustomQualitySettings(c)
    end
end

function XUiPanelGraphicsSet:OnClickHDR(isEnable)
    self.QualitySettings.UseHdr = self.TogHDR.isOn
    if self.CurQualityLevel ~= 0 then
        self.CurQualityLevel = 0
        self:OnClickQualitySettings(self.CurQualityLevel)
        self:UpdatePanel()
    end
end

function XUiPanelGraphicsSet:OnClickFXAA(isEnable)
    self.QualitySettings.UseFxaa = self.TogFxaa.isOn
    if self.CurQualityLevel ~= 0 then
        self.CurQualityLevel = 0
        self:OnClickQualitySettings(self.CurQualityLevel)
        self:UpdatePanel()
    end
end

-- function XUiPanelGraphicsSet:OnClickDistortion(isEnable)
--     -- self.QualitySettings.UseDistortion = self.TogDistortion.isOn
-- end

-- function XUiPanelPicQualitySet:OnClickHighFrameRate(isEnable)
--     self.QualitySettings.HighFrameRate = self.TogHighFrameRate.isOn
-- end
--on show
function XUiPanelGraphicsSet:ShowPanel()
    self.Dirty = false

    self.GameObject:SetActive(true)

    self.CurQualityLevel = XQualityManager:GetCurQualitySettings()
    self:UpdatePanel()
end

function XUiPanelGraphicsSet:UpdatePanel()
    self.lock = true

    for i, tog in pairs(self.TogQualityGroup) do
        tog.isOn = (i - 1) == self.CurQualityLevel
    end

    self.lock = false

    self:UpdateByCurrentLevel()
end

--on close
function XUiPanelGraphicsSet:HidePanel()
    XDataCenter.SetManager.SetUiResolutionEventFlag(false)
    self.GameObject:SetActive(false)
end

function XUiPanelGraphicsSet:SetAllInteractable(flag)
    for _, tog in pairs(self.TogEffectGroup) do
        SetToggleEnable(tog, flag)
    end

    for _, tog in pairs(self.TogFrameRateGroup) do
        SetToggleEnable(tog, flag)
    end

    for _, tog in pairs(self.TogGraphicsGroup) do
        SetToggleEnable(tog, flag)
    end

    for _, tog in pairs(self.TogMirrorGroup) do
        SetToggleEnable(tog, flag)
    end

    for _, tog in pairs(self.TogShadowGroup) do
        SetToggleEnable(tog, flag)
    end

    for _, tog in pairs(self.TogResolutionGroup) do
        SetToggleEnable(tog, flag)
    end

    for _, tog in pairs(self.TogDistortionGroup) do
        SetToggleEnable(tog, flag)
    end

    for _, tog in pairs(self.TogBloomGroup) do
        SetToggleEnable(tog, flag)
    end

    -- SetToggleEnable(self.TogHDR, flag)
    -- SetToggleEnable(self.TogFxaa, flag)
    -- SetToggleEnable(self.TogHighFrameRate, flag)
    -- SetToggleEnable(self.TogDistortion, flag)

end

function XUiPanelGraphicsSet:UpdateByCurrentLevel()

    local cQuality = XQualityManager:GetQualitySettings(self.CurQualityLevel)

    CopyCQualitySettings(self.QualitySettings, cQuality)

    if self.CurQualityLevel == 0 then
        self:UpdateCustomSettings()
    else
        self:UpdateDefaultSettings()
    end

end

--更新自定义设置
function XUiPanelGraphicsSet:UpdateCustomSettings()
    self:SetAllInteractable(true)
    self:UpdateContents()
end

--更新默认设置
function XUiPanelGraphicsSet:UpdateDefaultSettings()
    self:SetAllInteractable(false)
    self:UpdateContents()
end

function XUiPanelGraphicsSet:UpdateContents()

    self.lock = true

    local info = self.QualitySettings

    self.TogHDR.isOn = info.UseHdr
    self.TogFxaa.isOn = info.UseFxaa
    -- self.TogDistortion.isOn = info.UseDistortion
    -- self.TogHighFrameRate.isOn = info.HighFrameRate
    for i, tog in pairs(self.TogFrameRateGroup) do
        tog.isOn = info.FrameRateLevel == (i - 1)
    end

    for i, tog in pairs(self.TogEffectGroup) do
        tog.isOn = info.EffectLevel == (i - 1)
    end

    for i, tog in pairs(self.TogGraphicsGroup) do
        tog.isOn = info.GraphicsLevel == (i - 1)
    end

    for i, tog in pairs(self.TogShadowGroup) do
        tog.isOn = info.ShadowLevel == (i - 1)
    end

    for i, tog in pairs(self.TogMirrorGroup) do
        tog.isOn = info.MirrorLevel == (i - 1)
    end

    for i, tog in pairs(self.TogResolutionGroup) do
        tog.isOn = info.ResolutionLevel == (i - 1)
    end

    for i, tog in pairs(self.TogDistortionGroup) do
        tog.isOn = info.DistortionLevel == (i - 1)
    end

    for i, tog in pairs(self.TogBloomGroup) do
        tog.isOn = info.BloomLevel == (i - 1)
    end

    self.lock = false

end

--检测是否有数据变动
function XUiPanelGraphicsSet:CheckDataIsChange()
    return self.Dirty
end

--保存设置
function XUiPanelGraphicsSet:SaveChange()
    XDataCenter.SetManager.SetUiResolutionEventFlag(true)

    if self.CurQualityLevel == 0 then
        local c = GetCQualitySettings(self.QualitySettings)
        XQualityManager:SetQualitySettings(self.CurQualityLevel, c)

        -- self:SaveCustomQualitySettings()
    else

        XQualityManager:SetQualitySettings(self.CurQualityLevel)
    end

    self.Dirty = false
end

--取消保存
function XUiPanelGraphicsSet:CancelChange()

end

--重置到默认配置
function XUiPanelGraphicsSet:ResetToDefault()
    local defaultLevel = XQualityManager:GetDefaultLevel()
    self.CurQualityLevel = defaultLevel

    self:UpdatePanel()
    self.Dirty = true
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelGraphicsSet:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiPanelGraphicsSet:AutoInitUi()
    self.TogQuality_0 = self.Transform:Find("MainQuality/TGroupAuto/TogQuality_0"):GetComponent("Toggle")
    self.SView = self.Transform:Find("SView "):GetComponent("ScrollRect")
    self.PanelContent = self.Transform:Find("SView /Viewport/PanelContent")
    self.PanelLiangge2 = self.Transform:Find("SView /Viewport/PanelContent/PanelLiangge2")
    self.TogDistortion = self.Transform:Find("SView /Viewport/PanelContent/PanelLiangge2/Distortion/TogDistortion"):GetComponent("Toggle")
    self.TxtFxaaA = self.Transform:Find("SView /Viewport/PanelContent/PanelLiangge2/Distortion/TxtFxaa"):GetComponent("Text")
    self.TogHighFrameRate = self.Transform:Find("SView /Viewport/PanelContent/PanelLiangge2/HighFrameRate/TogHighFrameRate"):GetComponent("Toggle")
    self.TxtFxaaB = self.Transform:Find("SView /Viewport/PanelContent/PanelLiangge2/HighFrameRate/TxtFxaa"):GetComponent("Text")
    self.TogMirror_2 = self.Transform:Find("SView /Viewport/PanelContent/MirrorLevel/Array/TGroupResolution/TogMirror_2"):GetComponent("Toggle")
    self.ImgResStandN = self.Transform:Find("SView /Viewport/PanelContent/MirrorLevel/Array/TGroupResolution/TogMirror_2/ImgResStand"):GetComponent("Image")
    self.TxtResStandN = self.Transform:Find("SView /Viewport/PanelContent/MirrorLevel/Array/TGroupResolution/TogMirror_2/TxtResStand"):GetComponent("Text")
    self.TogMirror_1 = self.Transform:Find("SView /Viewport/PanelContent/MirrorLevel/Array/TGroupResolution/TogMirror_1"):GetComponent("Toggle")
    self.ImgResStandM = self.Transform:Find("SView /Viewport/PanelContent/MirrorLevel/Array/TGroupResolution/TogMirror_1/ImgResStand"):GetComponent("Image")
    self.TxtResStandM = self.Transform:Find("SView /Viewport/PanelContent/MirrorLevel/Array/TGroupResolution/TogMirror_1/TxtResStand"):GetComponent("Text")
    self.TogMirror_0 = self.Transform:Find("SView /Viewport/PanelContent/MirrorLevel/Array/TGroupResolution/TogMirror_0"):GetComponent("Toggle")
    self.ImgResStandL = self.Transform:Find("SView /Viewport/PanelContent/MirrorLevel/Array/TGroupResolution/TogMirror_0/ImgResStand"):GetComponent("Image")
    self.TxtResStandL = self.Transform:Find("SView /Viewport/PanelContent/MirrorLevel/Array/TGroupResolution/TogMirror_0/TxtResStand"):GetComponent("Text")
    self.TxtResC = self.Transform:Find("SView /Viewport/PanelContent/MirrorLevel/TxtRes"):GetComponent("Text")
    self.TogShadow_3 = self.Transform:Find("SView /Viewport/PanelContent/ShadowLevel/Array/TGroupResolution/TogShadow_3"):GetComponent("Toggle")
    self.ImgResStandK = self.Transform:Find("SView /Viewport/PanelContent/ShadowLevel/Array/TGroupResolution/TogShadow_3/ImgResStand"):GetComponent("Image")
    self.TxtResStandK = self.Transform:Find("SView /Viewport/PanelContent/ShadowLevel/Array/TGroupResolution/TogShadow_3/TxtResStand"):GetComponent("Text")
    self.TogShadow_2 = self.Transform:Find("SView /Viewport/PanelContent/ShadowLevel/Array/TGroupResolution/TogShadow_2"):GetComponent("Toggle")
    self.ImgResStandJ = self.Transform:Find("SView /Viewport/PanelContent/ShadowLevel/Array/TGroupResolution/TogShadow_2/ImgResStand"):GetComponent("Image")
    self.TxtResStandJ = self.Transform:Find("SView /Viewport/PanelContent/ShadowLevel/Array/TGroupResolution/TogShadow_2/TxtResStand"):GetComponent("Text")
    self.TogShadow_1 = self.Transform:Find("SView /Viewport/PanelContent/ShadowLevel/Array/TGroupResolution/TogShadow_1"):GetComponent("Toggle")
    self.ImgResStandI = self.Transform:Find("SView /Viewport/PanelContent/ShadowLevel/Array/TGroupResolution/TogShadow_1/ImgResStand"):GetComponent("Image")
    self.TxtResStandI = self.Transform:Find("SView /Viewport/PanelContent/ShadowLevel/Array/TGroupResolution/TogShadow_1/TxtResStand"):GetComponent("Text")
    self.TogShadow_0 = self.Transform:Find("SView /Viewport/PanelContent/ShadowLevel/Array/TGroupResolution/TogShadow_0"):GetComponent("Toggle")
    self.ImgResStandH = self.Transform:Find("SView /Viewport/PanelContent/ShadowLevel/Array/TGroupResolution/TogShadow_0/ImgResStand"):GetComponent("Image")
    self.TxtResStandH = self.Transform:Find("SView /Viewport/PanelContent/ShadowLevel/Array/TGroupResolution/TogShadow_0/TxtResStand"):GetComponent("Text")
    self.TxtResB = self.Transform:Find("SView /Viewport/PanelContent/ShadowLevel/TxtRes"):GetComponent("Text")
    self.TogEffect_2 = self.Transform:Find("SView /Viewport/PanelContent/EffectLevel/Array/TGroupResolution/TogEffect_2"):GetComponent("Toggle")
    self.ImgResStandG = self.Transform:Find("SView /Viewport/PanelContent/EffectLevel/Array/TGroupResolution/TogEffect_2/ImgResStand"):GetComponent("Image")
    self.TxtResStandG = self.Transform:Find("SView /Viewport/PanelContent/EffectLevel/Array/TGroupResolution/TogEffect_2/TxtResStand"):GetComponent("Text")
    self.TogEffect_1 = self.Transform:Find("SView /Viewport/PanelContent/EffectLevel/Array/TGroupResolution/TogEffect_1"):GetComponent("Toggle")
    self.ImgResStandF = self.Transform:Find("SView /Viewport/PanelContent/EffectLevel/Array/TGroupResolution/TogEffect_1/ImgResStand"):GetComponent("Image")
    self.TxtResStandF = self.Transform:Find("SView /Viewport/PanelContent/EffectLevel/Array/TGroupResolution/TogEffect_1/TxtResStand"):GetComponent("Text")
    self.TogEffect_0 = self.Transform:Find("SView /Viewport/PanelContent/EffectLevel/Array/TGroupResolution/TogEffect_0"):GetComponent("Toggle")
    self.ImgResStandE = self.Transform:Find("SView /Viewport/PanelContent/EffectLevel/Array/TGroupResolution/TogEffect_0/ImgResStand"):GetComponent("Image")
    self.TxtResStandE = self.Transform:Find("SView /Viewport/PanelContent/EffectLevel/Array/TGroupResolution/TogEffect_0/TxtResStand"):GetComponent("Text")
    self.TxtResA = self.Transform:Find("SView /Viewport/PanelContent/EffectLevel/TxtRes"):GetComponent("Text")
    self.TogGraphics_4 = self.Transform:Find("SView /Viewport/PanelContent/GraphicsLevel/Array/TGroupResolution/TogGraphics_4"):GetComponent("Toggle")
    self.ImgResStandD = self.Transform:Find("SView /Viewport/PanelContent/GraphicsLevel/Array/TGroupResolution/TogGraphics_4/ImgResStand"):GetComponent("Image")
    self.TxtResStandD = self.Transform:Find("SView /Viewport/PanelContent/GraphicsLevel/Array/TGroupResolution/TogGraphics_4/TxtResStand"):GetComponent("Text")
    self.TogGraphics_3 = self.Transform:Find("SView /Viewport/PanelContent/GraphicsLevel/Array/TGroupResolution/TogGraphics_3"):GetComponent("Toggle")
    self.ImgResStandC = self.Transform:Find("SView /Viewport/PanelContent/GraphicsLevel/Array/TGroupResolution/TogGraphics_3/ImgResStand"):GetComponent("Image")
    self.TxtResStandC = self.Transform:Find("SView /Viewport/PanelContent/GraphicsLevel/Array/TGroupResolution/TogGraphics_3/TxtResStand"):GetComponent("Text")
    self.TogGraphics_2 = self.Transform:Find("SView /Viewport/PanelContent/GraphicsLevel/Array/TGroupResolution/TogGraphics_2"):GetComponent("Toggle")
    self.ImgResStandB = self.Transform:Find("SView /Viewport/PanelContent/GraphicsLevel/Array/TGroupResolution/TogGraphics_2/ImgResStand"):GetComponent("Image")
    self.TxtResStandB = self.Transform:Find("SView /Viewport/PanelContent/GraphicsLevel/Array/TGroupResolution/TogGraphics_2/TxtResStand"):GetComponent("Text")
    self.TogGraphics_1 = self.Transform:Find("SView /Viewport/PanelContent/GraphicsLevel/Array/TGroupResolution/TogGraphics_1"):GetComponent("Toggle")
    self.ImgResStandA = self.Transform:Find("SView /Viewport/PanelContent/GraphicsLevel/Array/TGroupResolution/TogGraphics_1/ImgResStand"):GetComponent("Image")
    self.TxtResStandA = self.Transform:Find("SView /Viewport/PanelContent/GraphicsLevel/Array/TGroupResolution/TogGraphics_1/TxtResStand"):GetComponent("Text")
    self.TogGraphics_0 = self.Transform:Find("SView /Viewport/PanelContent/GraphicsLevel/Array/TGroupResolution/TogGraphics_0"):GetComponent("Toggle")
    self.ImgResStand = self.Transform:Find("SView /Viewport/PanelContent/GraphicsLevel/Array/TGroupResolution/TogGraphics_0/ImgResStand"):GetComponent("Image")
    self.TxtResStand = self.Transform:Find("SView /Viewport/PanelContent/GraphicsLevel/Array/TGroupResolution/TogGraphics_0/TxtResStand"):GetComponent("Text")
    self.TxtRes = self.Transform:Find("SView /Viewport/PanelContent/GraphicsLevel/TxtRes"):GetComponent("Text")
    self.PanelLiangge = self.Transform:Find("SView /Viewport/PanelContent/PanelLiangge")
    self.TxtFxaa = self.Transform:Find("SView /Viewport/PanelContent/PanelLiangge/FXAA/TxtFxaa"):GetComponent("Text")
    self.TogFxaa = self.Transform:Find("SView /Viewport/PanelContent/PanelLiangge/FXAA/TogFxaa"):GetComponent("Toggle")
    self.TxtHDR = self.Transform:Find("SView /Viewport/PanelContent/PanelLiangge/HDR/TxtHDR"):GetComponent("Text")
    self.TogHDR = self.Transform:Find("SView /Viewport/PanelContent/PanelLiangge/HDR/TogHDR"):GetComponent("Toggle")
    self.TxtResA = self.Transform:Find("SView /Viewport/PanelContent/ResolutionLevel/TxtRes"):GetComponent("Text")
    self.TogResolution_0 = self.Transform:Find("SView /Viewport/PanelContent/ResolutionLevel/Array/TGroupResolution/TogResolution_0"):GetComponent("Toggle")
    self.ImgResStandE = self.Transform:Find("SView /Viewport/PanelContent/ResolutionLevel/Array/TGroupResolution/TogResolution_0/ImgResStand"):GetComponent("Image")
    self.TxtResStandE = self.Transform:Find("SView /Viewport/PanelContent/ResolutionLevel/Array/TGroupResolution/TogResolution_0/TxtResStand"):GetComponent("Text")
    self.TogResolution_1 = self.Transform:Find("SView /Viewport/PanelContent/ResolutionLevel/Array/TGroupResolution/TogResolution_1"):GetComponent("Toggle")
    self.ImgResStandF = self.Transform:Find("SView /Viewport/PanelContent/ResolutionLevel/Array/TGroupResolution/TogResolution_1/ImgResStand"):GetComponent("Image")
    self.TxtResStandF = self.Transform:Find("SView /Viewport/PanelContent/ResolutionLevel/Array/TGroupResolution/TogResolution_1/TxtResStand"):GetComponent("Text")
    self.TogResolution_2 = self.Transform:Find("SView /Viewport/PanelContent/ResolutionLevel/Array/TGroupResolution/TogResolution_2"):GetComponent("Toggle")
    self.ImgResStandG = self.Transform:Find("SView /Viewport/PanelContent/ResolutionLevel/Array/TGroupResolution/TogResolution_2/ImgResStand"):GetComponent("Image")
    self.TxtResStandG = self.Transform:Find("SView /Viewport/PanelContent/ResolutionLevel/Array/TGroupResolution/TogResolution_2/TxtResStand"):GetComponent("Text")
    self.TogResolution_3 = self.Transform:Find("SView /Viewport/PanelContent/ResolutionLevel/Array/TGroupResolution/TogResolution_3"):GetComponent("Toggle")
    self.ImgResStandH = self.Transform:Find("SView /Viewport/PanelContent/ResolutionLevel/Array/TGroupResolution/TogResolution_3/ImgResStand"):GetComponent("Image")
    self.TxtResStandH = self.Transform:Find("SView /Viewport/PanelContent/ResolutionLevel/Array/TGroupResolution/TogResolution_3/TxtResStand"):GetComponent("Text")
    self.TogEffect_3 = self.Transform:Find("SView /Viewport/PanelContent/EffectLevel/Array/TGroupResolution/TogEffect_3"):GetComponent("Toggle")
    self.ImgResStandP = self.Transform:Find("SView /Viewport/PanelContent/EffectLevel/Array/TGroupResolution/TogEffect_3/ImgResStand"):GetComponent("Image")
    self.TxtResStandP = self.Transform:Find("SView /Viewport/PanelContent/EffectLevel/Array/TGroupResolution/TogEffect_3/TxtResStand"):GetComponent("Text")
    self.TogMirror_3 = self.Transform:Find("SView /Viewport/PanelContent/MirrorLevel/Array/TGroupResolution/TogMirror_3"):GetComponent("Toggle")
    self.ImgResStandT = self.Transform:Find("SView /Viewport/PanelContent/MirrorLevel/Array/TGroupResolution/TogMirror_3/ImgResStand"):GetComponent("Image")
    self.TxtResStandT = self.Transform:Find("SView /Viewport/PanelContent/MirrorLevel/Array/TGroupResolution/TogMirror_3/TxtResStand"):GetComponent("Text")
    self.TxtResE = self.Transform:Find("SView /Viewport/PanelContent/FrameRateLevel/TxtRes"):GetComponent("Text")
    self.TogFrameRate_0 = self.Transform:Find("SView /Viewport/PanelContent/FrameRateLevel/Array/TGroupResolution/TogFrameRate_0"):GetComponent("Toggle")
    self.ImgResStandU = self.Transform:Find("SView /Viewport/PanelContent/FrameRateLevel/Array/TGroupResolution/TogFrameRate_0/ImgResStand"):GetComponent("Image")
    self.TxtResStandU = self.Transform:Find("SView /Viewport/PanelContent/FrameRateLevel/Array/TGroupResolution/TogFrameRate_0/TxtResStand"):GetComponent("Text")
    self.TogFrameRate_1 = self.Transform:Find("SView /Viewport/PanelContent/FrameRateLevel/Array/TGroupResolution/TogFrameRate_1"):GetComponent("Toggle")
    self.ImgResStandV = self.Transform:Find("SView /Viewport/PanelContent/FrameRateLevel/Array/TGroupResolution/TogFrameRate_1/ImgResStand"):GetComponent("Image")
    self.TxtResStandV = self.Transform:Find("SView /Viewport/PanelContent/FrameRateLevel/Array/TGroupResolution/TogFrameRate_1/TxtResStand"):GetComponent("Text")
    self.TogFrameRate_2 = self.Transform:Find("SView /Viewport/PanelContent/FrameRateLevel/Array/TGroupResolution/TogFrameRate_2"):GetComponent("Toggle")
    self.ImgResStandW = self.Transform:Find("SView /Viewport/PanelContent/FrameRateLevel/Array/TGroupResolution/TogFrameRate_2/ImgResStand"):GetComponent("Image")
    self.TxtResStandW = self.Transform:Find("SView /Viewport/PanelContent/FrameRateLevel/Array/TGroupResolution/TogFrameRate_2/TxtResStand"):GetComponent("Text")
    self.TogQuality_5 = self.Transform:Find("MainQuality/TGroupAuto/TogQuality_5"):GetComponent("Toggle")
    self.TogQuality_4 = self.Transform:Find("MainQuality/TGroupAuto/TogQuality_4"):GetComponent("Toggle")
    self.TogQuality_3 = self.Transform:Find("MainQuality/TGroupAuto/TogQuality_3"):GetComponent("Toggle")
    self.TogAuto = self.Transform:Find("MainQuality/TGroupAuto/TogAuto"):GetComponent("Toggle")
    self.TogQuality_2 = self.Transform:Find("MainQuality/TGroupAuto/TogQuality_2"):GetComponent("Toggle")
    self.TogQuality_1 = self.Transform:Find("MainQuality/TGroupAuto/TogQuality_1"):GetComponent("Toggle")
end

function XUiPanelGraphicsSet:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelPicQualitySet:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelPicQualitySet:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelGraphicsSet:AutoAddListener()
end
-- auto
function XUiPanelGraphicsSet:OnTogHighFrameRateClick(eventData)

end