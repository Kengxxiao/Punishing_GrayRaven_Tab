local CsXTextManager = CS.XTextManager

local XUiGridActivityBranchReward = XClass()

function XUiGridActivityBranchReward:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
    self.GridList = {}
end

function XUiGridActivityBranchReward:SetRootUi(rootUi)
    self.RootUi = rootUi
end

function XUiGridActivityBranchReward:Refresh(sectionCfg,curSectionId)
    local sectionId = sectionCfg.Id

    self.TxtSection.text = sectionCfg.Name
    self.TxtLevel.text = CsXTextManager.GetText("ActivityBranchCurLevelDes", sectionCfg.MinLevel, sectionCfg.MaxLevel)
    self.TxtCur.gameObject:SetActive(curSectionId == sectionId)
    self.RootUi:SetUiSprite(self.ImgIcon, sectionCfg.Icon)

    --显示的奖励
    local rewards = XRewardManager.GetRewardList(sectionCfg.ShowRewardId)
    local start = 0
    for i, item in ipairs(rewards) do
        start = i
        local grid = nil
        if self.GridList[i] then
            grid = self.GridList[i]
        else
            local ui = CS.UnityEngine.Object.Instantiate(self.GridCommon)
            grid = XUiGridCommon.New(self.RootUi, ui)
            grid.Transform:SetParent(self.PanelRewards, false)
            self.GridList[i] = grid
        end
        grid:Refresh(item)
        grid.GameObject:SetActive(true)
    end

    for j = start + 1, #self.GridList do
        self.GridList[j].GameObject:SetActive(false)
    end
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridActivityBranchReward:InitAutoScript()
    XTool.InitUiObject(self)
    self:AutoAddListener()
end

function XUiGridActivityBranchReward:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiGridActivityBranchReward:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiGridActivityBranchReward:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiGridActivityBranchReward:AutoAddListener()
end
-- auto
return XUiGridActivityBranchReward