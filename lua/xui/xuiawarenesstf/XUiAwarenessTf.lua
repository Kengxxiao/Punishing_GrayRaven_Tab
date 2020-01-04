local XUiAwarenessTf = XLuaUiManager.Register(XLuaUi, "UiAwarenessTf")
local XUiGridEquip = require("XUi/XUiEquipAwarenessReplace/XUiGridEquip")
local MAX_MATERIAL_SLOT = 3
function XUiAwarenessTf:OnAwake()
    self:InitAutoScript()
end


function XUiAwarenessTf:OnStart(targetTemplateId)
    self.TemplateId = targetTemplateId
    --当前背包要选择的材料位置（1，2，3）
    self.CurSelectPos = 1
    self.CurBagSelectEquipId = {0,0,0}
    --有顺序1（Main），2，3
    self.CurMaterialEquipId = {0,0,0}
    self.MaterialGrid = {}
    self.AwarenessTfBagList = {}
    self.SuitId = XEquipConfig.GetEquipCfg(self.TemplateId).SuitId
    self.EquipIds = XDataCenter.EquipManager.GetEquipIdsBySuitId(self.SuitId)
    self.UpSort = true
    self:InitTargetInfo()
    self:UpdateConformBtn()
    self:UpdateMaterialBtn()
end

function XUiAwarenessTf:OnEnable()
end


function XUiAwarenessTf:OnDisable()
end


function XUiAwarenessTf:OnDestroy()
end


function XUiAwarenessTf:OnGetEvents()
    return nil
end


function XUiAwarenessTf:OnNotify(evt,...)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiAwarenessTf:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiAwarenessTf:AutoInitUi()
    self.PanelMaterial = self.Transform:Find("SafeAreaContentPane/PanelMaterial")
    self.GridMaterial2 = self.Transform:Find("SafeAreaContentPane/PanelMaterial/Material2/GridMaterial2")
    self.GridMaterial1 = self.Transform:Find("SafeAreaContentPane/PanelMaterial/Material1/GridMaterial1")
    self.BtnSelectMaterial1 = self.Transform:Find("SafeAreaContentPane/PanelMaterial/Material1/BtnSelectMaterial1"):GetComponent("Button")
    self.BtnStartTf = self.Transform:Find("SafeAreaContentPane/PanelMaterial/Buttons/BtnStartTf"):GetComponent("Button")
    self.BtnDisable = self.Transform:Find("SafeAreaContentPane/PanelMaterial/Buttons/BtnDisable"):GetComponent("Button")
    self.BtnSelectMaterial2 = self.Transform:Find("SafeAreaContentPane/PanelMaterial/Material2/BtnSelectMaterial2"):GetComponent("Button")
    self.GridMaterial3 = self.Transform:Find("SafeAreaContentPane/PanelMaterial/Material3/GridMaterial3")
    self.BtnSelectMaterial3 = self.Transform:Find("SafeAreaContentPane/PanelMaterial/Material3/BtnSelectMaterial3"):GetComponent("Button")
    self.GridResult = self.Transform:Find("SafeAreaContentPane/Result/GridResult")
    self.ImgGirdStar1 = self.Transform:Find("SafeAreaContentPane/Result/GridResult/Stars/PaneStar1/ImgGirdStar1"):GetComponent("Image")
    self.ImgGirdStar2 = self.Transform:Find("SafeAreaContentPane/Result/GridResult/Stars/PaneStar2/ImgGirdStar2"):GetComponent("Image")
    self.ImgGirdStar3 = self.Transform:Find("SafeAreaContentPane/Result/GridResult/Stars/PaneStar3/ImgGirdStar3"):GetComponent("Image")
    self.ImgGirdStar4 = self.Transform:Find("SafeAreaContentPane/Result/GridResult/Stars/PaneStar4/ImgGirdStar4"):GetComponent("Image")
    self.ImgGirdStar5 = self.Transform:Find("SafeAreaContentPane/Result/GridResult/Stars/PaneStar5/ImgGirdStar5"):GetComponent("Image")
    self.ImgGirdStar6 = self.Transform:Find("SafeAreaContentPane/Result/GridResult/Stars/PaneStar6/ImgGirdStar6"):GetComponent("Image")
    self.TxtResultName = self.Transform:Find("SafeAreaContentPane/Result/GridResult/TxtResultName"):GetComponent("Text")
    self.PanelPos = self.Transform:Find("SafeAreaContentPane/Result/GridResult/PanelPos")
    self.TxtResultPos = self.Transform:Find("SafeAreaContentPane/Result/GridResult/PanelPos/TxtResultPos"):GetComponent("Text")
    self.TxtResultLevel = self.Transform:Find("SafeAreaContentPane/Result/GridResult/Text/TxtResultLevel"):GetComponent("Text")
    self.BtnMainUi = self.Transform:Find("SafeAreaContentPane/PaneTop/BtnMainUi"):GetComponent("Button")
    self.BtnBack = self.Transform:Find("SafeAreaContentPane/PaneTop/BtnBack"):GetComponent("Button")
    self.RImgResultIcon = self.Transform:Find("SafeAreaContentPane/Result/RImgResultIcon"):GetComponent("RawImage")
    self.PanelAwarenessBag = self.Transform:Find("SafeAreaContentPane/PanelAwarenessBag")
    self.PanelGrid = self.Transform:Find("SafeAreaContentPane/PanelAwarenessBag/PanelGrid")
    self.PanelContent = self.Transform:Find("SafeAreaContentPane/PanelAwarenessBag/PanelGrid/ViewPort/PanelContent")
    self.GridAwarenessTfSelect = self.Transform:Find("SafeAreaContentPane/PanelAwarenessBag/PanelGrid/ViewPort/PanelContent/GridAwarenessTfSelect")
    self.BtnSortUp = self.Transform:Find("SafeAreaContentPane/PanelAwarenessBag/BtnSortUp"):GetComponent("Button")
    self.BtnConfirm = self.Transform:Find("SafeAreaContentPane/PanelAwarenessBag/BtnConfirm"):GetComponent("Button")
    self.BtnSortDown = self.Transform:Find("SafeAreaContentPane/PanelAwarenessBag/BtnSortDown"):GetComponent("Button")
    self.BtnCancel = self.Transform:Find("SafeAreaContentPane/PanelAwarenessBag/BtnCancel"):GetComponent("Button")
    self.PanelEmpty = self.Transform:Find("SafeAreaContentPane/PanelAwarenessBag/PanelEmpty")
