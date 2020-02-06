-- 家具建造节点
XUiGridCreate = XClass()

local CREATE_STATE = {
    AVALIABLE = 0,
    CREATING = 1,
    COMPLETE = 2,
}
local WhiteColor = CS.UnityEngine.Color(1.0, 1.0, 1.0)
local BlackColor = CS.UnityEngine.Color(0.0, 0.0, 0.0)


function XUiGridCreate:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform

    self.CurrentState = nil
    self.WorkingTimer = nil
    self.CreateState = CREATE_STATE.AVALIABLE
    self.RemainingTime = 0
    
    XTool.InitUiObject(self)

    self:AddBtnsListeners()
    self.BtnStart.CallBack = function()
        if not self.Cfg then return end
        self.Parent:ShowPanelCreationDetail(self.Cfg.Pos)
    end
end

function XUiGridCreate:Rename(index)
    self.GameObject.name = string.format("GridCreate%d", index)
end

function XUiGridCreate:AddBtnsListeners()
    self.AutoCreateListeners = {}
    XUiHelper.RegisterClickEvent(self, self.BtnCheck, self.OnBtnCheckClick)
end

function XUiGridCreate:RegisterListener(uiNode, eventName, func)
    if not uiNode then return end
    local key = eventName .. uiNode:GetHashCode()
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end
    
    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiBtnTab:RegisterListener: func is not a function")
        end
        
        listener = function(...)
            func(self, ...)
        end
        
        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiGridCreate:Init(cfg, parent)
    self.Parent = parent
    self.Cfg = cfg
    
    self:UpdateCreate()
end

function XUiGridCreate:OnClose()
    self:RemoveWorkingTimer()
end

function XUiGridCreate:UpdateCreate()
    if not self.Cfg then return end
    local createDatas = XDataCenter.FurnitureManager.GetFurnitureCreateItemByPos(self.Cfg.Pos)
    
    local now = XTime.GetServerNowTimestamp()

    if createDatas then
        --这个坑位正在创造或者已经创造完成
        local configId = createDatas.Furniture.ConfigId
        local furnitureTemplates = XFurnitureConfigs.GetFurnitureTemplateById(configId)
        local furnitureBaseTemplates = XFurnitureConfigs.GetFurnitureBaseTemplatesById(configId)
        if (not furnitureTemplates) or (not furnitureBaseTemplates) then return end

        
        local finishTime = createDatas.EndTime
        self.RemainingTime = finishTime - now 
        self.RemainingTime= (self.RemainingTime < 0) and 0 or self.RemainingTime
        
        if finishTime > now  then
            --坑位正在制作家具
            local typeDatas = XFurnitureConfigs.GetFurnitureTypeById(furnitureTemplates.TypeId)
            if not typeDatas then return end
            self.ImgWorkingItemIcon:SetRawImage(typeDatas.TypeIcon)
            self.CreateState = CREATE_STATE.CREATING
            self.TxtWorkingFurnitureName.text = typeDatas.CategoryName
        else
            --坑位家具制作完成，可以领取
            self.ImgCompleteItemIcon:SetRawImage(XDataCenter.FurnitureManager.GetIconByFurniture(createDatas.Furniture))
            self.CreateState = CREATE_STATE.COMPLETE
            self.TxtCompleteFurnitureName.text = furnitureBaseTemplates.Name
            self:UpdateFurnitureCompleteAttris(createDatas.Furniture, furnitureTemplates)
        end

    else
        --这个坑位空闲
        self.CreateState = CREATE_STATE.AVALIABLE
    end

    local serialNumber = string.format("0%d", self.Cfg.Pos + 1)
    self.TxtStartLabel.text = serialNumber
    self.TxtWorkingLabel.text = serialNumber
    self.TxtCompleteLabel.text = serialNumber

    if self.CreateState == CREATE_STATE.CREATING then--剩余时间
        self:AddWorkingTimer()
    end

    self:UpdateCreateView(self.CreateState)
