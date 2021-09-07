local PLUGIN = PLUGIN

include("shared.lua")

local new_material = CreateMaterial("MyMaterial","UnlitGeneric",params);

local screenOverlay = Material( "materials/bluesdoubleornothing/screen_overlay.png" )
local screenBackground = Material( "materials/bluesdoubleornothing/screen_background.png" )
local startMaterial = Material("materials/bluesdoubleornothing/start.png")
local cashoutMaterial = Material("materials/bluesdoubleornothing/cashout.png")
local jackpotMaterial = Material("materials/bluesdoubleornothing/jackpot.png")
local bsodMaterial = Material("materials/bluesdoubleornothing/bsod.png")

local numberMaterials = {}
for i = 0 , 10 do
	numberMaterials[i] = Material("materials/bluesdoubleornothing/x"..i..".png")
end

local lowEndColor = Color(130,130,210)
local highEndColor = Color(255,58,58)

local COL_1 = Color(255,255,255,255)
local COL_2 = Color(255,215,100)
local COL_3 = Color(0,0,0,0)
local COL_4 = Color(60,60,60,255)
local COL_5 = Color(83,255,136)
local COL_6 = Color(83,192,255)
local COL_7 = Color(160,0,0)
local COL_8 = Color(255,0,0)
local COL_9 = Color(255,90,90)


--Lerps between colors instead of single values
local function LerpColor(t, col1, col2)
	local newCol = COL_3

	newCol.r = Lerp(t, col1.r, col2.r)
	newCol.g = Lerp(t, col1.g, col2.g)
	newCol.b = Lerp(t, col1.b, col2.b)
	newCol.a = Lerp(t, col1.a, col2.a)

	return newCol
end

