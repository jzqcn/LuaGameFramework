-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf.protobuf"
module('MsgDef_pb')


COMMAND = protobuf.EnumDescriptor();
local COMMAND_MSG_HEARTBEAT_ENUM = protobuf.EnumValueDescriptor();
local COMMAND_MSG_ACOUNT_LOGIN_ENUM = protobuf.EnumValueDescriptor();
local COMMAND_MSG_OPENACCOUNT_LOGIN_ENUM = protobuf.EnumValueDescriptor();
local COMMAND_MSG_PLAYER_OFF_LINE_ENUM = protobuf.EnumValueDescriptor();
local COMMAND_MSG_LOGIN_GAME_ENUM = protobuf.EnumValueDescriptor();
local COMMAND_MSG_RANKING_ENUM = protobuf.EnumValueDescriptor();
local COMMAND_MSG_HALL_DATA_ENUM = protobuf.EnumValueDescriptor();
local COMMAND_MSG_SYN_DATA_ENUM = protobuf.EnumValueDescriptor();
local COMMAND_MSG_CURRENCY_ENUM = protobuf.EnumValueDescriptor();
local COMMAND_MSG_ANNOUNCE_ENUM = protobuf.EnumValueDescriptor();
local COMMAND_MSG_GAMEPERFORMANCE_ENUM = protobuf.EnumValueDescriptor();
local COMMAND_MSG_CHAT_ENUM = protobuf.EnumValueDescriptor();
local COMMAND_MSG_POSITION_ENUM = protobuf.EnumValueDescriptor();
local COMMAND_MSG_USER_ENUM = protobuf.EnumValueDescriptor();
local COMMAND_MSG_OPENACCOUNT_ENUM = protobuf.EnumValueDescriptor();
local COMMAND_MSG_GETBACKPASSWD_ENUM = protobuf.EnumValueDescriptor();
local COMMAND_MSG_SENDVERIFYCODE_ENUM = protobuf.EnumValueDescriptor();
local COMMAND_MSG_CLUB_ENUM = protobuf.EnumValueDescriptor();
local COMMAND_MSG_ROOM_HANDSHAKE_HALL_ENUM = protobuf.EnumValueDescriptor();
local COMMAND_MSG_ROOM_HEARTBEAT_ENUM = protobuf.EnumValueDescriptor();
local COMMAND_MSG_ROOM_ENUM = protobuf.EnumValueDescriptor();
local COMMAND_MSG_ITEM_ENUM = protobuf.EnumValueDescriptor();
local COMMAND_MSG_PLAYBACK_ENUM = protobuf.EnumValueDescriptor();
local COMMAND_MSG_PLATFORMGS_ENUM = protobuf.EnumValueDescriptor();
local COMMAND_MSG_GAMEPRESS_ENUM = protobuf.EnumValueDescriptor();
local COMMAND_MSG_KADANG_ENUM = protobuf.EnumValueDescriptor();
local COMMAND_MSG_KADANG_GOLD_CONFIG_ENUM = protobuf.EnumValueDescriptor();
local COMMAND_MSG_KADANG_CARD_CONFIG_ENUM = protobuf.EnumValueDescriptor();
local COMMAND_MSG_NIUNIU_ENUM = protobuf.EnumValueDescriptor();
local COMMAND_MSG_NIUNIU_GOLD_CONFIG_ENUM = protobuf.EnumValueDescriptor();
local COMMAND_MSG_PAODEKUAI_ENUM = protobuf.EnumValueDescriptor();
local COMMAND_MSG_PAODEKUAI_GOLD_CONFIG_ENUM = protobuf.EnumValueDescriptor();
local COMMAND_MSG_DOUDIZHU_ENUM = protobuf.EnumValueDescriptor();
local COMMAND_MSG_DOUDIZHU_GOLD_CONFIG_ENUM = protobuf.EnumValueDescriptor();
local COMMAND_MSG_DOUDIZHU_CARD_CONFIG_ENUM = protobuf.EnumValueDescriptor();
local COMMAND_MSG_SHISANSHUI_ENUM = protobuf.EnumValueDescriptor();
local COMMAND_MSG_SHISANSHUI_GOLD_CONFIG_ENUM = protobuf.EnumValueDescriptor();
local COMMAND_MSG_SHISANSHUI_CARD_CONFIG_ENUM = protobuf.EnumValueDescriptor();
local COMMAND_MSG_FISHING_ENUM = protobuf.EnumValueDescriptor();
local COMMAND_MSG_LONGHUDOU_ENUM = protobuf.EnumValueDescriptor();
local COMMAND_MSG_LONGHUDOU_GOLD_CONFIG_ENUM = protobuf.EnumValueDescriptor();
local COMMAND_MSG_MUSHIWANG_ENUM = protobuf.EnumValueDescriptor();
local COMMAND_MSG_MUSHIWANG_GOLD_CONFIG_ENUM = protobuf.EnumValueDescriptor();
local COMMAND_MSG_MUSHIWANG_CARD_CONFIG_ENUM = protobuf.EnumValueDescriptor();
local COMMAND_MSG_DANTIAO_ENUM = protobuf.EnumValueDescriptor();
local COMMAND_MSG_DANTIAO_GOLD_CONFIG_ENUM = protobuf.EnumValueDescriptor();
local COMMAND_MSG_BAIJIALE_ENUM = protobuf.EnumValueDescriptor();
local COMMAND_MSG_BAIJIALE_GOLD_CONFIG_ENUM = protobuf.EnumValueDescriptor();
local COMMAND_MSG_REDPACKET_ENUM = protobuf.EnumValueDescriptor();
local COMMAND_MSG_REDPACKET_GOLD_CONFIG_ENUM = protobuf.EnumValueDescriptor();
local COMMAND_MSG_GM_ENUM = protobuf.EnumValueDescriptor();

