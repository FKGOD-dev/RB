-- TigerMartialStyle.lua
-- ModuleScript en ReplicatedStorage/MartialStyles/
-- Sistema completo para el estilo TIGER

local TigerStyle = {}

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

-- ========================================
-- 🐅 CONFIGURACIÓN DEL ESTILO TIGER
-- ========================================

TigerStyle.CONFIG = {
	-- Info básica
	NAME = "TIGER",
	RARITY = "Common",
	PROBABILITY = 60,
	COLOR = Color3.new(1, 0.5, 0),
	DESCRIPTION = "Estilo feroz y agresivo de berserker",

	-- Stats y bonificaciones
	STAT_BONUSES = {
		Fuerza = 2,
		Velocidad = 1,
		MaxKi = 0
	},

	-- Configuración de habilidades
	BASIC_ATTACK = {
		damage_multiplier = 1.2,
		bleed_damage = 5,
		bleed_duration = 3,
		claw_effects = 3
	},

	KI_BLAST = {
		projectile_count = 1,
		pierce_enemies = true,
		leap_distance = 15,
		stun_duration = 1.5
	},

	E_ABILITY = {
		name = "Berserker Roar",
		ki_cost = 30,
		cooldown = 8,
		stun_radius = 12,
		stun_duration = 2,
		damage_buff = 50, -- +50% damage
		buff_duration = 15
	},

	R_ABILITY = {
		name = "Fury Mode",
		ki_cost = 50,
		cooldown = 25,
		speed_boost = 200, -- +200% speed
		damage_boost = 150, -- +150% damage
		duration = 10
	},

	PASSIVE = {
		low_hp_threshold = 0.3, -- Cuando HP < 30%
		low_hp_damage_boost = 75 -- +75% damage extra
	}
}

-- ========================================
-- 🎨 EFECTOS VISUALES Y ANIMACIONES
-- ========================================

function TigerStyle:CreateClawEffect(position, direction, intensity)
	intensity = intensity or 1

	-- Crear múltiples efectos de garra
	for i = 1, 3 do
		spawn(function()
			wait(i * 0.05)

			local claw = Instance.new("Part")
			claw.Name = "TigerClaw"
			claw.Size = Vector3.new(4 * intensity, 0.3, 0.8)
			claw.Material = Enum.Material.Neon
			claw.BrickColor = BrickColor.new("Really red")
			claw.CanCollide = false
			claw.Anchored = true
			claw.Parent = workspace

			-- Posición con ligero offset
			local offset = Vector3.new(0, (i-2) * 0.5, 0)
			claw.CFrame = CFrame.new(position + offset, position + direction) * 
				CFrame.Angles(0, 0, math.rad(45 + (i * 10)))

			-- Efecto de aparición y desvanecimiento
			claw.Transparency = 1
			local appearTween = TweenService:Create(claw, 
				TweenInfo.new(0.1), {Transparency = 0.2})
			local fadeTween = TweenService:Create(claw, 
				TweenInfo.new(0.4), {Transparency = 1})

			appearTween:Play()
			appearTween.Completed:Connect(function()
				fadeTween:Play()
			end)

			Debris:AddItem(claw, 0.5)
		end)
	end
end

function TigerStyle:CreateBloodEffect(position)
	local blood = Instance.new("Part")
	blood.Name = "BloodSplatter"
	blood.Size = Vector3.new(2, 0.1, 2)
	blood.Shape = Enum.PartType.Cylinder
	blood.Material = Enum.Material.Neon
	blood.BrickColor = BrickColor.new("Crimson")
	blood.CanCollide = false
	blood.Anchored = true
	blood.CFrame = CFrame.new(position) * CFrame.Angles(math.rad(90), 0, 0)
	blood.Parent = workspace

	-- Expandir y desvanecer
	local expandTween = TweenService:Create(blood, 
		TweenInfo.new(0.3), {Size = Vector3.new(4, 0.1, 4), Transparency = 0.8})
	expandTween:Play()

	Debris:AddItem(blood, 1)
end

function TigerStyle:CreateRageAura(character, intensity)
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	-- Remover aura anterior
	local existingAura = rootPart:FindFirstChild("TigerRageAura")
	if existingAura then existingAura:Destroy() end

	local aura = Instance.new("Attachment")
	aura.Name = "TigerRageAura"
	aura.Parent = rootPart

	-- Partículas de furia
	local particle = Instance.new("ParticleEmitter")
	particle.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0)),
		ColorSequenceKeypoint.new(0.5, Color3.new(1, 0.5, 0)),
		ColorSequenceKeypoint.new(1, Color3.new(1, 1, 0))
	})
	particle.Texture = "rbxasset://textures/particles/fire_main.dds"
	particle.Rate = 80 * intensity
	particle.Lifetime = NumberRange.new(0.8, 1.5)
	particle.Speed = NumberRange.new(8, 15)
	particle.SpreadAngle = Vector2.new(45, 45)
	particle.Parent = aura

	-- Luz roja intensa
	local light = Instance.new("PointLight")
	light.Color = Color3.new(1, 0.2, 0)
	light.Brightness = 2 * intensity
	light.Range = 12 * intensity
	light.Parent = rootPart

	return aura, light
