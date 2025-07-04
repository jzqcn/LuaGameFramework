-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf.protobuf"
module('Announce_pb')


local REQUESTTYPE = protobuf.EnumDescriptor();
local REQUESTTYPE_REQUEST_READ_ENUM = protobuf.EnumValueDescriptor();
local REQUESTTYPE_REQUEST_ATTACH_TAKE_ENUM = protobuf.EnumValueDescriptor();
local REQUESTTYPE_PUSH_ROLLINGMSG_ENUM = protobuf.EnumValueDescriptor();
local REQUESTTYPE_PUSH_MAILMSG_ENUM = protobuf.EnumValueDescriptor();
local REQUESTTYPE_REQUEST_CUSTOM_ENUM = protobuf.EnumValueDescriptor();
local REQUESTTYPE_PUSH_CUSTOM_ENUM = protobuf.EnumValueDescriptor();
local REQUESTTYPE_PUSH_COMMON_ENUM = protobuf.EnumValueDescriptor();
local REQUESTTYPE_PUSH_CANCEL_ENUM = protobuf.EnumValueDescriptor();
local REQUESTTYPE_PUSH_TIPSMSG_ENUM = protobuf.EnumValueDescriptor();
local ANNOUNCETYPE = protobuf.EnumDescriptor();
local ANNOUNCETYPE_MAIL_ENUM = protobuf.EnumValueDescriptor();
local ANNOUNCETYPE_CUSTOM_ENUM = protobuf.EnumValueDescriptor();
local ANNOUNCETYPE_ROLLING_ENUM = protobuf.EnumValueDescriptor();
local ANNOUNCETYPE_TIPS_ENUM = protobuf.EnumValueDescriptor();
local ROLLINGTYPE = protobuf.EnumDescriptor();
local ROLLINGTYPE_SYSTEM_ENUM = protobuf.EnumValueDescriptor();
local ROLLINGTYPE_ACTIVITY_ENUM = protobuf.EnumValueDescriptor();
local ROLLINGTYPE_COUNTDOWN_ENUM = protobuf.EnumValueDescriptor();
local ROLLINGTYPE_PRIZES_ENUM = protobuf.EnumValueDescriptor();
local ROLLINGTYPE_COMMON_ENUM = protobuf.EnumValueDescriptor();
local ROLLINGTYPE_OTHER_ENUM = protobuf.EnumValueDescriptor();
local MAILTYPE = protobuf.EnumDescriptor();
local MAILTYPE_NORMAL_ENUM = protobuf.EnumValueDescriptor();
local MAILTYPE_CHARGE_ENUM = protobuf.EnumValueDescriptor();
local MAILTYPE_GIVE_ENUM = protobuf.EnumValueDescriptor();
local ITEM = protobuf.Descriptor();
local ITEM_ID_FIELD = protobuf.FieldDescriptor();
local ITEM_NAME_FIELD = protobuf.FieldDescriptor();
local ITEM_NUM_FIELD = protobuf.FieldDescriptor();
local ATTACHMENT = protobuf.Descriptor();
local ATTACHMENT_SLIVER_FIELD = protobuf.FieldDescriptor();
local ATTACHMENT_GOLD_FIELD = protobuf.FieldDescriptor();
local ATTACHMENT_ITEM_FIELD = protobuf.FieldDescriptor();
local ROLLINGMSG = protobuf.Descriptor();
local ROLLINGMSG_ID_FIELD = protobuf.FieldDescriptor();
local ROLLINGMSG_CONTENT_FIELD = protobuf.FieldDescriptor();
local ROLLINGMSG_TYPE_FIELD = protobuf.FieldDescriptor();
local ROLLINGMSG_COUNTDOWN_FIELD = protobuf.FieldDescriptor();
local MAILMSG = protobuf.Descriptor();
local MAILMSG_ID_FIELD = protobuf.FieldDescriptor();
local MAILMSG_TITLE_FIELD = protobuf.FieldDescriptor();
local MAILMSG_CONTENT_FIELD = protobuf.FieldDescriptor();
local MAILMSG_ATTACH_FIELD = protobuf.FieldDescriptor();
local MAILMSG_ISREAD_FIELD = protobuf.FieldDescriptor();
local MAILMSG_ISATTACHTAKE_FIELD = protobuf.FieldDescriptor();
local MAILMSG_CREATTIME_FIELD = protobuf.FieldDescriptor();
local MAILMSG_MAILTYPE_FIELD = protobuf.FieldDescriptor();
local CUSTOMMSG = protobuf.Descriptor();
local CUSTOMMSG_ID_FIELD = protobuf.FieldDescriptor();
local CUSTOMMSG_TITLE_FIELD = protobuf.FieldDescriptor();
local CUSTOMMSG_CONTENT_FIELD = protobuf.FieldDescriptor();
local CUSTOMMSG_REPLY_FIELD = protobuf.FieldDescriptor();
local CUSTOMMSG_ISREAD_FIELD = protobuf.FieldDescriptor();
local CUSTOMMSG_CREATETIME_FIELD = protobuf.FieldDescriptor();
local CUSTOMMSG_REPLYTIME_FIELD = protobuf.FieldDescriptor();
local TIPSMSG = protobuf.Descriptor();
local TIPSMSG_ID_FIELD = protobuf.FieldDescriptor();
local TIPSMSG_TITLE_FIELD = protobuf.FieldDescriptor();
local TIPSMSG_CONTENT_FIELD = protobuf.FieldDescriptor();
local READREQUEST = protobuf.Descriptor();
local READREQUEST_ID_FIELD = protobuf.FieldDescriptor();
local READREQUEST_ANNOUNCETYPE_FIELD = protobuf.FieldDescriptor();
local ANNOUNCEREQUEST = protobuf.Descriptor();
local ANNOUNCEREQUEST_TYPE_FIELD = protobuf.FieldDescriptor();
local ANNOUNCEREQUEST_ID_FIELD = protobuf.FieldDescriptor();
local ANNOUNCEREQUEST_CUSTOMMSG_FIELD = protobuf.FieldDescriptor();
local ANNOUNCEREQUEST_READREQUEST_FIELD = protobuf.FieldDescriptor();
local ANNOUNCEPUSHRESPONSE = protobuf.Descriptor();
local ANNOUNCEPUSHRESPONSE_ROLLINGMSG_FIELD = protobuf.FieldDescriptor();
local ANNOUNCEPUSHRESPONSE_MAILMSG_FIELD = protobuf.FieldDescriptor();
local ANNOUNCEPUSHRESPONSE_CUSTOMMSG_FIELD = protobuf.FieldDescriptor();
local ANNOUNCEPUSHRESPONSE_TIPSMSG_FIELD = protobuf.FieldDescriptor();
local ANNOUNCERESPONSE = protobuf.Descriptor();
local ANNOUNCERESPONSE_TYPE_FIELD = protobuf.FieldDescriptor();
local ANNOUNCERESPONSE_ISSUCCESS_FIELD = protobuf.FieldDescriptor();
local ANNOUNCERESPONSE_TIPS_FIELD = protobuf.FieldDescriptor();
local ANNOUNCERESPONSE_PUSHRESPONSE_FIELD = protobuf.FieldDescriptor();

