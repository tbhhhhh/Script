local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

if not getgenv().Network then
	getgenv().Network = {
		BaseParts = {};
		FakeConnections = {};
		Connections = {};
		Output = {
			Enabled = true;
			Prefix = "[NETWORK] ";
			Send = function(Type,Output,BypassOutput)
				if typeof(Type) == "function" and (Type == print or Type == warn or Type == error) and typeof(Output) == "string" and (typeof(BypassOutput) == "nil" or typeof(BypassOutput) == "boolean") then
					if Network["Output"].Enabled or BypassOutput then
						Type(Network["Output"].Prefix..Output);
					end;
				elseif Network["Output"].Enabled then
					error(Network["Output"].Prefix.."Output Send Error : Invalid syntax.");
				end;
			end;
		};
		LostParts = {};
		CharacterRelative = true;
		LastCharacter = nil;
		TryKeep = true; --loop attempts to
		PartOwnership = {
			PreMethodSettings = {};
			Enabled = false;
		};
	}

	Network["Output"].Send(print,": Loading.")

	Network["RetainPart"] = function(Part,Silent,ReturnFakePart) --function for retaining ownership of unanchored parts
		assert(Network["PartOwnership"]["Enabled"], Network["Output"].Prefix.." RetainPart Error : PartOwnership is Disabled.")
		assert(typeof(Part) == "Instance" and Part:IsA("BasePart") and not Part:IsGrounded(),Network["Output"].Prefix.."RetainPart Error : Invalid syntax: Arg1 (Part) must be an ungrounded BasePart which is a descendant of workspace.")
		if not Part:IsDescendantOf(workspace) then
			Network["Output"].Send(error,"RetainPart Error : Invalid syntax: Arg1 (Part) must be an ungrounded BasePart which is a descendant of workspace.")
			local Index = table.find(Network["LostParts"],Part)
			if Index then
				table.remove(Network["LostParts"],Index)
			end
			return false
		end
		assert(typeof(Silent) == "boolean" or typeof(Silent) == "nil",Network["Output"].Prefix.."RetainPart Error : Invalid syntax: Arg2 (Silent) must be a boolean or nil.")
		assert(typeof(ReturnFakePart) == "boolean" or typeof(ReturnFakePart) == "nil",Network["Output"].Prefix.."RetainPart Error : Invalid syntax: Arg3 (ReturnFakePart) must be a boolean or nil.")
		if not table.find(Network["BaseParts"],Part) and not table.find(Network["LostParts"],Part) then
			table.insert(Network["BaseParts"],Part)
			Part.CustomPhysicalProperties = PhysicalProperties.new(0,0,0,0,0)
			if not Silent then
				Network["Output"].Send(print,"PartOwnership Output : PartOwnership applied to BasePart "..Part:GetFullName()..".")
			end
			if ReturnFakePart then
				local workspaceParts = {}
				return FakePart
			end
		else
			Network["Output"].Send(warn,"RetainPart Warning : PartOwnership not applied to BasePart "..Part:GetFullName()..", as it already active.")
			return false
		end
	end

	Network["RemovePart"] = function(Part,Silent) --function for removing ownership of unanchored part
		assert(typeof(Part) == "Instance" and Part:IsA("BasePart"),Network["Output"].Prefix.."RemovePart Error : Invalid syntax: Arg1 (Part) must be a BasePart.")
		local Index1 = table.find(Network["BaseParts"],Part)
		local Index2 = table.find(Network["LostParts"],Part)
		if Index1 then
			table.remove(Network["BaseParts"],Index1)
		else
			if not Silent then
				Network["Output"].Send(warn,"RemovePart Warning : BasePart "..Part:GetFullName().." not found in BaseParts table.")
			end
			return
		end
		if Index2 then
			table.remove(Network["LostParts"],Index2)
		end
		if not Silent then
			Network["Output"].Send(print,"RemovePart Output: PartOwnership removed from BasePart "..Part:GetFullName()..".")
		end
	end

	Network["PartOwnership"]["PartCoroutine"] = coroutine.create(function(Part)
		if Part:IsDescendantOf(workspace) then
			if Network.CharacterRelative then
				local Character = Network["LastCharacter"];
				if not Character.PrimaryPart then
					for _,Inst in pairs(Character:GetDescendants()) do
						if Inst:IsA("BasePart") then
							Character.PrimaryPart = Inst
							break
						end
					end
				end
				if Character and Character.PrimaryPart then
					local Distance = (Character.PrimaryPart.Position - Part.Position).Magnitude
					if Distance > gethiddenproperty(LocalPlayer,"MaximumSimulationRadius") and not isnetworkowner(Part) then
						Network["Output"].Send(warn,"PartOwnership Warning : PartOwnership not applied to BasePart "..Part:GetFullName()..", as it is more than "..gethiddenproperty(LocalPlayer,"MaximumSimulationRadius").." studs away.")
						Network["RemovePart"](Part)
						if not Part:IsGrounded() then
							table.insert(Network["LostParts"],Part)
						else
							Network["Output"].Send(warn,"PartOwnership Warning : PartOwnership not applied to BasePart "..Part:GetFullName()..", as it is grounded.")
						end
					end
				else
					Network["Output"].Send(warn,"PartOwnership Warning : PartOwnership not applied to BasePart "..Part:GetFullName()..", as the LocalPlayer Character's PrimaryPart does not exist.")
				end
			end
			Part.AssemblyLinearVelocity = (Part.AssemblyLinearVelocity.Unit+Vector3.new(.01,.01,.01))*(50+math.cos(tick()*10))
		else
			Network["RemovePart"](Part)
		end
	end)

	Network["PartOwnership"]["Enable"] = coroutine.create(function() --creating a thread for network stuff
		if not Network["PartOwnership"]["Enabled"] then
			Network["PartOwnership"]["Enabled"] = true
			Network["PartOwnership"]["PreMethodSettings"].ReplicationFocus = LocalPlayer.ReplicationFocus
			LocalPlayer.ReplicationFocus = workspace
			Network["PartOwnership"]["PreMethodSettings"].SimulationRadius = gethiddenproperty(LocalPlayer,"SimulationRadius")
			Network["PartOwnership"]["Connection"] = RunService.Stepped:Connect(function()
				Network["LastCharacter"] = pcall(function() return LocalPlayer.Character end) or Network["LastCharacter"]
				sethiddenproperty(LocalPlayer,"SimulationRadius",1/0)
				coroutine.wrap(function()
					for _,Part in pairs(Network["BaseParts"]) do --loop through parts and do network stuff
						coroutine.resume(Network["PartOwnership"]["PartCoroutine"],Part)
						--[==[ [[by 4eyes btw]] ]==]--
					end
				end)()
				coroutine.wrap(function()
					for _,Part in pairs(Network["LostParts"]) do
						Network.RetainPart(Part,true)
					end
				end)()
			end)
			Network["Output"].Send(print,"PartOwnership Output : PartOwnership enabled.")
		else
			Network["Output"].Send(warn,"PartOwnership Output : PartOwnership already enabled.")
		end
	end)

	Network["PartOwnership"]["Disable"] = coroutine.create(function()
		if Network["PartOwnership"]["Connection"] then
			Network["PartOwnership"]["Connection"]:Disconnect()
			LocalPlayer.ReplicationFocus = Network["PartOwnership"]["PreMethodSettings"].ReplicationFocus
			sethiddenproperty(LocalPlayer,"SimulationRadius",Network["PartOwnership"]["PreMethodSettings"].SimulationRadius)
			Network["PartOwnership"]["PreMethodSettings"] = {}
			for _,Part in pairs(Network["BaseParts"]) do
				Network["RemovePart"](Part)
			end
			for Index,Part in pairs(Network["LostParts"]) do
				table.remove(Network["LostParts"],Index)
			end
			Network["PartOwnership"]["Enabled"] = false
			Network["Output"].Send(print,"PartOwnership Output : PartOwnership disabled.")
		else
			Network["Output"].Send(warn,"PartOwnership Output : PartOwnership already disabled.")
		end
	end)

	Network["Output"].Send(print,": Loaded.")