surface.CreateFont( "BDON_SMALL", {
	font = "Roboto",
	extended = false,
	size = 50,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false, 
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "BDON_MEDIAM", {
	font = "Roboto",
	extended = false,
	size = 85,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "BDON_LARGE", {
	font = "Roboto",
	extended = false,
	size = 150,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

--Localise some vars

local surface = surface
local CurTime = CurTime
local math = math
local Color = Color
local draw = draw
local FrameTime = FrameTime
local oldLocalPlayer = LocalPlayer
local LocalPlayer = LocalPlayer
local Matrix = Matrix

if isfunction(LocalPlayer) and LocalPlayer():IsValid() then
	LocalPlayer = LocalPlayer()
end

function PLUGIN:InitPostEntity()
	LocalPlayer = oldLocalPlayer()
end

local screenDisabled = false

function ENT:Initialize()
	self.screenMaterial = CreateMaterial("bdn_machinescreenmat_"..self:EntIndex(), "UnlitGeneric", {})
	self.renderTarget = GetRenderTarget("bdn_machinescreen_"..self:EntIndex(), 2048, 2048, false)
	self.color = Color(math.random(0, 255), math.random(0, 255), math.random(0, 255))

	self.ScreenZoom = 1
	self.ScreenRotation = 0
	self.textRotation = 0

	self.cashOutSelected = false

	--This is frames used to draw the jackpot page, 0 means disabled.
	self.jackpotFrame = 0

	self.overrideGlitchMulti = false
	self.glitchMulti = 0

	self.screenMaterial:SetTexture('$basetexture', self.renderTarget)
end

--Stores draw frames for jackpots
local jackpotFrames = {}

--bsof screen
jackpotFrames[1] = function(ScrW, ScrH, ent)
	ent.ScreenZoom = 1 --Set instantly

	surface.SetDrawColor(COL_1)
	surface.SetMaterial(bsodMaterial) 
	surface.DrawTexturedRect(0, 0, ScrW, ScrH) 
end

--Dont worry
jackpotFrames[2] = function(ScrW, ScrH)
	draw.SimpleText(L("DONdontWorry"), "BDON_MEDIAM", ScrW/2 + 5, ScrH / 2 + 5, COL_4, 1, 0)
	draw.SimpleText(L("DONdontWorry"), "BDON_MEDIAM", ScrW/2, ScrH / 2, COL_1, 1, 0)
end

--This isnt a glitch
jackpotFrames[3] = function(ScrW, ScrH)
	draw.SimpleText(L("DONthisIsntAGlitch"), "BDON_MEDIAM", ScrW/2 + 5, ScrH / 2 + 5, COL_4, 1, 0)
	draw.SimpleText(L("DONthisIsntAGlitch"), "BDON_MEDIAM", ScrW/2, ScrH / 2, COL_1, 1, 0)
end

--I'v got something to tell you
jackpotFrames[4] = function(ScrW, ScrH)
	draw.SimpleText(L("DONiHaveSomething"), "BDON_MEDIAM", ScrW/2 + 5, ScrH / 2 + 5, COL_4, 1, 0)
	draw.SimpleText(L("DONiHaveSomething"), "BDON_MEDIAM", ScrW/2, ScrH / 2, COL_1, 1, 0)

	draw.SimpleText(L("DONtoTellYou"), "BDON_MEDIAM", ScrW/2 + 5, ScrH / 2 + 5 + 75, COL_4, 1, 0)
	draw.SimpleText(L("DONtoTellYou"), "BDON_MEDIAM", ScrW/2, ScrH / 2 + 75, COL_1, 1, 0)
end

--Something important
jackpotFrames[5] = function(ScrW, ScrH, ent)
	draw.SimpleText(L("DONsomethingImportant"), "BDON_MEDIAM", ScrW/2 + 5, ScrH / 2 + 5, COL_4, 1, 0)
	draw.SimpleText(L("DONsomethingImportant"), "BDON_MEDIAM", ScrW/2, ScrH / 2, COL_1, 1, 0)
end

--Congratulations player
jackpotFrames[6] = function(ScrW, ScrH, ent)
	draw.SimpleText(L("DONCongratulations"), "BDON_MEDIAM", ScrW/2 + 5, ScrH / 2 + 5, COL_4, 1, 0)
	draw.SimpleText(L("DONCongratulations"), "BDON_MEDIAM", ScrW/2, ScrH / 2, COL_1, 1, 0)

	draw.SimpleText(ent:GetUserName(), "BDON_MEDIAM", ScrW/2 + 5, ScrH / 2 + 5 + 75, COL_4, 1, 0)
	draw.SimpleText(ent:GetUserName(), "BDON_MEDIAM", ScrW/2, ScrH / 2 + 75, COL_1, 1, 0)
end

--You've just won the...
jackpotFrames[7] = function(ScrW, ScrH, ent)
	draw.SimpleText(L("DONYouveJust"), "BDON_MEDIAM", ScrW/2 + 5, ScrH / 2 + 5, COL_4, 1, 0)
	draw.SimpleText(L("DONYouveJust"), "BDON_MEDIAM", ScrW/2, ScrH / 2, COL_1, 1, 0)

	draw.SimpleText(L("DONwonThe"), "BDON_MEDIAM", ScrW/2 + 5, ScrH / 2 + 5 + 75, COL_4, 1, 0)
	draw.SimpleText(L("DONwonThe"), "BDON_MEDIAM", ScrW/2, ScrH / 2 + 75, COL_1, 1, 0)	
end

--You've just won the...
jackpotFrames[8] = function(ScrW, ScrH, ent)
	surface.SetDrawColor(LerpColor(math.sin((CurTime() * 22) + 1) / 2,COL_2, Color(255 * 0.6,215 * 0.6, 100)))
	surface.SetMaterial(screenBackground)
	surface.DrawTexturedRectRotated(ScrW /2, ScrH /2 , 2350, 2350, (CurTime() * 60) % 360)

	surface.SetDrawColor(COL_1)
	surface.SetMaterial(jackpotMaterial) 
	surface.DrawTexturedRectRotated(ScrW/2, ScrH/2, 1024 * 1.5, 512 * 1.5, ent.textRotation)	

	surface.SetDrawColor(COL_1)
	surface.SetMaterial(screenOverlay) 
	surface.DrawTexturedRect(0 - 50, 0 - 50, ScrW + 100, ScrH + 100) 
end

jackpotFrames[9] = function(ScrW, ScrH, ent)
	surface.SetDrawColor(LerpColor(math.sin((CurTime() * 22) + 1) / 2,COL_2, Color(255 * 0.6,215 * 0.6, 100)))
	surface.SetMaterial(screenBackground)
	surface.DrawTexturedRectRotated(ScrW /2, ScrH /2 , 2350, 2350, (CurTime() * 60) % 360)

	surface.SetDrawColor(COL_1)
	surface.SetMaterial(jackpotMaterial) 
	surface.DrawTexturedRectRotated(ScrW/2, ScrH/2, 1024 * 1.5, 512 * 1.5, ent.textRotation)	

	draw.SimpleText(L("DONyourPrize"), "BDON_LARGE", ScrW/2 + 5, 450 + 5 - 30, COL_4, 1, 0)
	draw.SimpleText(L("DONyourPrize"), "BDON_LARGE", ScrW/2, 450 - 30, COL_1, 1, 0)
 
	draw.SimpleText(ix.currency.Get(ent:GetJackpot()), "BDON_LARGE", ScrW/2 + 5, 450 + 5 + 75, COL_4, 1, 0)
	draw.SimpleText(ix.currency.Get(ent:GetJackpot()), "BDON_LARGE", ScrW/2, 450 + 75, COL_1, 1, 0)

	surface.SetDrawColor(COL_1)
	surface.SetMaterial(screenOverlay) 
	surface.DrawTexturedRect(0 - 50, 0 - 50, ScrW + 100, ScrH + 100) 
end

jackpotFrames[10] = function(ScrW, ScrH, ent)
	surface.SetDrawColor(LerpColor(math.sin((CurTime() * 22) + 1) / 2,COL_2, Color(255 * 0.6,215 * 0.6, 100)))
	surface.SetMaterial(screenBackground)
	surface.DrawTexturedRectRotated(ScrW /2, ScrH /2 , 2350, 2350, (CurTime() * 60) % 360)

	surface.SetDrawColor(COL_1)
	surface.SetMaterial(jackpotMaterial) 
	surface.DrawTexturedRectRotated(ScrW/2, ScrH/2, 1024 * 1.5, 512 * 1.5, ent.textRotation)	

	draw.SimpleText(L("DONyourPrize"), "BDON_LARGE", ScrW/2 + 5, 450 + 5 - 30, COL_4, 1, 0)
	draw.SimpleText(L("DONyourPrize"), "BDON_LARGE", ScrW/2, 450 - 30, COL_1, 1, 0)

	local prizeLerpValue = math.Clamp((ent.jackpotCountdown - CurTime()) / 13.97, 0, 1)
 
	local prizeValue = math.floor(Lerp(1 - prizeLerpValue, ent:GetJackpot(), 0))

	draw.SimpleText(ix.currency.Get(prizeValue), "BDON_LARGE", ScrW/2 + 5, 450 + 5 + 75, COL_4, 1, 0)
	draw.SimpleText(ix.currency.Get(prizeValue), "BDON_LARGE", ScrW/2, 450 + 75, COL_1, 1, 0)

	surface.SetDrawColor(COL_1)
	surface.SetMaterial(screenOverlay) 
	surface.DrawTexturedRect(0 - 50, 0 - 50, ScrW + 100, ScrH + 100) 
end



--Called when ever the screen should draw
function ENT:DrawScreen(ScrW, ScrH)
	local multiplier = self:GetMultiplier() -- out of 10
 
	--Do we override with the jackpot?
	if self.jackpotFrame ~= 0 then
		jackpotFrames[self.jackpotFrame](ScrW, ScrH, self)
		return --Dont draw anything else
	end

	--Draw cashout screen
	if self:GetCashOutAmount() > 0 then
		surface.SetDrawColor(LerpColor(math.sin((CurTime() * 8) + 1) / 2,COL_5, Color(83 * 0.6,255 * 0.6,136 * 0.6)))
		surface.SetMaterial(screenBackground)
		surface.DrawTexturedRectRotated(ScrW /2, ScrH /2 , 2350, 2350, (CurTime() * 10) % 360)

		surface.SetDrawColor(COL_1)
		surface.SetMaterial(cashoutMaterial) 
		surface.DrawTexturedRectRotated(ScrW/2, ScrH/2, 1024 * 1.3, 512 * 1.3, self.textRotation)	

		draw.SimpleText(L("DONYouWon"), "BDON_LARGE", ScrW/2 + 5, 350 + 5 - 30, COL_4, 1, 0)
		draw.SimpleText(L("DONYouWon"), "BDON_LARGE", ScrW/2, 350 - 30, COL_1, 1, 0)

		draw.SimpleText(ix.currency.Get(self:GetCashOutAmount()), "BDON_LARGE", ScrW/2 + 5, 350 + 5 + 75, COL_4, 1, 0)
		draw.SimpleText(ix.currency.Get(self:GetCashOutAmount()), "BDON_LARGE", ScrW/2, 350 + 75, COL_1, 1, 0)

		--Draw the current user 
		local textToDisplay = L("DONcurrentUser", self:GetUserName())
		if math.ceil((self:GetUserLastInteract() + 30) - CurTime()) > 0 then
			textToDisplay = textToDisplay.." ("..math.abs(math.ceil((self:GetUserLastInteract() + 30) - CurTime()))..")"
		end
		draw.SimpleText(textToDisplay, "BDON_SMALL", ScrW /2, ScrH - 75, COL_1, 1, 0)

		surface.SetDrawColor(COL_1)
		surface.SetMaterial(screenOverlay) 
		surface.DrawTexturedRect(0, 0, ScrW, ScrH) 

		return --Prevent rest from drawing
	end

	--Draw start screen stuff
	if self:GetGameStarted() == false then
		surface.SetDrawColor(LerpColor(math.sin((CurTime() * 3) + 1) / 2,COL_5, COL_6))
		surface.SetMaterial(screenBackground)
		surface.DrawTexturedRectRotated(ScrW /2, ScrH /2 , 2350, 2350, (CurTime() * 10) % 360)

		surface.SetDrawColor(COL_1)
		surface.SetMaterial(startMaterial) 
		surface.DrawTexturedRectRotated(ScrW/2, ScrH/2, 1150, 512, self.textRotation)	

		draw.SimpleText(ix.currency.Get(PLUGIN.bet).." "..L("DONperGameLabel"), "BDON_LARGE", ScrW/2 + 5, 350 + 5, COL_4, 1, 0)
		draw.SimpleText(ix.currency.Get(PLUGIN.bet).." "..L("DONperGameLabel"), "BDON_LARGE", ScrW/2, 350, COL_1, 1, 0)

		draw.SimpleText(L("DONreachX10forJackpot"), "BDON_MEDIAM", ScrW/2 + 5, ScrH - 450 + 5, COL_4, 1, 0)
		draw.SimpleText(L("DONreachX10forJackpot"), "BDON_MEDIAM", ScrW/2, ScrH - 450, COL_1, 1, 0)

		draw.SimpleText(ix.currency.Get(self:GetJackpot()), "BDON_MEDIAM", ScrW/2 + 5, ScrH - 450 + 5 + 75, COL_4, 1, 0)
		draw.SimpleText(ix.currency.Get(self:GetJackpot()), "BDON_MEDIAM", ScrW/2, ScrH - 450 + 75, COL_1, 1, 0)

		--Draw the current user 
		local textToDisplay = L("DONcurrentUser", self:GetUserName())
		if math.ceil((self:GetUserLastInteract() + 30) - CurTime()) > 0 then
			textToDisplay = textToDisplay.." ("..math.abs(math.ceil((self:GetUserLastInteract() + 30) - CurTime()))..")"
		end
		draw.SimpleText(textToDisplay, "BDON_SMALL", ScrW /2, ScrH - 75, COL_1, 1, 0)

		surface.SetDrawColor(COL_1)
		surface.SetMaterial(screenOverlay) 
		surface.DrawTexturedRect(0, 0, ScrW, ScrH) 

		return --Prevent the rest from drawin
	end

	--Draw in game stuff

	--Draw the background surface
	if multiplier ~= 0 then
		surface.SetDrawColor(LerpColor(multiplier/10, lowEndColor, highEndColor))
		surface.SetMaterial(screenBackground)
		surface.DrawTexturedRectRotated(ScrW /2, ScrH /2 , 2350, 2350, (CurTime() * self:GetMultiplier() * 10) % 360)
	else
		surface.SetDrawColor(LerpColor(math.sin((CurTime() * 10) + 1) / 2, COL_7, COL_8))
		surface.SetMaterial(screenBackground)
		surface.DrawTexturedRectRotated(ScrW /2, ScrH /2 , 2350, 2350, (CurTime() * 10) % 360)	
	end

	if multiplier ~= 0 then
		--Draw multiplier
		surface.SetDrawColor(LerpColor(1 - (multiplier/10), lowEndColor, highEndColor))
		surface.SetMaterial(numberMaterials[self:GetMultiplier()])
		surface.DrawTexturedRectRotated(ScrW/2, ScrH/2, 1024, 1024, self.textRotation)
	else
		surface.SetDrawColor(COL_9)
		surface.SetMaterial(numberMaterials[0])
		surface.DrawTexturedRectRotated(ScrW/2, ScrH/2, 1024, 512, self.textRotation)	
	end

	local bet = PLUGIN.bet

	for i = 1 , self:GetMultiplier() - 1 do
		bet = bet * 2
	end

	--Draw winning amount so far
	draw.SimpleText(ix.currency.Get(bet), "BDON_LARGE", ScrW/2 + 5, 350 + 5, COL_4, 1, 0)
	draw.SimpleText(ix.currency.Get(bet), "BDON_LARGE", ScrW/2, 350, COL_1, 1, 0)


	--Draw the current user 
	
	local textToDisplay = L("DONcurrentUser", self:GetUserName())
	if math.ceil((self:GetUserLastInteract() + 30) - CurTime()) > 0 then
		textToDisplay = textToDisplay.." ("..math.abs(math.ceil((self:GetUserLastInteract() + 30) - CurTime()))..")"
	end
	draw.SimpleText(textToDisplay, "BDON_SMALL", ScrW /2, ScrH - 75, COL_1, 1, 0)

	--Draw overlay 
	surface.SetDrawColor(COL_1)
	surface.SetMaterial(screenOverlay) 
	surface.DrawTexturedRect(0, 0, ScrW, ScrH) 
end

--Called to update the server of which button the client is looking at
function ENT:CheckSelectedButton()

	--To far
	if self:GetPos():Distance(LocalPlayer:GetPos()) > 150 then return end

	--Calculate ray position and rotation
	local origin = LocalPlayer:EyePos()
	local direction = LocalPlayer:EyeAngles():Forward()
	local planePosition = self:GetPos() + (self:GetAngles():Up() * 30) + (self:GetAngles():Forward() * -15)
	local planeNormal = self:GetUp() - self:GetForward()
	planeNormal:Normalize()

	--Interesect plane
	local hitPos = util.IntersectRayWithPlane(origin, direction, planePosition, planeNormal)

	if hitPos == nil then return end

	--Min = -13.100795 9.520778 31.899216
	--Max = -17.147301 2.431691 27.852707

	local localPosition = self:WorldToLocal(hitPos)

	local inBox = localPosition:WithinAABox(Vector(-17.147301, 1.431691, 27.852707), Vector(-13.100795, 11.520778, 31.899216))

	if self.cashOutSelected ~= inBox then
		net.Start("bdn:setselectedbutton")
		net.WriteEntity(self)
		net.WriteBool(inBox)
		net.SendToServer()
	end

	self.cashOutSelected = inBox
end


local screenX = 1024 + 128
local screenY = 2048

local xShake = 0
local yShake = 0

function ENT:Draw()

	if self:GetPos():Distance(LocalPlayer:GetPos()) < 800 and not screenDisabled then

		self.ScreenZoom = Lerp((10 - self:GetMultiplier()) * FrameTime(), self.ScreenZoom, 1)
		self.textRotation = Lerp((10 - self:GetMultiplier()) * FrameTime(), self.textRotation, 0)

		if self.overrideGlitchMulti then
			self.ScreenZoom = Lerp(3 * FrameTime(), self.ScreenZoom, 1)
			self.textRotation = Lerp(3 * FrameTime(), self.textRotation, 0)		 
		end

		xShake = 0
		yShake = 0

		local mat = Matrix()
		if self.ScreenZoom > 1 then
			if self:GetMultiplier() > 3 and not self.overrideGlitchMulti then
				xShake = Lerp((self.ScreenZoom - 1) / 2.5, 0, math.random(-75, 75))
				yShake = Lerp((self.ScreenZoom - 1) / 2.5, 0, math.random(-75, 75))
			else
				xShake = Lerp(((self.ScreenZoom - 1) * self.glitchMulti) / 2.5, 0, math.random(-75, 75))
				yShake = Lerp(((self.ScreenZoom - 1) * self.glitchMulti) / 2.5, 0, math.random(-75, 75))		
			end

			mat:SetTranslation(Vector((0 + (self.ScreenZoom * (screenX/2))) - (screenX / 2) + xShake, (0 + (self.ScreenZoom * (screenY/2))) - (screenY / 2) + yShake) * -1)
			mat:Scale( Vector( 1, 1, 1 ) * self.ScreenZoom) 
		end

		--Draw the screen
		render.PushRenderTarget(self.renderTarget)
			render.Clear(0,0,0,255, true, true)
			render.OverrideAlphaWriteEnable(true, true)
			cam.Start2D()
				cam.PushModelMatrix(mat)
					self:DrawScreen(screenX, screenY)
				cam.PopModelMatrix()
			cam.End2D()
		render.PopRenderTarget()

		--Update material texture
		--self.screenMaterial:SetTexture('$basetexture', self.renderTarget)
		self:SetSubMaterial(3, "!bdn_machinescreenmat_"..self:EntIndex())

		--Check where we are looking
		self:CheckSelectedButton()
	end

	--Draw the final result
	self:DrawModel()
end

function ENT:Think()
	if self.inJackpot then
		self:JackpotThink()
	end
end

--Update for the jackpot
function ENT:JackpotThink()

end

local jackpotTimers = {
	{timer = 3.69, func = function() end},
	{timer = 5.76, func = function() end},
	{timer = 7.61, func = function() end},
	{timer = 9.48, func = function() end},
	{timer = 11.35, func = function() end},
	{timer = 13.21, func = function() end}, 
	{timer = 15.09, func = function(ent) 
		ent.glitchMulti = 2
		timer.Create("jackpot_bounce_"..ent:EntIndex(), 468.75 / 1000, 0, function()
			ent.ScreenZoom = (1 + (3 / 4))
			ent.textRotation = math.random( -3 * 4, 3 * 4)	
		end) 
	end},
	{timer = 30.09, func = function(ent) ent.glitchMulti = 1 end},
	{timer = 45.09, func = function(ent) 
		ent.jackpotCountdown = CurTime() + 13.97
	end}, 
	{timer = 58, noframeAdvance = true, func = function(ent) --Reset
		timer.Destroy("jackpot_bounce_"..ent:EntIndex())
	end}, 
	{timer = 59, func = function(ent) --Reset
		ent.jackpotFrame = 0 
		ent.overrideGlitchMulti = false
	end}, 
} 

--Triggers the jackpot
function ENT:PlayJackpot()
	--Set up a bunch of timers (I know its ugly but honestly who really cares, amirite)

	self.jackpotStartTime = CurTime()

	self.jackpotFrame = 1 --Begin drawing
	self.overrideGlitchMulti = true

	self.overrideGlitchMulti = true
	self.glitchMulti = 2

	--Emit the audio
	self:EmitSound("bdon_jackpot")
	--Set up the timers
	for k, v in pairs(jackpotTimers) do
		timer.Simple(v.timer, function() 
			if not v.noframeAdvance then 
				self.jackpotFrame = self.jackpotFrame + 1	
			end
			v.func(self)	
		end)
	end 
end

--Trigger light effect
net.Receive("bdon:updateScreenEffect",function()
	local e = net.ReadEntity()
	local power = net.ReadFloat()

	if e == nil or not e:IsValid() then return end

	if power < 1 then power = (1 + (e:GetMultiplier() / 4)) end
	if e ~= nil and e:IsValid() then
		e.ScreenZoom = power
		e.textRotation = math.random( -3 * e:GetMultiplier(), 3 * e:GetMultiplier())
	end
end)
 
--Trigger win message
net.Receive("bdn:winninginfo", function()
	local winAmount = net.ReadInt(32)

	ix.util.NotifyLocalized("DONcongratsYouWon", ix.currency.Get(winAmount))
end)

net.Receive("bdn:beginjackpot", function()
	local e = net.ReadEntity()
	if e == nil or not e:IsValid() then return end

	--Trigger the jackpot
	e:PlayJackpot()
end)

net.Receive("bdn:jackpotinfo", function()
	local ply = net.ReadEntity()
	local amount = net.ReadInt(32)

	ix.util.NotifyLocalized("DONjackpotAnnounce", ply:Name(), ix.currency.Get(amount))
end)
--Sound related stuff

sound.Add( {
	name = "bdon_jackpot",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 75 * PLUGIN.Volume,
	pitch = {100},
	sound = "doubleornothing/jackpot.mp3"
} )

util.PrecacheSound("doubleornothing/jackpot.mp3")
util.PrecacheSound("bdon_jackpot")

concommand.Add("bdor_disable_screens", function() 
	screenDisabled = true
end)

concommand.Add("bdor_enable_screens", function() 
	screenDisabled = false
end)