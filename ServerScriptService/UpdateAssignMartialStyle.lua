-- UpdatedAssignMartialStyle.lua
-- Script en ServerScriptService (REEMPLAZA al AssignMartialStyle anterior)
-- Crea stats completos incluyendo Level, XP, MaxKi, etc.

local Players = game:GetService("Players")

-- Tabla de estilos marciales
local MARTIAL_STYLES = {
	{name = "TIGER", probability = 60, rarity = "Common", description = "Estilo feroz y agresivo", color = Color3.new(1, 0.5, 0)},
	{name = "CRANE", probability = 25, rarity = "Common", description = "Estilo elegante y preciso", color = Color3.new(0.8, 0.8, 1)},
	{name = "DRAGON", probability = 10, rarity = "Uncommon", description = "Estilo legendario y poderoso", color = Color3.new(1, 0.8, 0)},
	{name = "PHOENIX", probability = 3, rarity = "Rare", description = "Renacimiento y curación", color = Color3.new(1, 1, 0)},
	{name = "LIGHTNING", probability = 1, rarity = "Rare", description = "Velocidad del rayo", color = Color3.new(1, 1, 1)},
	{name = "SHADOW", probability = 0.4, rarity = "Epic", description = "Maestro de las sombras", color = Color3.new(0.3, 0.3, 0.3)},
	{name = "VOID", probability = 0.05, rarity = "Legendary", description = "Controlador del vacío", color = Color3.new(0.5, 0, 1)},
	{name = "CELESTIAL", probability = 0.03, rarity = "Legendary", description = "Poder de los cielos", color = Color3.new(0, 1, 1)},
	{name = "CHAOS", probability = 0.02, rarity = "Mythic", description = "Caos primordial", color = Color3.new(1, 0, 1)}
}

-- Stats completos para el nuevo sistema
local COMPLETE_STATS = {
	-- Stats básicos
	Ki = 100,
	Fuerza = 5,
	Velocidad = 5,
	Control = 5,

	-- Stats de progresión
	Level = 1,
	XP = 0,
	MaxXP = 100,
	MaxKi = 100,

	-- Stats de tracking
	TotalMeditationTime = 0,
	TotalKills = 0,
	TotalHits = 0
}

-- Bonificaciones por estilo
local STYLE_BONUSES = {
	TIGER = {Fuerza = 2, Velocidad = 1},
	CRANE = {Velocidad = 2, Control = 1},
	DRAGON = {Fuerza = 3, MaxKi = 20},
	PHOENIX = {MaxKi = 30, Control = 2},
	LIGHTNING = {Velocidad = 4, Control = 1},
	SHADOW = {Velocidad = 2, Control = 3},
	VOID = {Fuerza = 4, MaxKi = 40, Control = 2},
	CELESTIAL = {MaxKi = 50, Control = 4, Fuerza = 2},
	CHAOS = {Fuerza = 5, Velocidad = 3, MaxKi = 60, Control = 3}
}

-- Función para seleccionar estilo marcial
local function selectMartialStyle()
	local random = math.random() * 100
	local accumulated = 0

	for _, style in pairs(MARTIAL_STYLES) do
		accumulated = accumulated + style.probability
		if random <= accumulated then
			return style
		end
	end

	return MARTIAL_STYLES[1] -- Fallback a TIGER
end

-- Función para crear efecto visual
local function createAssignmentEffect(character, styleData)
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	local attachment = Instance.new("Attachment")
	attachment.Name = "StyleAssignmentAura"
	attachment.Parent = humanoidRootPart

	local particle = Instance.new("ParticleEmitter")
	particle.Parent = attachment
	particle.Color = ColorSequence.new(styleData.color)
	particle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	particle.Rate = 100
	particle.Lifetime = NumberRange.new(1, 2)
	particle.Speed = NumberRange.new(10, 15)

	-- Efectos especiales para estilos raros
	if styleData.rarity == "Legendary" or styleData.rarity == "Mythic" then
		particle.Rate = 200

		local light = Instance.new("PointLight")
		light.Color = styleData.color
		light.Brightness = 3
		light.Range = 20
		light.Parent = humanoidRootPart

		game:GetService("Debris"):AddItem(light, 5)
	end

	game:GetService("Debris"):AddItem(attachment, 5)
