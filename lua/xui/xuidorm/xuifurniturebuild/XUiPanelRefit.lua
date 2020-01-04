-- 家具改造子界面
XUiPanelRefit = XClass()

local DEFAULT_STRING1 = "？"
local DEFAULT_STRING2 = "无"
local DEFAULT_STRING3 = "选择家具"
local DEFAULT_DATA = {[1] = DEFAULT_STRING1, [2] = DEFAULT_STRING1, [3] = DEFAULT_STRING1 }

local EnoughColor = CS.UnityEngine.Color(0.0, 0.0, 0.0)
local NotEnoughColor = CS.UnityEngine.Color(1.0, 0.0, 0.0)

local CFG = {
    ConsumeCount = 3
}

function XUiPanelRefit:Ctor(rootUi, ui)
    self.RootUi = rootUi
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)

    self.SelectedFurnitureId = nil
    self.SelectedDrawingId = nil
    
    self.BtnSelectFurniture.CallBack = function() self:OnBtnSelectFurnitureClick() end
    self.BtnSelectDrawing.CallBack = function() self:OnBtnSelectDrawingClick() end
    self.BtnRefit.CallBack = function() self:OnBtnRefitClick() end
end

function XUiPanelRefit:Init()
    self:SelectFurniture()
    self:SelectDrawing()
    self.TxtConsume.text = CS.XTextManager.GetText("UiPanelRefitConsume")
    self.TxtSelectDrawing.text = CS.XTextManager.GetText("UiPanelRefitSelectDrawing")
end

function XUiPanelRefit:SetPanelActive(value)
    self.GameObject:SetActive(value)
    if not value then
        if self.SelectedFurnitureId then
            self:SelectFurniture()
        end
        if self.SelectedDrawingId then
            self:SelectDrawing()
        end
    else
        self.RootUi:PlayAnimRefitEnable()
    end
end

function XUiPanelRefit:CheckClearDrawing(furnitureId)
    if self.SelectedDrawingId then
        local selectedFurnitureDatas = XDataCenter.FurnitureManager.GetFurnitureById(furnitureId)
        local selectedFurnitureTemplate = XFurnitureConfigs.GetFurnitureTemplateById(selectedFurnitureDatas.ConfigId)
    
        local previewFurnitureId = XFurnitureConfigs.GetPreviewFurnitureByDrawingId(self.SelectedDrawingId)
        if not previewFurnitureId then 
            self.SelectedDrawingId = nil
            self:SelectDrawing()
            return 
        end
    
        local previewFurnitureTemplate = XFurnitureConfigs.GetFurnitureTemplateById(previewFurnitureId)
        if not previewFurnitureTemplate then 
            self.SelectedDrawingId = nil
            self:SelectDrawing()
            return 
        end
    
        if selectedFurnitureTemplate.TypeId ~= previewFurnitureTemplate.TypeId then
            self.SelectedDrawingId = nil
            self:SelectDrawing()
        end
    end
end

--显示选择的家具信息
function XUiPanelRefit:SelectFurniture(furnitureId)
    if furnitureId then
        local furnitureDatas = XDataCenter.FurnitureManager.GetFurnitureById(furnitureId)
        if not furnitureDatas then
            self:SelectFurniture()
            return 
        end

        -- 新增一个处理，如果已经选择了图纸，并且该图纸不能匹配当前的家具，清空
        self:CheckClearDrawing(furnitureId)

        self.SelectedFurnitureId = furnitureId
        local configId = furnitureDatas.ConfigId
        local furnitureTemplates = XFurnitureConfigs.GetFurnitureTemplateById(configId)
        local furnitureBaseTemplates = XFurnitureConfigs.GetFurnitureBaseTemplatesById(configId)

        self.TxtSelectFurniture.text = ""
        local totalScore = 0
        for k, v in pairs(furnitureDatas.AttrList or {}) do
            totalScore = totalScore + v
        end

        local addition = furnitureDatas.Addition or 0
        local introduce = DEFAULT_STRING2
        if addition > 0 then
            totalScore = totalScore + XFurnitureConfigs.GetAdditionalAddScore(addition)
            introduce = string.format("%s\n%s", XFurnitureConfigs.GetAdditionalRandomEntry(addition),XFurnitureConfigs.GetAdditionalRandomIntroduce(addition))
        end
        
        self.TxtSelectScore.gameObject:SetActive(true)
        self.TxtSelectSpecial.gameObject:SetActive(true)
        self.TxtSelectScore.text = CS.XTextManager.GetText("FurnitureRefitScore", totalScore)
        self.TxtSelectSpecial.text = introduce
        self.PanelSelectFrunitureInfo.gameObject:SetActive(true)
        self.ImgBtnSelectFurniture:SetRawImage(XDataCenter.FurnitureManager.GetFurnitureIconById(furnitureId, XDormConfig.DormDataType.Self))
        self.BtnSelectFurnitureCanvasGroup.alpha = 0
    else
        self.SelectedFurnitureId = nil
        self.TxtSelectFurniture.text = DEFAULT_STRING3
        self.TxtSelectScore.gameObject:SetActive(false)
        self.TxtSelectSpecial.gameObject:SetActive(false)
        self.PanelSelectFrunitureInfo.gameObject:SetActive(false)
        self.BtnSelectFurnitureCanvasGroup.alpha = 1
    end
    
    -- 计算消耗材料
    local ownFurnitureNum = XDataCenter.ItemManager.GetCount(XDataCenter.ItemManager.ItemId.FurnitureCoin)
    local needFurnitureNum = self:GetRefitNeedMoney(self.SelectedFurnitureId)
    self.TxtConsumeCount.text = needFurnitureNum
    self.ImgDrawingIcon:SetRawImage(XDataCenter.ItemManager.GetItemIcon(XDataCenter.ItemManager.ItemId.FurnitureCoin))
    if ownFurnitureNum >= needFurnitureNum then
        self.TxtConsumeCount.color = EnoughColor
    else
        self.TxtConsumeCount.color = NotEnoughColor
    end

    self:CheckPreview()
