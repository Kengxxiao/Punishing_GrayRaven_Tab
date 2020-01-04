local XHomeCharJudgeAttrIntNode = XLuaBehaviorManager.RegisterNode(XLuaBehaviorNode, "HomeCharJudgeAttrInt", CsBehaviorNodeType.Action, true, false)

local CompareSymbol = {
    Less = 1, --小于 <
    Greater = 2, --/大于 >
    LEqual = 3, --小于等于 <=
    GEqual = 4, --大于等于 >=
    Equal = 5, --大于等于 ==
    NotEqual = 6, --不等于 ！=
}


function XHomeCharJudgeAttrIntNode:OnAwake()
    if self.Fields == nil then
        self.Node.Status = CsNodeStatus.ERROR
        return
    end

    if self.Fields["AttributeKey"] == nil or self.Fields["CompareSymbol"] == nil or self.Fields["CompareValue"] == nil then
        self.Node.Status = CsNodeStatus.ERROR
        return
    end

    self.AttributeKey = self.Fields["AttributeKey"]
    self.CompareSymbol = self.Fields["CompareSymbol"]
    self.AttributeValue = self.Fields["CompareValue"]

end

function XHomeCharJudgeAttrIntNode:OnStart()
    self.Attribute = self.AgentProxy:GetAtrributeValue(self.AttributeKey)

end

function XHomeCharJudgeAttrIntNode:OnEnter()

    local result = false
    if self.CompareSymbol == CompareSymbol.Less then
        result = self.Attribute < self.AttributeValue
    elseif self.CompareSymbol == CompareSymbol.Equal then
        result = self.Attribute == self.AttributeValue
    elseif self.CompareSymbol == CompareSymbol.NotEqual then
        result = self.Attribute ~= self.AttributeValue
    elseif self.CompareSymbol == CompareSymbol.GEqual then
        result = self.Attribute >= self.AttributeValue
    elseif self.CompareSymbol == CompareSymbol.LEqual then
        result = self.Attribute <= self.AttributeValue
    elseif self.CompareSymbol == CompareSymbol.Greater then
        result = self.Attribute >= self.AttributeValue
    end


    if result then
        self.Node.Status = CsNodeStatus.SUCCESS
    else
        self.Node.Status = CsNodeStatus.FAILED
    end

end