REQUESTTYPE_REQUEST_READ_ENUM.name = "Request_Read"
REQUESTTYPE_REQUEST_READ_ENUM.index = 0
REQUESTTYPE_REQUEST_READ_ENUM.number = 1
REQUESTTYPE_REQUEST_ATTACH_TAKE_ENUM.name = "Request_Attach_Take"
REQUESTTYPE_REQUEST_ATTACH_TAKE_ENUM.index = 1
REQUESTTYPE_REQUEST_ATTACH_TAKE_ENUM.number = 2
REQUESTTYPE_PUSH_ROLLINGMSG_ENUM.name = "Push_RollingMsg"
REQUESTTYPE_PUSH_ROLLINGMSG_ENUM.index = 2
REQUESTTYPE_PUSH_ROLLINGMSG_ENUM.number = 3
REQUESTTYPE_PUSH_MAILMSG_ENUM.name = "Push_MailMsg"
REQUESTTYPE_PUSH_MAILMSG_ENUM.index = 3
REQUESTTYPE_PUSH_MAILMSG_ENUM.number = 4
REQUESTTYPE_REQUEST_CUSTOM_ENUM.name = "Request_Custom"
REQUESTTYPE_REQUEST_CUSTOM_ENUM.index = 4
REQUESTTYPE_REQUEST_CUSTOM_ENUM.number = 5
REQUESTTYPE_PUSH_CUSTOM_ENUM.name = "Push_Custom"
REQUESTTYPE_PUSH_CUSTOM_ENUM.index = 5
REQUESTTYPE_PUSH_CUSTOM_ENUM.number = 6
REQUESTTYPE_PUSH_COMMON_ENUM.name = "Push_Common"
REQUESTTYPE_PUSH_COMMON_ENUM.index = 6
REQUESTTYPE_PUSH_COMMON_ENUM.number = 7
REQUESTTYPE_PUSH_CANCEL_ENUM.name = "Push_Cancel"
REQUESTTYPE_PUSH_CANCEL_ENUM.index = 7
REQUESTTYPE_PUSH_CANCEL_ENUM.number = 8
REQUESTTYPE_PUSH_TIPSMSG_ENUM.name = "Push_TipsMsg"
REQUESTTYPE_PUSH_TIPSMSG_ENUM.index = 8
REQUESTTYPE_PUSH_TIPSMSG_ENUM.number = 9
REQUESTTYPE.name = "RequestType"
REQUESTTYPE.full_name = ".RequestType"
REQUESTTYPE.values = {REQUESTTYPE_REQUEST_READ_ENUM,REQUESTTYPE_REQUEST_ATTACH_TAKE_ENUM,REQUESTTYPE_PUSH_ROLLINGMSG_ENUM,REQUESTTYPE_PUSH_MAILMSG_ENUM,REQUESTTYPE_REQUEST_CUSTOM_ENUM,REQUESTTYPE_PUSH_CUSTOM_ENUM,REQUESTTYPE_PUSH_COMMON_ENUM,REQUESTTYPE_PUSH_CANCEL_ENUM,REQUESTTYPE_PUSH_TIPSMSG_ENUM}
ANNOUNCETYPE_MAIL_ENUM.name = "Mail"
ANNOUNCETYPE_MAIL_ENUM.index = 0
ANNOUNCETYPE_MAIL_ENUM.number = 1
ANNOUNCETYPE_CUSTOM_ENUM.name = "Custom"
ANNOUNCETYPE_CUSTOM_ENUM.index = 1
ANNOUNCETYPE_CUSTOM_ENUM.number = 2
ANNOUNCETYPE_ROLLING_ENUM.name = "Rolling"
ANNOUNCETYPE_ROLLING_ENUM.index = 2
ANNOUNCETYPE_ROLLING_ENUM.number = 3
ANNOUNCETYPE_TIPS_ENUM.name = "Tips"
ANNOUNCETYPE_TIPS_ENUM.index = 3
ANNOUNCETYPE_TIPS_ENUM.number = 4
ANNOUNCETYPE.name = "AnnounceType"
ANNOUNCETYPE.full_name = ".AnnounceType"
ANNOUNCETYPE.values = {ANNOUNCETYPE_MAIL_ENUM,ANNOUNCETYPE_CUSTOM_ENUM,ANNOUNCETYPE_ROLLING_ENUM,ANNOUNCETYPE_TIPS_ENUM}
ROLLINGTYPE_SYSTEM_ENUM.name = "System"
ROLLINGTYPE_SYSTEM_ENUM.index = 0
ROLLINGTYPE_SYSTEM_ENUM.number = 1
ROLLINGTYPE_ACTIVITY_ENUM.name = "Activity"
ROLLINGTYPE_ACTIVITY_ENUM.index = 1
ROLLINGTYPE_ACTIVITY_ENUM.number = 2
ROLLINGTYPE_COUNTDOWN_ENUM.name = "CountDown"
ROLLINGTYPE_COUNTDOWN_ENUM.index = 2
ROLLINGTYPE_COUNTDOWN_ENUM.number = 3
ROLLINGTYPE_PRIZES_ENUM.name = "Prizes"
ROLLINGTYPE_PRIZES_ENUM.index = 3
ROLLINGTYPE_PRIZES_ENUM.number = 4
ROLLINGTYPE_COMMON_ENUM.name = "Common"
ROLLINGTYPE_COMMON_ENUM.index = 4
ROLLINGTYPE_COMMON_ENUM.number = 5
ROLLINGTYPE_OTHER_ENUM.name = "Other"
ROLLINGTYPE_OTHER_ENUM.index = 5
ROLLINGTYPE_OTHER_ENUM.number = 6
ROLLINGTYPE.name = "RollingType"
ROLLINGTYPE.full_name = ".RollingType"
ROLLINGTYPE.values = {ROLLINGTYPE_SYSTEM_ENUM,ROLLINGTYPE_ACTIVITY_ENUM,ROLLINGTYPE_COUNTDOWN_ENUM,ROLLINGTYPE_PRIZES_ENUM,ROLLINGTYPE_COMMON_ENUM,ROLLINGTYPE_OTHER_ENUM}
MAILTYPE_NORMAL_ENUM.name = "Normal"
MAILTYPE_NORMAL_ENUM.index = 0
MAILTYPE_NORMAL_ENUM.number = 1
MAILTYPE_CHARGE_ENUM.name = "Charge"
MAILTYPE_CHARGE_ENUM.index = 1
MAILTYPE_CHARGE_ENUM.number = 2
MAILTYPE_GIVE_ENUM.name = "Give"
MAILTYPE_GIVE_ENUM.index = 2
MAILTYPE_GIVE_ENUM.number = 3
MAILTYPE.name = "MailType"
MAILTYPE.full_name = ".MailType"
MAILTYPE.values = {MAILTYPE_NORMAL_ENUM,MAILTYPE_CHARGE_ENUM,MAILTYPE_GIVE_ENUM}
ITEM_ID_FIELD.name = "id"
ITEM_ID_FIELD.full_name = ".Item.id"
ITEM_ID_FIELD.number = 1
ITEM_ID_FIELD.index = 0
ITEM_ID_FIELD.label = 1
ITEM_ID_FIELD.has_default_value = false
ITEM_ID_FIELD.default_value = 0
ITEM_ID_FIELD.type = 5
ITEM_ID_FIELD.cpp_type = 1

