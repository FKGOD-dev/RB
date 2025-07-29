-- EnhancedProgressionSystem.lua
-- Script en ServerScriptService
-- Sistema de progresión completo con meditación, niveles y Ki expandido

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

print("🌟 INICIANDO SISTEMA DE PROGRESIÓN MEJORADO...")

-- Esperar remotes
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local meditationRemote = remotes:WaitForChild("Meditation")

-- Configuración del sistema
local PROGRESSION_CONFIG = {
	BASE_KI = 100,
	KI_PER_LEVEL = 20, -- Ki adicional por nivel
	BASE_XP_REQUIRED = 100,
	XP_SCALING = 1.2, -- Multiplicador por nivel
	MEDITATION_XP_RATE = 5, -- XP por segundo meditando
	MEDITATION_KI_RATE = 8, -- Ki por segundo meditando
	DAMAGE_SCALING = 1.1, -- Multiplicador de daño por nivel
	MAX_LEVEL = 100
}

-- Tabla para trackear jugadores meditando
local meditatingPlayers = {}

-- Función para obtener o crear stats expandidos
local function getOrCreateExpandedStats(character)
	local statsFolder = character:FindFirstChild("PlayerStats")
	if not statsFolder then return nil end

	local stats = {
		martialStyle = statsFolder:FindFirstChild("MartialStyle"),
		ki = statsFolder:FindFirstChild("Ki"),
		fuerza = statsFolder:FindFirstChild("Fuerza"),
		velocidad = statsFolder:FindFirstChild("Velocidad"),
		control = statsFolder:FindFirstChild("Control")
	}

	-- Crear stats de progresión si no existen
	local progressionStats = {
		{name = "Level", defaultValue = 1},
		{name = "XP", defaultValue = 0},
		{name = "MaxXP", defaultValue = PROGRESSION_CONFIG.BASE_XP_REQUIRED},
		{name = "MaxKi", defaultValue = PROGRESSION_CONFIG.BASE_KI},
		{name = "TotalMeditationTime", defaultValue = 0},
		{name = "TotalKills", defaultValue = 0},
		{name = "TotalHits", defaultValue = 0}
	}

	for _, statData in pairs(progressionStats) do
		local stat = statsFolder:FindFirstChild(statData.name)
		if not stat then
			local newStat = Instance.new("NumberValue")
			newStat.Name = statData.name
			newStat.Value = statData.defaultValue
			newStat.Parent = statsFolder
			stats[statData.name] = newStat
		else
			stats[statData.name] = stat
		end
	end

	return stats
end

-- Función para calcular XP requerida para el siguiente nivel
local function calculateRequiredXP(level)
	return math.floor(PROGRESSION_CONFIG.BASE_XP_REQUIRED * (PROGRESSION_CONFIG.XP_SCALING ^ (level - 1)))
end

-- Función para calcular Ki máximo basado en el nivel
local function calculateMaxKi(level)
	return PROGRESSION_CONFIG.BASE_KI + ((level - 1) * PROGRESSION_CONFIG.KI_PER_LEVEL)
end

-- Función para subir de nivel
local function levelUp(player, stats)
	local currentLevel = stats.Level.Value
	local newLevel = currentLevel + 1

	if newLevel > PROGRESSION_CONFIG.MAX_LEVEL then
		return -- Nivel máximo alcanzado
	end

	-- Actualizar nivel
	stats.Level.Value = newLevel
	stats.XP.Value = 0
	stats.MaxXP.Value = calculateRequiredXP(newLevel)

	-- Actualizar Ki máximo y restaurar Ki completo
	local newMaxKi = calculateMaxKi(newLevel)
	stats.MaxKi.Value = newMaxKi
	stats.Ki.Value = newMaxKi -- Restaurar Ki completo al subir de nivel

	-- Bonificación de stats por nivel
	stats.Fuerza.Value = stats.Fuerza.Value + 2
	stats.Velocidad.Value = stats.Velocidad.Value + 1
	stats.Control.Value = stats.Control.Value + 1

	print("🌟 LEVEL UP! Jugador:", player.Name)
	print("   📈 Nuevo Nivel:", newLevel)
	print("   ⚡ Nuevo Ki Máximo:", newMaxKi)
	print("   💪 Nueva Fuerza:", stats.Fuerza.Value)
	print("   🏃 Nueva Velocidad:", stats.Velocidad.Value)
	print("   🎯 Nuevo Control:", stats.Control.Value)

	-- Crear efecto visual de level up
	createLevelUpEffect(player.Character)
end