end

function TigerStyle:PlayRoarAnimation(character)
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end

	-- TODO: Cargar animación de rugido cuando tengamos IDs
	-- local roarAnim = humanoid:LoadAnimation(roarAnimationId)
	-- roarAnim:Play()

	-- Por ahora, efecto visual temporal
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if rootPart then
		-- Onda de choque visual
		local shockwave = Instance.new("Part")
		shockwave.Name = "RoarShockwave"
		shockwave.Size = Vector3.new(1, 0.2, 1)
		shockwave.Shape = Enum.PartType.Cylinder
		shockwave.Material = Enum.Material.ForceField
		shockwave.BrickColor = BrickColor.new("Really red")
		shockwave.CanCollide = false
		shockwave.Anchored = true
		shockwave.CFrame = rootPart.CFrame * CFrame.Angles(0, 0, math.rad(90))
		shockwave.Parent = workspace

		local expandTween = TweenService:Create(shockwave,
			TweenInfo.new(0.5), {Size = Vector3.new(30, 0.2, 30), Transparency = 1})
		expandTween:Play()

		Debris:AddItem(shockwave, 0.5)
	end
end

-- ========================================
-- ⚔️ SISTEMA DE COMBATE TIGER
-- ========================================

function TigerStyle:ExecuteBasicAttack(character, target)
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	local targetHumanoid = target:FindFirstChild("Humanoid")
	local targetRootPart = target:FindFirstChild("HumanoidRootPart")

	if not humanoid or not rootPart or not targetHumanoid or not targetRootPart then
		return false
	end

	-- Obtener stats del jugador
	local stats = self:GetPlayerStats(character)
	if not stats then return false end

	-- Calcular daño base con bonificación tiger
	local baseDamage = 15 + (stats.fuerza * 3) + (stats.Level * 2)
	local tigerDamage = baseDamage * self.CONFIG.BASIC_ATTACK.damage_multiplier

	-- Bonificación por vida baja (pasiva)
	local currentHPPercent = humanoid.Health / humanoid.MaxHealth
	if currentHPPercent <= self.CONFIG.PASSIVE.low_hp_threshold then
		tigerDamage = tigerDamage * (1 + self.CONFIG.PASSIVE.low_hp_damage_boost / 100)
		print("🐅 PASIVA TIGER: Daño aumentado por vida baja!")
	end

	-- Aplicar daño
	targetHumanoid:TakeDamage(tigerDamage)

	-- Efecto de sangrado (DoT)
	self:ApplyBleedEffect(target, self.CONFIG.BASIC_ATTACK.bleed_damage, 
		self.CONFIG.BASIC_ATTACK.bleed_duration)

	-- Efectos visuales
	local direction = (targetRootPart.Position - rootPart.Position).Unit
	self:CreateClawEffect(targetRootPart.Position, direction, 1)
	self:CreateBloodEffect(targetRootPart.Position)

	print("🐅 Garra Feroz: " .. math.floor(tigerDamage) .. " damage + sangrado")
	return true
end

function TigerStyle:ExecuteKiBlast(character, direction)
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return false end

	local stats = self:GetPlayerStats(character)
	if not stats then return false end

	-- Salto de tigre que atraviesa enemigos
	local leapDistance = self.CONFIG.KI_BLAST.leap_distance
	local targetPosition = rootPart.Position + (direction * leapDistance)

	-- Efecto de salto
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
	bodyVelocity.Velocity = direction * 80 + Vector3.new(0, 20, 0)
	bodyVelocity.Parent = rootPart

	-- Remover después de 0.3 segundos
	Debris:AddItem(bodyVelocity, 0.3)

	-- Detectar enemigos en el camino
	spawn(function()
		local startPos = rootPart.Position

		for i = 1, 10 do
			wait(0.03)
			local currentPos = rootPart.Position

			-- Buscar enemigos cercanos durante el salto
			for _, player in pairs(Players:GetPlayers()) do
				if player.Character and player.Character ~= character then
					local enemyRoot = player.Character:FindFirstChild("HumanoidRootPart")
					local enemyHumanoid = player.Character:FindFirstChild("Humanoid")

					if enemyRoot and enemyHumanoid then
						local distance = (currentPos - enemyRoot.Position).Magnitude
						if distance <= 5 then
							-- Atravesar enemigo
							local damage = 35 + (stats.fuerza * 2)
							enemyHumanoid:TakeDamage(damage)

							-- Aturdir brevemente
							local originalSpeed = enemyHumanoid.WalkSpeed
							enemyHumanoid.WalkSpeed = 0
							spawn(function()
								wait(self.CONFIG.KI_BLAST.stun_duration)
								if enemyHumanoid then
									enemyHumanoid.WalkSpeed = originalSpeed
								end
							end)

							-- Efectos visuales
							self:CreateClawEffect(enemyRoot.Position, direction, 1.5)
							print("🐅 Salto de Tigre atravesó a " .. player.Name)
						end
					end
				end
			end
		end
	end)

	return true
