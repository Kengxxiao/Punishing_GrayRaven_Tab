local XUiAwarenessTfResult = XLuaUiManager.Register(XLuaUi, "UiAwarenessTfResult")
local MAX_AWARENESS_ATTR_COUNT = 4
function XUiAwarenessTfResult:OnAwake()
    self:InitAutoScript()
end


function XUiAwarenessTfResult:OnStart(equipId, cb)
    self.EquipId = equipId
    self.Cb = cb
    self.TemplateId = XDataCenter.EquipManager.GetEquipTemplateId(self.EquipId)
    self:UpdateInfo()
end


function XUiAwarenessTfResult:OnEnable()
end


function XUiAwarenessTfResult:OnDisable()
end


function XUiAwarenessTfResult:OnDestroy()
end


function XUiAwarenessTfResult:OnGetEvents()
    return nil
end


function XUiAwarenessTfResult:OnNotify(evt,...)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiAwarenessTfResult:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiAwarenessTfResult:AutoInitUi()
    self.PanelAttr4 = self.Transform:Find("SafeAreaContentPane/Attr/PaneAttrParent/PanelAttr4")
    self.TxtName4 = self.Transform:Find("SafeAreaContentPane/Attr/PaneAttrParent/PanelAttr4/TxtName4"):GetComponent("Text")
    self.TxtAttr4 = self.Transform:Find("SafeAreaContentPane/Attr/PaneAttrParent/PanelAttr4/TxtAttr4"):GetComponent("Text")
    self.PanelAttr3 = self.Transform:Find("SafeAreaContentPane/Attr/PaneAttrParent/PanelAttr3")
    self.TxtName3 = self.Transform:Find("SafeAreaContentPane/Attr/PaneAttrParent/PanelAttr3/TxtName3"):GetComponent("Text")
    self.TxtAttr3 = self.Transform:Find("SafeAreaContentPane/Attr/PaneAttrParent/PanelAttr3/TxtAttr3"):GetComponent("Text")
    self.PanelAttr2 = self.Transform:Find("SafeAreaContentPane/Attr/PaneAttrParent/PanelAttr2")
    self.TxtName2 = self.Transform:Find("SafeAreaContentPane/Attr/PaneAttrParent/PanelAttr2/TxtName2"):GetComponent("Text")
    self.TxtAttr2 = self.Transform:Find("SafeAreaContentPane/Attr/PaneAttrParent/PanelAttr2/TxtAttr2"):GetComponent("Text")
    self.PanelAttr1 = self.Transform:Find("SafeAreaContentPane/Attr/PaneAttrParent/PanelAttr1")
    self.TxtName1 = self.Transform:Find("SafeAreaContentPane/Attr/PaneAttrParent/PanelAttr1/TxtName1"):GetComponent("Text")
    self.TxtAttr1 = self.Transform:Find("SafeAreaContentPane/Attr/PaneAttrParent/PanelAttr1/TxtAttr1"):GetComponent("Text")
    self.RImgIcon = self.Transform:Find("SafeAreaContentPane/RImgIcon"):GetComponent("RawImage")
    self.GridSuitResult = self.Transform:Find("SafeAreaContentPane/GridSuitResult")
    self.ImgGirdStar1 = self.Transform:Find("SafeAreaContentPane/GridSuitResult/Stars/PaneStar1/ImgGirdStar1"):GetComponent("Image")
    self.ImgGirdStar2 = self.Transform:Find("SafeAreaContentPane/GridSuitResult/Stars/PaneStar2/ImgGirdStar2"):GetComponent("Image")
    self.ImgGirdStar3 = self.Transform:Find("SafeAreaContentPane/GridSuitResult/Stars/PaneStar3/ImgGirdStar3"):GetComponent("Image")
    self.ImgGirdStar4 = self.Transform:Find("SafeAreaContentPane/GridSuitResult/Stars/PaneStar4/ImgGirdStar4"):GetComponent("Image")
    self.ImgGirdStar5 = self.Transform:Find("SafeAreaContentPane/GridSuitResult/Stars/PaneStar5/ImgGirdStar5"):GetComponent("Image")
    self.ImgGirdStar6 = self.Transform:Find("SafeAreaContentPane/GridSuitResult/Stars/PaneStar6/ImgGirdStar6"):GetComponent("Image")
    self.TxtAwarenessName = self.Transform:Find("SafeAreaContentPane/GridSuitResult/TxtAwarenessName"):GetComponent("Text")
    self.PanelPos = self.Transform:Find("SafeAreaContentPane/GridSuitResult/PanelPos")
    self.TxtPos = self.Transform:Find("SafeAreaContentPane/GridSuitResult/PanelPos/TxtPos"):GetComponent("Text")
    self.TxtLevel = self.Transform:Find("SafeAreaContentPane/GridSuitResult/Level/TxtLevel"):GetComponent("Text")
    self.BtnBack = self.Transform:Find("SafeAreaContentPane/BtnBack"):GetComponent("Button")
    self.PanelContent = self.Transform:Find("SafeAreaContentPane/Content/PanelContent")
    self.TxtSkillDes1 = self.Transform:Find("SafeAreaContentPane/Content/PanelContent/TxtSkillDes1"):GetComponent("Text")
    self.TxtSkillDes2 = self.Transform:Find("SafeAreaContentPane/Content/PanelContent/TxtSkillDes2"):GetComponent("Text")
    self.TxtSkillDes3 = self.Transform:Find("SafeAreaContentPane/Content/PanelContent/TxtSkillDes3"):GetComponent("Text")
end

function XUiAwarenessTfResult:AutoAddListener()
    self:RegisterClickEvent(self.BtnBack, self.OnBtnBackClick)
end
-- auto

function XUiAwarenessTfResult:OnBtnBackClick(eventData)
    if self.Cb then
        self.Cb()
    end
    self:Close()
end

function XUiAwarenessTfResult:UpdateInfo()
    self:UpdateBaseInfo()
    self:UpdateStar()
    self:UpdateEquipAttr()
    self:UpdateSuitEffect()
end

--更新属性
function XUiAwarenessTfResult:UpdateEquipAttr()
    local attrCount = 1
    local attrMap = XDataCenter.EquipManager.GetEquipAttrMap(self.EquipId)
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

--套装效果
function XUiAwarenessTfResult:UpdateSuitEffect()
    local suitId = XDataCenter.EquipManager.GetSuitIdByTemplateId(self.TemplateId)
    local skillDesList = XDataCenter.EquipManager.GetSuitSkillDesList(suitId)
    for i = 1, XEquipConfig.MAX_SUIT_SKILL_COUNT do
        if skillDesList[i * 2] then
            self["TxtSkillDes" .. i].text = skillDesList[i * 2]
            self["TxtSkillDes" .. i].gameObject:SetActive(true)
        else
            self["TxtSkillDes" .. i].gameObject:SetActive(false)
        end
    end
end

--星星
function XUiAwarenessTfResult:UpdateStar()
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

--基础属性(名字，位置，等级，图标)
function XUiAwarenessTfResult:UpdateBaseInfo()
    self.TxtAwarenessName.text = XDataCenter.EquipManager.GetEquipName(self.TemplateId)
    self.TxtPos.text = XGoodsCommonManager.GetGoodsShowParamsByTemplateId(self.TemplateId).Site
    self.TxtLevel.text = XDataCenter.EquipManager.GetEquip(self.EquipId).Level
    local icon = XDataCenter.EquipManager.GetEquipLiHuiPath(self.TemplateId)
    self.RImgIcon:SetRawImage(icon)
end