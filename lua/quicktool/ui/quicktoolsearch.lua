local PANEL = {}

local gmod_tool = nil

function PANEL:Init ()
	self:SetTitle ("Tool search")
	
	self:SetSize (200, ScrH ())
	self:MakePopup ()
	
	self:SetDeleteOnClose (false)
	self:SetMouseInputEnabled (true)
	self:SetKeyboardInputEnabled (true)
	
	self.btnClose:Remove ()
	self.btnClose = nil
	
	self:SetPaintBackgroundEnabled (true)
	self:SetPaintBorderEnabled (true)
	
	self.HighlightedName = nil
	
	-- Textbox
	self.Searchbox = vgui.Create ("DTextEntry", self)
	self.Searchbox:SetPos (0, 0)
	self.Searchbox:SetWide (self:GetWide ())
	
	self.Searchbox.OnEnter = function (textbox)
		if self.Menu:GetHighlightedItem () then
			self:OnItemChosen (self.Menu:GetHighlightedItem ().Name)
		else
			self.Searchbox:RequestFocus ()
		end
	end
	
	self.Searchbox.OnKeyCodePressed = function (textbox, key)
		if key == KEY_UP then
			self:SelectPrevious ()
		elseif key == KEY_DOWN then
			self:SelectNext ()
		elseif key == KEY_TAB then
			timer.Simple (0, function ()
				if textbox:IsValid () then
					textbox:RequestFocus ()
				end
			end)
		end
	end
	
	self.Searchbox.OnTextChanged = function (textbox)
		self:Search (textbox:GetText ())
	end
	
	-- Menu
	self.Menu = vgui.Create ("QuickToolMenu", self)
	self.Menu:SetPos (0, self.Searchbox:GetTall () + 4)
	
	-- Callbacks
	self.Item_DoClick = function (item)
		self:OnItemChosen (item.Name)
	end
	
	self:Reposition ()
end

function PANEL:Clear ()
	self.Searchbox:SetText ("")
	self:Search (self.Searchbox:GetText ())
end

function PANEL:OnItemChosen (name)
	RunConsoleCommand ("tool_" .. name)
	self:SetVisible (false)
end

function PANEL:Paint ()
end

function PANEL:PerformLayout ()
	self.Menu:SetSize (self:GetWide (), self:GetTall ())
end

function PANEL:Remove ()
	self:SetVisible (false)

	_R.Panel.Remove (self)
end

function PANEL:Reposition ()
	self:SetPos ((ScrW () - self:GetWide ()) * 0.5, (ScrH () - self.Searchbox:GetTall ()) * 0.5)
end

function PANEL:RequestFocus ()
	self.Searchbox:RequestFocus ()
end
	
function PANEL:Search (text)
	self.Menu:Clear ()

	text = text:lower ():gsub ("*", ".*")
	gmod_tool = gmod_tool or weapons.Get ("gmod_tool")
	if not gmod_tool then
		return
	end
	local tools = gmod_tool.Tool
	
	local found = {}
	for name, tool in pairs (tools) do
		if name:lower ():find (text) then
			found [#found + 1] = name
		elseif tool.Name and tool.Name:lower ():find (text) then
			found [#found + 1] = name
		end
	end
	
	table.sort (found)
	
	local ScrH = ScrH ()
	local h = 0
	for k, name in ipairs (found) do
		local item = self.Menu:AddItem (tools [name].Name or name)
		item.Name = name
		item:SetIcon ("gui/silkicons/wrench")
		item.DoClick = self.Item_DoClick
		
		h = h + item:GetTall ()
		if name == self.HighlightedName then
			self.Menu:SetHighlightedItemIndex (k)
		end
		if h > ScrH * 0.5 then
			break
		end
	end
	
	if not self.Menu:GetHighlightedItem () then
		self.Menu:SetHighlightedItemIndex (1)
		self.HighlightedName = self.Menu:GetHighlightedItem () and self.Menu:GetHighlightedItem ().Name
	end
end

function PANEL:SelectNext ()
	local item = self.Menu:HighlightNext ()
	if not item then
		self.HighlightedName = nil
		return
	end
	
	self.HighlightedName = item.Name
end

function PANEL:SelectPrevious ()
	local item = self.Menu:HighlightPrevious ()
	if not item then
		self.HighlightedName = nil
		return
	end
	
	self.HighlightedName = item.Name
end

function PANEL:Think ()
	if input.IsKeyDown (KEY_ESCAPE) then
		RunConsoleCommand ("cancelselect")
		self:SetVisible (false)
	end
end

function PANEL:SetVisible (visible)
	if visible then
		self:Clear ()
		self:RequestFocus ()
		
		hook.Add ("Tick", "QuickToolSearchUI", function ()
			if input.IsKeyDown (KEY_ESCAPE) then
				RunConsoleCommand ("cancelselect")
				self:SetVisible (false)
			end
		end)
	else
		hook.Remove ("Tick", "QuickToolSearchUI")
	end
	_R.Panel.SetVisible (self, visible)
end

vgui.Register ("QuickToolSearch", PANEL, "DFrame")