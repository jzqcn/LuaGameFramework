-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf"
module('SDKVerify_pb')


local ESDKVERIFYRESULTTYPE = protobuf.EnumDescriptor();
local ESDKVERIFYRESULTTYPE_SUCCESS_ENUM = protobuf.EnumValueDescriptor();
local ESDKVERIFYRESULTTYPE_FAIL_ENUM = protobuf.EnumValueDescriptor();
local ACCOUNTINFO = protobuf.Descriptor();
local ACCOUNTINFO_ACCOUNTID_FIELD = protobuf.FieldDescriptor();
local ACCOUNTINFO_PASSWORD_FIELD = protobuf.FieldDescriptor();
local ACCOUNTINFO_OPENACCOUNTID_FIELD = protobuf.FieldDescriptor();
local ACCOUNTINFO_LOGTYPE_FIELD = protobuf.FieldDescriptor();
local SDKVERIFYREQUEST = protobuf.Descriptor();
local SDKVERIFYREQUEST_SDKTYPE_FIELD = protobuf.FieldDescriptor();
local SDKVERIFYREQUEST_VERIFYINFO_FIELD = protobuf.FieldDescriptor();
local SDKVERIFYREQUEST_ACCOUNTINFO_FIELD = protobuf.FieldDescriptor();
local SDKVERIFYRESPONSE = protobuf.Descriptor();
local SDKVERIFYRESPONSE_RESULTTYPE_FIELD = protobuf.FieldDescriptor();
local SDKVERIFYRESPONSE_MSG_FIELD = protobuf.FieldDescriptor();
local SDKVERIFYRESPONSE_ACCOUNTINFO_FIELD = protobuf.FieldDescriptor();

ESDKVERIFYRESULTTYPE_SUCCESS_ENUM.name = "SUCCESS"
ESDKVERIFYRESULTTYPE_SUCCESS_ENUM.index = 0
ESDKVERIFYRESULTTYPE_SUCCESS_ENUM.number = 1
ESDKVERIFYRESULTTYPE_FAIL_ENUM.name = "FAIL"
ESDKVERIFYRESULTTYPE_FAIL_ENUM.index = 1
ESDKVERIFYRESULTTYPE_FAIL_ENUM.number = 2
ESDKVERIFYRESULTTYPE.name = "eSDKVerifyResultType"
ESDKVERIFYRESULTTYPE.full_name = ".eSDKVerifyResultType"
ESDKVERIFYRESULTTYPE.values = {ESDKVERIFYRESULTTYPE_SUCCESS_ENUM,ESDKVERIFYRESULTTYPE_FAIL_ENUM}
ACCOUNTINFO_ACCOUNTID_FIELD.name = "accountId"
ACCOUNTINFO_ACCOUNTID_FIELD.full_name = ".AccountInfo.accountId"
ACCOUNTINFO_ACCOUNTID_FIELD.number = 1
ACCOUNTINFO_ACCOUNTID_FIELD.index = 0
ACCOUNTINFO_ACCOUNTID_FIELD.label = 1
ACCOUNTINFO_ACCOUNTID_FIELD.has_default_value = false
ACCOUNTINFO_ACCOUNTID_FIELD.default_value = ""
ACCOUNTINFO_ACCOUNTID_FIELD.type = 9
ACCOUNTINFO_ACCOUNTID_FIELD.cpp_type = 9

ACCOUNTINFO_PASSWORD_FIELD.name = "password"
ACCOUNTINFO_PASSWORD_FIELD.full_name = ".AccountInfo.password"
ACCOUNTINFO_PASSWORD_FIELD.number = 2
ACCOUNTINFO_PASSWORD_FIELD.index = 1
ACCOUNTINFO_PASSWORD_FIELD.label = 1
ACCOUNTINFO_PASSWORD_FIELD.has_default_value = false
ACCOUNTINFO_PASSWORD_FIELD.default_value = ""
ACCOUNTINFO_PASSWORD_FIELD.type = 9
ACCOUNTINFO_PASSWORD_FIELD.cpp_type = 9

