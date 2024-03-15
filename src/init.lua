--!strict
local HapticService = game:GetService("HapticService")

local HapticPulse = {}
HapticPulse.__index = HapticPulse
HapticPulse.Presets = require(script.HapticPresets)

--[=[
	Creates a new haptic feedback object
	
	For example:
	```lua
	local largeMotorFeedback = HapticFeedback.new(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Large)
	
	-- Run a 2-second motor
	largeMotorFeedback:PlayMotor(2)
	```
]=]
function HapticPulse.new(userInputType: Enum.UserInputType, vibrationMotor: Enum.VibrationMotor)
	local self = setmetatable({}, HapticPulse)

	self._inputType = userInputType
	self._vibrationMotor = vibrationMotor
	self._lastDelayThread = nil :: thread?
	return self
end

--[=[
	Returns true if the specified Enum.UserInputType supports haptic feedback.
	
	For example:
	```lua
	local largeMotorFeedback = HapticFeedback.new(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Large)
	
	-- Checks if specified vibration supported
	print(largeMotorFeedback:IsVibrationSupported())
	```
]=]
function HapticPulse:IsVibrationSupported(): boolean
	return HapticService:IsVibrationSupported(self._inputType)
end

--[=[
	Returns true if the specified motor is available to be used with the specified Enum.UserInputType
	
	For example:
	```lua
	local largeMotorFeedback = HapticFeedback.new(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Large)
	
	-- Checks if specified motor supported
	print(largeMotorFeedback:IsMotorSupported())
	```
]=]
function HapticPulse:IsMotorSupported(): boolean
	return HapticService:IsMotorSupported(self._inputType, self._vibrationMotor)
end

--[=[
	Returns the current vibration value set to the specified UserInputType and Enum.VibrationMotor. This will not return anything if SetMotor has not been called prior.
	
	For example:
	```lua
	local largeMotorFeedback = HapticFeedback.new(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Large)
	
	-- Gets the current vibration value
	print(largeMotorFeedback:GetMotor())
	```
]=]
function HapticPulse:GetMotor(): number?
	return HapticService:GetMotor(self._inputType, self._vibrationMotor)
end

--[=[
	Stops the specified motor forever
	
	For example:
	```lua
	local largeMotorFeedback = HapticFeedback.new(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Large)
	
	-- Stop the specified motor
	largeMotorFeedback:StopMotor()
	```
]=]
function HapticPulse:StopMotor()
	self:_setMotor()
end

function HapticPulse:_setMotor(power: number?)
	power = power or 0
	HapticService:SetMotor(self._inputType, self._vibrationMotor, power)
end

--[=[
	Starts the specified motor for a certain period of time
	Note: if you want it to be yield, make the 2nd argument true
	For example:
	```lua
	local largeMotorFeedback = HapticFeedback.new(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Large)
	
	-- Play the specified motor for a 1 seconds
	largeMotorFeedback:PlayMotor(1) -- Does not yield
	largeMotorFeedback:PlayMotor(2, true) -- yields for 2 seconds
	```
]=]
function HapticPulse:PlayMotor(
	presetOrTime: number? | (typeof(HapticPulse.new(...)), boolean?) -> (),
	isYield: boolean?
)
	if not self:IsVibrationSupported() or not self:IsMotorSupported() then
		return
	end
	if typeof(presetOrTime) == "function" then
		presetOrTime(self, isYield)
		return
	end

	local thread = coroutine.running()

	if self._lastDelayThread and coroutine.status(self._lastDelayThread) ~= "dead" then
		pcall(task.cancel, self._lastDelayThread)
	end

	self:_setMotor(1)
	self._lastDelayThread = task.delay(presetOrTime, function()
		self:StopMotor()
		task.spawn(thread)
	end)

	if isYield then
		return coroutine.yield()
	end
end

return table.freeze({
	new = HapticPulse.new,
	Presets = HapticPulse.Presets,
})
