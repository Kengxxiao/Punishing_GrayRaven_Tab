local XUiAwarenessTfChoice = XLuaUiManager.Register(XLuaUi, "UiAwarenessTfChoice")
local XUiGridSuitDetail = require("XUi/XUiEquipAwarenessReplace/XUiGridSuitDetail")
local XUiAwarenessTfBtnPos = require("XUi/XUiAwarenessTf/XUiAwarenessTfBtnPos")
local MAX_AWARENESS_ATTR_COUNT = 4 --包括了共鸣属性，最大有4条
function XUiAwarenessTfChoice:OnAwake()
    self:InitAutoScript()
end


function XUiAwarenessTfChoice:OnStart(suitIds, endTime)
    self.SuitIds = suitIds
    self.EndTime = endTime
    self.PartIds = {}
    self.PartList = {}
    self.SuitList = {}
    self.PartGroupGo = {}
    self.PanelSelectSuit.gameObject:SetActive(false)
    self.PanelSelectPart.gameObject:SetActive(false)
    self.CurSelectPos = 1
    self.CurSelectGrid = nil
    self:InitSuitList()
end


function XUiAwarenessTfChoice:OnEnable()
    if self.EndTime > 0 then
        self.PanelCountDownA.gameObject:SetActive(true)
        self.PanelCountDownB.gameObject:SetActive(true)
        self:SetUpCountDown()
    else
        self.PanelCountDownA.gameObject:SetActive(false)
        self.PanelCountDownB.gameObject:SetActive(false)
    end
end


function XUiAwarenessTfChoice:OnDisable()
end


function XUiAwarenessTfChoice:OnDestroy()
    if self.EndTime > 0 then
        self:RemoveCountDown()
    end
end


function XUiAwarenessTfChoice:OnGetEvents()
    return nil
end


