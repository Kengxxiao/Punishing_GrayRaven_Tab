local XUiDormMainItem = XClass()
local XUiDormMainAttItem = require("XUi/XUiDormMain/XUiDormMainAttItem")
local TextManager = CS.XTextManager
local DormManager
local DisplaySetType
local DormActiveState
local DormMaxCount = 3
local Next = _G.next

function XUiDormMainItem:Ctor(ui,uiroot)
    DormManager = XDataCenter.DormManager
    DisplaySetType = XDormConfig.VisitDisplaySetType
    DormActiveState = XDormConfig.DormActiveState
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
    if state == DormActiveState.Active then
        
        self.CurDormId = self.ItemData:GetRoomId()
        self.Attdatas = DormManager.GetDormitoryScoreIcons(self.CurDormId)
        local maxatt = self.Attdatas[1]
        self.Uiroot:SetUiSprite(self.ImgDes,maxatt[1])
        self.TxtNum.text = maxatt[2]
        self.DormName = itemdata:GetRoomName()
        self.TxtName.text = self.DormName

        local characters = self.ItemData:GetCharacter() or {}
        if Next(characters) == nil then
            self.IconsList.gameObject:SetActive(false)
            return
        end

        self.IconsList.gameObject:SetActive(true)
        for i=1,DormMaxCount do
            local d = characters[i]
            if d then
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
        return
    end

    self.IconsList.gameObject:SetActive(false)
    self.CurDormId = itemdata:GetRoomId()
    self.Attdatas = DormManager.GetDormitoryScoreIcons(self.CurDormId)
    local maxatt = self.Attdatas[1]
    self.Uiroot:SetUiSprite(self.ImgDes,maxatt[1])
    self.TxtNum.text = maxatt[2]
    self.TxtName.text = itemdata:GetRoomName()
end

function XUiDormMainItem:SetEvenIconState(state)
    if self.CurState ~= state then
        self.CurState = state
        self.EventIcon.gameObject:SetActive(state)
    end
end

return XUiDormMainItem