end

--显示选择的图纸信息
function XUiPanelRefit:SelectDrawing(DraftId)
    if DraftId then
        self.SelectedDrawingId = DraftId
        local icon = XDataCenter.ItemManager.GetItemIcon(DraftId)
        self.PanelSelectDrawingInfo.gameObject:SetActive(true)
        self.ImgSelectDrawing:SetRawImage(icon)
        self.TxtSelectDrawing.text = ""
        self.BtnSelectDrawingCanvasGroup.alpha = 0
    else
        self.SelectedDrawingId = nil
        self.PanelSelectDrawingInfo.gameObject:SetActive(false)
        self.TxtSelectDrawing.text = CS.XTextManager.GetText("UiPanelRefitSelectDrawing")
        self.BtnSelectDrawingCanvasGroup.alpha = 1
    end
    self:CheckPreview()
end

--显示预览信息
function XUiPanelRefit:CheckPreview()
    
    self.TxtPreviewScore.text = CS.XTextManager.GetText("FurnitureRefitScore", DEFAULT_STRING1)
    self.BtnSelectDrawing:SetDisable(false, true)
    self.PreviewKuangDisable.gameObject:SetActive(false)
    self.previewArrowDisable.gameObject:SetActive(false)
    self.previewArrowEnable.gameObject:SetActive(true)

    if self.SelectedFurnitureId and self.SelectedDrawingId then
        
        -- 通过图纸拿到要生成的家具ID，通过判断类型是否一致决定是否显示
        local previewFurnitureId = XFurnitureConfigs.GetPreviewFurnitureByDrawingId(self.SelectedDrawingId)
        if not previewFurnitureId then
            self.ImgPreviewItemIcon.gameObject:SetActive(false)
            return
        end
        
        -- -- 检查预览的家具，改装的家具类型是否一致
        local furnitureDatas = XDataCenter.FurnitureManager.GetFurnitureById(self.SelectedFurnitureId)
        local furnitureDatas = XFurnitureConfigs.GetFurnitureTemplateById(furnitureDatas.ConfigId)
        local previewDatas = XFurnitureConfigs.GetFurnitureTemplateById(previewFurnitureId)
        
        if furnitureDatas.TypeId ~= previewDatas.TypeId then
            self.ImgPreviewItemIcon.gameObject:SetActive(false)
            self.ImageAdd.gameObject:SetActive(false)
        else
            local furnitureBaseTemplates = XFurnitureConfigs.GetFurnitureBaseTemplatesById(previewFurnitureId)
            self.ImgPreviewItemIcon.gameObject:SetActive(true)
            self.ImgPreviewItemIcon:SetRawImage(furnitureBaseTemplates.Icon)
            self.ImageAdd.gameObject:SetActive(true)
        end
        
        -- 查询组随机属性
        local hasRandomGroup = previewDatas.RandomGroupId > 0
        self.PanelIcon.gameObject:SetActive(hasRandomGroup)
        if hasRandomGroup then
            local groupIntroduce = XFurnitureConfigs.GetGroupRandomIntroduce(previewDatas.RandomGroupId)
            local introduceBuffer = ""
            local a = {}
            for k, v in pairs(groupIntroduce) do
                for _,v1 in pairs(v) do
                    local k = XFurnitureConfigs.GetAdditionalRandomEntry(v1.Id,true)
                    if not a[k] then
                        a[k] = ""
                    end
                    a[k] = a[k] .. string.format("%s\n",v1.Introduce)
                end
            end
            for k,str in pairs(a)do
                local des = string.format("%s\n%s\n", k, str)
                introduceBuffer = introduceBuffer .. des
            end
            self.TxtPreviewSpecial.text = introduceBuffer
            self:ResizeRandomGroupContent()
        end

    else
        if self.SelectedFurnitureId == nil then
            -- 未选中家具，不能选择图纸
            self.BtnSelectDrawing:SetDisable(true, false)
            self.PreviewKuangDisable.gameObject:SetActive(true)
            self.previewArrowDisable.gameObject:SetActive(true)
            self.previewArrowEnable.gameObject:SetActive(false)
        end

        self.ImgPreviewItemIcon.gameObject:SetActive(false)
        self.PanelIcon.gameObject:SetActive(false)
        self.ImageAdd.gameObject:SetActive(false)
    end
