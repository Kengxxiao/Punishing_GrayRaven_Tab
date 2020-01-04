local XUiAutoFightRecord = XClass()

local stringformat = string.format
local tableinsert = table.insert

local AnimName = "AniAutoFightTemplate"

function XUiAutoFightRecord:Ctor(ui, parent)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Parent = parent
    self:InitAutoScript()
end

function XUiAutoFightRecord:SetData(index, record, onRemove)
    self:SetIndex(index)
    self:SetStageType(record)
    self.Record = record
    self.OnRemove = onRemove
    self.TxtStageName.text = XDataCenter.FubenManager.GetStageName(record.StageId)
    self.TimerName = "AutoFightRecord" .. index
    self:InitCharacters()
    self:BindTimer()
    self.GameObject:SetActive(true)
end

function XUiAutoFightRecord:SetIndex(index)
    self.Index = index
    self.TxtIndex.text = stringformat("%02d", index)
end

-- 新增接口,加入前传类型，默认主线
function XUiAutoFightRecord:SetStageType(record)
    local stageInfo = XDataCenter.FubenManager.GetStageInfo(record.StageId)
    if stageInfo.Type == XDataCenter.FubenManager.StageType.Prequel then
        self.TxtStageType.text = CS.XTextManager.GetText("AutoFightStagePrequelType")
    else
        self.TxtStageType.text = CS.XTextManager.GetText("AutoFightStageMainType")
    end
    
end

function XUiAutoFightRecord:InitCharacters()
    local stageCfg = XDataCenter.FubenManager.GetStageCfg(self.Record.StageId)
    local cardIds = self.Record.CardIds
    if stageCfg.RobotId and #stageCfg.RobotId > 0 then
        cardIds = {}
        for k, v in pairs(stageCfg.RobotId) do
            local charId = XRobotManager.GetCharaterId(v)
            tableinsert(cardIds, charId)
        end
    end
    for i, id in pairs(cardIds) do
        if id > 0 then
            local transform
            if i == 1 then
                transform = self.CharacterTemplate
            else
                transform = CS.UnityEngine.Object.Instantiate(self.CharacterTemplate, self.PanelCharacters)
            end

            local img = transform:Find("RImgIcon"):GetComponent("RawImage")
            local icon = XDataCenter.CharacterManager.GetCharRoundnessHeadIcon(id)
            img:SetRawImage(icon)
        end
    end
end

function XUiAutoFightRecord:BindTimer()
    local now = XTime.Now()
    local remainTime = self.Record.CompleteTime - now
    local complete = remainTime <= 0
    self:SetState(complete)
    XCountDown.CreateTimer(self.TimerName, remainTime, now)
    XCountDown.BindTimer(self.GameObject, self.TimerName, function(v, oldV)
        if v == 0 then
            self.Transform:PlayLegacyAnimation(AnimName, function()
                self:SetState(true)
            end)
            self:RemoveTimer()
        else
            self.TxtCountdown.text = XUiHelper.GetTime(v)
        end
    end)
end

function XUiAutoFightRecord:RemoveTimer()
    XCountDown.RemoveTimer(self.TimerName)
end

function XUiAutoFightRecord:SetState(complete)
    self.PanelFighting.gameObject:SetActive(not complete)
    self.BtnObtain.gameObject:SetActive(complete)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiAutoFightRecord:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiAutoFightRecord:AutoInitUi()
    self.TxtIndex = self.Transform:Find("RecordTemplate/TxtIndex"):GetComponent("Text")
    self.TxtStageType = self.Transform:Find("RecordTemplate/TxtStageType"):GetComponent("Text")
    self.TxtStageName = self.Transform:Find("RecordTemplate/TxtStageName"):GetComponent("Text")
    self.BtnObtain = self.Transform:Find("RecordTemplate/BtnObtain"):GetComponent("Button")
    self.PanelFighting = self.Transform:Find("RecordTemplate/PanelFighting")
    self.TxtCountdown = self.Transform:Find("RecordTemplate/PanelFighting/TxtCountdown"):GetComponent("Text")
    self.PanelCharacters = self.Transform:Find("RecordTemplate/PanelCharacters")
    self.CharacterTemplate = self.Transform:Find("RecordTemplate/PanelCharacters/CharacterTemplate")
end

function XUiAutoFightRecord:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiAutoFightRecord:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiAutoFightRecord:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiAutoFightRecord:AutoAddListener()
    self:RegisterClickEvent(self.BtnObtain, self.OnBtnObtainClick)
end
-- auto
function XUiAutoFightRecord:OnBtnObtainClick(eventData)
    XDataCenter.AutoFightManager.ObtainRewards(self.Index, function(res)
        if res.Code == XCode.Success then
            self.OnRemove(self.Index)
        end
    end)
end

function XUiAutoFightRecord:OnDestroy()
    self.BtnObtain.interactable = false
    self:RemoveTimer()
end

return XUiAutoFightRecord