end

function XUiAwarenessTf:AutoAddListener()
    self:RegisterClickEvent(self.BtnSelectMaterial1, self.OnBtnSelectMaterial1Click)
    self:RegisterClickEvent(self.BtnStartTf, self.OnBtnStartTfClick)
    self:RegisterClickEvent(self.BtnDisable, self.OnBtnDisableClick)
    self:RegisterClickEvent(self.BtnSelectMaterial2, self.OnBtnSelectMaterial2Click)
    self:RegisterClickEvent(self.BtnSelectMaterial3, self.OnBtnSelectMaterial3Click)
    self:RegisterClickEvent(self.BtnMainUi, self.OnBtnMainUiClick)
    self:RegisterClickEvent(self.BtnBack, self.OnBtnBackClick)
    self:RegisterClickEvent(self.BtnSortUp, self.OnBtnSortUpClick)
    self:RegisterClickEvent(self.BtnConfirm, self.OnBtnConfirmClick)
    self:RegisterClickEvent(self.BtnSortDown, self.OnBtnSortDownClick)
    self:RegisterClickEvent(self.BtnCancel, self.OnBtnCancelClick)
end
-- auto

function XUiAwarenessTf:OnBtnSelectMaterial1Click(eventData)
    self:StartSelectMaterial(1)
end

function XUiAwarenessTf:OnBtnSelectMaterial2Click(eventData)
    self:StartSelectMaterial(2)
end

function XUiAwarenessTf:OnBtnSelectMaterial3Click(eventData)
    self:StartSelectMaterial(3)
end

function XUiAwarenessTf:OnBtnCancelClick(eventData)
    self.CurBagSelectEquipId = {0,0,0}
    self.PanelAwarenessBag.gameObject:SetActive(false)
end

function XUiAwarenessTf:OnBtnSortDownClick(eventData)
    self:SortMaterial(true)
    self:UpdateBagItem()
    self:UpdateBagSelectMark()
end