COMMAND_MSG_HEARTBEAT_ENUM.name = "MSG_HeartBeat"
COMMAND_MSG_HEARTBEAT_ENUM.index = 0
COMMAND_MSG_HEARTBEAT_ENUM.number = 100
COMMAND_MSG_ACOUNT_LOGIN_ENUM.name = "MSG_ACOUNT_LOGIN"
COMMAND_MSG_ACOUNT_LOGIN_ENUM.index = 1
COMMAND_MSG_ACOUNT_LOGIN_ENUM.number = 101
COMMAND_MSG_OPENACCOUNT_LOGIN_ENUM.name = "MSG_OPENACCOUNT_LOGIN"
COMMAND_MSG_OPENACCOUNT_LOGIN_ENUM.index = 2
COMMAND_MSG_OPENACCOUNT_LOGIN_ENUM.number = 102
COMMAND_MSG_PLAYER_OFF_LINE_ENUM.name = "MSG_PLAYER_OFF_LINE"
COMMAND_MSG_PLAYER_OFF_LINE_ENUM.index = 3
COMMAND_MSG_PLAYER_OFF_LINE_ENUM.number = 103
COMMAND_MSG_LOGIN_GAME_ENUM.name = "MSG_LOGIN_GAME"
COMMAND_MSG_LOGIN_GAME_ENUM.index = 4
COMMAND_MSG_LOGIN_GAME_ENUM.number = 104
COMMAND_MSG_RANKING_ENUM.name = "MSG_RANKING"
COMMAND_MSG_RANKING_ENUM.index = 5
COMMAND_MSG_RANKING_ENUM.number = 105
COMMAND_MSG_HALL_DATA_ENUM.name = "MSG_HALL_DATA"
COMMAND_MSG_HALL_DATA_ENUM.index = 6
COMMAND_MSG_HALL_DATA_ENUM.number = 106
COMMAND_MSG_SYN_DATA_ENUM.name = "MSG_SYN_DATA"
COMMAND_MSG_SYN_DATA_ENUM.index = 7
COMMAND_MSG_SYN_DATA_ENUM.number = 108
COMMAND_MSG_CURRENCY_ENUM.name = "MSG_CURRENCY"
COMMAND_MSG_CURRENCY_ENUM.index = 8
COMMAND_MSG_CURRENCY_ENUM.number = 109
COMMAND_MSG_ANNOUNCE_ENUM.name = "MSG_ANNOUNCE"
COMMAND_MSG_ANNOUNCE_ENUM.index = 9
COMMAND_MSG_ANNOUNCE_ENUM.number = 110
COMMAND_MSG_GAMEPERFORMANCE_ENUM.name = "MSG_GamePerformance"
COMMAND_MSG_GAMEPERFORMANCE_ENUM.index = 10
COMMAND_MSG_GAMEPERFORMANCE_ENUM.number = 111
COMMAND_MSG_CHAT_ENUM.name = "MSG_CHAT"
COMMAND_MSG_CHAT_ENUM.index = 11
COMMAND_MSG_CHAT_ENUM.number = 112
COMMAND_MSG_POSITION_ENUM.name = "MSG_POSITION"
COMMAND_MSG_POSITION_ENUM.index = 12
COMMAND_MSG_POSITION_ENUM.number = 113
COMMAND_MSG_USER_ENUM.name = "MSG_USER"
COMMAND_MSG_USER_ENUM.index = 13
COMMAND_MSG_USER_ENUM.number = 114
COMMAND_MSG_OPENACCOUNT_ENUM.name = "MSG_OPENACCOUNT"
COMMAND_MSG_OPENACCOUNT_ENUM.index = 14
COMMAND_MSG_OPENACCOUNT_ENUM.number = 115
COMMAND_MSG_GETBACKPASSWD_ENUM.name = "MSG_GETBACKPASSWD"
COMMAND_MSG_GETBACKPASSWD_ENUM.index = 15
COMMAND_MSG_GETBACKPASSWD_ENUM.number = 116
COMMAND_MSG_SENDVERIFYCODE_ENUM.name = "MSG_SENDVERIFYCODE"
COMMAND_MSG_SENDVERIFYCODE_ENUM.index = 16
COMMAND_MSG_SENDVERIFYCODE_ENUM.number = 117
COMMAND_MSG_CLUB_ENUM.name = "MSG_CLUB"
COMMAND_MSG_CLUB_ENUM.index = 17
COMMAND_MSG_CLUB_ENUM.number = 201
COMMAND_MSG_ROOM_HANDSHAKE_HALL_ENUM.name = "MSG_ROOM_HANDSHAKE_HALL"
COMMAND_MSG_ROOM_HANDSHAKE_HALL_ENUM.index = 18
COMMAND_MSG_ROOM_HANDSHAKE_HALL_ENUM.number = 500
COMMAND_MSG_ROOM_HEARTBEAT_ENUM.name = "MSG_ROOM_HeartBeat"
COMMAND_MSG_ROOM_HEARTBEAT_ENUM.index = 19
COMMAND_MSG_ROOM_HEARTBEAT_ENUM.number = 501
COMMAND_MSG_ROOM_ENUM.name = "MSG_ROOM"
COMMAND_MSG_ROOM_ENUM.index = 20
COMMAND_MSG_ROOM_ENUM.number = 502
COMMAND_MSG_ITEM_ENUM.name = "MSG_ITEM"
COMMAND_MSG_ITEM_ENUM.index = 21
COMMAND_MSG_ITEM_ENUM.number = 801
COMMAND_MSG_PLAYBACK_ENUM.name = "MSG_PLAYBACK"
COMMAND_MSG_PLAYBACK_ENUM.index = 22
COMMAND_MSG_PLAYBACK_ENUM.number = 802
COMMAND_MSG_PLATFORMGS_ENUM.name = "MSG_PLATFORMGS"
COMMAND_MSG_PLATFORMGS_ENUM.index = 23
COMMAND_MSG_PLATFORMGS_ENUM.number = 998
COMMAND_MSG_GAMEPRESS_ENUM.name = "MSG_GAMEPRESS"
COMMAND_MSG_GAMEPRESS_ENUM.index = 24
COMMAND_MSG_GAMEPRESS_ENUM.number = 999
COMMAND_MSG_KADANG_ENUM.name = "MSG_KADANG"
COMMAND_MSG_KADANG_ENUM.index = 25
COMMAND_MSG_KADANG_ENUM.number = 1000
COMMAND_MSG_KADANG_GOLD_CONFIG_ENUM.name = "MSG_KADANG_GOLD_CONFIG"
COMMAND_MSG_KADANG_GOLD_CONFIG_ENUM.index = 26
COMMAND_MSG_KADANG_GOLD_CONFIG_ENUM.number = 1001
COMMAND_MSG_KADANG_CARD_CONFIG_ENUM.name = "MSG_KADANG_CARD_CONFIG"
COMMAND_MSG_KADANG_CARD_CONFIG_ENUM.index = 27
COMMAND_MSG_KADANG_CARD_CONFIG_ENUM.number = 1002
COMMAND_MSG_NIUNIU_ENUM.name = "MSG_NIUNIU"
COMMAND_MSG_NIUNIU_ENUM.index = 28
COMMAND_MSG_NIUNIU_ENUM.number = 2000
COMMAND_MSG_NIUNIU_GOLD_CONFIG_ENUM.name = "MSG_NIUNIU_GOLD_CONFIG"
COMMAND_MSG_NIUNIU_GOLD_CONFIG_ENUM.index = 29
COMMAND_MSG_NIUNIU_GOLD_CONFIG_ENUM.number = 2001
COMMAND_MSG_PAODEKUAI_ENUM.name = "MSG_PAODEKUAI"
COMMAND_MSG_PAODEKUAI_ENUM.index = 30
COMMAND_MSG_PAODEKUAI_ENUM.number = 3000
COMMAND_MSG_PAODEKUAI_GOLD_CONFIG_ENUM.name = "MSG_PAODEKUAI_GOLD_CONFIG"
COMMAND_MSG_PAODEKUAI_GOLD_CONFIG_ENUM.index = 31
COMMAND_MSG_PAODEKUAI_GOLD_CONFIG_ENUM.number = 3001
COMMAND_MSG_DOUDIZHU_ENUM.name = "MSG_DOUDIZHU"
COMMAND_MSG_DOUDIZHU_ENUM.index = 32
COMMAND_MSG_DOUDIZHU_ENUM.number = 4000
COMMAND_MSG_DOUDIZHU_GOLD_CONFIG_ENUM.name = "MSG_DOUDIZHU_GOLD_CONFIG"
COMMAND_MSG_DOUDIZHU_GOLD_CONFIG_ENUM.index = 33
COMMAND_MSG_DOUDIZHU_GOLD_CONFIG_ENUM.number = 4001
COMMAND_MSG_DOUDIZHU_CARD_CONFIG_ENUM.name = "MSG_DOUDIZHU_CARD_CONFIG"
COMMAND_MSG_DOUDIZHU_CARD_CONFIG_ENUM.index = 34
COMMAND_MSG_DOUDIZHU_CARD_CONFIG_ENUM.number = 4002
COMMAND_MSG_SHISANSHUI_ENUM.name = "MSG_SHISANSHUI"
COMMAND_MSG_SHISANSHUI_ENUM.index = 35
COMMAND_MSG_SHISANSHUI_ENUM.number = 5000
COMMAND_MSG_SHISANSHUI_GOLD_CONFIG_ENUM.name = "MSG_SHISANSHUI_GOLD_CONFIG"
COMMAND_MSG_SHISANSHUI_GOLD_CONFIG_ENUM.index = 36
COMMAND_MSG_SHISANSHUI_GOLD_CONFIG_ENUM.number = 5001
COMMAND_MSG_SHISANSHUI_CARD_CONFIG_ENUM.name = "MSG_SHISANSHUI_CARD_CONFIG"
COMMAND_MSG_SHISANSHUI_CARD_CONFIG_ENUM.index = 37
COMMAND_MSG_SHISANSHUI_CARD_CONFIG_ENUM.number = 5002
COMMAND_MSG_FISHING_ENUM.name = "MSG_FISHING"
COMMAND_MSG_FISHING_ENUM.index = 38
COMMAND_MSG_FISHING_ENUM.number = 8000
COMMAND_MSG_LONGHUDOU_ENUM.name = "MSG_LONGHUDOU"
COMMAND_MSG_LONGHUDOU_ENUM.index = 39
COMMAND_MSG_LONGHUDOU_ENUM.number = 10000
COMMAND_MSG_LONGHUDOU_GOLD_CONFIG_ENUM.name = "MSG_LONGHUDOU_GOLD_CONFIG"
COMMAND_MSG_LONGHUDOU_GOLD_CONFIG_ENUM.index = 40
COMMAND_MSG_LONGHUDOU_GOLD_CONFIG_ENUM.number = 10001
COMMAND_MSG_MUSHIWANG_ENUM.name = "MSG_MUSHIWANG"
COMMAND_MSG_MUSHIWANG_ENUM.index = 41
COMMAND_MSG_MUSHIWANG_ENUM.number = 12000
COMMAND_MSG_MUSHIWANG_GOLD_CONFIG_ENUM.name = "MSG_MUSHIWANG_GOLD_CONFIG"
COMMAND_MSG_MUSHIWANG_GOLD_CONFIG_ENUM.index = 42
COMMAND_MSG_MUSHIWANG_GOLD_CONFIG_ENUM.number = 12001
COMMAND_MSG_MUSHIWANG_CARD_CONFIG_ENUM.name = "MSG_MUSHIWANG_CARD_CONFIG"
COMMAND_MSG_MUSHIWANG_CARD_CONFIG_ENUM.index = 43
COMMAND_MSG_MUSHIWANG_CARD_CONFIG_ENUM.number = 12002
COMMAND_MSG_DANTIAO_ENUM.name = "MSG_DANTIAO"
COMMAND_MSG_DANTIAO_ENUM.index = 44
COMMAND_MSG_DANTIAO_ENUM.number = 13000
COMMAND_MSG_DANTIAO_GOLD_CONFIG_ENUM.name = "MSG_DANTIAO_GOLD_CONFIG"
COMMAND_MSG_DANTIAO_GOLD_CONFIG_ENUM.index = 45
COMMAND_MSG_DANTIAO_GOLD_CONFIG_ENUM.number = 13001
COMMAND_MSG_BAIJIALE_ENUM.name = "MSG_BAIJIALE"
COMMAND_MSG_BAIJIALE_ENUM.index = 46
COMMAND_MSG_BAIJIALE_ENUM.number = 14000
COMMAND_MSG_BAIJIALE_GOLD_CONFIG_ENUM.name = "MSG_BAIJIALE_GOLD_CONFIG"
COMMAND_MSG_BAIJIALE_GOLD_CONFIG_ENUM.index = 47
COMMAND_MSG_BAIJIALE_GOLD_CONFIG_ENUM.number = 14001
COMMAND_MSG_REDPACKET_ENUM.name = "MSG_REDPACKET"
COMMAND_MSG_REDPACKET_ENUM.index = 48
COMMAND_MSG_REDPACKET_ENUM.number = 16000
COMMAND_MSG_REDPACKET_GOLD_CONFIG_ENUM.name = "MSG_REDPACKET_GOLD_CONFIG"
COMMAND_MSG_REDPACKET_GOLD_CONFIG_ENUM.index = 49
COMMAND_MSG_REDPACKET_GOLD_CONFIG_ENUM.number = 16001
COMMAND_MSG_GM_ENUM.name = "MSG_GM"
COMMAND_MSG_GM_ENUM.index = 50
COMMAND_MSG_GM_ENUM.number = 9999
COMMAND.name = "Command"
COMMAND.full_name = ".MsgDef.Command"
COMMAND.values = {COMMAND_MSG_HEARTBEAT_ENUM,COMMAND_MSG_ACOUNT_LOGIN_ENUM,COMMAND_MSG_OPENACCOUNT_LOGIN_ENUM,COMMAND_MSG_PLAYER_OFF_LINE_ENUM,COMMAND_MSG_LOGIN_GAME_ENUM,COMMAND_MSG_RANKING_ENUM,COMMAND_MSG_HALL_DATA_ENUM,COMMAND_MSG_SYN_DATA_ENUM,COMMAND_MSG_CURRENCY_ENUM,COMMAND_MSG_ANNOUNCE_ENUM,COMMAND_MSG_GAMEPERFORMANCE_ENUM,COMMAND_MSG_CHAT_ENUM,COMMAND_MSG_POSITION_ENUM,COMMAND_MSG_USER_ENUM,COMMAND_MSG_OPENACCOUNT_ENUM,COMMAND_MSG_GETBACKPASSWD_ENUM,COMMAND_MSG_SENDVERIFYCODE_ENUM,COMMAND_MSG_CLUB_ENUM,COMMAND_MSG_ROOM_HANDSHAKE_HALL_ENUM,COMMAND_MSG_ROOM_HEARTBEAT_ENUM,COMMAND_MSG_ROOM_ENUM,COMMAND_MSG_ITEM_ENUM,COMMAND_MSG_PLAYBACK_ENUM,COMMAND_MSG_PLATFORMGS_ENUM,COMMAND_MSG_GAMEPRESS_ENUM,COMMAND_MSG_KADANG_ENUM,COMMAND_MSG_KADANG_GOLD_CONFIG_ENUM,COMMAND_MSG_KADANG_CARD_CONFIG_ENUM,COMMAND_MSG_NIUNIU_ENUM,COMMAND_MSG_NIUNIU_GOLD_CONFIG_ENUM,COMMAND_MSG_PAODEKUAI_ENUM,COMMAND_MSG_PAODEKUAI_GOLD_CONFIG_ENUM,COMMAND_MSG_DOUDIZHU_ENUM,COMMAND_MSG_DOUDIZHU_GOLD_CONFIG_ENUM,COMMAND_MSG_DOUDIZHU_CARD_CONFIG_ENUM,COMMAND_MSG_SHISANSHUI_ENUM,COMMAND_MSG_SHISANSHUI_GOLD_CONFIG_ENUM,COMMAND_MSG_SHISANSHUI_CARD_CONFIG_ENUM,COMMAND_MSG_FISHING_ENUM,COMMAND_MSG_LONGHUDOU_ENUM,COMMAND_MSG_LONGHUDOU_GOLD_CONFIG_ENUM,COMMAND_MSG_MUSHIWANG_ENUM,COMMAND_MSG_MUSHIWANG_GOLD_CONFIG_ENUM,COMMAND_MSG_MUSHIWANG_CARD_CONFIG_ENUM,COMMAND_MSG_DANTIAO_ENUM,COMMAND_MSG_DANTIAO_GOLD_CONFIG_ENUM,COMMAND_MSG_BAIJIALE_ENUM,COMMAND_MSG_BAIJIALE_GOLD_CONFIG_ENUM,COMMAND_MSG_REDPACKET_ENUM,COMMAND_MSG_REDPACKET_GOLD_CONFIG_ENUM,COMMAND_MSG_GM_ENUM}

