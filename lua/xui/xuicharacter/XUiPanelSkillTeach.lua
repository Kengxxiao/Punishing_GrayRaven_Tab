local XUiPanelSkillTeach = XLuaUiManager.Register(XLuaUi, "UiPanelSkillTeach")

function XUiPanelSkillTeach:OnAwake()
    self:AutoAddListener()
    self.BtnTeach.gameObject:SetActiveEx(false)
end

function XUiPanelSkillTeach:OnStart(characterId)
    self.CharacterId = characterId
end

function XUiPanelSkillTeach:OnEnable()
    self:UpdateView()
end

function XUiPanelSkillTeach:AutoAddListener()
    self:RegisterClickEvent(self.BtnTanchuangClose, self.OnBtnTanchuangCloseClick)
    self:RegisterClickEvent(self.BtnTeach, self.OnBtnTeachClick)
    self:RegisterClickEvent(self.BtnFight, self.OnBtnFightClick)
end

function XUiPanelSkillTeach:OnBtnTanchuangCloseClick(eventData)
    self:Close()
end

function XUiPanelSkillTeach:OnBtnTeachClick(eventData)
    local characterId = self.CharacterId
    local url = XCharacterConfigs.GetCharTeachWebUrlById(characterId)
    self:UpdateWebView(url)
end

function XUiPanelSkillTeach:OnBtnFightClick(eventData)
    local characterId = self.CharacterId
    XDataCenter.FubenManager.EnterSkillTeachFight(characterId)
end

function XUiPanelSkillTeach:UpdateView()
    local characterId = self.CharacterId

    local data = XCharacterConfigs.GetCharTeachById(characterId)
    if not data then return end

    self:SetUiSprite(self.ImgSkill, data.TeachIcon)
    self.TxtSkillName.text = data.Title
    self.TxtSkillDesc.text = string.format("%s%s", "　", data.Description)
end

function XUiPanelSkillTeach:UpdateWebView(url)
    if self.CurUrl and self.CurUrl == url then
        return
    end
    self.CurUrl = url

    if self.WebViewPanel then
        CS.UnityEngine.Object.Destroy(self.WebViewPanel.gameObject)
        self.WebViewPanel = nil
    end
    
    CS.XTool.WaitNativeCoroutine(CS.UnityEngine.WaitForEndOfFrame(), function ()
    self.WebViewPanel = CS.UnityEngine.Object.Instantiate(self.PanelWebView, self.PanelWebView.parent)
        CS.XWebView.Load(self.WebViewPanel.gameObject, self.CurUrl)
    end)
end

