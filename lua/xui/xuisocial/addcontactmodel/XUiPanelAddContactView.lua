XUiPanelAddContactView = XClass()
local XUiGridAddContactItem = require("XUi/XUiSocial/AddContactModel/XUiGridAddContactItem")

local zerovector3 = CS.UnityEngine.Vector3.zero
local zerovector2 = CS.UnityEngine.Vector2.zero

function XUiPanelAddContactView:Ctor(ui,rootUi)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    self:InitAutoScript()

    self.RecommendedList = {}

    self.DynamicListManager = XDynamicTableNormal.New(self.GameObject)
    self.DynamicListManager:SetProxy(XUiGridAddContactItem)
    self.DynamicListManager:SetDelegate(self)
    self.PanelAddContactViewPools.gameObject:SetActive(false)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelAddContactView:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiPanelAddContactView:AutoInitUi()
    self.TxtMyId = self.Transform:Find("AddPanelOther/TxtMyId"):GetComponent("Text")
    self.BtnRefresh = self.Transform:Find("AddPanelOther/BtnRefresh"):GetComponent("Button")
    self.BtnCopy = self.Transform:Find("AddPanelOther/BtnCopy"):GetComponent("Button")
    self.BtnSerach = self.Transform:Find("AddPanelOther/BtnSerach"):GetComponent("Button")
    self.InFSerach = self.Transform:Find("AddPanelOther/InFSerach"):GetComponent("InputField")
    self.PanelAddContactViewPools = self.Transform:Find("PanelAddContactViewPools")
end

function XUiPanelAddContactView:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiPanelAddContactView:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiPanelAddContactView:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiPanelAddContactView:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterListener(self.BtnRefresh, "onClick", self.OnBtnRefreshClick)
    self:RegisterListener(self.BtnCopy, "onClick", self.OnBtnCopyClick)
    self:RegisterListener(self.BtnSerach, "onClick", self.OnBtnSerachClick)
end
-- auto

function XUiPanelAddContactView:OnBtnRefreshClick()--刷新推荐
    self:RefreshList(true)
    self.RootUi:PlayAnimation("ContactListShuaXin")
end

function XUiPanelAddContactView:OnBtnCopyClick(...)--CopyId
    local id = XPlayer.Id
    if id ~= nil then
        CS.XAppPlatBridge.CopyStringToClipboard(tostring(id))
    end
    XUiManager.TipSuccess(CS.XTextManager.GetText("CopySuccess"))
end

function XUiPanelAddContactView:OnBtnSerachClick(...)--搜索玩家
    local callback = function(serachFriend)
        local temp = {}
        table.insert(temp, serachFriend)
        self:InitDynamicList(temp)
    end

    local inputid = self:GetInputId()
    if inputid ~= nil and inputid ~= '' then
        if inputid == XPlayer.Id then
            XUiManager.TipText("FriendNotAddSelf")
        else
            XDataCenter.SocialManager.SearchPlayer(inputid, callback)
        end
    end
end
--------------------------End Btn Event--------------------------

function XUiPanelAddContactView:RefreshList(isButton)
    local callback = function(code,time)
        if code == XCode.Success then
            self:InitDynamicList()
            if isButton then
                XUiManager.TipText("FrienRefreshSuccess")
            end
        end
    end
    XDataCenter.SocialManager.GetRecommendPlayers(callback)
end

function XUiPanelAddContactView:InitDynamicList(contactData)
    self.ContactData = contactData or XDataCenter.SocialManager.GetRecommendList()
    if not self.ContactData then
        return
    end


    self.DynamicListManager:SetDataSource(self.ContactData)
    self.DynamicListManager:ReloadDataASync(1)
end

function XUiPanelAddContactView:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        grid:Refresh(self.ContactData[index])
    end
end

function XUiPanelAddContactView:StartCountDown(countDownTime)

end

function XUiPanelAddContactView:GetInputId()
    if self.InFSerach.text ~= '' then
        local num = tonumber(self.InFSerach.text)
        if num then
            return num
        end
    end
    return nil
end

function XUiPanelAddContactView:Show()
    if not self.GameObject:Exist() then
        return
    end
    self.GameObject:SetActive(true)
    self.RootUi:PlayAnimation("AddContactViewQieHuan")
    self:RefreshSelfInfo()
    self:RefreshList(false)
end

function XUiPanelAddContactView:Hide()
    if not self.GameObject:Exist() then
        return
    end

    self.GameObject:SetActive(false)
end

function XUiPanelAddContactView:RefreshSelfInfo()
    local myIdText = CS.XTextManager.GetText("FriendMyId")
    self.TxtMyId.text = string.format("%s %d", myIdText, XPlayer.Id)
end

function XUiPanelAddContactView:OnClose()
    self:Hide()

    if self.RecommendTimer ~= nil then
        CS.XScheduleManager.UnSchedule(self.RecommendTimer)
        self.RecommendTimer = nil
    end

    if self.SearchTimer ~= nil then
        CS.XScheduleManager.UnSchedule(self.SearchTimer)
        self.SearchTimer = nil
    end
end