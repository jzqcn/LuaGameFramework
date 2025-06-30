net.msg:import(..., function()
	local id = 0xC0

	local cmdsSC =
	{
		--选中角色，进入游戏
		["PET_LIST"] =
		{
			0,
			{
				array("list", {
					attr("petId", "longstring"),
					attr("id", "int"),
					attr("name", "wstring"),
					attr("shapeId", "ushort"),
					attr("level", "ubyte"),
					attr("grow", "int"),
					attr("quality", "byte"),
					attr("exp", "int"),
					attr("expMax", "int"),
					attr("evolve", "short"),
					attr("evolveNum", "byte"),
					attr("star", "byte"),
					attr("fightState", "byte")
				}),
			},
		},
		["PET_DETAIL"] =
		{
			1,
			{
				attr("petId", "longstring"),
				attr("fightValue", "int"),
				attr("exp", "int"),
				attr("maxExp", "int"),
				array("baglist", {
					attr("bagId", "longstring"),
					attr("id", "int"),
					attr("slv", "wstring"),
					attr("upgradeFlag", "byte"),
					}),
				attr("maxVal", "int"),
				attr("atkBase", "int"),
				attr("atkUp", "int"),
				attr("defBase", "int"),
				attr("defUp", "int"),
				attr("lifeBase", "int"),
				attr("lifeUp", "int"),
				attr("speedBase", "int"),
				attr("speedUp", "int"),
				attr("atkMax", "int"),
				attr("defMax", "int"),
				attr("lifeMax", "int"),
				attr("speedMax", "int"),
			},
		},

		["PET_EQUIP_LIST"] = 
		{
			0x0C,
			{
				attr("petUuid", "longstring"),
				array("list", {
					attr("bagId", "longstring"),
					attr("itemId", "int"),
					attr("curStrongLv", "wstring"),
					attr("strongLv", "byte"),
					attr("isLevelUp", "byte"),
					}),
			},
		}
	}

	local cmdsCS =
	{
	}

	local types =
	{
	}

	return id, cmdsSC, cmdsCS, types
end
)