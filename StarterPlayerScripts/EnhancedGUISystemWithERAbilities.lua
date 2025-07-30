-- EnhancedGUISystemWithERAbilities.lua
-- LocalScript en StarterPlayerScripts
-- GUI actualizada con habilidades E y R

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

print("🎨 Iniciando Enhanced GUI System con habilidades E & R...")

-- Esperar remotes
wait(2)
local remotes = ReplicatedStorage:FindFirstChild("Remotes")
if not remotes then
	warn("❌ Remotes no encontrados")
	return
end

local basicAttackRemote = remotes:FindFirstChild("BasicAttack")
local kiBlastRemote = remotes:FindFirstChild("KiBlast")
local meditationRemote = remotes:FindFirstChild("Meditation")
local eAbilityRemote = remotes:FindFirstChild("EAbility")
local rAbilityRemote = remotes:FindFirstChild("RAbility")

if not basicAttackRemote or not kiBlastRemote or not meditationRemote then
	warn("❌ Algunos RemoteEvents básicos no encontrados")
	return
end

print("✅ RemoteEvents conectados")

-- Estados del cliente
local clientState = {
	lastBasicAttack = 0,
	lastKiBlast = 0,
	lastEAbility = 0,
	lastRAbility = 0,
	isMeditating = false,
	isRunning = false,
	canDoubleJump = false,
	jumpCount = 0
}

-- Cooldowns
local COOLDOWNS = {
	BasicAttack = 0.8,
	KiBlast = 2,
	EAbility = 8,
	RAbility = 15,
	Meditation = 1
}

-- Variables de GUI
local screenGui
local statsFrame
local abilitiesFrame
local kiBar, kiBarText
local levelBar, levelBarText
local stylePanel
local abilityButtons = {}

-- Función para crear la GUI principal
local function createMainGUI()
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "MartialArtsGUI"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = player.PlayerGui

	-- Frame principal de stats (más grande para mostrar más info)
	statsFrame = Instance.new("Frame")
	statsFrame.Name = "StatsFrame"
	statsFrame.Size = UDim2.new(0, 320, 0, 240)
	statsFrame.Position = UDim2.new(0, 20, 0, 20)
	statsFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.2)
	statsFrame.BackgroundTransparency = 0.2
	statsFrame.BorderSizePixel = 0
	statsFrame.Parent = screenGui

	-- Esquinas redondeadas
	local statsCorner = Instance.new("UICorner")
	statsCorner.CornerRadius = UDim.new(0, 12)
	statsCorner.Parent = statsFrame

	-- Borde brillante
	local statsStroke = Instance.new("UIStroke")
	statsStroke.Color = Color3.new(0.5, 0.3, 1)
	statsStroke.Thickness = 2
	statsStroke.Transparency = 0.5
	statsStroke.Parent = statsFrame

	-- Título
	local statsTitle = Instance.new("TextLabel")
	statsTitle.Name = "Title"
	statsTitle.Size = UDim2.new(1, 0, 0, 35)
	statsTitle.Position = UDim2.new(0, 0, 0, 0)
	statsTitle.BackgroundTransparency = 1
	statsTitle.Text = "⚔️ MARTIAL LEGENDS ⚔️"
	statsTitle.TextColor3 = Color3.new(1, 1, 1)
	statsTitle.TextScaled = true
	statsTitle.Font = Enum.Font.SourceSansBold
	statsTitle.Parent = statsFrame

	return statsFrame
end

-- Función para crear el panel de estilo
local function createStylePanel()
	stylePanel = Instance.new("Frame")
	stylePanel.Name = "StylePanel"
	stylePanel.Size = UDim2.new(1, -20, 0, 45)
	stylePanel.Position = UDim2.new(0, 10, 0, 45)
	stylePanel.BackgroundColor3 = Color3.new(0.2, 0.15, 0.3)
	stylePanel.BorderSizePixel = 0
	stylePanel.Parent = statsFrame

	local styleCorner = Instance.new("UICorner")
	styleCorner.CornerRadius = UDim.new(0, 8)
	styleCorner.Parent = stylePanel

	local styleText = Instance.new("TextLabel")
	styleText.Name = "StyleText"
	styleText.Size = UDim2.new(1, -10, 1, 0)
	styleText.Position = UDim2.new(0, 5, 0, 0)
	styleText.BackgroundTransparency = 1
	styleText.Text = "🥋 LOADING STYLE..."
	styleText.TextColor3 = Color3.new(1, 1, 1)
	styleText.TextScaled = true
	styleText.Font = Enum.Font.SourceSansBold
	styleText.TextXAlignment = Enum.TextXAlignment.Left
	styleText.Parent = stylePanel

	return stylePanel