function XUiAwarenessTf:OnBtnStartTfClick(eventData)
    local tfCb = function(equipData)
        XLuaUiManager.Open("UiAwarenessTfResult", equipData.Id, self:ClearSelect())
    end
    local okCb = function()
        local site = XGoodsCommonManager.GetGoodsShowParamsByTemplateId(self.TemplateId).Site
        XDataCenter.EquipManager.AwarenessTransform(self.SuitId, site, self.CurMaterialEquipId, tfCb)
    end

    local title = CS.XTextManager.GetText("AwarenessTfConfirmTitle")
    local hasResonanced = false
    for i = 1, MAX_MATERIAL_SLOT do
        local resonanceSkillNum = XDataCenter.EquipManager.GetResonanceSkillNum(self.CurMaterialEquipId[i])
        for j = 1, resonanceSkillNum do
            if XDataCenter.EquipManager.CheckEquipPosResonanced(self.CurMaterialEquipId[i], j) then
                hasResonanced = true
            end
        end
    end
    local content
    if hasResonanced then
        content = CS.XTextManager.GetText("AwarenessTfConfirmContentResonance")
    else
        content = CS.XTextManager.GetText("AwarenessTfConfirmContent")
    end
    XLuaUiManager.Open("UiDialog", title, content, XUiManager.DialogType.Normal, nil, okCb)
end

function XUiAwarenessTf:OnBtnDisableClick(eventData)
    local text = CS.XTextManager.GetText("AwarenessTfMaterialError")
    XUiManager.TipMsg(text, XUiManager.UiTipType.Tip)
end

function XUiAwarenessTf:OnBtnMainUiClick(eventData)
    XLuaUiManager.RunMain()
end

function XUiAwarenessTf:OnBtnBackClick(eventData)
    self:Close()
end

function XUiAwarenessTf:OnBtnSortUpClick(eventData)
    self:SortMaterial(false)
    self:UpdateBagItem()
    self:UpdateBagSelectMark()
end
--确认背包选择按钮
function XUiAwarenessTf:OnBtnConfirmClick(eventData)
    --改变了主材料清空副材料
    if self.CurSelectPos == 1 then
        if self.CurMaterialEquipId[1] ~= self.CurBagSelectEquipId[1] then
            self.CurMaterialEquipId[1] = self.CurBagSelectEquipId[1]
            self.CurMaterialEquipId[2] = 0
            self.CurBagSelectEquipId[2] = 0
            self.CurMaterialEquipId[3] = 0
            self.CurBagSelectEquipId[3] = 0
        end
    else
        for i = 2, MAX_MATERIAL_SLOT do
            self.CurMaterialEquipId[i] = self.CurBagSelectEquipId[i]
        end
    end
    self:UpdateMaterialBtn()
    self.PanelAwarenessBag.gameObject:SetActive(false)
    self:UpdateTargetLevel()
end


function XUiAwarenessTf:InitTargetInfo()
    self.PanelAwarenessBag.gameObject:SetActive(false)
    self:UpdateBaseInfo()
    self:UpdateStar()
end

--星星
function XUiAwarenessTf:UpdateStar()
    local star = XDataCenter.EquipManager.GetEquipStar(self.TemplateId)
    for i = 1, XEquipConfig.MAX_STAR_COUNT do
        if self["ImgGirdStar" .. i] then
            if i <= star then
                self["ImgGirdStar" .. i].gameObject:SetActive(true)
            else
                self["ImgGirdStar" .. i].gameObject:SetActive(false)
            end
        end
    end
end

--基础属性(名字，位置，等级，图标),等级默认1级，有继承在更新
function XUiAwarenessTf:UpdateBaseInfo()
    self.TxtResultName.text = XDataCenter.EquipManager.GetEquipName(self.TemplateId)
    self.TxtResultPos.text = XGoodsCommonManager.GetGoodsShowParamsByTemplateId(self.TemplateId).Site
    self.TxtResultLevel.text = 1
    local icon = XDataCenter.EquipManager.GetEquipLiHuiPath(self.TemplateId)
    self.RImgResultIcon:SetRawImage(icon)
end

--放入主材料后更新等级显示
function XUiAwarenessTf:UpdateTargetLevel()
    if self.CurMaterialEquipId[1] > 0 then
        self.TxtResultLevel.text = XDataCenter.EquipManager.GetEquip(self.CurMaterialEquipId[1]).Level
    else
        self.TxtResultLevel.text = 1
    end
end