end

function TigerStyle:ExecuteEAbility(character, player)
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not rootPart then return false end

	local stats = self:GetPlayerStats(character)
	if not stats then return false end

	print("🐅 RUGIDO BERSERKER activado!")

	-- Animación de rugido
	self:PlayRoarAnimation(character)

	-- Aturdir enemigos en área
	local stunRadius = self.CONFIG.E_ABILITY.stun_radius
	for _, otherPlayer in pairs(Players:GetPlayers()) do
		if otherPlayer.Character and otherPlayer.Character ~= character then
			local enemyRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
			local enemyHumanoid = otherPlayer.Character:FindFirstChild("Humanoid")

			if enemyRoot and enemyHumanoid then
				local distance = (rootPart.Position - enemyRoot.Position).Magnitude
				if distance <= stunRadius then
					-- Aturdir y dañar
					enemyHumanoid:TakeDamage(40)

					local originalSpeed = enemyHumanoid.WalkSpeed
					enemyHumanoid.WalkSpeed = originalSpeed * 0.2

					spawn(function()
						wait(self.CONFIG.E_ABILITY.stun_duration)
						if enemyHumanoid then
							enemyHumanoid.WalkSpeed = originalSpeed
						end
					end)

					print("🐅 " .. otherPlayer.Name .. " aterrorizado por el rugido!")
				end
			end
		end
	end

	-- Buff de daño para el tiger
	self:ApplyDamageBuff(character, self.CONFIG.E_ABILITY.damage_buff, 
		self.CONFIG.E_ABILITY.buff_duration)

	-- Efectos visuales
	self:CreateRageAura(character, 1.5)

	return true
end

function TigerStyle:ExecuteRAbility(character, player)
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not rootPart then return false end

	print("🐅 MODO FURIA ACTIVADO!")

	-- Guardar stats originales
	local originalSpeed = humanoid.WalkSpeed
	local originalJump = humanoid.JumpPower

	-- Aplicar buffs masivos
	local speedMultiplier = 1 + (self.CONFIG.R_ABILITY.speed_boost / 100)
	humanoid.WalkSpeed = originalSpeed * speedMultiplier
	humanoid.JumpPower = originalJump * 1.5

	-- Aplicar buff de daño
	self:ApplyDamageBuff(character, self.CONFIG.R_ABILITY.damage_boost, 
		self.CONFIG.R_ABILITY.duration)

	-- Aura de furia intensa
	local aura, light = self:CreateRageAura(character, 2.5)

	-- Efectos especiales durante la furia
	spawn(function()
		for i = 1, self.CONFIG.R_ABILITY.duration do
			wait(1)
			if not character.Parent then break end

			-- Regenerar Ki durante la furia
			local stats = self:GetPlayerStats(character)
			if stats and stats.Ki then
				stats.Ki.Value = math.min(stats.Ki.Value + 10, stats.MaxKi.Value)
			end

			-- Efecto visual de latido
			if rootPart:FindFirstChild("TigerRageAura") then
				local pulse = TweenService:Create(light, 
					TweenInfo.new(0.2), {Brightness = light.Brightness * 1.5})
				local pulseBack = TweenService:Create(light, 
					TweenInfo.new(0.2), {Brightness = light.Brightness})

				pulse:Play()
				pulse.Completed:Connect(function() pulseBack:Play() end)
			end
		end

		-- Restaurar stats después de la duración
		humanoid.WalkSpeed = originalSpeed
		humanoid.JumpPower = originalJump

		if aura then aura:Destroy() end
		if light then light:Destroy() end

		print("🐅 Modo Furia terminado")
	end)

	return true
end

-- ========================================
-- 🩸 EFECTOS ESPECIALES Y PASIVAS
-- ========================================

function TigerStyle:ApplyBleedEffect(target, damage, duration)
	local targetHumanoid = target:FindFirstChild("Humanoid")
	if not targetHumanoid then return end

	-- Aplicar sangrado DoT
	spawn(function()
		for i = 1, duration do
			wait(1)
			if targetHumanoid.Health > 0 then
				targetHumanoid:TakeDamage(damage)

				-- Efecto visual de sangrado
				local targetRoot = target:FindFirstChild("HumanoidRootPart")
				if targetRoot then
					self:CreateBloodEffect(targetRoot.Position + Vector3.new(0, 2, 0))
				end
			end
		end
	end)