end

-- Función para crear stats completos
local function createCompleteStats(character, styleData)
	-- Crear carpeta de stats
	local statsFolder = Instance.new("Folder")
	statsFolder.Name = "PlayerStats"
	statsFolder.Parent = character

	-- Crear información del estilo
	local styleValue = Instance.new("StringValue")
	styleValue.Name = "MartialStyle"
	styleValue.Value = styleData.name
	styleValue.Parent = statsFolder

	local rarityValue = Instance.new("StringValue")
	rarityValue.Name = "StyleRarity"
	rarityValue.Value = styleData.rarity
	rarityValue.Parent = statsFolder

	local descValue = Instance.new("StringValue")
	descValue.Name = "StyleDescription"
	descValue.Value = styleData.description
	descValue.Parent = statsFolder

	-- Obtener bonificaciones del estilo
	local bonuses = STYLE_BONUSES[styleData.name] or {}

	-- Crear todos los stats numéricos
	for statName, baseValue in pairs(COMPLETE_STATS) do
		local numberValue = Instance.new("NumberValue")
		numberValue.Name = statName

		-- Aplicar bonificaciones del estilo
		local bonus = bonuses[statName] or 0
		numberValue.Value = baseValue + bonus

		numberValue.Parent = statsFolder
	end

	-- Ajustar Ki inicial si MaxKi cambió
	local maxKi = statsFolder:FindFirstChild("MaxKi")
	local ki = statsFolder:FindFirstChild("Ki")
	if maxKi and ki and maxKi.Value > ki.Value then
		ki.Value = maxKi.Value -- Llenar el Ki al máximo inicial
	end

	-- Timestamp de obtención
	local timestampValue = Instance.new("NumberValue")
	timestampValue.Name = "ObtainedAt"
	timestampValue.Value = tick()
	timestampValue.Parent = statsFolder

	return statsFolder
end

-- Función principal cuando el jugador entra
local function onPlayerAdded(player)
	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")

		wait(1) -- Esperar que el personaje esté completamente cargado

		-- Seleccionar estilo marcial
		local selectedStyleData = selectMartialStyle()

		-- Crear stats completos
		createCompleteStats(character, selectedStyleData)

		-- Crear efecto visual
		createAssignmentEffect(character, selectedStyleData)

		-- Mensaje detallado en consola
		local raritySymbol = "⭐"
		if selectedStyleData.rarity == "Mythic" then
			raritySymbol = "🌟✨🌟"
		elseif selectedStyleData.rarity == "Legendary" then
			raritySymbol = "✨🌟✨"
		elseif selectedStyleData.rarity == "Epic" then
			raritySymbol = "💎⭐💎"
		elseif selectedStyleData.rarity == "Rare" then
			raritySymbol = "⭐💫⭐"
		end

		print(raritySymbol .. " MARTIAL STYLE ASSIGNED " .. raritySymbol)
		print("👤 Player:", player.Name)
		print("🥋 Style:", selectedStyleData.name)
		print("🏆 Rarity:", selectedStyleData.rarity)
		print("📝 Description:", selectedStyleData.description)
		print("🎲 Probability:", selectedStyleData.probability .. "%")
		print("=====================================")

		-- Mensaje especial para estilos muy raros
		if selectedStyleData.rarity == "Mythic" then
			print("🚨🚨🚨 MYTHIC STYLE OBTAINED! 🚨🚨🚨")
		elseif selectedStyleData.rarity == "Legendary" then
			print("🎉🎉 LEGENDARY STYLE! 🎉🎉")
		end
	end)
end

-- Conectar eventos
Players.PlayerAdded:Connect(onPlayerAdded)

-- Para jugadores que ya están en el servidor
for _, player in pairs(Players:GetPlayers()) do
	if player.Character then
		onPlayerAdded(player)
	end
end

print("✅ Updated Martial Style Assignment System loaded!")
print("🎯 Features:")
print("   ✅ Complete stat system with Level, XP, MaxKi")
print("   ✅ 9 martial styles with proper rarities")
print("   ✅ Style bonuses applied correctly")
print("   ✅ Visual effects for rare styles")
print("   ✅ Full integration with progression system")