XUiPanelVoiceSet = XClass()

function XUiPanelVoiceSet:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
    self.MyColor = CS.UnityEngine.Color()
    self:InitPanelData()
    self:SetPanel()
    self:AddListener()
end

function XUiPanelVoiceSet:AddListener()

    XUiHelper.RegisterClickEvent(self, self.TogRiwen, self.OnLanguageClick)
    XUiHelper.RegisterClickEvent(self, self.TogZhongWen, self.OnLanguageClick)
    XUiHelper.RegisterClickEvent(self, self.TogXiangGang, self.OnLanguageClick)
    XUiHelper.RegisterClickEvent(self, self.TogControl, self.OnTogControlClick)

    XUiHelper.RegisterSliderChangeEvent(self, self.SliMusic, self.OnSliMusicValueChanged)
    XUiHelper.RegisterSliderChangeEvent(self, self.SliSound, self.OnSliSoundValueChanged)
    XUiHelper.RegisterSliderChangeEvent(self, self.SliCv, self.OnSliCvValueChanged)

    XUiHelper.RegisterClickEvent(self, self.BtnCanDown, self.OnBtnCanDownClick)
    XUiHelper.RegisterClickEvent(self, self.BtnDownload, self.OnBtnDownloadClick)
    XUiHelper.RegisterClickEvent(self, self.BtnUpdate, self.OnBtnUpdateClick)
end

function XUiPanelVoiceSet:OnLanguageClick(...)
    if (self.TogRiwen.isOn) then
        self.NewCvType = 1
    elseif (self.TogZhongWen.isOn) then
        self.NewCvType = 2
    elseif (self.TogXiangGang.isOn) then
        self.NewCvType = 3
    end
    CS.XAudioManager.CvType = self.NewCvType
end

function XUiPanelVoiceSet:OnTogControlClick(...)
    self:SetTogControl(self.TogControl.isOn)
    if (self.TogControl.isOn) then
        self.NewControl = 1
    else
        self.NewControl = 2
    end
    self:SetVolume()
end

function XUiPanelVoiceSet:SetTogControl(IsOn)
    if (IsOn) then
        self:ChangeObjsTansparent(1.0)
    else
        self:ChangeObjsTansparent(0.5)
    end
    self.SliMusic.interactable = IsOn
    self.SliSound.interactable = IsOn
    self.SliCv.interactable = IsOn
end


function XUiPanelVoiceSet:OnSliDownloadValueChanged(...)

end

function XUiPanelVoiceSet:OnBtnCanDownClick(...)

end

function XUiPanelVoiceSet:OnBtnDownloadClick(...)

end

function XUiPanelVoiceSet:OnBtnUpdateClick(...)

end

function XUiPanelVoiceSet:OnSliMusicValueChanged(...)
    self.NewMusicVolume = self.SliMusic.value
    CS.XAudioManager.ChangeMusicVolume(self.SliMusic.value)
end

function XUiPanelVoiceSet:OnSliSoundValueChanged(...)
    self.NewSoundVolume = self.SliSound.value
    CS.XAudioManager.ChangeSoundVolume(self.SliSound.value)
end

function XUiPanelVoiceSet:OnSliCvValueChanged(...)
    self.NewCvVolume = self.SliCv.value
    CS.XAudioManager.ChangeCvVolume(self.SliCv.value)
end

function XUiPanelVoiceSet:InitPanelData()
    self.CvType = CS.XAudioManager.CvType
    self.MusicVolume = CS.XAudioManager.MusicVolume
    self.SoundVolume = CS.XAudioManager.SoundVolume
    self.CvVolume = CS.XAudioManager.CvVolume
    self.Control = CS.XAudioManager.Control
    self.NewCvType = self.CvType
    self.NewCvVolume = self.CvVolume
    self.NewMusicVolume = self.MusicVolume
    self.NewSoundVolume = self.SoundVolume
    self.NewControl = self.Control
end

function XUiPanelVoiceSet:ResetPanelData()
    CS.XAudioManager.ResetToDefault()
    self.NewCvType = CS.XAudioManager.CvType
    self.NewCvVolume = CS.XAudioManager.CvVolume
    self.NewMusicVolume = CS.XAudioManager.MusicVolume
    self.NewSoundVolume = CS.XAudioManager.SoundVolume
    self.NewControl = CS.XAudioManager.Control
end

