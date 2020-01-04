local XGuideShowDialogNode = XLuaBehaviorManager.RegisterNode(XLuaBehaviorNode, "GuideShowDialog",CsBehaviorNodeType.Action,true,false)
--显示对话头像
function XGuideShowDialogNode:OnAwake()
    if self.Fields == nil then
        self.Node.Status = CsNodeStatus.ERROR
        return
    end

    if self.Fields["Image"] == nil or self.Fields["Name"] == nil or self.Fields["Content"] == nil then    
        self.Node.Status = CsNodeStatus.ERROR
        return
    end

    self.ImageString = self.Fields["Image"]
    self.RoleName = self.Fields["Name"]
    self.Content = self.Fields["Content"]
    self.Pos = self.Fields["Pos"]
end

function XGuideShowDialogNode:OnEnter()
    self.AgentProxy:ShowDialog(self.ImageString,self.RoleName,self.Content,self.Pos)
    self.Node.Status = CsNodeStatus.SUCCESS
end