end

function TigerStyle:ApplyDamageBuff(character, buffPercent, duration)
	-- Marcar al personaje con buff de daño
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	local buffValue = Instance.new("NumberValue")
	buffValue.Name = "TigerDamageBuff"
	buffValue.Value = buffPercent
	buffValue.Parent = rootPart

	spawn(function()
		wait(duration)
		if buffValue then buffValue:Destroy() end
	end)
end

function TigerStyle:GetDamageMultiplier(character)
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return 1 end

	local buff = rootPart:FindFirstChild("TigerDamageBuff")
	if buff then
		return 1 + (buff.Value / 100)
	end

	return 1
end

-- ========================================
-- 🌱 SISTEMA DE CULTIVACIÓN ÚNICO
-- ========================================

function TigerStyle:OnKillEnemy(character, killedEnemy)
	local stats = self:GetPlayerStats(character)
	if not stats then return end

	-- Pasiva Tiger: Ganar fuerza extra por kills
	local bonusStrength = math.random(1, 3)
	stats.fuerza.Value = stats.fuerza.Value + bonusStrength

	print("🐅 KILL BONUS: +" .. bonusStrength .. " Fuerza (Total: " .. stats.fuerza.Value .. ")")

	-- Efecto visual de absorción de poder
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if rootPart then
		local powerAura = Instance.new("Attachment")
		powerAura.Parent = rootPart

		local particle = Instance.new("ParticleEmitter")
		particle.Color = ColorSequence.new(Color3.new(1, 0.8, 0))
		particle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		particle.Rate = 50
		particle.Lifetime = NumberRange.new(1, 2)
		particle.Speed = NumberRange.new(5, 10)
		particle.Parent = powerAura

		Debris:AddItem(powerAura, 3)
	end
end

function TigerStyle:OnMeditation(character, meditationTime)
	-- Tiger tiene cultivación normal, no hay bonus especial
	return 1 -- Multiplicador normal de XP
end

-- ========================================
-- 🛠️ FUNCIONES UTILITARIAS
-- ========================================

function TigerStyle:GetPlayerStats(character)
	local statsFolder = character:FindFirstChild("PlayerStats")
	if not statsFolder then return nil end

	return {
		martialStyle = statsFolder:FindFirstChild("MartialStyle"),
		Ki = statsFolder:FindFirstChild("Ki"),
		fuerza = statsFolder:FindFirstChild("Fuerza"),
		velocidad = statsFolder:FindFirstChild("Velocidad"),
		control = statsFolder:FindFirstChild("Control"),
		Level = statsFolder:FindFirstChild("Level"),
		MaxKi = statsFolder:FindFirstChild("MaxKi")
	}
end

function TigerStyle:CanUseAbility(character, abilityType)
	local stats = self:GetPlayerStats(character)
	if not stats then return false end

	local requiredLevels = {E = 10, R = 25}
	local requiredLevel = requiredLevels[abilityType]

	if requiredLevel and stats.Level.Value < requiredLevel then
		return false, "Nivel insuficiente (Requiere nivel " .. requiredLevel .. ")"
	end

	local kiCosts = {
		E = self.CONFIG.E_ABILITY.ki_cost,
		R = self.CONFIG.R_ABILITY.ki_cost
	}
	local requiredKi = kiCosts[abilityType] or 0

	if stats.Ki.Value < requiredKi then
		return false, "Ki insuficiente (Requiere " .. requiredKi .. " Ki)"
	end

	return true
end

function TigerStyle:ConsumeKi(character, amount)
	local stats = self:GetPlayerStats(character)
	if stats and stats.Ki then
		stats.Ki.Value = math.max(0, stats.Ki.Value - amount)
		return true
	end
	return false
end

-- ========================================
-- 📊 INFORMACIÓN DEL ESTILO
-- ========================================

function TigerStyle:GetStyleInfo()
	return {
		name = self.CONFIG.NAME,
		rarity = self.CONFIG.RARITY,
		probability = self.CONFIG.PROBABILITY,
		color = self.CONFIG.COLOR,
		description = self.CONFIG.DESCRIPTION,
		statBonuses = self.CONFIG.STAT_BONUSES,
		abilities = {
			LMB = "Garra feroz con sangrado",
			Q = "Salto de tigre que atraviesa enemigos", 
			E = "Rugido que aturde en área + buff de daño",
			R = "Modo furia - velocidad +200%, daño +150%"
		},
		passive = "Más daño cuando tienes poca vida",
		cultivation = "Normal, pero ganas fuerza extra por kills"
	}
end

return TigerStyle