function XUiAwarenessTfChoice:OnNotify(evt,...)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiAwarenessTfChoice:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiAwarenessTfChoice:AutoInitUi()
    self.BtnBack = self.Transform:Find("SafeAreaContentPane/PaneTop/BtnBack"):GetComponent("Button")
    self.BtnMainUi = self.Transform:Find("SafeAreaContentPane/PaneTop/BtnMainUi"):GetComponent("Button")
    self.PanelSelectSuit = self.Transform:Find("SafeAreaContentPane/PanelSelectSuit")
    self.PanelSuitContent = self.Transform:Find("SafeAreaContentPane/PanelSelectSuit/Viewport/PanelSuitContent")
    self.GridSuitSimple = self.Transform:Find("SafeAreaContentPane/PanelSelectSuit/Viewport/PanelSuitContent/GridSuitSimple")
    self.TxtName = self.Transform:Find("SafeAreaContentPane/PanelSelectSuit/Viewport/PanelSuitContent/GridSuitSimple/TxtName"):GetComponent("Text")
    self.RImgIcon = self.Transform:Find("SafeAreaContentPane/PanelSelectSuit/Viewport/PanelSuitContent/GridSuitSimple/RImgIcon"):GetComponent("RawImage")
    self.PanelCountDownA = self.Transform:Find("SafeAreaContentPane/PanelSelectSuit/Left/PanelCountDownA")
    self.TxtCountDownA = self.Transform:Find("SafeAreaContentPane/PanelSelectSuit/Left/PanelCountDownA/TxtCountDownA"):GetComponent("Text")
    self.PanelSelectPart = self.Transform:Find("SafeAreaContentPane/PanelSelectPart")
    self.PanelPartGroup = self.Transform:Find("SafeAreaContentPane/PanelSelectPart/PanelPartGroup")
    self.UiAwarenessTfBtnPos = self.Transform:Find("SafeAreaContentPane/PanelSelectPart/PanelPartGroup/UiAwarenessTfBtnPos")
    self.UiSelectBG = self.Transform:Find("SafeAreaContentPane/PanelSelectPart/PanelPartGroup/UiAwarenessTfBtnPos/UiSelectBG")
    self.UiBtnBackNone = self.Transform:Find("SafeAreaContentPane/PanelSelectPart/PanelPartGroup/UiAwarenessTfBtnPos/UiBtnBackNone")
    self.UiBtnBackHas = self.Transform:Find("SafeAreaContentPane/PanelSelectPart/PanelPartGroup/UiAwarenessTfBtnPos/UiBtnBackHas")
    self.TxtPosNum = self.Transform:Find("SafeAreaContentPane/PanelSelectPart/PanelPartGroup/UiAwarenessTfBtnPos/TxtPosNum"):GetComponent("Text")
    self.BtnPos = self.Transform:Find("SafeAreaContentPane/PanelSelectPart/PanelPartGroup/UiAwarenessTfBtnPos/BtnPos"):GetComponent("Button")
    self.TxtSuitName = self.Transform:Find("SafeAreaContentPane/PanelSelectPart/TxtSuitName"):GetComponent("Text")
    self.PanelCountDownB = self.Transform:Find("SafeAreaContentPane/PanelSelectPart/PanelCountDownB")
    self.TxtCountDownB = self.Transform:Find("SafeAreaContentPane/PanelSelectPart/PanelCountDownB/TxtCountDownB"):GetComponent("Text")
    self.PanelAttrParent = self.Transform:Find("SafeAreaContentPane/PanelSelectPart/GameObject/PanelAttrParent")
    self.PanelAttr1 = self.Transform:Find("SafeAreaContentPane/PanelSelectPart/GameObject/PanelAttrParent/PanelAttr1")
    self.TxtName1 = self.Transform:Find("SafeAreaContentPane/PanelSelectPart/GameObject/PanelAttrParent/PanelAttr1/TxtName1"):GetComponent("Text")
    self.TxtAttr1 = self.Transform:Find("SafeAreaContentPane/PanelSelectPart/GameObject/PanelAttrParent/PanelAttr1/TxtAttr1"):GetComponent("Text")
    self.PanelAttr2 = self.Transform:Find("SafeAreaContentPane/PanelSelectPart/GameObject/PanelAttrParent/PanelAttr2")
    self.TxtName2 = self.Transform:Find("SafeAreaContentPane/PanelSelectPart/GameObject/PanelAttrParent/PanelAttr2/TxtName2"):GetComponent("Text")
    self.TxtAttr2 = self.Transform:Find("SafeAreaContentPane/PanelSelectPart/GameObject/PanelAttrParent/PanelAttr2/TxtAttr2"):GetComponent("Text")
    self.PanelAttr3 = self.Transform:Find("SafeAreaContentPane/PanelSelectPart/GameObject/PanelAttrParent/PanelAttr3")
    self.TxtName3 = self.Transform:Find("SafeAreaContentPane/PanelSelectPart/GameObject/PanelAttrParent/PanelAttr3/TxtName3"):GetComponent("Text")
    self.TxtAttr3 = self.Transform:Find("SafeAreaContentPane/PanelSelectPart/GameObject/PanelAttrParent/PanelAttr3/TxtAttr3"):GetComponent("Text")
    self.PanelAttr4 = self.Transform:Find("SafeAreaContentPane/PanelSelectPart/GameObject/PanelAttrParent/PanelAttr4")
    self.TxtName4 = self.Transform:Find("SafeAreaContentPane/PanelSelectPart/GameObject/PanelAttrParent/PanelAttr4/TxtName4"):GetComponent("Text")
    self.TxtAttr4 = self.Transform:Find("SafeAreaContentPane/PanelSelectPart/GameObject/PanelAttrParent/PanelAttr4/TxtAttr4"):GetComponent("Text")
    self.BtnCancle = self.Transform:Find("SafeAreaContentPane/PanelSelectPart/BtnCancle"):GetComponent("Button")
    self.PanelContent = self.Transform:Find("SafeAreaContentPane/PanelSelectPart/SuitDis/PanelContent")
    self.TxtSkillDes1 = self.Transform:Find("SafeAreaContentPane/PanelSelectPart/SuitDis/PanelContent/TxtSkillDes1"):GetComponent("Text")
    self.TxtSkillDes2 = self.Transform:Find("SafeAreaContentPane/PanelSelectPart/SuitDis/PanelContent/TxtSkillDes2"):GetComponent("Text")
    self.TxtSkillDes3 = self.Transform:Find("SafeAreaContentPane/PanelSelectPart/SuitDis/PanelContent/TxtSkillDes3"):GetComponent("Text")
    self.PanelSelectAwareness = self.Transform:Find("SafeAreaContentPane/PanelSelectPart/PanelSelectAwareness")
    self.TxtPosNum = self.Transform:Find("SafeAreaContentPane/PanelSelectPart/PanelSelectAwareness/TxtPosNum"):GetComponent("Text")
    self.TxtNum = self.Transform:Find("SafeAreaContentPane/PanelSelectPart/PanelSelectAwareness/TxtNum"):GetComponent("Text")
    self.GridCurSelectPart = self.Transform:Find("SafeAreaContentPane/PanelSelectPart/PanelSelectAwareness/GridCurSelectPart")
    self.RImgIconA = self.Transform:Find("SafeAreaContentPane/PanelSelectPart/PanelSelectAwareness/GridCurSelectPart/RImgIcon"):GetComponent("RawImage")
    self.BtnConfirm = self.Transform:Find("SafeAreaContentPane/PanelSelectPart/BtnConfirm"):GetComponent("Button")