ITEM_NAME_FIELD.name = "name"
ITEM_NAME_FIELD.full_name = ".Item.name"
ITEM_NAME_FIELD.number = 2
ITEM_NAME_FIELD.index = 1
ITEM_NAME_FIELD.label = 1
ITEM_NAME_FIELD.has_default_value = false
ITEM_NAME_FIELD.default_value = ""
ITEM_NAME_FIELD.type = 9
ITEM_NAME_FIELD.cpp_type = 9

ITEM_NUM_FIELD.name = "num"
ITEM_NUM_FIELD.full_name = ".Item.num"
ITEM_NUM_FIELD.number = 3
ITEM_NUM_FIELD.index = 2
ITEM_NUM_FIELD.label = 1
ITEM_NUM_FIELD.has_default_value = false
ITEM_NUM_FIELD.default_value = 0
ITEM_NUM_FIELD.type = 5
ITEM_NUM_FIELD.cpp_type = 1

ITEM.name = "Item"
ITEM.full_name = ".Item"
ITEM.nested_types = {}
ITEM.enum_types = {}
ITEM.fields = {ITEM_ID_FIELD, ITEM_NAME_FIELD, ITEM_NUM_FIELD}
ITEM.is_extendable = false
ITEM.extensions = {}
ATTACHMENT_SLIVER_FIELD.name = "sliver"
ATTACHMENT_SLIVER_FIELD.full_name = ".Attachment.sliver"
ATTACHMENT_SLIVER_FIELD.number = 1
ATTACHMENT_SLIVER_FIELD.index = 0
ATTACHMENT_SLIVER_FIELD.label = 1
ATTACHMENT_SLIVER_FIELD.has_default_value = false
ATTACHMENT_SLIVER_FIELD.default_value = ""
ATTACHMENT_SLIVER_FIELD.type = 9
ATTACHMENT_SLIVER_FIELD.cpp_type = 9

ATTACHMENT_GOLD_FIELD.name = "gold"
ATTACHMENT_GOLD_FIELD.full_name = ".Attachment.gold"
ATTACHMENT_GOLD_FIELD.number = 2
ATTACHMENT_GOLD_FIELD.index = 1
ATTACHMENT_GOLD_FIELD.label = 1
ATTACHMENT_GOLD_FIELD.has_default_value = false
ATTACHMENT_GOLD_FIELD.default_value = ""
ATTACHMENT_GOLD_FIELD.type = 9
ATTACHMENT_GOLD_FIELD.cpp_type = 9

ATTACHMENT_ITEM_FIELD.name = "item"
ATTACHMENT_ITEM_FIELD.full_name = ".Attachment.item"
ATTACHMENT_ITEM_FIELD.number = 3
ATTACHMENT_ITEM_FIELD.index = 2
ATTACHMENT_ITEM_FIELD.label = 3
ATTACHMENT_ITEM_FIELD.has_default_value = false
ATTACHMENT_ITEM_FIELD.default_value = {}
ATTACHMENT_ITEM_FIELD.message_type = ITEM
ATTACHMENT_ITEM_FIELD.type = 11
ATTACHMENT_ITEM_FIELD.cpp_type = 10

ATTACHMENT.name = "Attachment"
ATTACHMENT.full_name = ".Attachment"
ATTACHMENT.nested_types = {}
ATTACHMENT.enum_types = {}
ATTACHMENT.fields = {ATTACHMENT_SLIVER_FIELD, ATTACHMENT_GOLD_FIELD, ATTACHMENT_ITEM_FIELD}
ATTACHMENT.is_extendable = false
ATTACHMENT.extensions = {}
ROLLINGMSG_ID_FIELD.name = "id"
ROLLINGMSG_ID_FIELD.full_name = ".RollingMsg.id"
ROLLINGMSG_ID_FIELD.number = 1
ROLLINGMSG_ID_FIELD.index = 0
ROLLINGMSG_ID_FIELD.label = 1
ROLLINGMSG_ID_FIELD.has_default_value = false
ROLLINGMSG_ID_FIELD.default_value = ""
ROLLINGMSG_ID_FIELD.type = 9
ROLLINGMSG_ID_FIELD.cpp_type = 9