function XUiPanelVoiceSet:SetPanel()
    self:SetVolume()
    self:SetTogControl(self.TogControl.isOn)

    self.SliMusic.value = self.NewMusicVolume
    self.SliSound.value = self.NewSoundVolume
    self.SliCv.value = self.NewCvVolume

    if (self.NewCvType == 1) then
        self.TogRiwen.isOn = true
    elseif (self.NewCvType == 2) then
        self.TogZhongWen.isOn = true
    elseif (self.NewCvType == 3) then
        self.TogXiangGang.isOn = true
    end
end

function XUiPanelVoiceSet:SetVolume()
    local XAManager = CS.XAudioManager
    if (self.NewControl == 2) then
        self.TogControl.isOn = false
        XAManager.ChangeMusicVolume(0)
        XAManager.ChangeSoundVolume(0)
        XAManager.ChangeCvVolume(0)
    else
        self.TogControl.isOn = true
        XAManager.ChangeMusicVolume(self.NewMusicVolume)
        XAManager.ChangeSoundVolume(self.NewSoundVolume)
        XAManager.ChangeCvVolume(self.NewCvVolume)
    end
end

function XUiPanelVoiceSet:ShowPanel()
    self.IsShow = true
    self.GameObject:SetActive(true)
    self.Transform:Find("Yuyanbao").gameObject:SetActive(false)

    self:InitPanelData()
    self:SetPanel()
    -- if (self:CheckNeedDownloadSource()==0) then
    --     -- self.BtnCanDown.gameObject:SetActive(false)
    --     -- self.BtnDownloaded.gameObject:SetActive(true)
    --     -- self.PanelDownload.gameObject:SetActive(false)

    --     self.BtnCanDown.gameObject:SetActive(false)
    --     self.BtnDownloaded.gameObject:SetActive(false)
    --     self.PanelDownload.gameObject:SetActive(false)

    -- end
end

function XUiPanelVoiceSet:CheckNeedDownloadSource()
    return 0
end

function XUiPanelVoiceSet:HidePanel()
    self.IsShow = false
    self.GameObject:SetActive(false)
end

function XUiPanelVoiceSet:CheckDataIsChange()
    if (self.NewCvType ~= self.CvType) then
        return true
    end
    if (self.NewCvVolume ~= self.CvVolume) then
        return true
    end
    if (self.NewMusicVolume ~= self.MusicVolume) then
        return true
    end
    if (self.NewSoundVolume ~= self.SoundVolume) then
        return true
    end
    if (self.NewControl ~= self.Control) then
        return true
    end

    return false
end

function XUiPanelVoiceSet:SaveChange()
    local XAManager = CS.XAudioManager
    self.CvType = self.NewCvType
    self.MusicVolume = self.NewMusicVolume
    self.SoundVolume = self.NewSoundVolume
    self.CvVolume = self.NewCvVolume
    self.Control = self.NewControl
    self:SaveAudioManagerData()
end

function XUiPanelVoiceSet:CancelChange()
    self.NewCvType = self.CvType
    self.NewCvVolume = self.CvVolume
    self.NewMusicVolume = self.MusicVolume
    self.NewSoundVolume = self.SoundVolume
    self.NewControl = self.Control
    self:SetVolume()
    self:SaveAudioManagerData()
end

function XUiPanelVoiceSet:SaveAudioManagerData()
    local XAManager = CS.XAudioManager
    XAManager.CvType = self.NewCvType
    XAManager.MusicVolume = self.NewMusicVolume
    XAManager.SoundVolume = self.NewSoundVolume
    XAManager.CvVolume = self.NewCvVolume
    XAManager.Control = self.NewControl
    XAManager.SaveChange()
end

function XUiPanelVoiceSet:ResetToDefault()
    self:ResetPanelData()
    self:SetPanel()
end

function XUiPanelVoiceSet:ChangeObjsTansparent(alpha)
    self.MyColor.a = alpha

    self.TxtMusic.color = self.MyColor
    self.ImgMusicON.color = self.MyColor
    self.ImgMusicOFF.color = self.MyColor
    self.ImgMusicFill.color = self.MyColor

    self.TxtSound.color = self.MyColor
    self.ImgSoundON.color = self.MyColor
    self.ImgSoundOFF.color = self.MyColor
    self.ImgSoundFill.color = self.MyColor

    self.TxtYinliang.color = self.MyColor
    self.ImgYinliangON.color = self.MyColor
    self.ImgYinliangOFF.color = self.MyColor
    self.ImgYinliangFill.color = self.MyColor
end