--用于更新改造按钮状态(3个材料都放入)
function XUiAwarenessTf:UpdateConformBtn()
    if self.CurMaterialEquipId[1] > 0 and self.CurMaterialEquipId[2] > 0 and self.CurMaterialEquipId[3] > 0 then
        self.BtnStartTf.gameObject:SetActive(true)
        self.BtnDisable.gameObject:SetActive(false)
    else
        self.BtnStartTf.gameObject:SetActive(false)
        self.BtnDisable.gameObject:SetActive(true)
    end
end

--开始选择材料
function XUiAwarenessTf:StartSelectMaterial(index)
    if index > 1 then
        if self.CurMaterialEquipId[1] == 0 then
            local text = CS.XTextManager.GetText("AwarenessTfMaterialMainError")
            XUiManager.TipMsg(text, XUiManager.UiTipType.Tip)
            return
        end
    end
    self.CurSelectPos = index
    self:InitMaterialBag()
    self.PanelAwarenessBag.gameObject:SetActive(true)
end

function XUiAwarenessTf:InitMaterialBag()
    self.GridAwarenessTfSelect.gameObject:SetActive(false)

    --筛选：去除已穿戴的，锁定的，主材料，与目标同位置的
    self.EquipIds = XDataCenter.EquipManager.GetEquipIdsBySuitId(self.SuitId)
    self:FilterMaterial()
    --sort(默认升序)
    self.UpSort = true
    self.BtnSortDown.gameObject:SetActive(false)
    self.BtnSortUp.gameObject:SetActive(true)
    XDataCenter.EquipManager.SortEquipIdListByPriorType(self.EquipIds)
    self:SortMaterial()
    --生成Grid
    self:UpdateBagItem()

    --设置选中状态
    for i = 1, #self.EquipIds do
        if self:IsSelected(self.EquipIds[i]) then
            self.AwarenessTfBagList[i]:SetSelected(true)
        else
            self.AwarenessTfBagList[i]:SetSelected(false)
        end
    end
    --设置已选择的数据
    if self.CurSelectPos == 1 then
        return self.CurBagSelectEquipId[1] == self.CurMaterialEquipId[1]
    else
        for i = 2, MAX_MATERIAL_SLOT do
            self.CurBagSelectEquipId[i] = self.CurMaterialEquipId[i]
        end
    end
end

function XUiAwarenessTf:UpdateBagSelectMark()
    for i = 1, #self.EquipIds do
        if self:IsBagSelected(self.EquipIds[i]) then
            self.AwarenessTfBagList[i]:SetSelected(true)
        else
            self.AwarenessTfBagList[i]:SetSelected(false)
        end
    end
end

function XUiAwarenessTf:UpdateBagItem()
    --init
    local clickCb = function(equipId, grid)
        if self.CurSelectPos == 1 then
            if grid:IsSelected() then
                grid:SetSelected(false)
                self.CurBagSelectEquipId[self.CurSelectPos] = 0
            else
                for k, v in pairs(self.AwarenessTfBagList) do
                    v:SetSelected(false)
                end
                grid:SetSelected(true)
                self.CurBagSelectEquipId[self.CurSelectPos] = equipId
            end
        else
            if grid:IsSelected() then
                grid:SetSelected(false)
                if self.CurBagSelectEquipId[2] == equipId then
                    self.CurBagSelectEquipId[2] = 0
                else
                    self.CurBagSelectEquipId[3] = 0
                end
            else
                if self.CurBagSelectEquipId[2] == 0 or self.CurBagSelectEquipId[3] == 0 then
                    if self.CurBagSelectEquipId[2] == 0 then
                        self.CurBagSelectEquipId[2] = equipId
                    elseif self.CurBagSelectEquipId[3] == 0 then
                        self.CurBagSelectEquipId[3] = equipId
                    end
                    grid:SetSelected(true)
                else
                    local text = CS.XTextManager.GetText("AwarenessTfMaterialSelectError")
                    XUiManager.TipMsg(text, XUiManager.UiTipType.Tip)
                end
            end
        end
    end

    for i = 1, #self.EquipIds do
        if not self.AwarenessTfBagList[i] then
            local tempGo = CS.UnityEngine.Object.Instantiate(self.GridAwarenessTfSelect.gameObject)
            tempGo.transform:SetParent(self.PanelContent, false)
            self.AwarenessTfBagList[i] = XUiGridEquip.New(tempGo, clickCb, self)
        end
        self.AwarenessTfBagList[i]:Refresh(self.EquipIds[i])
        self.AwarenessTfBagList[i].GameObject:SetActive(true)
    end

    for i = #self.EquipIds + 1, #self.AwarenessTfBagList do
        self.AwarenessTfBagList[i].GameObject:SetActive(false)
    end

    if #self.EquipIds > 0 then
        self.PanelEmpty.gameObject:SetActive(false)
    else
        self.PanelEmpty.gameObject:SetActive(true)
    end
