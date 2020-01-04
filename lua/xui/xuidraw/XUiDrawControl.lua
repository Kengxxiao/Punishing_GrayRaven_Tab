local XUiDrawControl = XClass()
local characterRecord = require("XUi/XUiDraw/XUiDrawTools/XUiDrawCharacterRecord")

local DrawButton = {
    Tips = nil,
    DrawCount = 0,
    Btn = nil,
}

local MAX_DRAW_BTN_COUNT = 3

function XUiDrawControl:Ctor(rootUi, drawInfo, drawCb, uiDraw)
    self.RootUi = rootUi
    self.DrawInfo = drawInfo
    self.DrawCb = drawCb
    self.UiDraw = uiDraw
    self.DrawBtns = {}
    self.IsCanDraw = true
    self:InitRes()
    self:InitButtons()
    self:Update(drawInfo)
    return self
end

function XUiDrawControl:InitRes()
    self.UseItemIcon = XDataCenter.ItemManager.GetItemBigIcon(self.DrawInfo.UseItemId)
    self.TxtDrawCount = XUiHelper.TryGetComponent(self.RootUi.PanelDrawButtons, "TxtTotalDrawCount", "Text")
end

function XUiDrawControl:InitButtons()
    for i = 1, MAX_DRAW_BTN_COUNT do
        local btnName = "BtnDraw" .. i
        local btn = XUiHelper.TryGetComponent(self.RootUi.PanelDrawButtons, btnName)
        if btn then
            self:InitButton(btn, i)
        end
    end
end

function XUiDrawControl:InitButton(btn, index)
    --@DATA
    local drawCount = self.DrawInfo.BtnDrawCount[index]
    btn.transform:Find("TxtDrawDesc"):GetComponent("Text").text = CS.XTextManager.GetText("DrawCount", drawCount)
    local itemIcon = btn.transform:Find("ImgUseItemIcon"):GetComponent("RawImage")
    itemIcon:SetRawImage(self.UseItemIcon)
    btn.transform:Find("TxtUseItemCount"):GetComponent("Text").text = drawCount * self.DrawInfo.UseItemCount

    self.DrawBtns[index] = {
        Tips = btn.transform:Find("ImgTips"),
        DrawCount = drawCount,
        Btn = btn
    }

    self.RootUi:RegisterClickEvent(btn:GetComponent("Button"), function()
        self.UiDraw:UpdateItemCount()
        self:OnDraw(drawCount)
    end)
end

function XUiDrawControl:OnDraw(drawCount)
    local info
    local list

    if not XDataCenter.ItemManager.DoNotEnoughBuyAsset(self.DrawInfo.UseItemId,
    self.DrawInfo.UseItemCount,
    drawCount,
    function() self.UiDraw:UpdateItemCount() end,
    "DrawNotEnoughError") then
        return
    end

    if self.IsCanDraw then
        self.IsCanDraw = false
        local onAnimFinish = function()
            if list and #list > 0 then
                self.IsCanDraw = true
                self.UiDraw:PushShow(info, list)
            else
                --self.UiDraw:ResetUiView()
                --self.UiDraw:ResetScene()
            end
        end

        characterRecord.Record()

        XDataCenter.DrawManager.DrawCard(self.DrawInfo.Id, drawCount, function(drawInfo, rewardList)
            XDataCenter.AntiAddictionManager.BeginDrawCardAction()
            if self.DrawCb then
                self.DrawCb()
            end

            self:Update(drawInfo)
            info = drawInfo
            list = rewardList
            self.UiDraw:HideUiView(onAnimFinish)
        end)
    end
end

function XUiDrawControl:Update(drawInfo)
    self.DrawInfo = drawInfo

    if self.TxtDrawCount then
        self.TxtDrawCount.text = CS.XTextManager.GetText("DrawTotalCount", drawInfo.TotalCount)
    end
end

return XUiDrawControl