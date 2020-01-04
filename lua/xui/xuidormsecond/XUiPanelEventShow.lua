local XUiPanelEventShow = XClass()

local XScheduleManager = CS.XScheduleManager
local WaitSecond = 3
local SimpleFadeTimer = nil
local ComplexFadeTimer = nil

function XUiPanelEventShow:Ctor(uiroot,ui)
    self.DormManager = XDataCenter.DormManager
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.UiRoot = uiroot

    XTool.InitUiObject(self)
end

function XUiPanelEventShow:SetDefaultPoint()
    local pos = self.Transform.localPosition
    local targetPos = self.PanelTarget.localPosition
    self.Transform.localPosition = CS.UnityEngine.Vector3(targetPos.x, pos.y, 0)
end

function XUiPanelEventShow:Show(data)
    self.ShowConfig = XDormConfig.GetCharacterShowEvent(data.EventId)
    if self.ShowConfig.ShowType <= 0 then
        self:GetNextShowEvent()
        return
    end

    if self.ShowConfig.ShowType == XDormConfig.ShowEffectType.Simple then
        self:ShowSimple(data)
    elseif self.ShowConfig.ShowType == XDormConfig.ShowEffectType.Complex then
        self:ShowComplex(data)
    end

    self.PanelEvenetShowSimple.gameObject:SetActive(self.ShowConfig.ShowType == XDormConfig.ShowEffectType.Simple)
    self.PanelEvenetShowComplex.gameObject:SetActive(self.ShowConfig.ShowType == XDormConfig.ShowEffectType.Complex)

    if self.ShowConfig.ShowType == XDormConfig.ShowEffectType.Simple then

        self.UiRoot:PlayAnimation("EvenetShowSimpleEnable", function()
            self:StopSimpleTimer()
            SimpleFadeTimer = XScheduleManager.ScheduleOnce(function()
                self.UiRoot:PlayAnimation("EvenetShowSimpleDisable", function()
                    self:GetNextShowEvent()
                end)
            end, 1000 * WaitSecond)
        end)
            
    elseif self.ShowConfig.ShowType == XDormConfig.ShowEffectType.Complex then

        self.UiRoot:PlayAnimation("EvenetShowComplexEnable", function()
            self:StopComplexTimer()
            SimpleFadeTimer = XScheduleManager.ScheduleOnce(function()
                self.UiRoot:PlayAnimation("EvenetShowComplexDisable", function()
                    self:GetNextShowEvent()
                end)
            end, 1000 * WaitSecond)
        end)
    end
end

function XUiPanelEventShow:StopSimpleTimer()
    if SimpleFadeTimer then
        XScheduleManager.UnSchedule(SimpleFadeTimer)
        SimpleFadeTimer = nil
    end
end

function XUiPanelEventShow:StopComplexTimer()
    if ComplexFadeTimer then
        XScheduleManager.UnSchedule(ComplexFadeTimer)
        ComplexFadeTimer = nil
    end
end

function XUiPanelEventShow:OnEventShowDestroy()
    self:StopSimpleTimer()
    self:StopComplexTimer()
end

function XUiPanelEventShow:ShowSimple(data)
    self.TextDesc.text = CS.XTextManager.FormatString(self.ShowConfig.Description[1], math.abs(data.ChangeValue))
    local charStyleConfig = XDormConfig.GetCharacterStyleConfigById(data.CharacterId)
    self.RawImage:SetRawImage(charStyleConfig.HeadIcon, nil, true)
end

function XUiPanelEventShow:ShowComplex(data)
    self.TextComplexDesc.text = CS.XTextManager.FormatString(self.ShowConfig.Description[1], math.abs(data.ChangeValue))
    self.TextComplexDesc2.text = self.ShowConfig.Description[2]
    local charStyleConfig = XDormConfig.GetCharacterStyleConfigById(data.CharacterId)
    self.RawComplexImage:SetRawImage(charStyleConfig.HeadIcon, nil, true)
end

function XUiPanelEventShow:GetNextShowEvent()
    XDataCenter.DormManager.GetNextShowEvent()
end

function XUiPanelEventShow:EventShowAnimaStart(cb)
    self.PanelEventShowTimeLine.gameObject:PlayTimelineAnimation(cb)
end

return XUiPanelEventShow