end

-- Función para crear barra de progreso
local function createProgressBar(parent, name, position, color1, color2, labelText)
	local barFrame = Instance.new("Frame")
	barFrame.Name = name .. "Frame"
	barFrame.Size = UDim2.new(1, -20, 0, 28)
	barFrame.Position = position
	barFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
	barFrame.BorderSizePixel = 0
	barFrame.Parent = parent

	local barCorner = Instance.new("UICorner")
	barCorner.CornerRadius = UDim.new(0, 6)
	barCorner.Parent = barFrame

	-- Barra de progreso
	local progressBar = Instance.new("Frame")
	progressBar.Name = name
	progressBar.Size = UDim2.new(0.5, 0, 1, 0)
	progressBar.Position = UDim2.new(0, 0, 0, 0)
	progressBar.BackgroundColor3 = color1
	progressBar.BorderSizePixel = 0
	progressBar.Parent = barFrame

	local progressCorner = Instance.new("UICorner")
	progressCorner.CornerRadius = UDim.new(0, 6)
	progressCorner.Parent = progressBar

	-- Gradiente
	local barGradient = Instance.new("UIGradient")
	barGradient.Color = ColorSequence.new(color1, color2)
	barGradient.Parent = progressBar

	-- Texto de la barra
	local barText = Instance.new("TextLabel")
	barText.Name = name .. "Text"
	barText.Size = UDim2.new(1, 0, 1, 0)
	barText.Position = UDim2.new(0, 0, 0, 0)
	barText.BackgroundTransparency = 1
	barText.Text = labelText
	barText.TextColor3 = Color3.new(1, 1, 1)
	barText.TextScaled = true
	barText.Font = Enum.Font.SourceSansBold
	barText.TextStrokeTransparency = 0.5
	barText.Parent = barFrame

	return progressBar, barText
end

-- Función para crear frame de habilidades (más grande)
local function createAbilitiesFrame()
	abilitiesFrame = Instance.new("Frame")
	abilitiesFrame.Name = "AbilitiesFrame"
	abilitiesFrame.Size = UDim2.new(0, 420, 0, 120)
	abilitiesFrame.Position = UDim2.new(0, 20, 0, 280)
	abilitiesFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.2)
	abilitiesFrame.BackgroundTransparency = 0.2
	abilitiesFrame.BorderSizePixel = 0
	abilitiesFrame.Parent = screenGui

	local abilitiesCorner = Instance.new("UICorner")
	abilitiesCorner.CornerRadius = UDim.new(0, 12)
	abilitiesCorner.Parent = abilitiesFrame

	local abilitiesStroke = Instance.new("UIStroke")
	abilitiesStroke.Color = Color3.new(1, 0.5, 0.2)
	abilitiesStroke.Thickness = 2
	abilitiesStroke.Transparency = 0.5
	abilitiesStroke.Parent = abilitiesFrame

	-- Título
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0, 25)
	title.Position = UDim2.new(0, 0, 0, 5)
	title.BackgroundTransparency = 1
	title.Text = "⚡ COMBAT ABILITIES"
	title.TextColor3 = Color3.new(1, 0.8, 0.4)
	title.TextScaled = true
	title.Font = Enum.Font.SourceSansBold
	title.Parent = abilitiesFrame

	return abilitiesFrame
end