-- Función para crear efecto visual de level up en el servidor
local function createLevelUpEffect(character)
	if not character then return end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	-- Crear aura dorada de level up
	local levelUpAura = Instance.new("Attachment")
	levelUpAura.Name = "LevelUpAura"
	levelUpAura.Parent = humanoidRootPart

	local particle = Instance.new("ParticleEmitter")
	particle.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new(1, 1, 0)),
		ColorSequenceKeypoint.new(0.5, Color3.new(1, 0.8, 0)),
		ColorSequenceKeypoint.new(1, Color3.new(1, 1, 0.5))
	})
	particle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	particle.Rate = 200
	particle.Lifetime = NumberRange.new(1, 2)
	particle.Speed = NumberRange.new(15, 25)
	particle.SpreadAngle = Vector2.new(360, 360)
	particle.Parent = levelUpAura

	-- Crear luz dorada
	local light = Instance.new("PointLight")
	light.Color = Color3.new(1, 1, 0)
	light.Brightness = 3
	light.Range = 20
	light.Parent = humanoidRootPart

	-- Auto-destruir después de 5 segundos
	game:GetService("Debris"):AddItem(levelUpAura, 5)
	game:GetService("Debris"):AddItem(light, 3)

	-- Efecto de explosión
	local explosion = Instance.new("Explosion")
	explosion.Position = humanoidRootPart.Position
	explosion.BlastRadius = 0
	explosion.BlastPressure = 0
	explosion.Visible = false -- Solo sonido
	explosion.Parent = workspace
end

-- Función para dar XP a un jugador
local function giveXP(player, amount, reason)
	local character = player.Character
	if not character then return end

	local stats = getOrCreateExpandedStats(character)
	if not stats then return end

	local currentXP = stats.XP.Value
	local currentLevel = stats.Level.Value
	local maxXP = stats.MaxXP.Value

	-- Agregar XP
	stats.XP.Value = currentXP + amount

	print("📈 XP otorgada a", player.Name, ":", amount, "(" .. reason .. ")")

	-- Verificar si sube de nivel
	if stats.XP.Value >= maxXP then
		levelUp(player, stats)
	end
end

-- Función para crear aura de meditación
local function createMeditationAura(character)
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	-- Remover aura anterior si existe
	local existingAura = humanoidRootPart:FindFirstChild("MeditationAura")
	if existingAura then existingAura:Destroy() end

	-- Crear nueva aura de meditación
	local meditationAura = Instance.new("Attachment")
	meditationAura.Name = "MeditationAura"
	meditationAura.Parent = humanoidRootPart

	local particle = Instance.new("ParticleEmitter")
	particle.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new(0, 1, 0.5)),
		ColorSequenceKeypoint.new(0.5, Color3.new(0.5, 1, 0.8)),
		ColorSequenceKeypoint.new(1, Color3.new(0, 0.8, 1))
	})
	particle.Texture = "rbxasset://textures/particles/smoke_main.dds"
	particle.Rate = 50
	particle.Lifetime = NumberRange.new(2, 4)
	particle.Speed = NumberRange.new(3, 6)
	particle.SpreadAngle = Vector2.new(45, 45)
	particle.Parent = meditationAura

	-- Luz suave de meditación
	local light = Instance.new("PointLight")
	light.Color = Color3.new(0, 1, 0.8)
	light.Brightness = 1
	light.Range = 15
	light.Parent = humanoidRootPart

	return meditationAura, light
end

-- Función para remover aura de meditación
local function removeMeditationAura(character)
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	local aura = humanoidRootPart:FindFirstChild("MeditationAura")
	local light = humanoidRootPart:FindFirstChild("PointLight")

	if aura then aura:Destroy() end
	if light then light:Destroy() end
end

-- Evento de meditación
meditationRemote.OnServerEvent:Connect(function(player, isStarting)
	local character = player.Character
	if not character then return end

	if isStarting then
		-- Iniciar meditación
		meditatingPlayers[player] = {
			startTime = tick(),
			character = character
		}

		-- Crear aura visual
		createMeditationAura(character)

		print("🧘 " .. player.Name .. " comenzó a meditar")

	else
		-- Terminar meditación
		local meditationData = meditatingPlayers[player]
		if meditationData then
			local meditationTime = tick() - meditationData.startTime
			local stats = getOrCreateExpandedStats(character)

			if stats then
				-- Actualizar tiempo total de meditación
				stats.TotalMeditationTime.Value = stats.TotalMeditationTime.Value + meditationTime

				-- Dar XP por meditación
				local xpGained = math.floor(meditationTime * PROGRESSION_CONFIG.MEDITATION_XP_RATE)
				if xpGained > 0 then
					giveXP(player, xpGained, "meditation")
				end
			end

			meditatingPlayers[player] = nil
		end

		-- Remover aura visual
		removeMeditationAura(character)

		print("🧘 " .. player.Name .. " terminó de meditar")
	end
end)

