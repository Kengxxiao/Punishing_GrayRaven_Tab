local XUiGridDraft = require("XUi/XUiDormBag/XUiGridDraft")
local XUiGridFurniture = require("XUi/XUiDormBag/XUiGridFurniture")
local XUiGridDormCharacter = require("XUi/XUiDormBag/XUiGridDormCharacter")

local XUiPanelDormBagItem = XClass()

function XUiPanelDormBagItem:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
end

function XUiPanelDormBagItem:Init(rootUi)
    self.Parent = rootUi
    self.DraftGrid = XUiGridDraft.New(self.GridDraft, rootUi)
    self.FurnitureGrid = XUiGridFurniture.New(rootUi, self.GridFurniture)
    self.FurnitureWorkGrid = XUiGridFurniture.New(rootUi, self.GridFurnitureWork)
    self.CharacterGrid = XUiGridDormCharacter.New(self.GridCharacter, rootUi)
end

function XUiPanelDormBagItem:SetupFurniture(furnitureId, isSelect)
    if isSelect then
        self.FurnitureWorkGrid:Refresh(furnitureId)
    else
        self.FurnitureGrid:Refresh(furnitureId)
    end

    self.FurnitureGrid.GameObject:SetActiveEx(not isSelect)
    self.CharacterGrid.GameObject:SetActiveEx(false)
    self.DraftGrid.GameObject:SetActiveEx(false)
    self.FurnitureWorkGrid.GameObject:SetActiveEx(isSelect)
end

function XUiPanelDormBagItem:SetupCharacter(characterId)
    self.CharacterGrid:Refresh(characterId)
    self.FurnitureGrid.GameObject:SetActiveEx(false)
    self.CharacterGrid.GameObject:SetActiveEx(true)
    self.DraftGrid.GameObject:SetActiveEx(false)
    self.FurnitureWorkGrid.GameObject:SetActiveEx(false)
end

function XUiPanelDormBagItem:SetupDraft(data)
    self.DraftGrid:Refresh(data)
    self.FurnitureGrid.GameObject:SetActiveEx(false)
    self.CharacterGrid.GameObject:SetActiveEx(false)
    self.DraftGrid.GameObject:SetActiveEx(true)
    self.FurnitureWorkGrid.GameObject:SetActiveEx(false)
end

return XUiPanelDormBagItem
