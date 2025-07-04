-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf.protobuf"
module('Common_pb')


PLATFORMTYPE = protobuf.EnumDescriptor();
local PLATFORMTYPE_WX_ENUM = protobuf.EnumValueDescriptor();
local PLATFORMTYPE_QQ_ENUM = protobuf.EnumValueDescriptor();
SCOREPAYTYPE = protobuf.EnumDescriptor();
local SCOREPAYTYPE_ROOMOWNNER_ENUM = protobuf.EnumValueDescriptor();
local SCOREPAYTYPE_AA_ENUM = protobuf.EnumValueDescriptor();
MEMBERTYPE = protobuf.EnumDescriptor();
local MEMBERTYPE_ADD_ENUM = protobuf.EnumValueDescriptor();
local MEMBERTYPE_UPDATE_ENUM = protobuf.EnumValueDescriptor();
local MEMBERTYPE_LEAVE_ENUM = protobuf.EnumValueDescriptor();
ROOMSTYLE = protobuf.EnumDescriptor();
local ROOMSTYLE_RSGOLD_ENUM = protobuf.EnumValueDescriptor();
local ROOMSTYLE_RSCARD_ENUM = protobuf.EnumValueDescriptor();
local ROOMSTYLE_RSACTIVITY_ENUM = protobuf.EnumValueDescriptor();
CURRENCYTYPE = protobuf.EnumDescriptor();
local CURRENCYTYPE_SCORE_ENUM = protobuf.EnumValueDescriptor();
local CURRENCYTYPE_SLIVER_ENUM = protobuf.EnumValueDescriptor();
local CURRENCYTYPE_GOLD_ENUM = protobuf.EnumValueDescriptor();
local CURRENCYTYPE_CARD_ENUM = protobuf.EnumValueDescriptor();
POSITION = protobuf.Descriptor();
local POSITION_IP_FIELD = protobuf.FieldDescriptor();
local POSITION_LONGITUDE_FIELD = protobuf.FieldDescriptor();
local POSITION_LATITUDE_FIELD = protobuf.FieldDescriptor();

