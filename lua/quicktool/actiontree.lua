local ActionTree = {}

QuickTool.ActionTree = QuickTool.MakeConstructor (ActionTree)

local gmod_tool = nil

function ActionTree:ctor (...)
	self.Children = nil
	self.Description = nil
	
	self.Type = "none"
	self.EscapeKey = nil
	self.UpKey = nil
	self.Command = nil
	self.Tool = nil
end

-- Serialization
function ActionTree:Deserialize (node)
	self.Description = node.description
	
	if node.keys then
		self.Type = "tree"
		self.Children = {}
		self.EscapeKey = node.escapekey
		self.UpKey = node.upkey or self.UpKey
		for key, childnode in pairs (node.keys) do
			local child = QuickTool.ActionTree ()
			self.Children [key:lower ()] = child
			child:SetUpKey (self:GetUpKey ())
			
			if type (childnode) == "table" then
				child:Deserialize (childnode)
			else
				ErrorNoHalt ("Error in quicktool_hotkeys: " .. self.Description .. " has invalid children.")
			end
		end
	elseif node.command then
		self.Type = "command"
		self.Command = node.command
	elseif node.tool then
		self.Type = "tool"
		self.Tool = node.tool
	end
end

function ActionTree:Serialize ()
	-- TODO: Implement this properly
	local node = {}
	if self.Type == "tree" then
		node.Children = {}
		for k, child in pairs (self.Children) do
			node.Children [k] = child:Serialize ()
		end
	end
	
	return node
end

function ActionTree:CanUseTool ()
	if self.Type == "tool" then
		gmod_tool = gmod_tool or weapons.Get ("gmod_tool")
		if not gmod_tool then
			return false
		end
		local tool = gmod_tool.Tool [self.Tool]
		return tool ~= nil
	end
	return false
end

function ActionTree:Clear ()
	self.Type = "none"
	self.Children = nil
end

function ActionTree:GetChild (key)
	if not self.Children then
		return nil
	end
	return self.Children [key:lower ()]
end

function ActionTree:GetChildren ()
	return self.Children
end

function ActionTree:GetCommand ()
	return self.Command
end

function ActionTree:GetDescription ()
	if self.Description == nil and self.Type == "tool" then
		gmod_tool = gmod_tool or weapons.Get ("gmod_tool")
		if not gmod_tool then
			return self.Tool
		end
		self.Tooltable = self.Tooltable or gmod_tool.Tool [self.Tool]
		if self.Tooltable then
			return self.Tooltable.Name
		end
		return self.Tool
	end
	return self.Description
end

function ActionTree:GetEscapeKey ()
	return self.EscapeKey
end

function ActionTree:GetType ()
	return self.Type
end

function ActionTree:GetUpKey ()
	return self.UpKey
end

function ActionTree:RunAction ()
	if self.Type == "tool" then
		RunConsoleCommand ("tool_" .. self.Tool)
	elseif self.Type == "command" then
		-- RunConsoleCommand does not allow multiple commands to be chained with semicolons.
		LocalPlayer ():ConCommand (self.Command)
	end
end

function ActionTree:SetDescription (description)
	self.Description = description
end

function ActionTree:SetEscapeKey (key)
	self.EscapeKey = key
end

function ActionTree:SetUpKey (key)
	self.UpKey = key
end