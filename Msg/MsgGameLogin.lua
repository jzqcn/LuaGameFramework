net.msg:import(..., function()
	local id = 0x10

	local cmdsSC =
	{
	--下发玩家角色信息
		["GAME_ACTOR"] =
		{
			0,
			{
				attr("loginId", "int"),
				attr("uuid", "long"),
				attr("power", "int"),
				attr("level", "int"),
				attr("exp", "int"),
				attr("money", "int"),
				attr("rmb", "int"),
				attr("vipLv", "byte"),
				attr("name", "string"),
				attr("powerMax", "int"),
				attr("vipExp", "int"),
				attr("vipShopOpen", "byte"),
				attr("soulBoxPoint", "int"),  --魂匣积分
				attr("isNew", "byte"),   --1:yes 0:no
				attr("isFirstPay", "int"),  --是否首充
				attr("badgeNum", "int"),  --徽章数量
				attr("systemConfig", "int"),  --系统设置
				attr("serverId", "int"),
				-- ...  后面还有 等正式的
			},
		},

		--角色信息
		--@need   需要修改
		["PLAYER_LIST"] =
		{
			2,
			{
				-- array("list", {
				-- 	attr("roleKey", "string"),
				-- 	attr("serverName", "string"),
				-- 	attr("roleName", "string"),
				-- 	attr("roleLevel", "int"),
				-- 	attr("vipLevel", "int"),
				-- }),
			}, 
		},

		--下发随机生成玩家名字
		["RANDOM_NAME"] =
		{
			6,
			{
				attr("name", "string"),
			},
		},
	}

	local cmdsCS =
	{
		--选中角色，进入游戏
		["GAME_LOGIN"] =
		{
			0,
			{
				attr("roleKey", "string")
			},
		},

		--创建角色
		["CREATE_PLAYER"] =
		{
			3,
			{
				attr("param", "string"),
			},
		},

		--请求角色列表
		["PLAYER_LIST"] =
		{
			2,
			{
				attr("userKey", "string"),
			},
		},
	}

	local types =  --存放枚举 或 共用的对象
	{
		-- 账号状态
		['AccountState'] = enum
		{	
			-- 正常
			[0] = 'NORMAL',
			-- 锁定
			[1] = 'BLOCK',
		},
	}

	return id, cmdsSC, cmdsCS, types
end
)