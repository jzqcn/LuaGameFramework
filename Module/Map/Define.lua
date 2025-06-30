
module(..., package.seeall)

MAP_FILE_PRE_PATH = "resource/map/export/"
MAP_IMAGE_PRE_PATH = "resource/map/resource/"

CONTROL_MODE_TYPE_ITEM = 1
CONTROL_MODE_TYPE_ROLE = 2

MAP_STATIC_MODEL = enum
{
	"ITEM",
	"ROLE",
}

MAP_CONTROL_MODEL = enum
{
	"DROP_ITEM",
	"ROLE",
	"EFFECT",
}

ROLE_TYPE = enum
{
	"HERO",
	"PLAYER",
	"PET",
	"MONSTER",
	"NPC",
}

SKILL_FILE_PRE_PATH = "resource/skill/"