end

function XUiGridCreate:UpdateCreateView(currentState)
    self.PanelStart.gameObject:SetActive(currentState == CREATE_STATE.AVALIABLE)
    self.PanelWorking.gameObject:SetActive(currentState == CREATE_STATE.CREATING)
    self.PanelComplete.gameObject:SetActive(currentState == CREATE_STATE.COMPLETE)
end

function XUiGridCreate:UpdateFurnitureWorkingAttris(furniture, furnitureTemplates)
    if not furniture then return end
    for i=1, #furniture.AttrList do
        local attrScore = furniture.AttrList[i] or 0
        self[string.format("TxtWorkingValue%d", i)].text = XFurnitureConfigs.GetFurnitureAttrLevelDescription(furnitureTemplates.TypeId, i, attrScore)
    end
end
function XUiGridCreate:UpdateFurnitureCompleteAttris(furniture, furnitureTemplates)
    if not furniture then return end
    for i=1, #furniture.AttrList do
        local attrScore = furniture.AttrList[i] or 0
        self[string.format("TxtCompleteValue%d", i)].text = XFurnitureConfigs.GetFurnitureAttrLevelDescription(furnitureTemplates.TypeId, i, attrScore)
    end
end

function XUiGridCreate:AddWorkingTimer()
    self:RemoveWorkingTimer()
    local dataTime = XUiHelper.GetTime(self.RemainingTime, XUiHelper.TimeFormatType.HOSTEL)
    self.TxtRemaining.text = dataTime
    self.WorkingTimer = CS.XScheduleManager.Schedule(function(...)
        if XTool.UObjIsNil(self.Transform) then
            self:RemoveWorkingTimer()
            return
        end
        local dataTime
        self.RemainingTime = self.RemainingTime - 1
        if self.RemainingTime <= 0 then
            dataTime = XUiHelper.GetTime(0, XUiHelper.TimeFormatType.HOSTEL)
            self.TxtRemaining.text = dataTime
            self:RemoveWorkingTimer()
            self:UpdateCreate()
        else
            dataTime = XUiHelper.GetTime(self.RemainingTime, XUiHelper.TimeFormatType.HOSTEL)
            self.TxtRemaining.text = dataTime
        end
    end, 1000, 0, 0)
end

function XUiGridCreate:GetProgress()
    if not self.Cfg then return 0 end
    local createDatas = XDataCenter.FurnitureManager.GetFurnitureCreateItemByPos(self.Cfg.Pos)
    local now = XTime.GetServerNowTimestamp()
    if not createDatas then return 0 end
    
    local configId = createDatas.Furniture.ConfigId
    local furnitureTemplates = XFurnitureConfigs.GetFurnitureTemplateById(configId)
    local progress = (now - createDatas.EndTime + furnitureTemplates.CreateTime) / furnitureTemplates.CreateTime
    return (progress > 1) and 1 or progress
end

function XUiGridCreate:RemoveWorkingTimer()
    if self.WorkingTimer then
        CS.XScheduleManager.UnSchedule(self.WorkingTimer)
        self.WorkingTimer = nil
    end
end

function XUiGridCreate:OnBtnStartClick(...)
    self.Parent:ShowPanelCreationDetail(self.Cfg.Pos)
end

function XUiGridCreate:OnBtnCheckClick(...)
    -- 领取
    if self.CreateState and self.CreateState == CREATE_STATE.COMPLETE and self.Cfg then

        local createDatas = XDataCenter.FurnitureManager.GetFurnitureCreateItemByPos(self.Cfg.Pos)
        XDataCenter.FurnitureManager.CheckCreateFurniture(self.Cfg.Pos, function(furniture)
            if furniture then
                XLuaUiManager.Open("UiFurnitureDetail", furniture.Id, furniture.ConfigId)
            end
            self:UpdateCreate()
        end)
    end
end

return XUiGridCreate