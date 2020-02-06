local XUiDormFoundryDetailItem = XClass()
local DormManager
local TextManager

function XUiDormFoundryDetailItem:Ctor(ui)
    TextManager = CS.XTextManager
    DormManager = XDataCenter.DormManager
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
end

-- 更新数据
function XUiDormFoundryDetailItem:OnRefresh(itemData)
    if not itemData then
        return
    end

    local iconpath = itemData.CurIconpath
    if iconpath and self.CurIconpath ~= iconpath then
        self.CurIconpath = iconpath
        self.UiRoot:SetUiSprite(self.ImgIcon,iconpath)
    end
    
    self.MoodValue.text = string.format( "-%s",math.floor(itemData.DaiGongData.Mood/100))
end

function XUiDormFoundryDetailItem:Init(parent,uiroot)
    self.Parent = parent
    self.UiRoot = uiroot
end
return XUiDormFoundryDetailItem