-- Función para crear botones de habilidades mejorados
local function createAbilityButtons()
	local buttonData = {
		{name = "Attack", key = "LMB", pos = UDim2.new(0, 10, 0, 35), color = Color3.new(0.8, 0.3, 0.3), cooldown = "BasicAttack"},
		{name = "Ki Blast", key = "Q", pos = UDim2.new(0, 90, 0, 35), color = Color3.new(0.3, 0.5, 0.8), cooldown = "KiBlast"},
		{name = "E Ability", key = "E", pos = UDim2.new(0, 170, 0, 35), color = Color3.new(0.6, 0.3, 0.8), cooldown = "EAbility", requiresLevel = 10},
		{name = "R Ability", key = "R", pos = UDim2.new(0, 250, 0, 35), color = Color3.new(0.8, 0.2, 0.5), cooldown = "RAbility", requiresLevel = 25},
		{name = "Meditate", key = "M", pos = UDim2.new(0, 330, 0, 35), color = Color3.new(0.3, 0.8, 0.3), cooldown = "Meditation"},
		{name = "Run", key = "Shift", pos = UDim2.new(0, 10, 0, 75), color = Color3.new(0.8, 0.6, 0.2), isToggle = true}
	}

	for _, data in pairs(buttonData) do
		local button = Instance.new("Frame")
		button.Name = data.name .. "Button"
		button.Size = UDim2.new(0, 75, 0, 35)
		button.Position = data.pos
		button.BackgroundColor3 = data.color
		button.BorderSizePixel = 0
		button.Parent = abilitiesFrame

		local buttonCorner = Instance.new("UICorner")
		buttonCorner.CornerRadius = UDim.new(0, 8)
		buttonCorner.Parent = button

		-- Tecla
		local keyLabel = Instance.new("TextLabel")
		keyLabel.Name = "KeyLabel"
		keyLabel.Size = UDim2.new(1, 0, 0, 12)
		keyLabel.Position = UDim2.new(0, 0, 0, 2)
		keyLabel.BackgroundTransparency = 1
		keyLabel.Text = data.key
		keyLabel.TextColor3 = Color3.new(1, 1, 1)
		keyLabel.TextScaled = true
		keyLabel.Font = Enum.Font.SourceSansBold
		keyLabel.Parent = button

		-- Nombre
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Name = "NameLabel"
		nameLabel.Size = UDim2.new(1, 0, 0, 12)
		nameLabel.Position = UDim2.new(0, 0, 1, -14)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = data.name
		nameLabel.TextColor3 = Color3.new(1, 1, 1)
		nameLabel.TextScaled = true
		nameLabel.Font = Enum.Font.SourceSans
		nameLabel.Parent = button

		-- Cooldown overlay
		if data.cooldown then
			local cooldownOverlay = Instance.new("Frame")
			cooldownOverlay.Name = "CooldownOverlay"
			cooldownOverlay.Size = UDim2.new(1, 0, 1, 0)
			cooldownOverlay.Position = UDim2.new(0, 0, 0, 0)
			cooldownOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
			cooldownOverlay.BackgroundTransparency = 0.7
			cooldownOverlay.BorderSizePixel = 0
			cooldownOverlay.Visible = false
			cooldownOverlay.Parent = button

			local cooldownCorner = Instance.new("UICorner")
			cooldownCorner.CornerRadius = UDim.new(0, 8)
			cooldownCorner.Parent = cooldownOverlay

			local cooldownText = Instance.new("TextLabel")
			cooldownText.Name = "CooldownText"
			cooldownText.Size = UDim2.new(1, 0, 1, 0)
			cooldownText.BackgroundTransparency = 1
			cooldownText.Text = "0"
			cooldownText.TextColor3 = Color3.new(1, 1, 1)
			cooldownText.TextScaled = true
			cooldownText.Font = Enum.Font.SourceSansBold
			cooldownText.Parent = cooldownOverlay
		end

		-- Lock overlay para habilidades que requieren nivel
		if data.requiresLevel then
			local lockOverlay = Instance.new("Frame")
			lockOverlay.Name = "LockOverlay"
			lockOverlay.Size = UDim2.new(1, 0, 1, 0)
			lockOverlay.Position = UDim2.new(0, 0, 0, 0)
			lockOverlay.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
			lockOverlay.BackgroundTransparency = 0.3
			lockOverlay.BorderSizePixel = 0
			lockOverlay.Parent = button

			local lockCorner = Instance.new("UICorner")
			lockCorner.CornerRadius = UDim.new(0, 8)
			lockCorner.Parent = lockOverlay

			local lockText = Instance.new("TextLabel")
			lockText.Name = "LockText"
			lockText.Size = UDim2.new(1, 0, 1, 0)
			lockText.BackgroundTransparency = 1
			lockText.Text = "🔒\nLv." .. data.requiresLevel
			lockText.TextColor3 = Color3.new(1, 1, 1)
			lockText.TextScaled = true
			lockText.Font = Enum.Font.SourceSansBold
			lockText.Parent = lockOverlay
		end

		abilityButtons[data.cooldown or data.name] = button
	end
end