ROLLINGMSG_CONTENT_FIELD.name = "content"
ROLLINGMSG_CONTENT_FIELD.full_name = ".RollingMsg.content"
ROLLINGMSG_CONTENT_FIELD.number = 2
ROLLINGMSG_CONTENT_FIELD.index = 1
ROLLINGMSG_CONTENT_FIELD.label = 2
ROLLINGMSG_CONTENT_FIELD.has_default_value = false
ROLLINGMSG_CONTENT_FIELD.default_value = ""
ROLLINGMSG_CONTENT_FIELD.type = 9
ROLLINGMSG_CONTENT_FIELD.cpp_type = 9

ROLLINGMSG_TYPE_FIELD.name = "type"
ROLLINGMSG_TYPE_FIELD.full_name = ".RollingMsg.type"
ROLLINGMSG_TYPE_FIELD.number = 3
ROLLINGMSG_TYPE_FIELD.index = 2
ROLLINGMSG_TYPE_FIELD.label = 2
ROLLINGMSG_TYPE_FIELD.has_default_value = false
ROLLINGMSG_TYPE_FIELD.default_value = nil
ROLLINGMSG_TYPE_FIELD.enum_type = ROLLINGTYPE
ROLLINGMSG_TYPE_FIELD.type = 14
ROLLINGMSG_TYPE_FIELD.cpp_type = 8

ROLLINGMSG_COUNTDOWN_FIELD.name = "countDown"
ROLLINGMSG_COUNTDOWN_FIELD.full_name = ".RollingMsg.countDown"
ROLLINGMSG_COUNTDOWN_FIELD.number = 4
ROLLINGMSG_COUNTDOWN_FIELD.index = 3
ROLLINGMSG_COUNTDOWN_FIELD.label = 1
ROLLINGMSG_COUNTDOWN_FIELD.has_default_value = false
ROLLINGMSG_COUNTDOWN_FIELD.default_value = 0
ROLLINGMSG_COUNTDOWN_FIELD.type = 5
ROLLINGMSG_COUNTDOWN_FIELD.cpp_type = 1

ROLLINGMSG.name = "RollingMsg"
ROLLINGMSG.full_name = ".RollingMsg"
ROLLINGMSG.nested_types = {}
ROLLINGMSG.enum_types = {}
ROLLINGMSG.fields = {ROLLINGMSG_ID_FIELD, ROLLINGMSG_CONTENT_FIELD, ROLLINGMSG_TYPE_FIELD, ROLLINGMSG_COUNTDOWN_FIELD}
ROLLINGMSG.is_extendable = false
ROLLINGMSG.extensions = {}
MAILMSG_ID_FIELD.name = "id"
MAILMSG_ID_FIELD.full_name = ".MailMsg.id"
MAILMSG_ID_FIELD.number = 1
MAILMSG_ID_FIELD.index = 0
MAILMSG_ID_FIELD.label = 2
MAILMSG_ID_FIELD.has_default_value = false
MAILMSG_ID_FIELD.default_value = ""
MAILMSG_ID_FIELD.type = 9
MAILMSG_ID_FIELD.cpp_type = 9

MAILMSG_TITLE_FIELD.name = "title"
MAILMSG_TITLE_FIELD.full_name = ".MailMsg.title"
MAILMSG_TITLE_FIELD.number = 2
MAILMSG_TITLE_FIELD.index = 1
MAILMSG_TITLE_FIELD.label = 1
MAILMSG_TITLE_FIELD.has_default_value = false
MAILMSG_TITLE_FIELD.default_value = ""
MAILMSG_TITLE_FIELD.type = 9
MAILMSG_TITLE_FIELD.cpp_type = 9

MAILMSG_CONTENT_FIELD.name = "content"
MAILMSG_CONTENT_FIELD.full_name = ".MailMsg.content"
MAILMSG_CONTENT_FIELD.number = 3
MAILMSG_CONTENT_FIELD.index = 2
MAILMSG_CONTENT_FIELD.label = 1
MAILMSG_CONTENT_FIELD.has_default_value = false
MAILMSG_CONTENT_FIELD.default_value = ""
MAILMSG_CONTENT_FIELD.type = 9
MAILMSG_CONTENT_FIELD.cpp_type = 9

MAILMSG_ATTACH_FIELD.name = "attach"
MAILMSG_ATTACH_FIELD.full_name = ".MailMsg.attach"
MAILMSG_ATTACH_FIELD.number = 4
MAILMSG_ATTACH_FIELD.index = 3
MAILMSG_ATTACH_FIELD.label = 1
MAILMSG_ATTACH_FIELD.has_default_value = false
MAILMSG_ATTACH_FIELD.default_value = nil
MAILMSG_ATTACH_FIELD.message_type = ATTACHMENT
MAILMSG_ATTACH_FIELD.type = 11
MAILMSG_ATTACH_FIELD.cpp_type = 10

MAILMSG_ISREAD_FIELD.name = "isRead"
MAILMSG_ISREAD_FIELD.full_name = ".MailMsg.isRead"
MAILMSG_ISREAD_FIELD.number = 5
MAILMSG_ISREAD_FIELD.index = 4
MAILMSG_ISREAD_FIELD.label = 1
MAILMSG_ISREAD_FIELD.has_default_value = false
MAILMSG_ISREAD_FIELD.default_value = false
MAILMSG_ISREAD_FIELD.type = 8
MAILMSG_ISREAD_FIELD.cpp_type = 7

MAILMSG_ISATTACHTAKE_FIELD.name = "isAttachTake"
MAILMSG_ISATTACHTAKE_FIELD.full_name = ".MailMsg.isAttachTake"
MAILMSG_ISATTACHTAKE_FIELD.number = 6
MAILMSG_ISATTACHTAKE_FIELD.index = 5
MAILMSG_ISATTACHTAKE_FIELD.label = 1
MAILMSG_ISATTACHTAKE_FIELD.has_default_value = false
MAILMSG_ISATTACHTAKE_FIELD.default_value = false
MAILMSG_ISATTACHTAKE_FIELD.type = 8
MAILMSG_ISATTACHTAKE_FIELD.cpp_type = 7

