XUiGridDailyBanner = XClass()

function XUiGridDailyBanner:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
end

function XUiGridDailyBanner:UpdateGrid(chapter, parent)
    self.RImgIcon:SetRawImage(chapter.Icon)
    self.TxtName.text = chapter.Title
    self.TxtRemainCount.text = ""
    self.TxtSimpleDesc.text = chapter.Describe
    
    local tmpText = ""
    local IsAllDay = false
    tmpText,IsAllDay = XDataCenter.FubenDailyManager.GetOpenDayString(chapter)
    
    if IsAllDay then 
        self.TxtRemainCount.text = tmpText
    else
        self.TxtRemainCount.text = CS.XTextManager.GetText("FubenDailyOpenRemark", tmpText)
    end
    
    
    local ConditionNameId = XDataCenter.FubenDailyManager.GetConditionData(chapter.Id).functionNameId
    local IsConditionLock = XDataCenter.FubenDailyManager.GetConditionData(chapter.Id).IsLock
    local IsDayLock = XDataCenter.FubenDailyManager.IsDayLock(chapter.Id)
    local IsEventOpen = XDataCenter.FubenDailyManager.GetEventOpen(chapter.Id).IsOpen
    local EventText = XDataCenter.FubenDailyManager.GetEventOpen(chapter.Id).Text
    
    if IsConditionLock then
        self.PanelLock.gameObject:SetActive(true)
        self.ImgEvent.gameObject:SetActive(false)
        self.TxtLock.text = CS.XTextManager.GetText("NotUnlock")
    else
        if IsEventOpen then
            self.PanelLock.gameObject:SetActive(false)
            self.ImgEvent.gameObject:SetActive(true)
            self.TxtEvent.text = EventText
        else
            if IsDayLock then
                self.PanelLock.gameObject:SetActive(true)
            else
                self.PanelLock.gameObject:SetActive(false)
            end
            self.TxtLock.text = CS.XTextManager.GetText("NotUnlock")
            self.ImgEvent.gameObject:SetActive(false)
        end
    end
end

return XUiGridDailyBanner 