-- Función para crear panel de información del estilo
local function createStyleInfoPanel()
	local infoPanel = Instance.new("Frame")
	infoPanel.Name = "StyleInfoPanel"
	infoPanel.Size = UDim2.new(1, -20, 0, 40)
	infoPanel.Position = UDim2.new(0, 10, 0, 195)
	infoPanel.BackgroundColor3 = Color3.new(0.15, 0.15, 0.25)
	infoPanel.BorderSizePixel = 0
	infoPanel.Parent = statsFrame

	local infoCorner = Instance.new("UICorner")
	infoCorner.CornerRadius = UDim.new(0, 8)
	infoCorner.Parent = infoPanel

	local infoText = Instance.new("TextLabel")
	infoText.Name = "InfoText"
	infoText.Size = UDim2.new(1, -10, 1, 0)
	infoText.Position = UDim2.new(0, 5, 0, 0)
	infoText.BackgroundTransparency = 1
	infoText.Text = "E: Lv.10+ | R: Lv.25+ | Meditate to gain XP & Ki"
	infoText.TextColor3 = Color3.new(0.8, 0.8, 0.8)
	infoText.TextScaled = true
	infoText.Font = Enum.Font.SourceSans
	infoText.TextXAlignment = Enum.TextXAlignment.Left
	infoText.Parent = infoPanel

	return infoPanel
end

-- Función para animar barra
local function animateBar(bar, targetValue, maxValue)
	local targetSize = UDim2.new(math.max(targetValue / maxValue, 0), 0, 1, 0)

	local tween = TweenService:Create(bar, 
		TweenInfo.new(0.5, Enum.EasingStyle.Quad), 
		{Size = targetSize}
	)
	tween:Play()
end

-- Función para mostrar cooldown en botón
local function showCooldown(buttonName, duration)
	local button = abilityButtons[buttonName]
	if not button then return end

	local overlay = button:FindFirstChild("CooldownOverlay")
	local cooldownText = overlay and overlay:FindFirstChild("CooldownText")

	if overlay and cooldownText then
		overlay.Visible = true

		spawn(function()
			local remaining = duration
			while remaining > 0 do
				cooldownText.Text = string.format("%.1f", remaining)
				wait(0.1)
				remaining = remaining - 0.1
			end

			overlay.Visible = false
		end)
	end
end

-- Función para actualizar locks de habilidades
local function updateAbilityLocks(level)
	-- Habilidad E
	local eButton = abilityButtons["EAbility"]
	if eButton then
		local lockOverlay = eButton:FindFirstChild("LockOverlay")
		if lockOverlay then
			lockOverlay.Visible = level < 10
		end
	end

	-- Habilidad R
	local rButton = abilityButtons["RAbility"]
	if rButton then
		local lockOverlay = rButton:FindFirstChild("LockOverlay")
		if lockOverlay then
			lockOverlay.Visible = level < 25
		end
	end
end

-- Función para crear toda la GUI
local function setupCompleteGUI()
	createMainGUI()
	createStylePanel()

	-- Crear barras de progreso
	kiBar, kiBarText = createProgressBar(
		statsFrame, "Ki", 
		UDim2.new(0, 10, 0, 100),
		Color3.new(0, 0.8, 1),
		Color3.new(0.5, 1, 1),
		"Ki: 100/100"
	)

	levelBar, levelBarText = createProgressBar(
		statsFrame, "Level",
		UDim2.new(0, 10, 0, 140),
		Color3.new(1, 0.8, 0),
		Color3.new(1, 1, 0.5),
		"Level: 1 (0/100)"
	)

	createStyleInfoPanel()
	createAbilitiesFrame()
	createAbilityButtons()

	print("✅ Enhanced GUI creada exitosamente")
end

-- Variables para stats anteriores
local lastStats = {
	ki = 0, maxKi = 100, level = 1, xp = 0, maxXp = 100, style = "", fuerza = 5, velocidad = 5, control = 5
}

