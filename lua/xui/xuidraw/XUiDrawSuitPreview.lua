local XUiDrawSuitPreview = XLuaUiManager.Register(XLuaUi, "UiDrawSuitPreview")

function XUiDrawSuitPreview:OnAwake()
    self:InitAutoScript()
end


function XUiDrawSuitPreview:OnStart(suitId, parentUi)
    self.ParentUi = parentUi
    self.Grids = {}
    self:UpdatePanel()
end

function XUiDrawSuitPreview:UpdatePanel()
    self.SuitId = self.ParentUi.CurSuitId
    self.GridCommon.gameObject:SetActive(false)
    local skillDesList = XDataCenter.EquipManager.GetSuitSkillDesList(self.SuitId)
    for i = 1, XEquipConfig.MAX_SUIT_SKILL_COUNT do
        if skillDesList[i * 2] then
            self["TxtSkillDes" .. i].text = skillDesList[i * 2]
            self["TxtSkillDes" .. i].gameObject:SetActive(true)
        else
            self["TxtSkillDes" .. i].gameObject:SetActive(false)
        end
    end
    CS.UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(self.PanelContent)
    self.TxtName.text = XDataCenter.EquipManager.GetSuitName(self.SuitId)
    self.RImgIco:SetRawImage(XDataCenter.EquipManager.GetSuitBigIconBagPath(self.SuitId))
    local ids = XDataCenter.EquipManager.GetEquipTemplateIdsBySuitId(self.SuitId)

    table.sort(ids, function(a, b)
        local aid = XGoodsCommonManager.GetGoodsShowParamsByTemplateId(a)
        local bid = XGoodsCommonManager.GetGoodsShowParamsByTemplateId(b)
        return aid.Site < bid.Site
    end)

    for i = 1, #ids do
        if not self.Grids[i] then
            local go = CS.UnityEngine.Object.Instantiate(self.GridCommon, self.PanelGrid)
            local item = XUiGridCommon.New(self, go)
            go.gameObject:SetActive(true)
            table.insert(self.Grids, item)
        end
    end

    for i = 1, #self.Grids do
        self.Grids[i]:Refresh(ids[i])
    end

    for i = #ids + 1, #self.Grids do
        self.Grids[i].GameObject:SetActive(false)
    end
end

function XUiDrawSuitPreview:RefreshData()

end

function XUiDrawSuitPreview:OnEnable()
    XUiHelper.PlayAnimation(self, "AniDrawSuitPreviewBegin")
    if self.ParentUi then
        self:UpdatePanel()
    end
end


function XUiDrawSuitPreview:OnDisable()
end


function XUiDrawSuitPreview:OnDestroy()
end


function XUiDrawSuitPreview:OnGetEvents()
    return nil
end


function XUiDrawSuitPreview:OnNotify(evt,...)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiDrawSuitPreview:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiDrawSuitPreview:AutoInitUi()
    self.PanelSuitPreview = self.Transform:Find("SafeAreaContentPane/PanelSuitPreview")
    self.TxtName = self.Transform:Find("SafeAreaContentPane/PanelSuitPreview/PanelDetail/PanelWafer/TxtName"):GetComponent("Text")
    self.RImgIco = self.Transform:Find("SafeAreaContentPane/PanelSuitPreview/PanelDetail/PanelWafer/RImgIco"):GetComponent("RawImage")
    self.PanelContent = self.Transform:Find("SafeAreaContentPane/PanelSuitPreview/PanelDetail/PanelContent")
    self.TxtSkillDes1 = self.Transform:Find("SafeAreaContentPane/PanelSuitPreview/PanelDetail/PanelContent/TxtSkillDes1"):GetComponent("Text")
    self.TxtSkillDes2 = self.Transform:Find("SafeAreaContentPane/PanelSuitPreview/PanelDetail/PanelContent/TxtSkillDes2"):GetComponent("Text")
    self.TxtSkillDes3 = self.Transform:Find("SafeAreaContentPane/PanelSuitPreview/PanelDetail/PanelContent/TxtSkillDes3"):GetComponent("Text")
    self.PanelGrid = self.Transform:Find("SafeAreaContentPane/PanelSuitPreview/PanelSuitDetail/PanelGrid")
    self.GridCommon = self.Transform:Find("SafeAreaContentPane/PanelSuitPreview/PanelSuitDetail/PanelGrid/GridCommon")
    self.BtnClose = self.Transform:Find("SafeAreaContentPane/BtnClose"):GetComponent("Button")
end

function XUiDrawSuitPreview:AutoAddListener()
    self:RegisterClickEvent(self.BtnClose, self.OnBtnCloseClick)
end
-- auto

function XUiDrawSuitPreview:OnBtnCloseClick(eventData)
    XUiHelper.PlayAnimation(self, "AniDrawSuitPreviewEnd", nil, function()
        self:Close()
    end)
end
