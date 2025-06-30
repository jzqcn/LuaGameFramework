
-- Net = Net or {}
-- Net.PROTOCOL_BASE = 
-- {
--     LOGIN_ACCOUNT                       = 0x00,--登陆服
--     GAMESERVER_LOGIN_BASE               = 0x10,--游戏服
--     MAP_BASE                            = 0x20,--场景地图协议
--     WAR_BASE                            = 0x30,--战斗协议
--     SC_PKBuffInfo                       = 0x3b,--Buff协议
--     SC_Other                            = 0x40,--任务及其它协议
--     SC_Other_UI                         = 0x50,--邮件及其他协议
--     SC_ITEM                             = 0x60,--物品I
--     SC_SOCIAL                           = 0x70,--社交
--     SC_ASTROLOGY                        = 0x80,--加成
--     SC_TONG                             = 0x90,--帮派
--     SC_MOUNT                            = 0xA0,--坐骑
--     SC_ITEM2                            = 0xB0,--物品II
--     SC_PET                              = 0xC0,--宠物
--     SC_HOME                             = 0xd0,--家园
--     SC_ACTIVITY                         = 0xe0,--活动任务
-- }

require "Protol.request_pb"
require "Protol.response_pb" 
require "Protol.MsgDef_pb"
require "Protol.AccountLogin_pb"
require "Protol.OpenAccountLogin_pb"
require "Protol.HallData_pb"
require "Protol.Ranking_pb"
require "Protol.Common_pb"
require "Protol.Position_pb"
require "Protol.item_pb"
require "Protol.CardKind_pb"
require "Protol.VerifyCode_pb"


-- require "MsgAccount"
-- require "MsgCommand"
-- require "MsgGameLogin"
-- require "MsgBag"
-- require "MsgPet"
-- require "MsgItem"
-- require "MsgSocial"
-- require "MsgEmail"
-- require "MsgOther"
-- require "MsgAstrology"
-- require "MsgTong"

-- require "MsgTestJson"