ACCOUNTINFO_OPENACCOUNTID_FIELD.name = "openAccountId"
ACCOUNTINFO_OPENACCOUNTID_FIELD.full_name = ".AccountInfo.openAccountId"
ACCOUNTINFO_OPENACCOUNTID_FIELD.number = 3
ACCOUNTINFO_OPENACCOUNTID_FIELD.index = 2
ACCOUNTINFO_OPENACCOUNTID_FIELD.label = 1
ACCOUNTINFO_OPENACCOUNTID_FIELD.has_default_value = false
ACCOUNTINFO_OPENACCOUNTID_FIELD.default_value = ""
ACCOUNTINFO_OPENACCOUNTID_FIELD.type = 9
ACCOUNTINFO_OPENACCOUNTID_FIELD.cpp_type = 9

ACCOUNTINFO_LOGTYPE_FIELD.name = "logType"
ACCOUNTINFO_LOGTYPE_FIELD.full_name = ".AccountInfo.logType"
ACCOUNTINFO_LOGTYPE_FIELD.number = 4
ACCOUNTINFO_LOGTYPE_FIELD.index = 3
ACCOUNTINFO_LOGTYPE_FIELD.label = 1
ACCOUNTINFO_LOGTYPE_FIELD.has_default_value = false
ACCOUNTINFO_LOGTYPE_FIELD.default_value = 0
ACCOUNTINFO_LOGTYPE_FIELD.type = 5
ACCOUNTINFO_LOGTYPE_FIELD.cpp_type = 1

ACCOUNTINFO.name = "AccountInfo"
ACCOUNTINFO.full_name = ".AccountInfo"
ACCOUNTINFO.nested_types = {}
ACCOUNTINFO.enum_types = {}
ACCOUNTINFO.fields = {ACCOUNTINFO_ACCOUNTID_FIELD, ACCOUNTINFO_PASSWORD_FIELD, ACCOUNTINFO_OPENACCOUNTID_FIELD, ACCOUNTINFO_LOGTYPE_FIELD}
ACCOUNTINFO.is_extendable = false
ACCOUNTINFO.extensions = {}
SDKVERIFYREQUEST_SDKTYPE_FIELD.name = "sdkType"
SDKVERIFYREQUEST_SDKTYPE_FIELD.full_name = ".SDKVerifyRequest.sdkType"
SDKVERIFYREQUEST_SDKTYPE_FIELD.number = 1
SDKVERIFYREQUEST_SDKTYPE_FIELD.index = 0
SDKVERIFYREQUEST_SDKTYPE_FIELD.label = 2
SDKVERIFYREQUEST_SDKTYPE_FIELD.has_default_value = false
SDKVERIFYREQUEST_SDKTYPE_FIELD.default_value = 0
SDKVERIFYREQUEST_SDKTYPE_FIELD.type = 5
SDKVERIFYREQUEST_SDKTYPE_FIELD.cpp_type = 1

SDKVERIFYREQUEST_VERIFYINFO_FIELD.name = "verifyInfo"
SDKVERIFYREQUEST_VERIFYINFO_FIELD.full_name = ".SDKVerifyRequest.verifyInfo"
SDKVERIFYREQUEST_VERIFYINFO_FIELD.number = 2
SDKVERIFYREQUEST_VERIFYINFO_FIELD.index = 1
SDKVERIFYREQUEST_VERIFYINFO_FIELD.label = 1
SDKVERIFYREQUEST_VERIFYINFO_FIELD.has_default_value = false
SDKVERIFYREQUEST_VERIFYINFO_FIELD.default_value = ""
SDKVERIFYREQUEST_VERIFYINFO_FIELD.type = 9
SDKVERIFYREQUEST_VERIFYINFO_FIELD.cpp_type = 9

SDKVERIFYREQUEST_ACCOUNTINFO_FIELD.name = "accountInfo"
SDKVERIFYREQUEST_ACCOUNTINFO_FIELD.full_name = ".SDKVerifyRequest.accountInfo"
SDKVERIFYREQUEST_ACCOUNTINFO_FIELD.number = 3
SDKVERIFYREQUEST_ACCOUNTINFO_FIELD.index = 2
SDKVERIFYREQUEST_ACCOUNTINFO_FIELD.label = 2
SDKVERIFYREQUEST_ACCOUNTINFO_FIELD.has_default_value = false
SDKVERIFYREQUEST_ACCOUNTINFO_FIELD.default_value = nil
SDKVERIFYREQUEST_ACCOUNTINFO_FIELD.message_type = ACCOUNTINFO
SDKVERIFYREQUEST_ACCOUNTINFO_FIELD.type = 11
SDKVERIFYREQUEST_ACCOUNTINFO_FIELD.cpp_type = 10

