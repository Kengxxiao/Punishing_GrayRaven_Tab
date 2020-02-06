XUiPanelMissionChapterGird = XClass()

function XUiPanelMissionChapterGird:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
    self:InitAutoScript()
    for i = 1, 3, 1 do
        self["Txt" .. tostring(i)].text = ""
        self["Txt" .. tostring(i).."A"].text = ""
    end
end

function XUiPanelMissionChapterGird:SetupContent(data)
    local curSectionId = XDataCenter.TaskForceManager.GetCurTaskForceSectionId()
    self.PanelChapterHave.gameObject:SetActive(curSectionId > data.Id)
    self.PanelChapterSlect.gameObject:SetActive(curSectionId == data.Id)
    self.PanelChapterLock.gameObject:SetActive(curSectionId < data.Id)

    local sprite = data.SectionChapterIcon

    if curSectionId == data.Id then
        self.TxtName.text = data.Name..CS.XTextManager.GetText("MissionCurContent")
        --self.RootUi:SetUiSprite(self.RImgIcon, sprite)
        self.RImgIcon:SetRawImage(sprite)
        
        for i = 1, 3, 1 do
            if data.Desc[i] ~= nil and data.Desc[i] ~= "" then
                self["Txt" .. tostring(i)].text = data.Desc[i]
            else
                self["Txt" .. tostring(i)].text = string.format(CS.XTextManager.GetText("MissionTaskCountContent"),data.TaskCount)
                break
            end
        end
    elseif curSectionId > data.Id then
        self.TxtNameA.text = data.Name
        --self.RootUi:SetUiSprite(self.RImgIconA, sprite)
        self.RImgIconA:SetRawImage(sprite)
        for i = 1, 3, 1 do
            if data.Desc[i] ~= nil and data.Desc[i] ~= "" then
                self["Txt" .. tostring(i).."A"].text = data.Desc[i]
            else
                self["Txt" .. tostring(i).."A"].text = string.format(CS.XTextManager.GetText("MissionTaskCountContent"),data.TaskCount)
                break
            end
        end
    elseif curSectionId < data.Id then
        self.TxtNameB.text = data.Name
        local template = XConditionManager.GetConditionTemplate(data.ConditionId)
        if template then
            self.Txt1B.text = template.Desc
        end
    end



    --local stageId = tostring(template.Params[1])
    --local chapterStr = string.sub(stageId, 4, 4)




   -- self.ImgCondition.gameObject:SetActive(curSectionId < data.Id)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelMissionChapterGird:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiPanelMissionChapterGird:AutoInitUi()
    -- self.PanelChapterSlect = self.Transform:Find("PanelChapterSlect")
    -- self.ImgChapter = self.Transform:Find("PanelChapterSlect/ImgChapter"):GetComponent("Image")
    -- self.RImgIcon = self.Transform:Find("PanelChapterSlect/ImgChapter/RImgIcon"):GetComponent("RawImage")
    -- self.PanelTxt = self.Transform:Find("PanelChapterSlect/PanelTxt")
    -- self.Txt1 = self.Transform:Find("PanelChapterSlect/PanelTxt/Txt1"):GetComponent("Text")
    -- self.Txt2 = self.Transform:Find("PanelChapterSlect/PanelTxt/Txt2"):GetComponent("Text")
    -- self.Txt3 = self.Transform:Find("PanelChapterSlect/PanelTxt/Txt3"):GetComponent("Text")
    -- self.TxtName = self.Transform:Find("PanelChapterSlect/TxtName"):GetComponent("Text")
    -- self.PanelChapterHave = self.Transform:Find("PanelChapterHave")
    -- self.ImgChapterA = self.Transform:Find("PanelChapterHave/ImgChapter"):GetComponent("Image")
    -- self.RImgIconA = self.Transform:Find("PanelChapterHave/ImgChapter/RImgIcon"):GetComponent("RawImage")
    -- self.PanelTxtA = self.Transform:Find("PanelChapterHave/PanelTxt")
    -- self.Txt1A = self.Transform:Find("PanelChapterHave/PanelTxt/Txt1"):GetComponent("Text")
    -- self.Txt2A = self.Transform:Find("PanelChapterHave/PanelTxt/Txt2"):GetComponent("Text")
    -- self.Txt3A = self.Transform:Find("PanelChapterHave/PanelTxt/Txt3"):GetComponent("Text")
    -- self.TxtNameA = self.Transform:Find("PanelChapterHave/TxtName"):GetComponent("Text")
    -- self.PanelChapterLock = self.Transform:Find("PanelChapterLock")
    -- self.ImgLock = self.Transform:Find("PanelChapterLock/ImgLock"):GetComponent("Image")
    -- self.Txt1B = self.Transform:Find("PanelChapterLock/Txt1"):GetComponent("Text")
    -- self.TxtNameB = self.Transform:Find("PanelChapterLock/TxtName"):GetComponent("Text")
end

function XUiPanelMissionChapterGird:GetAutoKey(uiNode, eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiPanelMissionChapterGird:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiPanelMissionChapterGird:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiPanelMissionChapterGird:AutoAddListener()
    self.AutoCreateListeners = {}
end
-- auto
return XUiPanelMissionChapterGird