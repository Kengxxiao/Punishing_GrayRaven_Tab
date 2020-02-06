XUiPanelArea = XClass()

function XUiPanelArea:Ctor(ui,sectionData,parent)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.SectionData = sectionData
    self.RootUi = parent
    XTool.InitUiObject(self)
    self:InitAutoScript()
    self:Init()
end

function XUiPanelArea:Init()
    if not self.SectionData then
        return
    end

    self.TxtAreaLock.text = self.SectionData.Name
    self.TxtAreaNow.text = self.SectionData.Name
    self.TxtAreaNor.text = self.SectionData.Name
    --self.RootUi:SetUiSprite(self.RImgChapter,self.SectionData.SectionIcon)
    self.RImgChapter:SetRawImage(self.SectionData.SectionIcon)
end

function XUiPanelArea:SetCurSection(taskSectionCfg)
    if not self.SectionData then
        return
    end

    self.PanelNow.gameObject:SetActive(self.SectionData.Id == taskSectionCfg.Id)
    self.PanelLock.gameObject:SetActive(self.SectionData.Id > taskSectionCfg.Id)
    self.PanelNor.gameObject:SetActive(self.SectionData.Id < taskSectionCfg.Id)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelArea:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiPanelArea:AutoInitUi()
    -- self.PanelLock = self.Transform:Find("PanelLock")
    -- self.TxtAreaLock = self.Transform:Find("PanelLock/TxtAreaLock"):GetComponent("Text")
    -- self.PanelNow = self.Transform:Find("PanelNow")
    -- self.RImgChapter = self.Transform:Find("PanelNow/RImgChapter"):GetComponent("RawImage")
    -- self.TxtAreaNow = self.Transform:Find("PanelNow/TxtAreaNow"):GetComponent("Text")
    -- self.PanelNor = self.Transform:Find("PanelNor")
    -- self.TxtAreaNor = self.Transform:Find("PanelNor/TxtAreaNor"):GetComponent("Text")
end

function XUiPanelArea:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiPanelArea:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiPanelArea:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiPanelArea:AutoAddListener()
    self.AutoCreateListeners = {}
end
-- auto

return XUiPanelArea
