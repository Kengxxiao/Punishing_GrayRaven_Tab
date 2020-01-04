local next = next
local tableInsert = table.insert

local XUiPanelTask = require("XUi/XUiActivityBase/XUiPanelTask")
local XUiPanelShop = require("XUi/XUiActivityBase/XUiPanelShop")
local XUiPanelSkip = require("XUi/XUiActivityBase/XUiPanelSkip")

local XUiActivityBaseChild = XLuaUiManager.Register(XLuaUi, "UiActivityBaseChild")

function XUiActivityBaseChild:OnStart(activityGroupInfos, selectIndex)
    local isAcitivityOpen = next(activityGroupInfos)
    self.PaneNothing.gameObject:SetActive(not isAcitivityOpen)
    self.ScrollTitleTab.gameObject:SetActive(isAcitivityOpen)
    self.PanelRightContent.gameObject:SetActive(isAcitivityOpen)
    self.RImgContentBg.gameObject:SetActive(isAcitivityOpen)
    if not isAcitivityOpen then return end

    self.ActivityGroupInfos = activityGroupInfos
    self:UpdateActivityInfos(selectIndex)
end

function XUiActivityBaseChild:OnEnable()
    if self.SelectIndex then 
        self.PanelNoticeTitleBtnGroup:SelectIndex(self.SelectIndex)
    end
end

function XUiActivityBaseChild:OnDestroy()
    if self.ShopPanel then
        self.ShopPanel:OnDestroy()
    end
end

function XUiActivityBaseChild:OnGetEvents()
    return { XEventId.EVENT_FINISH_TASK }
end

function XUiActivityBaseChild:OnNotify(evt, ...)
    if evt == XEventId.EVENT_FINISH_TASK then
        self.PanelNoticeTitleBtnGroup:SelectIndex(self.SelectIndex)
    end
end

function XUiActivityBaseChild:UpdateActivityInfos(selectIndex)
    self.AcitivityIndexDic = {}
    self:UpdateLeftTabBtns(selectIndex)
end

function XUiActivityBaseChild:UpdateLeftTabBtns(selectIndex)
    self.TabBtns = {}
    local btnIndex = 0
    local firstRedPointIndex

    --一级标题
    for groupId, activityGroupInfo in ipairs(self.ActivityGroupInfos) do
        local activityGroupCfg = activityGroupInfo.ActivityGroupCfg

        local btn = btnIndex == 0 and self.BtnFirst or CS.UnityEngine.Object.Instantiate(self.BtnFirst)
        btn.transform:SetParent(self.PanelNoticeTitleBtnGroup.transform, false)
        btn:SetName(activityGroupCfg.Name)

        local bg = btn.transform:Find("RImgBg"):GetComponent("RawImage")
        bg:SetRawImage(activityGroupCfg.Bg)

        local uiButton = btn:GetComponent("XUiButton")
        tableInsert(self.TabBtns, uiButton)
        btnIndex = btnIndex + 1
        local firstNeedRed = false

        --二级标题
        local needRedPoint = false
        local firstIndex = btnIndex
        local activityCfgs = activityGroupInfo.ActivityCfgs
        local onlyOne = #activityCfgs == 1
        for activityIndex, activityCfg in ipairs(activityCfgs) do
            needRedPoint = XDataCenter.ActivityManager.CheckRedPointByActivityId(activityCfg.Id)

            if not onlyOne then
                local btn = CS.UnityEngine.Object.Instantiate(self.BtnSecond)
                btn:SetName(activityCfg.Name)
                btn.transform:SetParent(self.PanelNoticeTitleBtnGroup.transform, false)
                btn.gameObject:SetActive(true)

                local uiButton = btn:GetComponent("XUiButton")
                uiButton.SubGroupIndex = firstIndex
                tableInsert(self.TabBtns, uiButton)
                btnIndex = btnIndex + 1

                if needRedPoint then
                    uiButton:ShowReddot(true)
                    if not firstRedPointIndex then
                        firstRedPointIndex = btnIndex
                    end
                    firstNeedRed = true
                else
                    uiButton:ShowReddot(false)
                end
            end

            local activityIndexInfo = {
                ActivityIndex = activityIndex,
                GroupId = groupId
            }
            self.AcitivityIndexDic[btnIndex] = activityIndexInfo
        end

        uiButton:ShowReddot(firstNeedRed)
    end
    self.BtnSecond.gameObject:SetActive(false)

    self.PanelNoticeTitleBtnGroup:Init(self.TabBtns, function(index) self:OnSelectedTog(index) end)
    self.SelectIndex = selectIndex or firstRedPointIndex or 1
