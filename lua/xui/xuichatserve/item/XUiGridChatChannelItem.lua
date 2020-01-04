local XUiGridChatChannelItem = XClass()
local XUiButtonState = CS.UiButtonState
local isShowChannelNumber = CS.XGame.ClientConfig:GetInt("IsShowChannelNumber")

function XUiGridChatChannelItem:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform

    XTool.InitUiObject(self)
end

function XUiGridChatChannelItem:Init(uiRoot)
    self.UiRoot = uiRoot
end

function XUiGridChatChannelItem:SetItemData(itemData)
    self.GridChannelItem:SetNameByGroup(0, CS.XTextManager.GetText("ChannelLabel"))
    self.GridChannelItem:SetNameByGroup(1, tostring(itemData.ChannelId))
    
    if isShowChannelNumber == 1 then
        self.GridChannelItem:SetNameByGroup(2, CS.XTextManager.GetText("ChannelNumberLabel", itemData.PlayerNum))
    else
        self.GridChannelItem:SetNameByGroup(2, "")
    end
    
    local isSelectChannel = itemData.ChannelId == XDataCenter.ChatManager.GetCurrentChatChannelId()
    self.GridChannelItem:ShowTag(isSelectChannel)
    self:SetChannelSelected(itemData.IsSelected)
end

function XUiGridChatChannelItem:SetChannelSelected(isSelected)
    local btnState = isSelected and XUiButtonState.Select or XUiButtonState.Normal
    self.GridChannelItem:SetButtonState(btnState)
end

return XUiGridChatChannelItem