PLATFORMTYPE_WX_ENUM.name = "wx"
PLATFORMTYPE_WX_ENUM.index = 0
PLATFORMTYPE_WX_ENUM.number = 1
PLATFORMTYPE_QQ_ENUM.name = "qq"
PLATFORMTYPE_QQ_ENUM.index = 1
PLATFORMTYPE_QQ_ENUM.number = 2
PLATFORMTYPE.name = "PlatformType"
PLATFORMTYPE.full_name = ".Common.PlatformType"
PLATFORMTYPE.values = {PLATFORMTYPE_WX_ENUM,PLATFORMTYPE_QQ_ENUM}
SCOREPAYTYPE_ROOMOWNNER_ENUM.name = "RoomOwnner"
SCOREPAYTYPE_ROOMOWNNER_ENUM.index = 0
SCOREPAYTYPE_ROOMOWNNER_ENUM.number = 1
SCOREPAYTYPE_AA_ENUM.name = "AA"
SCOREPAYTYPE_AA_ENUM.index = 1
SCOREPAYTYPE_AA_ENUM.number = 2
SCOREPAYTYPE.name = "ScorePayType"
SCOREPAYTYPE.full_name = ".Common.ScorePayType"
SCOREPAYTYPE.values = {SCOREPAYTYPE_ROOMOWNNER_ENUM,SCOREPAYTYPE_AA_ENUM}
MEMBERTYPE_ADD_ENUM.name = "Add"
MEMBERTYPE_ADD_ENUM.index = 0
MEMBERTYPE_ADD_ENUM.number = 1
MEMBERTYPE_UPDATE_ENUM.name = "Update"
MEMBERTYPE_UPDATE_ENUM.index = 1
MEMBERTYPE_UPDATE_ENUM.number = 2
MEMBERTYPE_LEAVE_ENUM.name = "Leave"
MEMBERTYPE_LEAVE_ENUM.index = 2
MEMBERTYPE_LEAVE_ENUM.number = 3
MEMBERTYPE.name = "MemberType"
MEMBERTYPE.full_name = ".Common.MemberType"
MEMBERTYPE.values = {MEMBERTYPE_ADD_ENUM,MEMBERTYPE_UPDATE_ENUM,MEMBERTYPE_LEAVE_ENUM}
ROOMSTYLE_RSGOLD_ENUM.name = "RsGold"
ROOMSTYLE_RSGOLD_ENUM.index = 0
ROOMSTYLE_RSGOLD_ENUM.number = 1
ROOMSTYLE_RSCARD_ENUM.name = "RsCard"
ROOMSTYLE_RSCARD_ENUM.index = 1
ROOMSTYLE_RSCARD_ENUM.number = 2
ROOMSTYLE_RSACTIVITY_ENUM.name = "RsActivity"
ROOMSTYLE_RSACTIVITY_ENUM.index = 2
ROOMSTYLE_RSACTIVITY_ENUM.number = 3
ROOMSTYLE.name = "RoomStyle"
ROOMSTYLE.full_name = ".Common.RoomStyle"
ROOMSTYLE.values = {ROOMSTYLE_RSGOLD_ENUM,ROOMSTYLE_RSCARD_ENUM,ROOMSTYLE_RSACTIVITY_ENUM}
CURRENCYTYPE_SCORE_ENUM.name = "Score"
CURRENCYTYPE_SCORE_ENUM.index = 0
CURRENCYTYPE_SCORE_ENUM.number = 1
CURRENCYTYPE_SLIVER_ENUM.name = "Sliver"
CURRENCYTYPE_SLIVER_ENUM.index = 1
CURRENCYTYPE_SLIVER_ENUM.number = 2
CURRENCYTYPE_GOLD_ENUM.name = "Gold"
CURRENCYTYPE_GOLD_ENUM.index = 2
CURRENCYTYPE_GOLD_ENUM.number = 3
CURRENCYTYPE_CARD_ENUM.name = "Card"
CURRENCYTYPE_CARD_ENUM.index = 3
CURRENCYTYPE_CARD_ENUM.number = 4
CURRENCYTYPE.name = "CurrencyType"
CURRENCYTYPE.full_name = ".Common.CurrencyType"
CURRENCYTYPE.values = {CURRENCYTYPE_SCORE_ENUM,CURRENCYTYPE_SLIVER_ENUM,CURRENCYTYPE_GOLD_ENUM,CURRENCYTYPE_CARD_ENUM}
POSITION_IP_FIELD.name = "ip"
POSITION_IP_FIELD.full_name = ".Common.Position.ip"
POSITION_IP_FIELD.number = 1
POSITION_IP_FIELD.index = 0
POSITION_IP_FIELD.label = 1
POSITION_IP_FIELD.has_default_value = false
POSITION_IP_FIELD.default_value = ""
POSITION_IP_FIELD.type = 9
POSITION_IP_FIELD.cpp_type = 9

POSITION_LONGITUDE_FIELD.name = "longitude"
POSITION_LONGITUDE_FIELD.full_name = ".Common.Position.longitude"
POSITION_LONGITUDE_FIELD.number = 2
POSITION_LONGITUDE_FIELD.index = 1
POSITION_LONGITUDE_FIELD.label = 1
POSITION_LONGITUDE_FIELD.has_default_value = false
POSITION_LONGITUDE_FIELD.default_value = ""
POSITION_LONGITUDE_FIELD.type = 9
POSITION_LONGITUDE_FIELD.cpp_type = 9

POSITION_LATITUDE_FIELD.name = "latitude"
POSITION_LATITUDE_FIELD.full_name = ".Common.Position.latitude"
POSITION_LATITUDE_FIELD.number = 3
POSITION_LATITUDE_FIELD.index = 2
POSITION_LATITUDE_FIELD.label = 1
POSITION_LATITUDE_FIELD.has_default_value = false
POSITION_LATITUDE_FIELD.default_value = ""
POSITION_LATITUDE_FIELD.type = 9
POSITION_LATITUDE_FIELD.cpp_type = 9

POSITION.name = "Position"
POSITION.full_name = ".Common.Position"
POSITION.nested_types = {}
POSITION.enum_types = {}
POSITION.fields = {POSITION_IP_FIELD, POSITION_LONGITUDE_FIELD, POSITION_LATITUDE_FIELD}
POSITION.is_extendable = false
POSITION.extensions = {}

AA = 2
Add = 1
Card = 4
Gold = 3
Leave = 3
Position = protobuf.Message(POSITION)
RoomOwnner = 1
RsActivity = 3
RsCard = 2
RsGold = 1
Score = 1
Sliver = 2
Update = 2
qq = 2
wx = 1

