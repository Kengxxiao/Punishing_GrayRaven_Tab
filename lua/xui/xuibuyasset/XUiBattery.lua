XUiBattery = Class()
local GoodsId = 1
local RewardIndex = 2
local FoEver = 0
local UnFoEver = 1
local FoEverText = CS.XTextManager.GetText("Forever")
local OverdueText = CS.XTextManager.GetText("TaskStateOverdue")
function XUiBattery:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = ui
    XTool.InitUiObject(self)
    self:AutoAddListener()
end

function XUiBattery:OnRecycle()
    if self.Timers then
        CS.XScheduleManager.UnSchedule(self.Timers)
        self.Timers = nil
    end
end

function XUiBattery:AutoAddListener()
    self.BtnClick.CallBack = function()
        self:OnBtnClick()
    end
end

function XUiBattery:OnBtnClick()
    if not self.IsCantUse then
        self.Base.SelectItem = self.BagItem
        self:SetSelectShow(self.Base)
        self.Base.OldSelectGrig:SetSelectShow(self.Base)
        self.Base.OldSelectGrig = self
    else
        XUiManager.TipError(OverdueText)
    end
end

function XUiBattery:UpdateGrid(bagItem, parent)
    self.Base = parent
    self.BagItem = bagItem
    self.GoodsShowParams = XGoodsCommonManager.GetGoodsShowParamsByTemplateId(self.BagItem.Data.Id)

    local count = bagItem.RecycleBatch and bagItem.RecycleBatch.RecycleCount or bagItem.Data:GetCount()
    -- 数量
    if self.TxtCount and count then
        self.TxtCount.text = CS.XTextManager.GetText("ShopGridCommonCount", count)
    end
    
    -- 图标
    if self.RImgIcon then
        local icon = self.GoodsShowParams.Icon 
        if icon and #icon > 0 then
            self.RImgIcon:SetRawImage(icon)
        end
    end
    
    if self.ImgQuality and self.GoodsShowParams.Quality then
        local qualityIcon = self.GoodsShowParams.QualityIcon
        
        if qualityIcon then
            parent:SetUiSprite(self.ImgQuality, qualityIcon)
        else
            XUiHelper.SetQualityIcon(parent, self.ImgQuality, self.GoodsShowParams.Quality)
        end
    end

    if self.BagItem.Data.Template.TimelinessType and
    self.BagItem.Data.Template.TimelinessType ~= FoEver then
        self.Timers = CS.XScheduleManager.ScheduleForever(function() self:SetTime() end, CS.XScheduleManager.SECOND)
    end
    
    self:SetTime()
    self:SetSelectShow(parent)
end

function XUiBattery:SetTime()
    local sprite = XUiHelper.TagBgPath.Green
    if not self.BagItem.Data.Template.TimelinessType or
    self.BagItem.Data.Template.TimelinessType == FoEver then
        self.TxtTime.text = FoEverText
        sprite = XUiHelper.TagBgPath.Green
        self.IsCantUse = false
    else
        local LifeTime = self.BagItem.RecycleBatch and self.BagItem.RecycleBatch.RecycleTime - XTime.GetServerNowTimestamp() or XDataCenter.ItemManager.GetRecycleLeftTime(self.BagItem.Data.Id)
        if LifeTime and LifeTime > 0 then
            local tmpTime = XUiHelper.GetTime(LifeTime,XUiHelper.TimeFormatType.MAINBATTERY)
            self.TxtTime.text = tmpTime
            if LifeTime > CS.XDateUtil.ONE_DAY_SECOND * 7 then
                sprite = XUiHelper.TagBgPath.Green
            elseif LifeTime > CS.XDateUtil.ONE_DAY_SECOND then
                sprite = XUiHelper.TagBgPath.Yellow
            else
                sprite = XUiHelper.TagBgPath.Red
            end
            self.IsCantUse = false
        else
            self.TxtTime.text = OverdueText
            sprite = XUiHelper.TagBgPath.Red
            self.IsCantUse = true
            if self.Base.SelectItem.Data.Id == self.BagItem.Data.Id and self.Base.SelectItem.GridIndex == self.BagItem.GridIndex then
                self.Base.SelectItem = nil
                self:SetSelectShow(self.Base)
            end
        end
    end
    self.Base:SetUiSprite(self.TimeTag, sprite)
end

function XUiBattery:SetSelectShow(parent)
    if parent.SelectItem.Data.Id == self.BagItem.Data.Id and parent.SelectItem.GridIndex == self.BagItem.GridIndex then
        self:ShowSelect(true)
        local goodsList = XRewardManager.GetRewardList(self.BagItem.Data.Template.SubTypeParams[RewardIndex])
        parent.TxtElectricNumPackage.text = goodsList[GoodsId].Count
    else
        self:ShowSelect(false)
    end
    if not self.Base.OldSelectGrig then 
        self.Base.OldSelectGrig = self
    end
end

function XUiBattery:ShowSelect(bShow)
    self.ImgSelect.gameObject:SetActiveEx(bShow)
end

return XUiBattery