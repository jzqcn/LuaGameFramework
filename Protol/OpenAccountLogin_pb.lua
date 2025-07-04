-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf.protobuf"
local COMMON_PB = require("Common_pb")
local ACCOUNTLOGIN_PB = require("AccountLogin_pb")
module('OpenAccountLogin_pb')


local OPALOGINREQUEST = protobuf.Descriptor();
local OPALOGINREQUEST_PLATFORMTYPE_FIELD = protobuf.FieldDescriptor();
local OPALOGINREQUEST_CODE_FIELD = protobuf.FieldDescriptor();
local OPALOGINREQUEST_ACCESS_TOKEN_FIELD = protobuf.FieldDescriptor();
local OPALOGINREQUEST_OPENID_FIELD = protobuf.FieldDescriptor();
local OPALOGINREQUEST_REFRESH_TOKEN_FIELD = protobuf.FieldDescriptor();
local OPALOGINRESPONSE = protobuf.Descriptor();
local OPALOGINRESPONSE_PLATFORMTYPE_FIELD = protobuf.FieldDescriptor();
local OPALOGINRESPONSE_RESULTTYPE_FIELD = protobuf.FieldDescriptor();
local OPALOGINRESPONSE_ERROR_FIELD = protobuf.FieldDescriptor();
local OPALOGINRESPONSE_ACCESS_TOKEN_FIELD = protobuf.FieldDescriptor();
local OPALOGINRESPONSE_OPENID_FIELD = protobuf.FieldDescriptor();
local OPALOGINRESPONSE_REFRESH_TOKEN_FIELD = protobuf.FieldDescriptor();
local OPALOGINRESPONSE_ACCOUNTINFO_FIELD = protobuf.FieldDescriptor();

OPALOGINREQUEST_PLATFORMTYPE_FIELD.name = "platformType"
OPALOGINREQUEST_PLATFORMTYPE_FIELD.full_name = ".OpaLoginRequest.platformType"
OPALOGINREQUEST_PLATFORMTYPE_FIELD.number = 1
OPALOGINREQUEST_PLATFORMTYPE_FIELD.index = 0
OPALOGINREQUEST_PLATFORMTYPE_FIELD.label = 2
OPALOGINREQUEST_PLATFORMTYPE_FIELD.has_default_value = false
OPALOGINREQUEST_PLATFORMTYPE_FIELD.default_value = nil
OPALOGINREQUEST_PLATFORMTYPE_FIELD.enum_type = COMMON_PB.PLATFORMTYPE
OPALOGINREQUEST_PLATFORMTYPE_FIELD.type = 14
OPALOGINREQUEST_PLATFORMTYPE_FIELD.cpp_type = 8

OPALOGINREQUEST_CODE_FIELD.name = "code"
OPALOGINREQUEST_CODE_FIELD.full_name = ".OpaLoginRequest.code"
OPALOGINREQUEST_CODE_FIELD.number = 2
OPALOGINREQUEST_CODE_FIELD.index = 1
OPALOGINREQUEST_CODE_FIELD.label = 1
OPALOGINREQUEST_CODE_FIELD.has_default_value = false
OPALOGINREQUEST_CODE_FIELD.default_value = ""
OPALOGINREQUEST_CODE_FIELD.type = 9
OPALOGINREQUEST_CODE_FIELD.cpp_type = 9

OPALOGINREQUEST_ACCESS_TOKEN_FIELD.name = "access_token"
OPALOGINREQUEST_ACCESS_TOKEN_FIELD.full_name = ".OpaLoginRequest.access_token"
OPALOGINREQUEST_ACCESS_TOKEN_FIELD.number = 3
OPALOGINREQUEST_ACCESS_TOKEN_FIELD.index = 2
OPALOGINREQUEST_ACCESS_TOKEN_FIELD.label = 1
OPALOGINREQUEST_ACCESS_TOKEN_FIELD.has_default_value = false
OPALOGINREQUEST_ACCESS_TOKEN_FIELD.default_value = ""
OPALOGINREQUEST_ACCESS_TOKEN_FIELD.type = 9
OPALOGINREQUEST_ACCESS_TOKEN_FIELD.cpp_type = 9

