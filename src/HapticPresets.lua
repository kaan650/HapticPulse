type FeedbackObject = {
	--IsVibrationSupported: (self:FeedbackObject) -> boolean,
	--IsMotorSupported: (self:FeedbackObject) -> boolean,
	GetMotor: (self: FeedbackObject) -> number?,
	StopMotor: (self: FeedbackObject) -> (),
	PlayMotor: (self: FeedbackObject, number?, boolean?) -> (),
}

local HapticPresets = {}

function HapticPresets.ShortVibration(hapticFeedbackObject: FeedbackObject, isYield: boolean?)
	hapticFeedbackObject:PlayMotor(0.025)
end

function HapticPresets.LongVibration(hapticFeedbackObject: FeedbackObject, isYield: boolean?)
	hapticFeedbackObject:PlayMotor(1)
end

return HapticPresets