-- Loop de meditación (recuperación de Ki y XP)
spawn(function()
	while true do
		wait(1) -- Cada segundo

		for player, data in pairs(meditatingPlayers) do
			if player.Parent and data.character.Parent then
				local stats = getOrCreateExpandedStats(data.character)
				if stats then
					local currentKi = stats.Ki.Value
					local maxKi = stats.MaxKi.Value

					-- Recuperar Ki más rápido mientras medita
					if currentKi < maxKi then
						local newKi = math.min(currentKi + PROGRESSION_CONFIG.MEDITATION_KI_RATE, maxKi)
						stats.Ki.Value = newKi
					end

					-- Dar XP por meditación continuada
					giveXP(player, PROGRESSION_CONFIG.MEDITATION_XP_RATE, "meditation")
				end
			else
				-- Limpiar si el jugador se desconectó
				meditatingPlayers[player] = nil
			end
		end
	end
end)

-- Regeneración pasiva de Ki (más lenta que meditación)
spawn(function()
	while true do
		wait(3) -- Cada 3 segundos

		for _, player in pairs(Players:GetPlayers()) do
			if player.Character and not meditatingPlayers[player] then
				local stats = getOrCreateExpandedStats(player.Character)
				if stats then
					local currentKi = stats.Ki.Value
					local maxKi = stats.MaxKi.Value

					if currentKi < maxKi then
						local newKi = math.min(currentKi + 3, maxKi) -- Regeneración pasiva más lenta
						stats.Ki.Value = newKi
					end
				end
			end
		end
	end
end)

-- Función para inicializar stats de nuevos jugadores
local function initializePlayerProgression(player)
	player.CharacterAdded:Connect(function(character)
		wait(2) -- Esperar que se creen los stats básicos

		local stats = getOrCreateExpandedStats(character)
		if stats then
			-- Asegurar que el Ki máximo esté configurado correctamente
			local level = stats.Level.Value
			local maxKi = calculateMaxKi(level)
			stats.MaxKi.Value = maxKi

			-- Si es un personaje nuevo, restaurar Ki completo
			if stats.Ki.Value <= 0 then
				stats.Ki.Value = maxKi
			end

			print("✅ Stats de progresión inicializados para", player.Name)
			print("   📊 Nivel:", level)
			print("   ⚡ Ki máximo:", maxKi)
		end
	end)
end

-- Función para dar XP por combate (llamada desde otros scripts)
local function giveXPForCombat(player, actionType)
	if actionType == "hit" then
		giveXP(player, 2, "successful hit")
	elseif actionType == "kill" then
		giveXP(player, 25, "enemy defeated")
	elseif actionType == "technique" then
		giveXP(player, 10, "technique used")
	end
end

-- Crear función global para otros scripts
_G.GiveXP = giveXPForCombat

-- Conectar eventos de jugadores
Players.PlayerAdded:Connect(initializePlayerProgression)

-- Para jugadores ya conectados
for _, player in pairs(Players:GetPlayers()) do
	initializePlayerProgression(player)
end

-- Limpiar al salir
Players.PlayerRemoving:Connect(function(player)
	meditatingPlayers[player] = nil
end)

-- Comando de administrador para dar XP
game.Players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(message)
		if player.UserId == game.CreatorId then
			local args = string.split(message, " ")
			local command = args[1]:lower()

			if command == "/givexp" then
				local targetName = args[2]
				local amount = tonumber(args[3]) or 100

				if targetName then
					local targetPlayer = game.Players:FindFirstChild(targetName)
					if targetPlayer then
						giveXP(targetPlayer, amount, "admin command")
						print("💰 Dado", amount, "XP a", targetName)
					end
				else
					giveXP(player, amount, "admin command")
				end

			elseif command == "/setlevel" then
				local targetName = args[2]
				local level = tonumber(args[3]) or 1

				if targetName then
					local targetPlayer = game.Players:FindFirstChild(targetName)
					if targetPlayer and targetPlayer.Character then
						local stats = getOrCreateExpandedStats(targetPlayer.Character)
						if stats then
							stats.Level.Value = level
							stats.MaxKi.Value = calculateMaxKi(level)
							stats.Ki.Value = stats.MaxKi.Value
							stats.MaxXP.Value = calculateRequiredXP(level)
							stats.XP.Value = 0

							print("🎯 Nivel de", targetName, "establecido a", level)
						end
					end
				end
			end
		end
	end)
end)

print("✅ Sistema de Progresión Mejorado cargado correctamente!")
print("🎮 Características:")
print("   ✅ Meditación para XP y Ki")
print("   ✅ Sistema de niveles escalable")
print("   ✅ Ki máximo aumenta por nivel")
print("   ✅ Stats aumentan por nivel")
print("   ✅ Efectos visuales épicos")
print("   ✅ Comandos de admin disponibles")