MAILMSG_CREATTIME_FIELD.name = "creatTime"
MAILMSG_CREATTIME_FIELD.full_name = ".MailMsg.creatTime"
MAILMSG_CREATTIME_FIELD.number = 7
MAILMSG_CREATTIME_FIELD.index = 6
MAILMSG_CREATTIME_FIELD.label = 1
MAILMSG_CREATTIME_FIELD.has_default_value = false
MAILMSG_CREATTIME_FIELD.default_value = ""
MAILMSG_CREATTIME_FIELD.type = 9
MAILMSG_CREATTIME_FIELD.cpp_type = 9

MAILMSG_MAILTYPE_FIELD.name = "mailType"
MAILMSG_MAILTYPE_FIELD.full_name = ".MailMsg.mailType"
MAILMSG_MAILTYPE_FIELD.number = 8
MAILMSG_MAILTYPE_FIELD.index = 7
MAILMSG_MAILTYPE_FIELD.label = 1
MAILMSG_MAILTYPE_FIELD.has_default_value = false
MAILMSG_MAILTYPE_FIELD.default_value = nil
MAILMSG_MAILTYPE_FIELD.enum_type = MAILTYPE
MAILMSG_MAILTYPE_FIELD.type = 14
MAILMSG_MAILTYPE_FIELD.cpp_type = 8

MAILMSG.name = "MailMsg"
MAILMSG.full_name = ".MailMsg"
MAILMSG.nested_types = {}
MAILMSG.enum_types = {}
MAILMSG.fields = {MAILMSG_ID_FIELD, MAILMSG_TITLE_FIELD, MAILMSG_CONTENT_FIELD, MAILMSG_ATTACH_FIELD, MAILMSG_ISREAD_FIELD, MAILMSG_ISATTACHTAKE_FIELD, MAILMSG_CREATTIME_FIELD, MAILMSG_MAILTYPE_FIELD}
MAILMSG.is_extendable = false
MAILMSG.extensions = {}
CUSTOMMSG_ID_FIELD.name = "id"
CUSTOMMSG_ID_FIELD.full_name = ".CustomMsg.id"
CUSTOMMSG_ID_FIELD.number = 1
CUSTOMMSG_ID_FIELD.index = 0
CUSTOMMSG_ID_FIELD.label = 1
CUSTOMMSG_ID_FIELD.has_default_value = false
CUSTOMMSG_ID_FIELD.default_value = ""
CUSTOMMSG_ID_FIELD.type = 9
CUSTOMMSG_ID_FIELD.cpp_type = 9

CUSTOMMSG_TITLE_FIELD.name = "title"
CUSTOMMSG_TITLE_FIELD.full_name = ".CustomMsg.title"
CUSTOMMSG_TITLE_FIELD.number = 2
CUSTOMMSG_TITLE_FIELD.index = 1
CUSTOMMSG_TITLE_FIELD.label = 1
CUSTOMMSG_TITLE_FIELD.has_default_value = false
CUSTOMMSG_TITLE_FIELD.default_value = ""
CUSTOMMSG_TITLE_FIELD.type = 9
CUSTOMMSG_TITLE_FIELD.cpp_type = 9

CUSTOMMSG_CONTENT_FIELD.name = "content"
CUSTOMMSG_CONTENT_FIELD.full_name = ".CustomMsg.content"
CUSTOMMSG_CONTENT_FIELD.number = 3
CUSTOMMSG_CONTENT_FIELD.index = 2
CUSTOMMSG_CONTENT_FIELD.label = 1
CUSTOMMSG_CONTENT_FIELD.has_default_value = false
CUSTOMMSG_CONTENT_FIELD.default_value = ""
CUSTOMMSG_CONTENT_FIELD.type = 9
CUSTOMMSG_CONTENT_FIELD.cpp_type = 9

CUSTOMMSG_REPLY_FIELD.name = "reply"
CUSTOMMSG_REPLY_FIELD.full_name = ".CustomMsg.reply"
CUSTOMMSG_REPLY_FIELD.number = 4
CUSTOMMSG_REPLY_FIELD.index = 3
CUSTOMMSG_REPLY_FIELD.label = 1
CUSTOMMSG_REPLY_FIELD.has_default_value = false
CUSTOMMSG_REPLY_FIELD.default_value = ""
CUSTOMMSG_REPLY_FIELD.type = 9
CUSTOMMSG_REPLY_FIELD.cpp_type = 9

CUSTOMMSG_ISREAD_FIELD.name = "isRead"
CUSTOMMSG_ISREAD_FIELD.full_name = ".CustomMsg.isRead"
CUSTOMMSG_ISREAD_FIELD.number = 5
CUSTOMMSG_ISREAD_FIELD.index = 4
CUSTOMMSG_ISREAD_FIELD.label = 1
CUSTOMMSG_ISREAD_FIELD.has_default_value = false
CUSTOMMSG_ISREAD_FIELD.default_value = false
CUSTOMMSG_ISREAD_FIELD.type = 8
CUSTOMMSG_ISREAD_FIELD.cpp_type = 7

CUSTOMMSG_CREATETIME_FIELD.name = "createTime"
CUSTOMMSG_CREATETIME_FIELD.full_name = ".CustomMsg.createTime"
CUSTOMMSG_CREATETIME_FIELD.number = 6
CUSTOMMSG_CREATETIME_FIELD.index = 5
CUSTOMMSG_CREATETIME_FIELD.label = 1
CUSTOMMSG_CREATETIME_FIELD.has_default_value = false
CUSTOMMSG_CREATETIME_FIELD.default_value = ""
CUSTOMMSG_CREATETIME_FIELD.type = 9
CUSTOMMSG_CREATETIME_FIELD.cpp_type = 9

CUSTOMMSG_REPLYTIME_FIELD.name = "replyTime"
CUSTOMMSG_REPLYTIME_FIELD.full_name = ".CustomMsg.replyTime"
CUSTOMMSG_REPLYTIME_FIELD.number = 7
CUSTOMMSG_REPLYTIME_FIELD.index = 6
CUSTOMMSG_REPLYTIME_FIELD.label = 1
CUSTOMMSG_REPLYTIME_FIELD.has_default_value = false
CUSTOMMSG_REPLYTIME_FIELD.default_value = ""
CUSTOMMSG_REPLYTIME_FIELD.type = 9
CUSTOMMSG_REPLYTIME_FIELD.cpp_type = 9

