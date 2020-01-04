XUiInstruction = XClass()

function XUiInstruction:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)

    self.Npc = {self.Npc1, self.Npc2, self.Npc3}
    self.TogPortrait = {self.TogPortrait1, self.TogPortrait2, self.TogPortrait3}
    self.PanelNpc:Init(self.Npc, function(index) self:OnPanelNpc(index) end)
    self.Core = {}
    self.CoreDescription = {}
    self:Init()
end

function XUiInstruction:Init()
    local role = CS.XFight.GetClientRole();
    for i = 1, 3 do
        local npc
        local hasNpc, npc = role:GetNpc(i - 1)
        if not hasNpc then
            self.Npc[i].gameObject:SetActiveEx(false)
        else
            local characterId = math.floor(npc.TemplateId / 10)
            self.Core[i] = XCharacterConfigs.GetCharTeachIconById(characterId)
            self.CoreDescription[i] = XCharacterConfigs.GetCharTeachDescriptionById(characterId)
            local iconPath = npc.Template.HeadImageName
            if npc.FightNpcData ~= nil then
                iconPath = XDataCenter.CharacterManager.GetFightCharHeadIcon(npc.FightNpcData.Character)
            end
            self.TogPortrait[i]:SetRawImage(iconPath)
        end
    end
    self.PanelNpc:SelectIndex(1)
end

function XUiInstruction:OnPanelNpc(index)
    self.ImgCoreSkill:SetRawImage(self.Core[index])
    self.TxtCoreDescription.text = self.CoreDescription[index]
end

function XUiInstruction:ShowPanel()
    self.IsShow = true
    self.GameObject:SetActive(true)
end

function XUiInstruction:HidePanel()
    self.IsShow = false
    self.GameObject:SetActive(false)
end

function XUiInstruction:CheckDataIsChange()
    
    return false
end

function XUiInstruction:SaveChange()
    
end

function XUiInstruction:CancelChange()

end

function XUiInstruction:ResetToDefault()
    
end