-- Función para actualizar la GUI
local function updateGUI()
	local character = player.Character
	if not character or not screenGui or not screenGui.Parent then return end

	local stats = character:FindFirstChild("PlayerStats")
	if not stats then return end

	-- Actualizar Ki
	local ki = stats:FindFirstChild("Ki")
	local maxKi = stats:FindFirstChild("MaxKi")
	if ki and kiBar and kiBarText then
		local currentKi = ki.Value
		local maxKiValue = maxKi and maxKi.Value or 100

		if currentKi ~= lastStats.ki or maxKiValue ~= lastStats.maxKi then
			animateBar(kiBar, currentKi, maxKiValue)
			kiBarText.Text = "⚡ Ki: " .. math.floor(currentKi) .. "/" .. maxKiValue

			-- Cambiar color según nivel de Ki
			if currentKi < maxKiValue * 0.3 then
				kiBar.BackgroundColor3 = Color3.new(1, 0.3, 0.3)
			elseif currentKi < maxKiValue * 0.6 then
				kiBar.BackgroundColor3 = Color3.new(1, 1, 0.3)
			else
				kiBar.BackgroundColor3 = Color3.new(0, 0.8, 1)
			end

			lastStats.ki = currentKi
			lastStats.maxKi = maxKiValue
		end
	end

	-- Actualizar Nivel y XP
	local level = stats:FindFirstChild("Level")
	local xp = stats:FindFirstChild("XP")
	local maxXp = stats:FindFirstChild("MaxXP")

	if level and xp and levelBar and levelBarText then
		local currentLevel = level.Value
		local currentXp = xp.Value
		local maxXpValue = maxXp and maxXp.Value or 100

		if currentLevel ~= lastStats.level then
			-- Efecto de level up
			local levelUpEffect = Instance.new("Frame")
			levelUpEffect.Size = UDim2.new(0, 250, 0, 80)
			levelUpEffect.Position = UDim2.new(0.5, -125, 0.3, 0)
			levelUpEffect.BackgroundColor3 = Color3.new(1, 1, 0)
			levelUpEffect.BorderSizePixel = 0
			levelUpEffect.Parent = screenGui

			local levelUpCorner = Instance.new("UICorner")
			levelUpCorner.CornerRadius = UDim.new(0, 15)
			levelUpCorner.Parent = levelUpEffect

			local levelUpText = Instance.new("TextLabel")
			levelUpText.Size = UDim2.new(1, 0, 1, 0)
			levelUpText.BackgroundTransparency = 1
			levelUpText.Text = "🌟 LEVEL UP! 🌟\nLevel " .. currentLevel .. " Reached!"
			levelUpText.TextColor3 = Color3.new(0, 0, 0)
			levelUpText.TextScaled = true
			levelUpText.Font = Enum.Font.SourceSansBold
			levelUpText.Parent = levelUpEffect

			game:GetService("Debris"):AddItem(levelUpEffect, 4)

			-- Actualizar locks de habilidades
			updateAbilityLocks(currentLevel)

			lastStats.level = currentLevel
		end

		if currentXp ~= lastStats.xp or maxXpValue ~= lastStats.maxXp then
			animateBar(levelBar, currentXp, maxXpValue)
			levelBarText.Text = "📊 Lv." .. currentLevel .. " (" .. math.floor(currentXp) .. "/" .. maxXpValue .. ")"
			lastStats.xp = currentXp
			lastStats.maxXp = maxXpValue
		end
	end

	-- Actualizar estilo marcial
	local martialStyle = stats:FindFirstChild("MartialStyle")
	local styleRarity = stats:FindFirstChild("StyleRarity")
	local fuerza = stats:FindFirstChild("Fuerza")
	local velocidad = stats:FindFirstChild("Velocidad")
	local control = stats:FindFirstChild("Control")

	if martialStyle and stylePanel then
		local styleText = stylePanel:FindFirstChild("StyleText")
		if styleText and martialStyle.Value ~= lastStats.style then
			local rarityText = styleRarity and styleRarity.Value or "Common"
			local rarityEmoji = ""

			if rarityText == "Mythic" then
				rarityEmoji = "🌟✨"
			elseif rarityText == "Legendary" then
				rarityEmoji = "✨"
			elseif rarityText == "Epic" then
				rarityEmoji = "💎"
			elseif rarityText == "Rare" then
				rarityEmoji = "⭐"
			end

			styleText.Text = "🥋 " .. martialStyle.Value .. " " .. rarityEmoji .. " (" .. rarityText .. ")"

			-- Colores según estilo
			local styleColors = {
				TIGER = Color3.new(1, 0.5, 0),
				CRANE = Color3.new(0.8, 0.8, 1),
				DRAGON = Color3.new(1, 0.8, 0),
				PHOENIX = Color3.new(1, 1, 0),
				LIGHTNING = Color3.new(1, 1, 1),
				SHADOW = Color3.new(0.5, 0.5, 0.5),
				VOID = Color3.new(0.5, 0, 1),
				CELESTIAL = Color3.new(0, 1, 1),
				CHAOS = Color3.new(1, 0, 1)
			}

			styleText.TextColor3 = styleColors[martialStyle.Value] or Color3.new(1, 1, 1)
			lastStats.style = martialStyle.Value
		end
	end

	-- Actualizar información del estilo en panel de info
	if fuerza and velocidad and control then
		local infoPanel = statsFrame:FindFirstChild("StyleInfoPanel")
		if infoPanel then
			local infoText = infoPanel:FindFirstChild("InfoText")
			if infoText and (fuerza.Value ~= lastStats.fuerza or velocidad.Value ~= lastStats.velocidad or control.Value ~= lastStats.control) then
				infoText.Text = string.format("F:%d V:%d C:%d | E: Lv.10+ | R: Lv.25+", 
					fuerza.Value, velocidad.Value, control.Value)

				lastStats.fuerza = fuerza.Value
				lastStats.velocidad = velocidad.Value
				lastStats.control = control.Value
			end
		end
	end
