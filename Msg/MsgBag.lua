net.msg:import(..., function()
	local id = 0x60

	local cmdsSC =
	{
		["BAGLIST"] =
		{
			0,
			{
				attr("limit", "ushort"),
				array("itemlist", {
					attr("bagId", "longstring"),
					attr("id", "int"),
					attr("count", "byte"),
					attr("category", "byte"),
					attr("ifnew", "byte"),

					-- if category == CATEGORYI_EQUIM(= 1) or ==CATEGORYI_EQUIM_PET(= 2)
					attr("qianghuacolor", "wstring"),
					attr("qianghua", "wstring"),
					attr("stronglv", "byte"),
					--endif

					attr("index", "ubyte"),
				}, "ushort"),

				array("equiplist", {
					attr("bagId", "longstring"),
					attr("id", "int"),
					attr("upgradeLv", "wstring"),
					attr("ifup", "byte"),
					attr("strongLv", "byte"),
				}, "ubyte"),
			},
		},

		["UPDATEITEM"] =
		{
			1,
			{
				attr("bagId", "longstring"),
				attr("id", "int"),
				attr("count", "byte"),
				attr("category", "byte"),
				attr("ifnew", "byte"),

				-- if category == CATEGORYI_EQUIM(= 1) or ==CATEGORYI_EQUIM_PET(= 2)
				attr("qianghuacolor", "wstring"),
				attr("qianghua", "wstring"),
				--endif

				attr("index", "ubyte"),
			},
		}, 

		["EQUIP_INFO"] = 
		{
			4,
			{
			},
		},

		["EQUIP_UPDATE"] = 
		{
			5,
			{
			},
		},
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