CUSTOMMSG.name = "CustomMsg"
CUSTOMMSG.full_name = ".CustomMsg"
CUSTOMMSG.nested_types = {}
CUSTOMMSG.enum_types = {}
CUSTOMMSG.fields = {CUSTOMMSG_ID_FIELD, CUSTOMMSG_TITLE_FIELD, CUSTOMMSG_CONTENT_FIELD, CUSTOMMSG_REPLY_FIELD, CUSTOMMSG_ISREAD_FIELD, CUSTOMMSG_CREATETIME_FIELD, CUSTOMMSG_REPLYTIME_FIELD}
CUSTOMMSG.is_extendable = false
CUSTOMMSG.extensions = {}
TIPSMSG_ID_FIELD.name = "id"
TIPSMSG_ID_FIELD.full_name = ".TipsMsg.id"
TIPSMSG_ID_FIELD.number = 1
TIPSMSG_ID_FIELD.index = 0
TIPSMSG_ID_FIELD.label = 1
TIPSMSG_ID_FIELD.has_default_value = false
TIPSMSG_ID_FIELD.default_value = ""
TIPSMSG_ID_FIELD.type = 9
TIPSMSG_ID_FIELD.cpp_type = 9

TIPSMSG_TITLE_FIELD.name = "title"
TIPSMSG_TITLE_FIELD.full_name = ".TipsMsg.title"
TIPSMSG_TITLE_FIELD.number = 2
TIPSMSG_TITLE_FIELD.index = 1
TIPSMSG_TITLE_FIELD.label = 1
TIPSMSG_TITLE_FIELD.has_default_value = false
TIPSMSG_TITLE_FIELD.default_value = ""
TIPSMSG_TITLE_FIELD.type = 9
TIPSMSG_TITLE_FIELD.cpp_type = 9

TIPSMSG_CONTENT_FIELD.name = "content"
TIPSMSG_CONTENT_FIELD.full_name = ".TipsMsg.content"
TIPSMSG_CONTENT_FIELD.number = 3
TIPSMSG_CONTENT_FIELD.index = 2
TIPSMSG_CONTENT_FIELD.label = 1
TIPSMSG_CONTENT_FIELD.has_default_value = false
TIPSMSG_CONTENT_FIELD.default_value = ""
TIPSMSG_CONTENT_FIELD.type = 9
TIPSMSG_CONTENT_FIELD.cpp_type = 9

TIPSMSG.name = "TipsMsg"
TIPSMSG.full_name = ".TipsMsg"
TIPSMSG.nested_types = {}
TIPSMSG.enum_types = {}
TIPSMSG.fields = {TIPSMSG_ID_FIELD, TIPSMSG_TITLE_FIELD, TIPSMSG_CONTENT_FIELD}
TIPSMSG.is_extendable = false
TIPSMSG.extensions = {}
READREQUEST_ID_FIELD.name = "id"
READREQUEST_ID_FIELD.full_name = ".ReadRequest.id"
READREQUEST_ID_FIELD.number = 1
READREQUEST_ID_FIELD.index = 0
READREQUEST_ID_FIELD.label = 1
READREQUEST_ID_FIELD.has_default_value = false
READREQUEST_ID_FIELD.default_value = ""
READREQUEST_ID_FIELD.type = 9
READREQUEST_ID_FIELD.cpp_type = 9

READREQUEST_ANNOUNCETYPE_FIELD.name = "announceType"
READREQUEST_ANNOUNCETYPE_FIELD.full_name = ".ReadRequest.announceType"
READREQUEST_ANNOUNCETYPE_FIELD.number = 2
READREQUEST_ANNOUNCETYPE_FIELD.index = 1
READREQUEST_ANNOUNCETYPE_FIELD.label = 2
READREQUEST_ANNOUNCETYPE_FIELD.has_default_value = false
READREQUEST_ANNOUNCETYPE_FIELD.default_value = nil
READREQUEST_ANNOUNCETYPE_FIELD.enum_type = ANNOUNCETYPE
READREQUEST_ANNOUNCETYPE_FIELD.type = 14
READREQUEST_ANNOUNCETYPE_FIELD.cpp_type = 8

READREQUEST.name = "ReadRequest"
READREQUEST.full_name = ".ReadRequest"
READREQUEST.nested_types = {}
READREQUEST.enum_types = {}
READREQUEST.fields = {READREQUEST_ID_FIELD, READREQUEST_ANNOUNCETYPE_FIELD}
READREQUEST.is_extendable = false
READREQUEST.extensions = {}
ANNOUNCEREQUEST_TYPE_FIELD.name = "type"
ANNOUNCEREQUEST_TYPE_FIELD.full_name = ".AnnounceRequest.type"
ANNOUNCEREQUEST_TYPE_FIELD.number = 1
ANNOUNCEREQUEST_TYPE_FIELD.index = 0
ANNOUNCEREQUEST_TYPE_FIELD.label = 2
ANNOUNCEREQUEST_TYPE_FIELD.has_default_value = false
ANNOUNCEREQUEST_TYPE_FIELD.default_value = nil
ANNOUNCEREQUEST_TYPE_FIELD.enum_type = REQUESTTYPE
ANNOUNCEREQUEST_TYPE_FIELD.type = 14
ANNOUNCEREQUEST_TYPE_FIELD.cpp_type = 8

ANNOUNCEREQUEST_ID_FIELD.name = "id"
ANNOUNCEREQUEST_ID_FIELD.full_name = ".AnnounceRequest.id"
ANNOUNCEREQUEST_ID_FIELD.number = 2
ANNOUNCEREQUEST_ID_FIELD.index = 1
ANNOUNCEREQUEST_ID_FIELD.label = 3
ANNOUNCEREQUEST_ID_FIELD.has_default_value = false
ANNOUNCEREQUEST_ID_FIELD.default_value = {}
ANNOUNCEREQUEST_ID_FIELD.type = 9
ANNOUNCEREQUEST_ID_FIELD.cpp_type = 9

