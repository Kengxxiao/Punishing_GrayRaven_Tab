local ATTR_COLOR = {
    BELOW = XUiHelper.Hexcolor2Color("d11e38ff"),
    EQUAL = XUiHelper.Hexcolor2Color("000000ff"),
    OVER = XUiHelper.Hexcolor2Color("188649ff"),
}

local XUiGridEquipReplaceAttr = XClass()

function XUiGridEquipReplaceAttr:Ctor(ui, name, doNotChangeColor)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
    self.TxtName.text = name
    self.DoNotChangeColor = doNotChangeColor
end

function XUiGridEquipReplaceAttr:UpdateData(curAttrValue, newattrvalue, notShowSame)
    if curAttrValue then
        self.CurAttrValue = curAttrValue
        self.TxtCurAttr.text = self.CurAttrValue
    end

    if not newattrvalue or notShowSame and self.CurAttrValue and newattrvalue == self.CurAttrValue then
        self.TxtSelectAttr.gameObject:SetActive(false)
        return
    end

    self.Newattrvalue = newattrvalue
    self.TxtSelectAttr.text = self.Newattrvalue
    self.TxtSelectAttr.gameObject:SetActive(true)

    if not self.DoNotChangeColor then
        if self.CurAttrValue == self.Newattrvalue then
            self.TxtSelectAttr.color = ATTR_COLOR.EQUAL
        elseif self.CurAttrValue < self.Newattrvalue then
            self.TxtSelectAttr.color = ATTR_COLOR.OVER
        elseif self.CurAttrValue > self.Newattrvalue then
            self.TxtSelectAttr.color = ATTR_COLOR.BELOW
        end
    end
end
-- auto
-- Automatic generation of code, forbid to edit
function XUiGridEquipReplaceAttr:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiGridEquipReplaceAttr:AutoInitUi()
    self.TxtName = self.Transform:Find("TxtName"):GetComponent("Text")
    self.TxtCurAttr = self.Transform:Find("TxtCurAttr"):GetComponent("Text")
    self.TxtSelectAttr = self.Transform:Find("TxtSelectAttr"):GetComponent("Text")
end

function XUiGridEquipReplaceAttr:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiGridEquipReplaceAttr:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiGridEquipReplaceAttr:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiGridEquipReplaceAttr:AutoAddListener()
end
-- auto
return XUiGridEquipReplaceAttr