end
coroutine.resume(Network["PartOwnership"]["Enable"])


--"More"
for i,v in pairs(LocalPlayer.Character:GetDescendants()) do
  if v:IsA("Accessory") then
    Network.RetainPart(v.Handle)
  end
end

for i,lplr in pairs(Players:GetPlayers()) do
	lplr.Character:WaitForChild("Humanoid").DisplayName = lplr.DisplayName.."\n\@"..lplr.Name
    lplr.CharacterAdded:Connect(function()
        lplr.Character:WaitForChild("Humanoid").DisplayName = lplr.DisplayName.."\n\@"..lplr.Name
    end)
end

Players.PlayerAdded:Connect(function(lplr)
    repeat
		wait()
	until lplr.Character ~= nil
	lplr.Character:WaitForChild("Humanoid").DisplayName = lplr.DisplayName.."\n\@"..lplr.Name
    lplr.CharacterAdded:Connect(function()
        lplr.Character:WaitForChild("Humanoid").DisplayName = lplr.DisplayName.."\n\@"..lplr.Name
    end)
end)


local_player = LP

character = local_player.Character

character.Hat1:SetAttribute("Minion",true)
character.LavanderHair:SetAttribute("Minion",true)
character.Robloxclassicred:SetAttribute("Minion",true)
character["Kate Hair"]:SetAttribute("Minion",true)
character["Pal Hair"]:SetAttribute("Minion",true)

game:GetService("StarterGui"):SetCore("SendNotification",{
	Title = "FE Minions V2",
	Text = "Made by Rouxhaver",
	Icon = "rbxassetid://12997341656"
})