ANNOUNCEREQUEST_CUSTOMMSG_FIELD.name = "customMsg"
ANNOUNCEREQUEST_CUSTOMMSG_FIELD.full_name = ".AnnounceRequest.customMsg"
ANNOUNCEREQUEST_CUSTOMMSG_FIELD.number = 3
ANNOUNCEREQUEST_CUSTOMMSG_FIELD.index = 2
ANNOUNCEREQUEST_CUSTOMMSG_FIELD.label = 1
ANNOUNCEREQUEST_CUSTOMMSG_FIELD.has_default_value = false
ANNOUNCEREQUEST_CUSTOMMSG_FIELD.default_value = nil
ANNOUNCEREQUEST_CUSTOMMSG_FIELD.message_type = CUSTOMMSG
ANNOUNCEREQUEST_CUSTOMMSG_FIELD.type = 11
ANNOUNCEREQUEST_CUSTOMMSG_FIELD.cpp_type = 10

ANNOUNCEREQUEST_READREQUEST_FIELD.name = "readRequest"
ANNOUNCEREQUEST_READREQUEST_FIELD.full_name = ".AnnounceRequest.readRequest"
ANNOUNCEREQUEST_READREQUEST_FIELD.number = 4
ANNOUNCEREQUEST_READREQUEST_FIELD.index = 3
ANNOUNCEREQUEST_READREQUEST_FIELD.label = 3
ANNOUNCEREQUEST_READREQUEST_FIELD.has_default_value = false
ANNOUNCEREQUEST_READREQUEST_FIELD.default_value = {}
ANNOUNCEREQUEST_READREQUEST_FIELD.message_type = READREQUEST
ANNOUNCEREQUEST_READREQUEST_FIELD.type = 11
ANNOUNCEREQUEST_READREQUEST_FIELD.cpp_type = 10

ANNOUNCEREQUEST.name = "AnnounceRequest"
ANNOUNCEREQUEST.full_name = ".AnnounceRequest"
ANNOUNCEREQUEST.nested_types = {}
ANNOUNCEREQUEST.enum_types = {}
ANNOUNCEREQUEST.fields = {ANNOUNCEREQUEST_TYPE_FIELD, ANNOUNCEREQUEST_ID_FIELD, ANNOUNCEREQUEST_CUSTOMMSG_FIELD, ANNOUNCEREQUEST_READREQUEST_FIELD}
ANNOUNCEREQUEST.is_extendable = false
ANNOUNCEREQUEST.extensions = {}
ANNOUNCEPUSHRESPONSE_ROLLINGMSG_FIELD.name = "rollingMsg"
ANNOUNCEPUSHRESPONSE_ROLLINGMSG_FIELD.full_name = ".AnnouncePushResponse.rollingMsg"
ANNOUNCEPUSHRESPONSE_ROLLINGMSG_FIELD.number = 1
ANNOUNCEPUSHRESPONSE_ROLLINGMSG_FIELD.index = 0
ANNOUNCEPUSHRESPONSE_ROLLINGMSG_FIELD.label = 3
ANNOUNCEPUSHRESPONSE_ROLLINGMSG_FIELD.has_default_value = false
ANNOUNCEPUSHRESPONSE_ROLLINGMSG_FIELD.default_value = {}
ANNOUNCEPUSHRESPONSE_ROLLINGMSG_FIELD.message_type = ROLLINGMSG
ANNOUNCEPUSHRESPONSE_ROLLINGMSG_FIELD.type = 11
ANNOUNCEPUSHRESPONSE_ROLLINGMSG_FIELD.cpp_type = 10

ANNOUNCEPUSHRESPONSE_MAILMSG_FIELD.name = "mailMsg"
ANNOUNCEPUSHRESPONSE_MAILMSG_FIELD.full_name = ".AnnouncePushResponse.mailMsg"
ANNOUNCEPUSHRESPONSE_MAILMSG_FIELD.number = 2
ANNOUNCEPUSHRESPONSE_MAILMSG_FIELD.index = 1
ANNOUNCEPUSHRESPONSE_MAILMSG_FIELD.label = 3
ANNOUNCEPUSHRESPONSE_MAILMSG_FIELD.has_default_value = false
ANNOUNCEPUSHRESPONSE_MAILMSG_FIELD.default_value = {}
ANNOUNCEPUSHRESPONSE_MAILMSG_FIELD.message_type = MAILMSG
ANNOUNCEPUSHRESPONSE_MAILMSG_FIELD.type = 11
ANNOUNCEPUSHRESPONSE_MAILMSG_FIELD.cpp_type = 10

ANNOUNCEPUSHRESPONSE_CUSTOMMSG_FIELD.name = "customMsg"
ANNOUNCEPUSHRESPONSE_CUSTOMMSG_FIELD.full_name = ".AnnouncePushResponse.customMsg"
ANNOUNCEPUSHRESPONSE_CUSTOMMSG_FIELD.number = 3
ANNOUNCEPUSHRESPONSE_CUSTOMMSG_FIELD.index = 2
ANNOUNCEPUSHRESPONSE_CUSTOMMSG_FIELD.label = 3
ANNOUNCEPUSHRESPONSE_CUSTOMMSG_FIELD.has_default_value = false
ANNOUNCEPUSHRESPONSE_CUSTOMMSG_FIELD.default_value = {}
ANNOUNCEPUSHRESPONSE_CUSTOMMSG_FIELD.message_type = CUSTOMMSG
ANNOUNCEPUSHRESPONSE_CUSTOMMSG_FIELD.type = 11
ANNOUNCEPUSHRESPONSE_CUSTOMMSG_FIELD.cpp_type = 10

ANNOUNCEPUSHRESPONSE_TIPSMSG_FIELD.name = "tipsMsg"
ANNOUNCEPUSHRESPONSE_TIPSMSG_FIELD.full_name = ".AnnouncePushResponse.tipsMsg"
ANNOUNCEPUSHRESPONSE_TIPSMSG_FIELD.number = 4
ANNOUNCEPUSHRESPONSE_TIPSMSG_FIELD.index = 3
ANNOUNCEPUSHRESPONSE_TIPSMSG_FIELD.label = 3
ANNOUNCEPUSHRESPONSE_TIPSMSG_FIELD.has_default_value = false
ANNOUNCEPUSHRESPONSE_TIPSMSG_FIELD.default_value = {}
ANNOUNCEPUSHRESPONSE_TIPSMSG_FIELD.message_type = TIPSMSG
ANNOUNCEPUSHRESPONSE_TIPSMSG_FIELD.type = 11
ANNOUNCEPUSHRESPONSE_TIPSMSG_FIELD.cpp_type = 10

