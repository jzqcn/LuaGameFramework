module(..., package.seeall)

SpineCurveType = enum
{
    "CURVE_LOOP",
    "CURVE_SCALE",
    "CURVE_SPEED",
}

SpineActionIndex = enum
{
    "AA_NONE",
    "AA_IDLE",
    "AA_IDLE1",
    "AA_MOVE",
    "AA_ATTACK",
    "AA_DAMAGE",
    "AA_VICTORY",
    "AA_DIE",
    "AA_COUNT",
}

SpineAction = {
	["idle"] = SpineActionIndex.AA_IDLE,
	["run"] = SpineActionIndex.AA_MOVE,
	["walk"] = SpineActionIndex.AA_MOVE,
	["damage"] = SpineActionIndex.AA_DAMAGE,
	["die"] = SpineActionIndex.AA_DIE,
	["victory"] = SpineActionIndex.AA_VICTORY,
	["skill0"] = SpineActionIndex.AA_ATTACK,
	["skill1"] = SpineActionIndex.AA_ATTACK,
	["skill2"] = SpineActionIndex.AA_ATTACK,
	["skill3"] = SpineActionIndex.AA_ATTACK,
	["skill4"] = SpineActionIndex.AA_ATTACK,
	["skill5"] = SpineActionIndex.AA_ATTACK,
	["skill6"] = SpineActionIndex.AA_ATTACK,
}

SpineLoopAction = enum{
	"idle",
	"run",
	"walk",
	"victory",
}