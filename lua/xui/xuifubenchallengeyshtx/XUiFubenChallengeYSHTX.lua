local XUiFubenChallengeYSHTX = XLuaUiManager.Register(XLuaUi, "UiFubenChallengeYSHTX")
local XUiPanelYSHTXStageTemplate = require("XUi/XUiFubenChallengeYSHTX/XUiPanelYSHTXStageTemplate")

function XUiFubenChallengeYSHTX:OnAwake()
    self:InitAutoScript()
end

function XUiFubenChallengeYSHTX:OnStart(parent, config)
    self.Parent = parent
    self:Init(config)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiFubenChallengeYSHTX:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiFubenChallengeYSHTX:AutoInitUi()
    self.PanelPageView = self.Transform:Find("SafeAreaContentPane/PanelPageView")
    self.PanelContent = self.Transform:Find("SafeAreaContentPane/PanelPageView/Viewport/PanelContent")
    self.PanelYSHTXStageTemplate = self.Transform:Find("SafeAreaContentPane/PanelPageView/Viewport/PanelContent/PanelYSHTXStageTemplate")
    self.ImgBg = self.Transform:Find("FullScreenBackground/ImgBg"):GetComponent("Image")
    self.ImgHero = self.Transform:Find("SafeAreaContentPane/ImgHero"):GetComponent("Image")
end

function XUiFubenChallengeYSHTX:AutoAddListener()
end
-- auto
function XUiFubenChallengeYSHTX:OnSViewStageListValueChanged(...)

end

function XUiFubenChallengeYSHTX:Init(config)
    self.ChallengeCfg = config
    if config.Bg and config.Bg ~= "" then
        self:SetUiSprite(self.ImgBg, config.Bg)
    end
    self.PanelYSHTXStageTemplate.gameObject:SetActive(false)

    -- 自己的列表
    local rect = self.PanelYSHTXStageTemplate:GetComponent("RectTransform").rect
    self.SectionCfg = XDataCenter.FubenDailyManager.GetDailySectionByChapterId(config.Id, self.Parent.CurDiff)
    local lastIndex = 0
    for index, stageId in ipairs(self.SectionCfg.StageId) do
        local stageCfg = XDataCenter.FubenManager.GetStageCfg(stageId)
        if stageCfg then
            local obj = CS.UnityEngine.Object.Instantiate(self.PanelYSHTXStageTemplate)
            obj.gameObject:SetActive(true)
            obj.gameObject.name = index
            local item = XUiPanelYSHTXStageTemplate.New(self, obj, stageCfg, function(cfg, info)
                self:OnEnterStage(cfg, info)
            end)
            if item:IsOpen() then
                lastIndex = index - 1
            end
            obj.transform:SetParent(self.PanelContent, false)
        end
    end
end

function XUiFubenChallengeYSHTX:OnEnterStage(stageCfg, stageInfo)
    if stageInfo and not stageInfo.Unlock then
        local msg = XDataCenter.FubenManager.GetFubenOpenTips(stageCfg.StageId)
        XUiManager.TipMsg(msg)
        return
    end
    -- self.PanelPageView.gameObject:SetActive(false)
    self.Parent:OpenPanelStageDetail(stageCfg, stageInfo)
end

function XUiFubenChallengeYSHTX:OnCloseStageDetail()
    self.PanelPageView.gameObject:SetActive(true)
end

return XUiFubenChallengeYSHTX