end

function XUiPanelRefit:ResizeRandomGroupContent()
    local rectTranform = self.TxtPreviewSpecial.transform:GetComponent("RectTransform")
    local adjustHeight = self.TxtPreviewSpecial.preferredHeight
    local sizeDelta = rectTranform.sizeDelta
    rectTranform.sizeDelta = CS.UnityEngine.Vector2(sizeDelta.x, adjustHeight)
end

function XUiPanelRefit:GetRefitNeedMoney(id)
    if id then
        local furnitureDatas = XDataCenter.FurnitureManager.GetFurnitureById(id)
        if not furnitureDatas then
            return 0
        else
            local configId = furnitureDatas.ConfigId
            local furnitureTemplates = XFurnitureConfigs.GetFurnitureTemplateById(configId)
            return furnitureTemplates.MoneyNum
        end
    else
        return 0
    end
end

function XUiPanelRefit:OnBtnSelectFurnitureClick(...)
    --TODO
    --跳转到仓库选择一个家具
    local pageRecord = XDormConfig.DORM_BAG_PANEL_INDEX.FURITURE
    local furnitureState = XFurnitureConfigs.FURNITURE_STATE.SELECT
    local func = function(furnitureId)
        self:SelectFurniture(furnitureId)
    end
    
    XLuaUiManager.Open("UiDormBag", pageRecord, furnitureState, func)
end

function XUiPanelRefit:OnBtnSelectDrawingClick(...)
    --TODO
    --跳转到仓库选择一个图纸
    local pageRecord = XDormConfig.DORM_BAG_PANEL_INDEX.DRAFT
    local furnitureState = XFurnitureConfigs.FURNITURE_STATE.SELECT
    local func = function(draftId)
        self:SelectDrawing(draftId)
    end
    local filter = function(drawingId)
        if self.SelectedFurnitureId then
            local selectedFurnitureDatas = XDataCenter.FurnitureManager.GetFurnitureById(self.SelectedFurnitureId)
            local selectedFurnitureTemplate = XFurnitureConfigs.GetFurnitureTemplateById(selectedFurnitureDatas.ConfigId)

            local typeDatas = XFurnitureConfigs.GetRefitTypeDatas(selectedFurnitureTemplate.TypeId) or {}
            for k, v in pairs(typeDatas) do
                if v.PicId == drawingId and v.GainType == XFurnitureConfigs.GainType.Refit then
                    return true
                end
            end
            return false
            
        end
        return true
    end
    XLuaUiManager.Open("UiDormBag", pageRecord, furnitureState, func, filter)
end

function XUiPanelRefit:OnBtnRefitClick(...)
    if not self.SelectedFurnitureId then
        XUiManager.TipMsg(CS.XTextManager.GetText("FurnitureChooseFurniture"))
        return
    end

    if not self.SelectedDrawingId then
        XUiManager.TipMsg(CS.XTextManager.GetText("FurnitureChooseDraft"))
        return
    end

    -- 图纸是否可以改装家具,通过图纸找到改装之后的家具，然后判断：改装之后生成的家具、用于改装的家具两者类型是否一致。
    local previewFurnitureId = XFurnitureConfigs.GetPreviewFurnitureByDrawingId(self.SelectedDrawingId)
    if not previewFurnitureId then
        XUiManager.TipMsg(CS.XTextManager.GetText("FunitureCannotCompound"))
        return
    end
    
    -- 检查预览的家具，改装的家具类型是否一致
    local furnitureDatas = XDataCenter.FurnitureManager.GetFurnitureById(self.SelectedFurnitureId)
    local previewTypeId = XFurnitureConfigs.GetFurnitureTemplateById(previewFurnitureId).TypeId
    local selectTypeId = XFurnitureConfigs.GetFurnitureTemplateById(furnitureDatas.ConfigId).TypeId
    if previewTypeId ~= selectTypeId then
        XUiManager.TipMsg(CS.XTextManager.GetText("FurnitureNotMatchDraft"))
        return
    end

    XDataCenter.FurnitureManager.RemouldFurniture(self.SelectedFurnitureId, self.SelectedDrawingId, function(furniture)
        self:Init()
        if furniture then
            XUiManager.TipMsg(CS.XTextManager.GetText("FurnitureRefitSuccess"), XUiManager.UiTipType.Tip, function()
                XLuaUiManager.Open("UiFurnitureDetail", furniture.Id, furniture.ConfigId)
            end)
        end
    end)
end

return XUiPanelRefit