end

function XUiAwarenessTfChoice:AutoAddListener()
    self:RegisterClickEvent(self.BtnBack, self.OnBtnBackClick)
    self:RegisterClickEvent(self.BtnMainUi, self.OnBtnMainUiClick)
    self:RegisterClickEvent(self.BtnPos, self.OnBtnPosClick)
    self:RegisterClickEvent(self.BtnCancle, self.OnBtnCancleClick)
    self:RegisterClickEvent(self.BtnConfirm, self.OnBtnConfirmClick)
end
-- auto

function XUiAwarenessTfChoice:OnBtnPosClick(eventData)

end

function XUiAwarenessTfChoice:OnBtnCancleClick(eventData)
    self.PanelSelectPart.gameObject:SetActive(false)
end

function XUiAwarenessTfChoice:OnBtnConfirmClick(eventData)
    self.PanelSelectPart.gameObject:SetActive(false)
    XLuaUiManager.Open("UiAwarenessTf", self.PartIds[self.CurSelectPos])
end

function XUiAwarenessTfChoice:OnBtnBackClick(eventData)
    self:Close()
end

function XUiAwarenessTfChoice:OnBtnMainUiClick(eventData)
    XLuaUiManager.RunMain()
end


function XUiAwarenessTfChoice:InitSuitList()
    self.GridSuitSimple.gameObject:SetActive(false)
    self.PanelSelectSuit.gameObject:SetActive(true)

    local clickCb = function(suitId, grid)
        self:OnSuitGridClick(suitId, grid)
    end

    for i = 1, #self.SuitIds do
        if not self.SuitList[i] then
            local tempGo = CS.UnityEngine.Object.Instantiate(self.GridSuitSimple.gameObject)
            tempGo.transform:SetParent(self.PanelSuitContent, false)
            self.SuitList[i] = XUiGridSuitDetail.New(tempGo, self, clickCb)
        end
        self.SuitList[i]:Refresh(self.SuitIds[i], nil, true)
        self.SuitList[i].GameObject:SetActive(true)
    end

    for i = #self.SuitIds + 1, #self.SuitList do
        self.SuitList[i].GameObject:SetActive(false)
    end
end

function XUiAwarenessTfChoice:OnSuitGridClick(suitId, grid)
    self:InitSelectPart(suitId)
    self.PanelSelectPart.gameObject:SetActive(true)
end

function XUiAwarenessTfChoice:OnSelectPart(pos)
    for i = 1, #self.PartIds do
        if i == pos then
            self.PartList[i].UiSelectBG.gameObject:SetActive(true)
        else
            self.PartList[i].UiSelectBG.gameObject:SetActive(false)
        end
    end
    self.CurSelectPos = pos
    self:UpdateSelectPos()
end