ANNOUNCEPUSHRESPONSE.name = "AnnouncePushResponse"
ANNOUNCEPUSHRESPONSE.full_name = ".AnnouncePushResponse"
ANNOUNCEPUSHRESPONSE.nested_types = {}
ANNOUNCEPUSHRESPONSE.enum_types = {}
ANNOUNCEPUSHRESPONSE.fields = {ANNOUNCEPUSHRESPONSE_ROLLINGMSG_FIELD, ANNOUNCEPUSHRESPONSE_MAILMSG_FIELD, ANNOUNCEPUSHRESPONSE_CUSTOMMSG_FIELD, ANNOUNCEPUSHRESPONSE_TIPSMSG_FIELD}
ANNOUNCEPUSHRESPONSE.is_extendable = false
ANNOUNCEPUSHRESPONSE.extensions = {}
ANNOUNCERESPONSE_TYPE_FIELD.name = "type"
ANNOUNCERESPONSE_TYPE_FIELD.full_name = ".AnnounceResponse.type"
ANNOUNCERESPONSE_TYPE_FIELD.number = 1
ANNOUNCERESPONSE_TYPE_FIELD.index = 0
ANNOUNCERESPONSE_TYPE_FIELD.label = 2
ANNOUNCERESPONSE_TYPE_FIELD.has_default_value = false
ANNOUNCERESPONSE_TYPE_FIELD.default_value = nil
ANNOUNCERESPONSE_TYPE_FIELD.enum_type = REQUESTTYPE
ANNOUNCERESPONSE_TYPE_FIELD.type = 14
ANNOUNCERESPONSE_TYPE_FIELD.cpp_type = 8

ANNOUNCERESPONSE_ISSUCCESS_FIELD.name = "isSuccess"
ANNOUNCERESPONSE_ISSUCCESS_FIELD.full_name = ".AnnounceResponse.isSuccess"
ANNOUNCERESPONSE_ISSUCCESS_FIELD.number = 2
ANNOUNCERESPONSE_ISSUCCESS_FIELD.index = 1
ANNOUNCERESPONSE_ISSUCCESS_FIELD.label = 1
ANNOUNCERESPONSE_ISSUCCESS_FIELD.has_default_value = false
ANNOUNCERESPONSE_ISSUCCESS_FIELD.default_value = false
ANNOUNCERESPONSE_ISSUCCESS_FIELD.type = 8
ANNOUNCERESPONSE_ISSUCCESS_FIELD.cpp_type = 7

ANNOUNCERESPONSE_TIPS_FIELD.name = "tips"
ANNOUNCERESPONSE_TIPS_FIELD.full_name = ".AnnounceResponse.tips"
ANNOUNCERESPONSE_TIPS_FIELD.number = 3
ANNOUNCERESPONSE_TIPS_FIELD.index = 2
ANNOUNCERESPONSE_TIPS_FIELD.label = 1
ANNOUNCERESPONSE_TIPS_FIELD.has_default_value = false
ANNOUNCERESPONSE_TIPS_FIELD.default_value = ""
ANNOUNCERESPONSE_TIPS_FIELD.type = 9
ANNOUNCERESPONSE_TIPS_FIELD.cpp_type = 9

ANNOUNCERESPONSE_PUSHRESPONSE_FIELD.name = "pushResponse"
ANNOUNCERESPONSE_PUSHRESPONSE_FIELD.full_name = ".AnnounceResponse.pushResponse"
ANNOUNCERESPONSE_PUSHRESPONSE_FIELD.number = 4
ANNOUNCERESPONSE_PUSHRESPONSE_FIELD.index = 3
ANNOUNCERESPONSE_PUSHRESPONSE_FIELD.label = 1
ANNOUNCERESPONSE_PUSHRESPONSE_FIELD.has_default_value = false
ANNOUNCERESPONSE_PUSHRESPONSE_FIELD.default_value = nil
ANNOUNCERESPONSE_PUSHRESPONSE_FIELD.message_type = ANNOUNCEPUSHRESPONSE
ANNOUNCERESPONSE_PUSHRESPONSE_FIELD.type = 11
ANNOUNCERESPONSE_PUSHRESPONSE_FIELD.cpp_type = 10

ANNOUNCERESPONSE.name = "AnnounceResponse"
ANNOUNCERESPONSE.full_name = ".AnnounceResponse"
ANNOUNCERESPONSE.nested_types = {}
ANNOUNCERESPONSE.enum_types = {}
ANNOUNCERESPONSE.fields = {ANNOUNCERESPONSE_TYPE_FIELD, ANNOUNCERESPONSE_ISSUCCESS_FIELD, ANNOUNCERESPONSE_TIPS_FIELD, ANNOUNCERESPONSE_PUSHRESPONSE_FIELD}
ANNOUNCERESPONSE.is_extendable = false
ANNOUNCERESPONSE.extensions = {}

Activity = 2
AnnouncePushResponse = protobuf.Message(ANNOUNCEPUSHRESPONSE)
AnnounceRequest = protobuf.Message(ANNOUNCEREQUEST)
AnnounceResponse = protobuf.Message(ANNOUNCERESPONSE)
Attachment = protobuf.Message(ATTACHMENT)
Charge = 2
Common = 5
CountDown = 3
Custom = 2
CustomMsg = protobuf.Message(CUSTOMMSG)
Give = 3
Item = protobuf.Message(ITEM)
Mail = 1
MailMsg = protobuf.Message(MAILMSG)
Normal = 1
Other = 6
Prizes = 4
Push_Cancel = 8
Push_Common = 7
Push_Custom = 6
Push_MailMsg = 4
Push_RollingMsg = 3
Push_TipsMsg = 9
ReadRequest = protobuf.Message(READREQUEST)
Request_Attach_Take = 2
Request_Custom = 5
Request_Read = 1
Rolling = 3
RollingMsg = protobuf.Message(ROLLINGMSG)
System = 1
Tips = 4
TipsMsg = protobuf.Message(TIPSMSG)

