local PANEL = {}

function PANEL:Init ()
	self.Key = ""
	self.SortKey = ""
	self.ActionTree = nil
	
	self.KeyText = vgui.Create ("DLabel", self)
	self.Dash = vgui.Create ("DLabel", self)
	self.Dash:SetText (" - ")
	self.Dash:SetVisible (false)
	
	self:SetIcon ("gui/silkicons/world")
end

function PANEL:PerformLayout ()
	local w = self:GetWide ()
	local h = self:GetItemHeight ()

	self:SetTall (h + 2)
	local offset = 0
	if self.Depressed then
		offset = 1
	end
	
	self.KeyText:SetPos (20 + offset, 0 + offset)
	self.KeyText:SetSize (w, h)
	self.Dash:SetPos (44 + offset, 0 + offset)
	self.Dash:SetSize (w, h)
	self.Text:SetPos (64 + offset, 0 + offset)
	self.Text:SetSize (w, h)
	
	self.Icon:SetPos (2 + offset, 2 + offset)
	self.Icon:SetSize (16, 16)
end

function PANEL:SetActionTree (tree)
	local type = tree:GetType ()
	if tree then
		local description = tree:GetDescription ()
		if tree:GetDescription () then
			self:SetText (description)
		elseif type == "command" then
			self:SetText (tree:GetCommand ())
		end
	end
	
	if tree then
		if type == "tree" then
			self:SetIcon ("gui/silkicons/folder_go")
		elseif type == "command" then
			self:SetIcon ("gui/silkicons/car")
		elseif type == "tool" then
			if tree:CanUseTool () then
				self:SetIcon ("gui/silkicons/wrench")
			else
				self:SetIcon ("gui/silkicons/check_off")
			end
		else
			self:SetIcon ("gui/silkicons/exclamation")
		end
	end
end

function PANEL:SetKey (key)
	if self.SortKey == self.Key then
		self.SortKey = key
	end
	self.Key = key
	self.KeyText:SetText (key:upper ())
end

function PANEL:SetText (text)
	text = text or ""
	self.Dash:SetVisible (text ~= "")
	self.BaseClass.SetText (self, text)
end

vgui.Register ("QuickToolHotkeyMenuItem", PANEL, "QuickToolMenuItem")