end

-- Sistema de movimiento
local function setupMovementSystem()
	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not rootPart then return end

	humanoid.WalkSpeed = 20
	humanoid.JumpPower = 50

	clientState.canDoubleJump = false
	clientState.jumpCount = 0

	humanoid.StateChanged:Connect(function(oldState, newState)
		if newState == Enum.HumanoidStateType.Landed then
			clientState.canDoubleJump = true
			clientState.jumpCount = 0
		elseif newState == Enum.HumanoidStateType.Jumping then
			clientState.jumpCount = clientState.jumpCount + 1
		end
	end)

	print("✅ Sistema de movimiento configurado")
end

-- Manejar inputs
local function handleInput(input, gameProcessed)
	if gameProcessed then return end

	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")

	if input.KeyCode == Enum.KeyCode.Space then
		-- Doble salto
		if clientState.jumpCount == 1 and clientState.canDoubleJump and humanoid and rootPart then
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
			bodyVelocity.Velocity = Vector3.new(0, 50, 0)
			bodyVelocity.Parent = rootPart

			game:GetService("Debris"):AddItem(bodyVelocity, 0.3)
			clientState.canDoubleJump = false

			print("🦘 Double Jump!")
		end

	elseif input.KeyCode == Enum.KeyCode.LeftShift then
		-- Correr
		if humanoid then
			clientState.isRunning = true
			humanoid.WalkSpeed = 35

			if rootPart then
				local runEffect = Instance.new("Attachment")
				runEffect.Name = "RunEffect"
				runEffect.Parent = rootPart

				local particle = Instance.new("ParticleEmitter")
				particle.Color = ColorSequence.new(Color3.new(1, 1, 0.5))
				particle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
				particle.Rate = 50
				particle.Lifetime = NumberRange.new(0.3, 0.6)
				particle.Speed = NumberRange.new(5, 10)
				particle.Parent = runEffect

				print("🏃 Running!")
			end
		end

	elseif input.KeyCode == Enum.KeyCode.Q then
		-- Ki Blast
		local currentTime = tick()
		if currentTime - clientState.lastKiBlast >= COOLDOWNS.KiBlast then
			if kiBlastRemote then
				kiBlastRemote:FireServer()
				clientState.lastKiBlast = currentTime
				showCooldown("KiBlast", COOLDOWNS.KiBlast)
				print("⚡ Ki Blast!")
			end
		end

	elseif input.KeyCode == Enum.KeyCode.E then
		-- Habilidad E
		local currentTime = tick()
		if currentTime - clientState.lastEAbility >= COOLDOWNS.EAbility then
			if eAbilityRemote then
				eAbilityRemote:FireServer()
				clientState.lastEAbility = currentTime
				showCooldown("EAbility", COOLDOWNS.EAbility)
				print("🔥 E Ability!")
			end
		end

	elseif input.KeyCode == Enum.KeyCode.R then
		-- Habilidad R
		local currentTime = tick()
		if currentTime - clientState.lastRAbility >= COOLDOWNS.RAbility then
			if rAbilityRemote then
				rAbilityRemote:FireServer()
				clientState.lastRAbility = currentTime
				showCooldown("RAbility", COOLDOWNS.RAbility)
				print("💥 R Ability!")
			end
		end

	elseif input.KeyCode == Enum.KeyCode.M then
		-- Meditación
		clientState.isMeditating = not clientState.isMeditating
		if meditationRemote then
			meditationRemote:FireServer(clientState.isMeditating)
		end

		if clientState.isMeditating then
			print("🧘 Meditating...")
		else
			print("🧘 Meditation stopped")
		end
	end
