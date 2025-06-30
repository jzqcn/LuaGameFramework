local logger = require 'Log.logger'

--[[----------------------------------------------------------------------------

	1、支持DEBUG、INFO、WARN、ERROR、FATAL五种类型，等级从低到高

	2、category('misc', 'DEBUG')，创建log4misc，并定义最低显示等级，默认为WARN
	
	3、用法：log4misc:debug('xxx')、log4misc:info('%s-%s', 'xx', 'yy')
	
--]]----------------------------------------------------------------------------

logger.category('cocos2d',	'WARN')
logger.category('system',	'WARN')
logger.category('net',		'WARN')
logger.category('http',		'WARN')
logger.category('event',	'WARN')
logger.category('ui',		'WARN')
logger.category('misc',		'WARN')
logger.category('music',	'WARN')
logger.category('temp',		'DEBUG')
logger.category('t',		'DEBUG')	--as temp

logger.category('login',	'WARN')
logger.category('map',		'WARN')
logger.category('battle',	'WARN')
logger.category('model',	'WARN')
logger.category('patch',	'WARN')

logd = bind(log4temp.debug, log4temp)
logw = bind(log4temp.warn, log4temp)

