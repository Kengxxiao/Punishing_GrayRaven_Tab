local XHomeCharFSMInteract  = XHomeCharFSMFactory.RegisterFSM("XHomeCharFSMInteract",XHomeCharFSMType.INTERACT)

function XHomeCharFSMInteract:OnEnter()

end

function XHomeCharFSMInteract:Execute()
    --ToDo
end

function XHomeCharFSMInteract:OnExit()

    --如果有家具交互
    if self.Agent.Furniture then
        self.Agent:DisInteractFurniture()
    end

    self.Agent.NavMeshAgent.IsObstacle = true
end

return XHomeCharFSMInteract