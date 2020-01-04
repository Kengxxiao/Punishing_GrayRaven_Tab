XUiPanelLeaveMsgItem = XClass()

function XUiPanelLeaveMsgItem:Ctor(rootUi,ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    self:InitAutoScript()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelLeaveMsgItem:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiPanelLeaveMsgItem:AutoInitUi()
    self.ImgIcon = self.Transform:Find("ImgIcon"):GetComponent("Image")
    self.PanelTop = self.Transform:Find("PanelTop")
    self.TxtName = self.Transform:Find("PanelTop/TxtName"):GetComponent("Text")
    self.TxtTime = self.Transform:Find("PanelTop/TxtTime"):GetComponent("Text")
    self.PanelTxtContent = self.Transform:Find("PanelTxtContent")
    self.TxtContent = self.Transform:Find("PanelTxtContent/TxtContent"):GetComponent("Text")
    if not XTool.UObjIsNil(self.Transform:Find("BtnDelete")) then
        self.BtnDelete = self.Transform:Find("BtnDelete"):GetComponent("Button")
    end
end

function XUiPanelLeaveMsgItem:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiPanelLeaveMsgItem:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiPanelLeaveMsgItem:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end
function XUiPanelLeaveMsgItem:AutoAddListener()
    self.AutoCreateListeners = {}
    if not XTool.UObjIsNil(self.BtnDelete) then
        self:RegisterListener(self.BtnDelete, "onClick", self.OnBtnBtnDeleteClick)
    end
end
-- auto

function XUiPanelLeaveMsgItem:OnBtnBtnDeleteClick( ... )
    XDataCenter.PersonalInfoManager.DeleteLeaveMsg(self.ParentId,self.data.Id,function( ... )
        XDataCenter.PersonalInfoManager.RefreshLeaveMsgData(self.data.DailyId,self.pageNum,
        function( ... )
         XDataCenter.PersonalInfoManager.PanelMsgBoard:Refresh()
        end)
    end)
end

function XUiPanelLeaveMsgItem:SetProperty( data,index,pageNum,parentId)
    self.data = data
    self.index = index
    self.pageNum = pageNum
    self.ParentId = parentId
    self:RefreshPanel()
end

function XUiPanelLeaveMsgItem:RefreshPanel()
    self.TxtContent.text = self.data.Content
    self.TxtName.text = self.data.Name
    self.RootUi:SetUiSprite(self.ImgIcon, XPlayerManager.GetHeadPortraitInfoById(self.data.CurrHeadPortraitId).ImgSrc)
    self.TxtTime.text = XUiHelper.CalcLatelyLoginTime(self.data.LeaveMsgTime)
    self.GameObject.gameObject:SetActive(true)
end

return XUiPanelLeaveMsgItem
