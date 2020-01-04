local CARRY_NUM = 3

local XUiCharacterCarerrTips = XLuaUiManager.Register(XLuaUi, "UiCharacterCarerrTips")

function XUiCharacterCarerrTips:OnStart()
    self:InitCareerView()
    self.BtnClose.CallBack = function() self:Close() end
end

function XUiCharacterCarerrTips:InitCareerView()
    for i = 1, CARRY_NUM do
        local config = XCharacterConfigs.GetNpcTypeTemplate(i)
        self["TxtTypeName" .. i].text = config.Name
        self["TxtTypeDes" .. i].text = config.Des
        self["RImgCareerType" .. i]:SetRawImage(config.Icon)
    end
end