for _,hat in pairs(character:GetChildren()) do
	if hat:IsA("Accessory") and hat:GetAttribute("Minion") == true then
		local minion = Instance.new("Model",workspace)
		minion.Name = "Minion"

		local hrp = Instance.new("Part",minion)
		hrp.Position = Vector3.new(0, 10, 0)
		hrp.Size = Vector3.new(1, 2, 1)
		hrp.Transparency = 1
		hrp.Name = "HumanoidRootPart"

		local torso = Instance.new("Part",minion)
		torso.Position = hrp.Position
		torso.Size = Vector3.new(1, 2 ,1)
		torso.Name = "Torso"
		torso.Transparency = 1

		local head = Instance.new("Part",minion)
		head.Position = hrp.Position
		head.Size = Vector3.new(1,1,1)
		head.Name = "Head"
		head.Transparency = 1

		local neck = Instance.new("Motor6D",torso)
		neck.Part0 = torso
		neck.Part1 = head
		neck.Name = "Neck"
		neck.C0 = CFrame.new(0, 1, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0)
		neck.C1 = CFrame.new(0, -0.5, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0)
		neck.MaxVelocity = 0.1

		local rootjoint = Instance.new("Motor6D",torso)
		rootjoint.Part0 = hrp
		rootjoint.Part1 = torso
		rootjoint.Name = "RootJoint"
		rootjoint.C0 = CFrame.new( 0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0)
		rootjoint.C1 = CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0)
		rootjoint.MaxVelocity = 0.1

		local humanoid = Instance.new("Humanoid",minion)
		humanoid.HipHeight = 0.01

		hrp.CFrame = character.Head.CFrame

		local animation = Instance.new("Animation",script)
		animation.AnimationId = "http://www.roblox.com/asset/?id=180426354"

		dance = humanoid:LoadAnimation(animation)
		dance:Play()


		players = Players

		frame = local_player.PlayerGui.Chat.Frame.ChatBarParentFrame.Frame.BoxFrame.Frame

		chatbar = frame.ChatBar

		autofill = frame.TextLabel:Clone()
		autofill.Name = "autofill"
		autofill.Parent = frame
		autofill.TextColor3 = Color3.fromRGB(62, 62, 62)
		autofill.Text = ""
		autofill.TextTransparency = 0.4
		autofill.Visible = true

		chatbar:GetPropertyChangedSignal("Text"):Connect(function()
			local text = chatbar.Text
			if text:match("/e follow ") then do
					local remove_autofill = true
					local player_typed = string.gsub(text,"/e follow ",""):lower()
					for i,v in pairs(players:GetPlayers()) do
						if v.Name:sub(0,#player_typed):lower():match(player_typed) then
							autofill.Text = text..v.Name:sub(#player_typed+1,#v.Name)
							remove_autofill = false
							break
						end
					end
					if remove_autofill == true then
						autofill.Text = ""
					end
				end else
				autofill.Text = ""
			end
		end)

		parent = local_player.Character

		local_player.Chatted:Connect(function(chat)
			if chat:match("/e follow ") then
				local player_typed = string.gsub(chat,"/e follow ",""):lower()
				for i,v in pairs(players:GetPlayers()) do
					if v.Name:sub(0,#player_typed):lower():match(player_typed) then
						if v.Character ~= nil then
							parent = v.Character
						end
						break
					end
				end
			end
		end)

		local offset = Vector3.new(math.random(-5,5),math.random(-5,5),math.random(-5,5))

		spawn(function()
			while wait(math.random(0.001,1.5)) do
				if math.random(1,7) == 1 then humanoid.Jump = true end
				if math.random(1,50) == 1 then humanoid.Sit = true end
				if math.random(1,5) == 1 then offset = Vector3.new(math.random(-5,5),math.random(-5,5),math.random(-5,5)) end
				if parent:FindFirstChild("Head") then
					humanoid:MoveTo(parent.Head.Position + offset)
				end
			end     
		end)

		local body = nil

		for i,v in pairs(character:GetDescendants()) do
			if v:GetAttribute("Minion") == true and v:GetAttribute("Used") == nil then
				body = v.Handle
				v:SetAttribute("Used", true)
				break
			end
		end

		local hat = nil

		for i,v in pairs(character:GetDescendants()) do
			if v:IsA("Accessory") and v:GetAttribute("Minion") == nil and v:GetAttribute("Used") == nil then
				hat = v.Handle
				v:SetAttribute("Used", true)
				break
			end
		end

		hat.AccessoryWeld:Destroy()

		body.AccessoryWeld:Destroy()

		body:FindFirstChildOfClass("SpecialMesh"):Destroy()
		spawn(function()
			while task.wait() do
				body.CFrame = torso.CFrame * CFrame.Angles(math.rad(90),0,0)
				hat.CFrame = head.CFrame
			end
		end)

	end
end