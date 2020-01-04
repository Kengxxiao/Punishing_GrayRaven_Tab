
XHomeCharFSM = Class("XHomeCharFSM")

function XHomeCharFSM:Ctor(agent)
    self.Agent = agent
end

function XHomeCharFSM:Enter()
    self:OnEnter()
end

function XHomeCharFSM:OnEnter()

end

function XHomeCharFSM:Execute()

end


function XHomeCharFSM:Exit()
    self:OnExit()
end

function XHomeCharFSM:OnExit()

end