MSG_ACOUNT_LOGIN = 101
MSG_ANNOUNCE = 110
MSG_BAIJIALE = 14000
MSG_BAIJIALE_GOLD_CONFIG = 14001
MSG_CHAT = 112
MSG_CLUB = 201
MSG_CURRENCY = 109
MSG_DANTIAO = 13000
MSG_DANTIAO_GOLD_CONFIG = 13001
MSG_DOUDIZHU = 4000
MSG_DOUDIZHU_CARD_CONFIG = 4002
MSG_DOUDIZHU_GOLD_CONFIG = 4001
MSG_FISHING = 8000
MSG_GAMEPRESS = 999
MSG_GETBACKPASSWD = 116
MSG_GM = 9999
MSG_GamePerformance = 111
MSG_HALL_DATA = 106
MSG_HeartBeat = 100
MSG_ITEM = 801
MSG_KADANG = 1000
MSG_KADANG_CARD_CONFIG = 1002
MSG_KADANG_GOLD_CONFIG = 1001
MSG_LOGIN_GAME = 104
MSG_LONGHUDOU = 10000
MSG_LONGHUDOU_GOLD_CONFIG = 10001
MSG_MUSHIWANG = 12000
MSG_MUSHIWANG_CARD_CONFIG = 12002
MSG_MUSHIWANG_GOLD_CONFIG = 12001
MSG_NIUNIU = 2000
MSG_NIUNIU_GOLD_CONFIG = 2001
MSG_OPENACCOUNT = 115
MSG_OPENACCOUNT_LOGIN = 102
MSG_PAODEKUAI = 3000
MSG_PAODEKUAI_GOLD_CONFIG = 3001
MSG_PLATFORMGS = 998
MSG_PLAYBACK = 802
MSG_PLAYER_OFF_LINE = 103
MSG_POSITION = 113
MSG_RANKING = 105
MSG_REDPACKET = 16000
MSG_REDPACKET_GOLD_CONFIG = 16001
MSG_ROOM = 502
MSG_ROOM_HANDSHAKE_HALL = 500
MSG_ROOM_HeartBeat = 501
MSG_SENDVERIFYCODE = 117
MSG_SHISANSHUI = 5000
MSG_SHISANSHUI_CARD_CONFIG = 5002
MSG_SHISANSHUI_GOLD_CONFIG = 5001
MSG_SYN_DATA = 108
MSG_USER = 114