end

-- Manejar cuando se suelta una tecla
local function handleInputEnded(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.LeftShift then
		local character = player.Character
		if character then
			local humanoid = character:FindFirstChild("Humanoid")
			local rootPart = character:FindFirstChild("HumanoidRootPart")

			if humanoid then
				clientState.isRunning = false
				humanoid.WalkSpeed = 20
			end

			if rootPart then
				local runEffect = rootPart:FindFirstChild("RunEffect")
				if runEffect then
					runEffect:Destroy()
				end
				print("🚶 Stopped running")
			end
		end
	end
end

-- Manejar clicks del mouse
local function handleMouseClick()
	local character = player.Character
	if not character then return end

	local currentTime = tick()
	if currentTime - clientState.lastBasicAttack >= COOLDOWNS.BasicAttack then
		if basicAttackRemote then
			basicAttackRemote:FireServer()
			clientState.lastBasicAttack = currentTime
			showCooldown("BasicAttack", COOLDOWNS.BasicAttack)
			print("👊 Basic Attack!")
		end
	end
end

-- Función principal cuando aparece personaje
local function onCharacterAdded(character)
	print("👤 Personaje aparecido:", player.Name)

	wait(2)

	setupCompleteGUI()
	setupMovementSystem()

	-- Mensaje de bienvenida
	spawn(function()
		wait(1)
		if screenGui and screenGui.Parent then
			local welcome = Instance.new("Frame")
			welcome.Size = UDim2.new(0, 350, 0, 100)
			welcome.Position = UDim2.new(0.5, -175, 0.7, 0)
			welcome.BackgroundColor3 = Color3.new(0.1, 0.1, 0.2)
			welcome.BorderSizePixel = 0
			welcome.Parent = screenGui

			local welcomeCorner = Instance.new("UICorner")
			welcomeCorner.CornerRadius = UDim.new(0, 12)
			welcomeCorner.Parent = welcome

			local welcomeText = Instance.new("TextLabel")
			welcomeText.Size = UDim2.new(1, 0, 1, 0)
			welcomeText.BackgroundTransparency = 1
			welcomeText.Text = "🥋 Welcome to Martial Arts Legends! 🥋\nControls: LMB, Q, E (Lv.10+), R (Lv.25+), M, Shift, Space x2"
			welcomeText.TextColor3 = Color3.new(1, 1, 1)
			welcomeText.TextScaled = true
			welcomeText.Font = Enum.Font.SourceSansBold
			welcomeText.Parent = welcome

			game:GetService("Debris"):AddItem(welcome, 6)
		end
	end)
end

-- Conectar eventos
UserInputService.InputBegan:Connect(handleInput)
UserInputService.InputEnded:Connect(handleInputEnded)
player.CharacterAdded:Connect(onCharacterAdded)

-- Para personaje ya existente
if player.Character then
	onCharacterAdded(player.Character)
end

-- Conectar mouse
spawn(function()
	wait(1)
	local mouse = player:GetMouse()
	if mouse then
		mouse.Button1Down:Connect(handleMouseClick)
	end
end)

-- Loop de actualización
spawn(function()
	while true do
		wait(0.2)
		if player.Character then
			updateGUI()
		end
	end
end)

print("✅ Enhanced GUI System con habilidades E & R cargado!")
print("🎮 Controles actualizados:")
print("   👊 LMB - Ataque básico")
print("   ⚡ Q - Ki Blast")
print("   🔥 E - Habilidad especial (Nivel 10+)")
print("   💥 R - Habilidad definitiva (Nivel 25+)")
print("   🧘 M - Meditación")
print("   🏃 Shift - Correr")
print("   🦘 Space x2 - Doble salto")
print("🎯 Nuevas características:")
print("   ✅ Cooldowns visuales en botones")
print("   ✅ Locks para habilidades por nivel")
print("   ✅ Stats expandidos mostrados")
print("   ✅ Efectos de level up mejorados")
print("   ✅ Panel de información del estilo")