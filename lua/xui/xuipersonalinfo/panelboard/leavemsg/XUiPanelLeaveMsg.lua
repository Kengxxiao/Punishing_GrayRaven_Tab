XUiPanelLeaveMsg = XClass()

function XUiPanelLeaveMsg:Ctor(ui,rootUi)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    self:InitAutoScript()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelLeaveMsg:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiPanelLeaveMsg:AutoInitUi()
    self.PanelLeaveMsgItem = self.Transform:Find("PanelLeaveMsgItem")
end

function XUiPanelLeaveMsg:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiPanelLeaveMsg:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiPanelLeaveMsg:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiPanelLeaveMsg:AutoAddListener()
    self.AutoCreateListeners = {}
end
-- auto

function XUiPanelLeaveMsg:SetIsShow( code )  
    if self.GameObject ~= nil then
        self.GameObject.gameObject:SetActive(code)
    end
end
function XUiPanelLeaveMsg:Refresh( parent )
    XDataCenter.PersonalInfoManager.CreateItems(self.RootUi, self.PanelLeaveMsgItem, self.PanelLeaveMsgItem.gameObject.transform.parent,parent.pageNum,parent.data.Id,XDataCenter.PersonalInfoManager.ItemPanelType.DailyleaveMsg,function(items)
        self:SetIsShow(true)    
    end)
end

return XUiPanelLeaveMsg