OPALOGINREQUEST_OPENID_FIELD.name = "openid"
OPALOGINREQUEST_OPENID_FIELD.full_name = ".OpaLoginRequest.openid"
OPALOGINREQUEST_OPENID_FIELD.number = 4
OPALOGINREQUEST_OPENID_FIELD.index = 3
OPALOGINREQUEST_OPENID_FIELD.label = 1
OPALOGINREQUEST_OPENID_FIELD.has_default_value = false
OPALOGINREQUEST_OPENID_FIELD.default_value = ""
OPALOGINREQUEST_OPENID_FIELD.type = 9
OPALOGINREQUEST_OPENID_FIELD.cpp_type = 9

OPALOGINREQUEST_REFRESH_TOKEN_FIELD.name = "refresh_token"
OPALOGINREQUEST_REFRESH_TOKEN_FIELD.full_name = ".OpaLoginRequest.refresh_token"
OPALOGINREQUEST_REFRESH_TOKEN_FIELD.number = 5
OPALOGINREQUEST_REFRESH_TOKEN_FIELD.index = 4
OPALOGINREQUEST_REFRESH_TOKEN_FIELD.label = 1
OPALOGINREQUEST_REFRESH_TOKEN_FIELD.has_default_value = false
OPALOGINREQUEST_REFRESH_TOKEN_FIELD.default_value = ""
OPALOGINREQUEST_REFRESH_TOKEN_FIELD.type = 9
OPALOGINREQUEST_REFRESH_TOKEN_FIELD.cpp_type = 9

OPALOGINREQUEST.name = "OpaLoginRequest"
OPALOGINREQUEST.full_name = ".OpaLoginRequest"
OPALOGINREQUEST.nested_types = {}
OPALOGINREQUEST.enum_types = {}
OPALOGINREQUEST.fields = {OPALOGINREQUEST_PLATFORMTYPE_FIELD, OPALOGINREQUEST_CODE_FIELD, OPALOGINREQUEST_ACCESS_TOKEN_FIELD, OPALOGINREQUEST_OPENID_FIELD, OPALOGINREQUEST_REFRESH_TOKEN_FIELD}
OPALOGINREQUEST.is_extendable = false
OPALOGINREQUEST.extensions = {}
OPALOGINRESPONSE_PLATFORMTYPE_FIELD.name = "platformType"
OPALOGINRESPONSE_PLATFORMTYPE_FIELD.full_name = ".OpaLoginResponse.platformType"
OPALOGINRESPONSE_PLATFORMTYPE_FIELD.number = 1
OPALOGINRESPONSE_PLATFORMTYPE_FIELD.index = 0
OPALOGINRESPONSE_PLATFORMTYPE_FIELD.label = 2
OPALOGINRESPONSE_PLATFORMTYPE_FIELD.has_default_value = false
OPALOGINRESPONSE_PLATFORMTYPE_FIELD.default_value = nil
OPALOGINRESPONSE_PLATFORMTYPE_FIELD.enum_type = COMMON_PB.PLATFORMTYPE
OPALOGINRESPONSE_PLATFORMTYPE_FIELD.type = 14
OPALOGINRESPONSE_PLATFORMTYPE_FIELD.cpp_type = 8

OPALOGINRESPONSE_RESULTTYPE_FIELD.name = "resultType"
OPALOGINRESPONSE_RESULTTYPE_FIELD.full_name = ".OpaLoginResponse.resultType"
OPALOGINRESPONSE_RESULTTYPE_FIELD.number = 2
OPALOGINRESPONSE_RESULTTYPE_FIELD.index = 1
OPALOGINRESPONSE_RESULTTYPE_FIELD.label = 2
OPALOGINRESPONSE_RESULTTYPE_FIELD.has_default_value = false
OPALOGINRESPONSE_RESULTTYPE_FIELD.default_value = nil
OPALOGINRESPONSE_RESULTTYPE_FIELD.enum_type = ACCOUNTLOGIN_PB.ELOGINRESULTTYPE
OPALOGINRESPONSE_RESULTTYPE_FIELD.type = 14
OPALOGINRESPONSE_RESULTTYPE_FIELD.cpp_type = 8

OPALOGINRESPONSE_ERROR_FIELD.name = "error"
OPALOGINRESPONSE_ERROR_FIELD.full_name = ".OpaLoginResponse.error"
OPALOGINRESPONSE_ERROR_FIELD.number = 3
OPALOGINRESPONSE_ERROR_FIELD.index = 2
OPALOGINRESPONSE_ERROR_FIELD.label = 1
OPALOGINRESPONSE_ERROR_FIELD.has_default_value = false
OPALOGINRESPONSE_ERROR_FIELD.default_value = ""
OPALOGINRESPONSE_ERROR_FIELD.type = 9
OPALOGINRESPONSE_ERROR_FIELD.cpp_type = 9

