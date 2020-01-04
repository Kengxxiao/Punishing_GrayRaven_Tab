local XUiGridCommon = require("XUi/XUiObtain/XUiGridCommon")
local XUiGridMissionCommon = Class("XUiGridMissionCommon", XUiGridCommon)

function XUiGridMissionCommon:Ctor(rootUi, ui)
    self.super.Ctor(self, rootUi, ui)
    self.ImgBig = XUiHelper.TryGetComponent(self.Transform, "ImgBig", "Image")
    self.ImgAdditional = XUiHelper.TryGetComponent(self.Transform, "ImgAdditional", "Image")
end

return XUiGridMissionCommon