end

function XUiAwarenessTf:IsSelected(equipId)
    if self.CurSelectPos == 1 then
        return self.CurMaterialEquipId[1] == equipId
    end
    for i = 2, MAX_MATERIAL_SLOT do
        if self.CurMaterialEquipId[i] == equipId then
            return true
        end
    end
    return false
end

function XUiAwarenessTf:IsBagSelected(equipId)
    if self.CurSelectPos == 1 then
        return self.CurBagSelectEquipId[1] == equipId
    end
    for i = 2, MAX_MATERIAL_SLOT do
        if self.CurBagSelectEquipId[i] == equipId then
            return true
        end
    end
    return false
end

--更新3个材料槽状态
function XUiAwarenessTf:UpdateMaterialBtn()
    for i = 1, MAX_MATERIAL_SLOT do
        if self.CurMaterialEquipId[i] > 0 then
            self["GridMaterial" .. i].gameObject:SetActive(true)
            self["BtnSelectMaterial" .. i].gameObject:SetActive(false)
        else
            self["GridMaterial" .. i].gameObject:SetActive(false)
            self["BtnSelectMaterial" .. i].gameObject:SetActive(true)
        end
    end
    self:UpdateMaterialGrid()
    self:UpdateConformBtn()
end

function XUiAwarenessTf:SortMaterial(upSort)
    if upSort ~=nil then
        self.UpSort = upSort
    end
    if self.UpSort then
        self.BtnSortDown.gameObject:SetActive(false)
        self.BtnSortUp.gameObject:SetActive(true)
    else
        self.BtnSortDown.gameObject:SetActive(true)
        self.BtnSortUp.gameObject:SetActive(false)
    end

    self.EquipIds = XTool.ReverseList(self.EquipIds)

    --[[
    table.sort(self.EquipIds, function(a, b)
        if self.UpSort then
            return XDataCenter.EquipManager.GetEquip(a).Level < XDataCenter.EquipManager.GetEquip(b).Level
        else
            return XDataCenter.EquipManager.GetEquip(a).Level > XDataCenter.EquipManager.GetEquip(b).Level
        end
    end)
    --]]
end

function XUiAwarenessTf:FilterMaterial()
    local removeIds = {}
    for k, v in pairs(self.EquipIds) do
        --已穿戴的
        if XDataCenter.EquipManager.IsWearing(v) then
            removeIds[k] = true
        end
        --锁定的
        if XDataCenter.EquipManager.IsLock(v) then
            removeIds[k] = true
        end
        --主材料
        if self.CurMaterialEquipId[1] > 0 and v == self.CurMaterialEquipId[1]  and self.CurSelectPos ~= 1 then
            removeIds[k] = true
        end
        --同位置的
        local targetPos = XGoodsCommonManager.GetGoodsShowParamsByTemplateId(self.TemplateId).Site
        local tempPos = XDataCenter.EquipManager.GetEquipSite(v)
        if targetPos == tempPos then
            removeIds[k] = true
        end
    end
    for i = #self.EquipIds, 1, -1 do
        if removeIds[i] then
            table.remove(self.EquipIds, i)
        end
    end
end

function XUiAwarenessTf:UpdateMaterialGrid()
    local clickCb = function(equipId, grid)
        for i = 1, MAX_MATERIAL_SLOT do
            if self.CurMaterialEquipId[i] == equipId then
                self:StartSelectMaterial(i)
            end
        end
    end
    for i = 1, MAX_MATERIAL_SLOT do
        if not self.MaterialGrid[i] then
            self.MaterialGrid[i] = XUiGridEquip.New(self["GridMaterial" .. i], clickCb, self)
        end
        if self.CurMaterialEquipId[i] > 0 then
            self.MaterialGrid[i]:Refresh(self.CurMaterialEquipId[i])
        end
    end
end


function XUiAwarenessTf:ClearSelect()
    self.CurBagSelectEquipId = {0,0,0}
    self.CurMaterialEquipId = {0,0,0}
    self:InitTargetInfo()
    self:UpdateConformBtn()
    self:UpdateMaterialBtn()
end