end

function XUiActivityBaseChild:OnSelectedTog(index)
    self.SelectIndex = index

    local activityIndexInfo = self.AcitivityIndexDic[index]
    if not activityIndexInfo or not next(activityIndexInfo) then
        return
    end
    local groupId = activityIndexInfo.GroupId
    local activityIndex = activityIndexInfo.ActivityIndex
    local activityGroupInfo = self.ActivityGroupInfos[groupId]
    local activityCfgs = activityGroupInfo.ActivityCfgs
    local activityCfg = activityCfgs[activityIndex]

    --刷新右边UI
    if activityCfg.ActivityType == XActivityConfigs.ActivityType.Task then
        self.PanelTask.gameObject:SetActive(true)
        self.PanelShop.gameObject:SetActive(false)
        self.PanelSkip.gameObject:SetActive(false)
        self:UpdatePanelTask(activityCfg)
    elseif activityCfg.ActivityType == XActivityConfigs.ActivityType.Shop then
        self.PanelShop.gameObject:SetActive(true)
        self.PanelSkip.gameObject:SetActive(false)
        self.PanelTask.gameObject:SetActive(false)
        self:UpdatePanelShop(activityCfg)
    elseif activityCfg.ActivityType == XActivityConfigs.ActivityType.Skip then
        self.PanelSkip.gameObject:SetActive(true)
        self.PanelShop.gameObject:SetActive(false)
        self.PanelTask.gameObject:SetActive(false)
        self:UpdatePanelSkip(activityCfg)
    end

    self.RImgContentBg:SetRawImage(activityCfg.ActivityBg)

    --刷新小红点
    XDataCenter.ActivityManager.SaveInGameNoticeReadList(activityCfg.Id)
    local uiButton = self.TabBtns[index]
    local needRedPoint = XDataCenter.ActivityManager.CheckRedPointByActivityId(activityCfg.Id)
    uiButton:ShowReddot(needRedPoint)

    --判断一级按钮小红点
    local subGroupIndex = uiButton.SubGroupIndex
    if subGroupIndex and self.TabBtns[subGroupIndex] then
        local needRed = false
        for _, btn in pairs(self.TabBtns) do
            if btn.SubGroupIndex and btn.SubGroupIndex == subGroupIndex
            and btn.ReddotObj.activeSelf then
                needRed = true
                break
            end
        end
        self.TabBtns[subGroupIndex]:ShowReddot(needRed)
    end

    self:PlayAnimation("QieHuanTwo", function()
        XLuaUiManager.SetMask(false)
    end, function()
        XLuaUiManager.SetMask(true)
    end)
end

function XUiActivityBaseChild:UpdatePanelTask(activityCfg)
    self.TaskPanel = self.TaskPanel or XUiPanelTask.New(self.PanelTask.gameObject, self)
    self.TaskPanel:Refresh(activityCfg)
end

function XUiActivityBaseChild:UpdatePanelShop(activityCfg)
    self.ShopPanel = self.ShopPanel or XUiPanelShop.New(self.PanelShop.gameObject, self)
    self.ShopPanel:Refresh(activityCfg)
end

function XUiActivityBaseChild:UpdatePanelSkip(activityCfg)
    self.SkipPanel = self.SkipPanel or XUiPanelSkip.New(self.PanelSkip.gameObject)
    self.SkipPanel:Refresh(activityCfg)
end