function XUiAwarenessTfChoice:InitSelectPart(suitId)
    self.UiAwarenessTfBtnPos.gameObject:SetActive(false)
    local cb = function(pos)
        self:OnSelectPart(pos)
    end
    --套装名字
    self.TxtSuitName.text = XDataCenter.EquipManager.GetSuitName(suitId)
    --套装效果
    local skillDesList = XDataCenter.EquipManager.GetSuitSkillDesList(suitId)
    for i = 1, XEquipConfig.MAX_SUIT_SKILL_COUNT do
        if skillDesList[i * 2] then
            self["TxtSkillDes" .. i].text = skillDesList[i * 2]
            self["TxtSkillDes" .. i].gameObject:SetActive(true)
        else
            self["TxtSkillDes" .. i].gameObject:SetActive(false)
        end
    end
    --部位选择
    --获取数据
    self.PartIds = XDataCenter.EquipManager.GetEquipTemplateIdsBySuitId(suitId)
    table.sort(self.PartIds, function(a, b)
        local aid = XGoodsCommonManager.GetGoodsShowParamsByTemplateId(a)
        local bid = XGoodsCommonManager.GetGoodsShowParamsByTemplateId(b)
        return aid.Site < bid.Site
    end)
    self.PartSiteIds = {}
    for i = 1, #self.PartIds do
        self.PartSiteIds[i] = XGoodsCommonManager.GetGoodsShowParamsByTemplateId(self.PartIds[i]).Site
    end
    --生成按钮
    for i = 1, #self.PartIds do
        if not self.PartList[i] then
            local tempGo = CS.UnityEngine.Object.Instantiate(self.UiAwarenessTfBtnPos.gameObject)
            tempGo.transform:SetParent(self.PanelPartGroup, false)
            tempGo.gameObject:SetActive(true)
            self.PartList[i] = XUiAwarenessTfBtnPos.New(tempGo, i, self.PartSiteIds[i], self.PartIds[i], cb)
        end
        self.PartList[i].GameObject:SetActive(true)
    end

    for i = #self.PartIds + 1, #self.PartList do
        self.PartList[i].GameObject:SetActive(false)
    end
    --初始化按钮
    for i = 1, #self.PartIds do
        self.PartList[i]:Refresh(self.PartSiteIds[i], self.PartIds[i])
    end
    --默认选择1号
    self:OnSelectPart(1)
end
--更新中间的Grid
function XUiAwarenessTfChoice:UpdateSelectPos()
    if not self.CurSelectGrid then
        self.CurSelectGrid = XUiGridCommon.New(self, self.GridCurSelectPart)
    end
    self.CurSelectGrid:Refresh(self.PartIds[self.CurSelectPos])
    self.TxtPosNum.text = CS.XTextManager.GetText("AwarenessTfPos", self.PartSiteIds[self.CurSelectPos])
    self.TxtNum.text = XDataCenter.EquipManager.GetEquipCountByTemplateID(self.PartIds[self.CurSelectPos])
    self:UpdateEquipAttr()
end

--更新属性(未获取只能显示1级的属性)
function XUiAwarenessTfChoice:UpdateEquipAttr()
    local attrCount = 1
    local attrMap = XDataCenter.EquipManager.GetTemplateEquipAttrMap(self.PartIds[self.CurSelectPos], 1)
    for _, attrInfo in pairs(attrMap) do
        if attrCount > MAX_AWARENESS_ATTR_COUNT then break end
        self["TxtName" .. attrCount].text = attrInfo.Name
        self["TxtAttr" .. attrCount].text = attrInfo.Value
        self["PanelAttr" .. attrCount].gameObject:SetActive(true)
        attrCount = attrCount + 1
    end
    for i = attrCount, MAX_AWARENESS_ATTR_COUNT do
        self["PanelAttr" .. i].gameObject:SetActive(false)
    end
end

--设置倒计时
function XUiAwarenessTfChoice:SetUpCountDown()
    local remainTime = self.EndTime - XTime.Now()
    XCountDown.CreateTimer(self.GameObject.name, remainTime)
    XCountDown.BindTimer(self.GameObject, self.GameObject.name, function(v, oldV)

        self.TxtCountDownA.text = XUiHelper.GetTime(v, XUiHelper.TimeFormatType.DRAW)
        self.TxtCountDownB.text = self.TxtCountDownA.text
    end)
end
function XUiAwarenessTfChoice:RemoveCountDown()
    XCountDown.RemoveTimer(self.Name)
end