OPALOGINRESPONSE_ACCESS_TOKEN_FIELD.name = "access_token"
OPALOGINRESPONSE_ACCESS_TOKEN_FIELD.full_name = ".OpaLoginResponse.access_token"
OPALOGINRESPONSE_ACCESS_TOKEN_FIELD.number = 4
OPALOGINRESPONSE_ACCESS_TOKEN_FIELD.index = 3
OPALOGINRESPONSE_ACCESS_TOKEN_FIELD.label = 1
OPALOGINRESPONSE_ACCESS_TOKEN_FIELD.has_default_value = false
OPALOGINRESPONSE_ACCESS_TOKEN_FIELD.default_value = ""
OPALOGINRESPONSE_ACCESS_TOKEN_FIELD.type = 9
OPALOGINRESPONSE_ACCESS_TOKEN_FIELD.cpp_type = 9

OPALOGINRESPONSE_OPENID_FIELD.name = "openid"
OPALOGINRESPONSE_OPENID_FIELD.full_name = ".OpaLoginResponse.openid"
OPALOGINRESPONSE_OPENID_FIELD.number = 5
OPALOGINRESPONSE_OPENID_FIELD.index = 4
OPALOGINRESPONSE_OPENID_FIELD.label = 1
OPALOGINRESPONSE_OPENID_FIELD.has_default_value = false
OPALOGINRESPONSE_OPENID_FIELD.default_value = ""
OPALOGINRESPONSE_OPENID_FIELD.type = 9
OPALOGINRESPONSE_OPENID_FIELD.cpp_type = 9

OPALOGINRESPONSE_REFRESH_TOKEN_FIELD.name = "refresh_token"
OPALOGINRESPONSE_REFRESH_TOKEN_FIELD.full_name = ".OpaLoginResponse.refresh_token"
OPALOGINRESPONSE_REFRESH_TOKEN_FIELD.number = 6
OPALOGINRESPONSE_REFRESH_TOKEN_FIELD.index = 5
OPALOGINRESPONSE_REFRESH_TOKEN_FIELD.label = 1
OPALOGINRESPONSE_REFRESH_TOKEN_FIELD.has_default_value = false
OPALOGINRESPONSE_REFRESH_TOKEN_FIELD.default_value = ""
OPALOGINRESPONSE_REFRESH_TOKEN_FIELD.type = 9
OPALOGINRESPONSE_REFRESH_TOKEN_FIELD.cpp_type = 9

OPALOGINRESPONSE_ACCOUNTINFO_FIELD.name = "accountInfo"
OPALOGINRESPONSE_ACCOUNTINFO_FIELD.full_name = ".OpaLoginResponse.accountInfo"
OPALOGINRESPONSE_ACCOUNTINFO_FIELD.number = 7
OPALOGINRESPONSE_ACCOUNTINFO_FIELD.index = 6
OPALOGINRESPONSE_ACCOUNTINFO_FIELD.label = 1
OPALOGINRESPONSE_ACCOUNTINFO_FIELD.has_default_value = false
OPALOGINRESPONSE_ACCOUNTINFO_FIELD.default_value = nil
OPALOGINRESPONSE_ACCOUNTINFO_FIELD.message_type = ACCOUNTLOGIN_PB.ACCOUNTINFO
OPALOGINRESPONSE_ACCOUNTINFO_FIELD.type = 11
OPALOGINRESPONSE_ACCOUNTINFO_FIELD.cpp_type = 10

OPALOGINRESPONSE.name = "OpaLoginResponse"
OPALOGINRESPONSE.full_name = ".OpaLoginResponse"
OPALOGINRESPONSE.nested_types = {}
OPALOGINRESPONSE.enum_types = {}
OPALOGINRESPONSE.fields = {OPALOGINRESPONSE_PLATFORMTYPE_FIELD, OPALOGINRESPONSE_RESULTTYPE_FIELD, OPALOGINRESPONSE_ERROR_FIELD, OPALOGINRESPONSE_ACCESS_TOKEN_FIELD, OPALOGINRESPONSE_OPENID_FIELD, OPALOGINRESPONSE_REFRESH_TOKEN_FIELD, OPALOGINRESPONSE_ACCOUNTINFO_FIELD}
OPALOGINRESPONSE.is_extendable = false
OPALOGINRESPONSE.extensions = {}

OpaLoginRequest = protobuf.Message(OPALOGINREQUEST)
OpaLoginResponse = protobuf.Message(OPALOGINRESPONSE)