SDKVERIFYREQUEST.name = "SDKVerifyRequest"
SDKVERIFYREQUEST.full_name = ".SDKVerifyRequest"
SDKVERIFYREQUEST.nested_types = {}
SDKVERIFYREQUEST.enum_types = {}
SDKVERIFYREQUEST.fields = {SDKVERIFYREQUEST_SDKTYPE_FIELD, SDKVERIFYREQUEST_VERIFYINFO_FIELD, SDKVERIFYREQUEST_ACCOUNTINFO_FIELD}
SDKVERIFYREQUEST.is_extendable = false
SDKVERIFYREQUEST.extensions = {}
SDKVERIFYRESPONSE_RESULTTYPE_FIELD.name = "resultType"
SDKVERIFYRESPONSE_RESULTTYPE_FIELD.full_name = ".SDKVerifyResponse.resultType"
SDKVERIFYRESPONSE_RESULTTYPE_FIELD.number = 1
SDKVERIFYRESPONSE_RESULTTYPE_FIELD.index = 0
SDKVERIFYRESPONSE_RESULTTYPE_FIELD.label = 2
SDKVERIFYRESPONSE_RESULTTYPE_FIELD.has_default_value = false
SDKVERIFYRESPONSE_RESULTTYPE_FIELD.default_value = nil
SDKVERIFYRESPONSE_RESULTTYPE_FIELD.enum_type = ESDKVERIFYRESULTTYPE
SDKVERIFYRESPONSE_RESULTTYPE_FIELD.type = 14
SDKVERIFYRESPONSE_RESULTTYPE_FIELD.cpp_type = 8

SDKVERIFYRESPONSE_MSG_FIELD.name = "msg"
SDKVERIFYRESPONSE_MSG_FIELD.full_name = ".SDKVerifyResponse.msg"
SDKVERIFYRESPONSE_MSG_FIELD.number = 2
SDKVERIFYRESPONSE_MSG_FIELD.index = 1
SDKVERIFYRESPONSE_MSG_FIELD.label = 2
SDKVERIFYRESPONSE_MSG_FIELD.has_default_value = false
SDKVERIFYRESPONSE_MSG_FIELD.default_value = ""
SDKVERIFYRESPONSE_MSG_FIELD.type = 9
SDKVERIFYRESPONSE_MSG_FIELD.cpp_type = 9

SDKVERIFYRESPONSE_ACCOUNTINFO_FIELD.name = "accountInfo"
SDKVERIFYRESPONSE_ACCOUNTINFO_FIELD.full_name = ".SDKVerifyResponse.accountInfo"
SDKVERIFYRESPONSE_ACCOUNTINFO_FIELD.number = 4
SDKVERIFYRESPONSE_ACCOUNTINFO_FIELD.index = 2
SDKVERIFYRESPONSE_ACCOUNTINFO_FIELD.label = 1
SDKVERIFYRESPONSE_ACCOUNTINFO_FIELD.has_default_value = false
SDKVERIFYRESPONSE_ACCOUNTINFO_FIELD.default_value = nil
SDKVERIFYRESPONSE_ACCOUNTINFO_FIELD.message_type = ACCOUNTINFO
SDKVERIFYRESPONSE_ACCOUNTINFO_FIELD.type = 11
SDKVERIFYRESPONSE_ACCOUNTINFO_FIELD.cpp_type = 10

SDKVERIFYRESPONSE.name = "SDKVerifyResponse"
SDKVERIFYRESPONSE.full_name = ".SDKVerifyResponse"
SDKVERIFYRESPONSE.nested_types = {}
SDKVERIFYRESPONSE.enum_types = {}
SDKVERIFYRESPONSE.fields = {SDKVERIFYRESPONSE_RESULTTYPE_FIELD, SDKVERIFYRESPONSE_MSG_FIELD, SDKVERIFYRESPONSE_ACCOUNTINFO_FIELD}
SDKVERIFYRESPONSE.is_extendable = false
SDKVERIFYRESPONSE.extensions = {}

AccountInfo = protobuf.Message(ACCOUNTINFO)
FAIL = 2
SDKVerifyRequest = protobuf.Message(SDKVERIFYREQUEST)
SDKVerifyResponse = protobuf.Message(SDKVERIFYRESPONSE)
SUCCESS = 1

