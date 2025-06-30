net.msg:import(..., function()
	local id = 0x00

	local cmdsSC =
	{
		--登录失败
		["LOGIN_ACCOUNT"] =
		{
			0,
			{
				attr("content", "string"),  
			}, 
		},

		["SERVERLIST"] =
		{
			1,
			{
				attr("userKey", "string"),  --帐号加密KEY
				array("list", {
					attr("serverID", "int"),
					attr("serverName", "string"),
					attr("ip", "string"),
					attr("port", "short"),
					attr("status", "byte"),  --（0维护,1流畅,2繁忙,3爆满,4未开放,-1隐藏）
					attr("line", "byte"),
					attr("partition", "byte"),  --所属分区
					attr("remarks", "string"),  --备注
					attr("newServer", "byte"),
					attr("recommd", "byte"),  --是否推存服
					attr("roleNum", "int"),  --在线人数
				}),
			},
		},

		["LOGIN_KEY"] =
		{
			2,
			{
				attr("key", "int")
			},
		},

		--注册成功
		["REGIST_SUC"] =
		{
			4,
			{
				attr("name", "string"),
				attr("password", "string"),
			}, 
		},

		--注册失败
		["REGIST_FAIL"] =
		{
			5,
			{
				attr("content", "string"),
			}, 
		},
	}

	local cmdsCS =
	{
		--帐号登陆   成功就下发服务器列表
		["LOGIN_ACCOUNT"] =
		{
			0,
			{
				attr("name", "string"),
				attr("password", "string"),
				attr("unionId", "string"),  --渠道id  是一个数字
				attr("extra", "string"),  --额外数据
			},
		},

		["REGIST"] =
		{
			1,
			{
				attr("unionId", "string"),
				attr("ua", "string"),
				attr("version", "byte"),
				attr("sdk", "byte"),
				attr("regType", "byte"),
				attr("name", "string"),
				attr("password", "string"),
			},
		},
	}

	local types =  --存放枚举 或 共用的对象
	{
		['SERVER_STATUS'] = enum
		{	
			[-1] = 'HIDE',  --隐藏
			[0] = 'MAINTAIN',  --维护
			[1] = 'GOOD',  --流畅
			[2] = 'BUSY',  --繁忙
			[3] = 'FULL',  --爆满
			[4] = 'CLOSE',  --未开放
		},

		-- 账号状态
		['ACCOUNT_STATE'] = enum
		{	
			-- 正常
			[0] = 'NORMAL',
			-- 锁定
			[1] = 'BLOCK',
		},
		-- 防沉迷收益类型
		['INCOME_RATE'] = enum
		{	
			-- 完全收益(未被防沉迷状态)
			[0] = 'FULL',
			-- 收益减半(半防沉迷状态)
			[1] = 'HALF',
			-- 收益为空(完全防沉迷状态)
			[2] = 'EMPTY',
		},
	}

	return id, cmdsSC, cmdsCS, types
end
)