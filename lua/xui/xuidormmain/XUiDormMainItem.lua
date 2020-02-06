local XUiDormMainItem = XClass()
local XUiDormMainAttItem = require("XUi/XUiDormMain/XUiDormMainAttItem")
local TextManager = CS.XTextManager
local DormManager
local DisplaySetType
local DormActiveState
local DormMaxCount = 3
local Next = _G.next
local DormSex

function XUiDormMainItem:Ctor(ui,uiroot)
    DormManager = XDataCenter.DormManager
    DisplaySetType = XDormConfig.VisitDisplaySetType
    DormActiveState = XDormConfig.DormActiveState
    DormSex = XDormConfig.DormSex

    self.CurState = false
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Uiroot = uiroot
    XTool.InitUiObject(self)

    self.ImgDormlMainIcons = {}
    self.ImgDormlMainIcons[1] = self.ImgDormlMainIcon0
    self.ImgDormlMainIcons[2] = self.ImgDormlMainIcon1
    self.ImgDormlMainIcons[3] = self.ImgDormlMainIcon2

    self.ImgHeads = {}
    self.ImgHeads[1] = self.Head0
    self.ImgHeads[2] = self.Head1
    self.ImgHeads[3] = self.Head2

    self.ImgHeadsMask = {}
    self.ImgHeadsMask[1] = self.HeadMask0
    self.ImgHeadsMask[2] = self.HeadMask1
    self.ImgHeadsMask[3] = self.HeadMask2

end

-- 更新数据
function XUiDormMainItem:OnRefresh(itemdata,state)
    if not itemdata then
        return
    end

    self.CurDormState = state
    self.ItemData = itemdata
    self.HudEnable:Play()
    local characterIds = {}
    if state == DormActiveState.Active then
        self.CurDormId = self.ItemData:GetRoomId()
        self.Attdatas = DormManager.GetDormitoryScoreIcons(self.CurDormId)
        local maxatt = self.Attdatas[1]
        self.Uiroot:SetUiSprite(self.ImgDes,maxatt[1])
        self.TxtNum.text = TextManager.GetText(XDormConfig.DormAttDesIndex[maxatt[3]],maxatt[2] or 0)
        self.DormName = itemdata:GetRoomName()
        self.TxtName.text = self.DormName

        local characters = self.ItemData:GetCharacter() or {}
        if Next(characters) == nil then
            self.IconsList.gameObject:SetActive(false)
            self.DormManIcon.gameObject:SetActiveEx(false)
            self.DormWomanIcon.gameObject:SetActiveEx(false)
            return
        end

        self.IconsList.gameObject:SetActive(true)
        for i=1,DormMaxCount do
            local d = characters[i]
            if d then
                characterIds[d.CharacterId] = d.CharacterId
                local path = XDormConfig.GetCharacterStyleConfigQIconById(d.CharacterId)
                local img = self.ImgDormlMainIcons[i]
                local headgo = self.ImgHeads[i]
                headgo.gameObject:SetActive(true)
                img.gameObject:SetActive(true)
                img:SetRawImage(path,nil,true)
                local isworking = DormManager.IsWorking(d.CharacterId)
                self.ImgHeadsMask[i].gameObject:SetActive(isworking)
            else
                local headgo = self.ImgHeads[i]
                headgo.gameObject:SetActive(false)
                local img = self.ImgDormlMainIcons[i]
                img.gameObject:SetActive(false)
                self.ImgHeadsMask[i].gameObject:SetActive(false)
            end
        end
        -- return
    end

    -- self.IconsList.gameObject:SetActive(false)
    -- self.CurDormId = itemdata:GetRoomId()
    -- self.Attdatas = DormManager.GetDormitoryScoreIcons(self.CurDormId)
    -- local maxatt = self.Attdatas[1]
    -- self.Uiroot:SetUiSprite(self.ImgDes,maxatt[1])
    -- self.TxtNum.text = maxatt[2]
    -- self.TxtName.text = itemdata:GetRoomName()
    local t = self:GetDormSexType(characterIds)
    if t == DormSex.Other then
        self.DormManIcon.gameObject:SetActiveEx(false)
        self.DormWomanIcon.gameObject:SetActiveEx(false)
        self.DormGanIcon.gameObject:SetActiveEx(false)
    elseif t == DormSex.Man then
        self.DormManIcon.gameObject:SetActiveEx(true)
        self.DormWomanIcon.gameObject:SetActiveEx(false)
        self.DormGanIcon.gameObject:SetActiveEx(false)
    elseif t == DormSex.Woman then
        self.DormManIcon.gameObject:SetActiveEx(false)
        self.DormWomanIcon.gameObject:SetActiveEx(true)
        self.DormGanIcon.gameObject:SetActiveEx(false)
    else
        self.DormManIcon.gameObject:SetActiveEx(false)
        self.DormWomanIcon.gameObject:SetActiveEx(false)
        self.DormGanIcon.gameObject:SetActiveEx(true)
    end
end

function XUiDormMainItem:SetEvenIconState(state)
    if self.CurState ~= state then
        self.CurState = state
        self.EventIcon.gameObject:SetActive(state)
    end
end

function XUiDormMainItem:GetDormSexType(characterIds)
    if not characterIds or not Next(characterIds) then
        return DormSex.Other
    end

    local pretype = nil
    for _,Id in pairs(characterIds)do
        local t = DormManager.GetDormSex(Id)
        if not pretype then
            pretype = t
        else
            if pretype ~= t then
                return DormSex.Other 
            end
        end
    end

    return pretype
end

return XUiDormMainItem