XUiFubenExploreQuickJumpBtn = XClass()
function XUiFubenExploreQuickJumpBtn:Ctor(ui, data, cb)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.NodeInfo = data
    self.Cb = cb
    XTool.InitUiObject(self)
    self.BtnNormalDot.CallBack = function() self:OnBtnNodeClick() end
    self:UpdateNode(self.NodeInfo)
end

function XUiFubenExploreQuickJumpBtn:OnBtnNodeClick(...)
    self.Cb(self.NodeInfo)
end

function XUiFubenExploreQuickJumpBtn:UpdateNode(data)
    self.NodeInfo = data
    self.TxtName.text = data.tableData.Name
end