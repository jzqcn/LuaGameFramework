
local EARTH_RADIUS = 6378.137 --地球半径

--[[
 * 提供了百度坐标（BD09）、国测局坐标（火星坐标，GCJ02）、和WGS84坐标系之间的转换
 * 定义一些常量var x_PI = 3.14159265358979324 * 3000.0 / 180.0;var PI = 3.1415926535897932384626;var a = 6378245.0;var ee = 0.00669342162296594323;/**
 * 百度坐标系 (BD-09) 与 火星坐标系 (GCJ-02)的转换
 * 即 百度 转 谷歌、高德
 * @param bd_lon
 * @param bd_lat
 * @returns {*[]}
 --]]
function bd09togcj02(bd_lon, bd_lat)
    local x_pi = 3.14159265358979324 * 3000.0 / 180.0
    local x = bd_lon - 0.0065
    local y = bd_lat - 0.006
    local z = math.sqrt(x * x + y * y) - 0.00002 * math.sin(y * x_pi)
    local theta = math.atan2(y, x) - 0.000003 * math.cos(x * x_pi)
    local gg_lng = z * math.cos(theta)
    local gg_lat = z * math.sin(theta)
    return gg_lng, gg_lat
end
 
--[[
 * 火星坐标系 (GCJ-02) 与百度坐标系 (BD-09) 的转换
 * 即谷歌、高德 转 百度
 * @param lng
 * @param lat
 * @returns {*[]}
 --]]
function gcj02tobd09(lng, lat)
    local z = math.sqrt(lng * lng + lat * lat) + 0.00002 * math.sin(lat * x_PI)
    local theta = math.atan2(lat, lng) + 0.000003 * math.cos(lng * x_PI)
    local bd_lng = z * math.cos(theta) + 0.0065
    local bd_lat = z * math.sin(theta) + 0.006
    return bd_lng, bd_lat
end
 
--[[
 * WGS84转GCj02
 * @param lng
 * @param lat
 * @returns {*[]}
 --]]
function wgs84togcj02(lng, lat)
    if out_of_china(lng, lat) then
        return lng, lat
    else
        local dlat = transformlat(lng - 105.0, lat - 35.0)
        local dlng = transformlng(lng - 105.0, lat - 35.0)
        local radlat = lat / 180.0 * PI
        local magic = math.sin(radlat)
        magic = 1 - ee * magic * magic
        local sqrtmagic = math.sqrt(magic)
        dlat = (dlat * 180.0) / ((a * (1 - ee)) / (magic * sqrtmagic) * PI)
        dlng = (dlng * 180.0) / (a / sqrtmagic * math.cos(radlat) * PI)
        local mglat = lat + dlat
        local mglng = lng + dlng
        return mglng, mglat
    end
end

--[[
 * GCJ02 转换为 WGS84
 * @param lng
 * @param lat
 * @returns {*[]}
 --]]
function gcj02towgs84(lng, lat) 
    if (out_of_china(lng, lat)) then
        return lng, lat
    else
        local dlat = transformlat(lng - 105.0, lat - 35.0)
        local dlng = transformlng(lng - 105.0, lat - 35.0)
        local radlat = lat / 180.0 * PI
        local magic = math.sin(radlat)
        magic = 1 - ee * magic * magic
        local sqrtmagic = math.sqrt(magic)
        dlat = (dlat * 180.0) / ((a * (1 - ee)) / (magic * sqrtmagic) * PI)
        dlng = (dlng * 180.0) / (a / sqrtmagic * math.cos(radlat) * PI)
        mglat = lat + dlat
        mglng = lng + dlng
        return lng * 2 - mglng, lat * 2 - mglat
    end
end

function transformlat(lng, lat)
    local ret = -100.0 + 2.0 * lng + 3.0 * lat + 0.2 * lat * lat + 0.1 * lng * lat + 0.2 * math.sqrt(math.abs(lng))
    ret = ret + (20.0 * math.sin(6.0 * lng * PI) + 20.0 * math.sin(2.0 * lng * PI)) * 2.0 / 3.0
    ret = ret + (20.0 * math.sin(lat * PI) + 40.0 * math.sin(lat / 3.0 * PI)) * 2.0 / 3.0
    ret = ret + (160.0 * math.sin(lat / 12.0 * PI) + 320 * math.sin(lat * PI / 30.0)) * 2.0 / 3.0
    return ret
end

function transformlng(lng, lat)
    local ret = 300.0 + lng + 2.0 * lat + 0.1 * lng * lng + 0.1 * lng * lat + 0.1 * math.sqrt(math.abs(lng))
    ret = ret + (20.0 * math.sin(6.0 * lng * PI) + 20.0 * math.sin(2.0 * lng * PI)) * 2.0 / 3.0
    ret = ret + (20.0 * math.sin(lng * PI) + 40.0 * math.sin(lng / 3.0 * PI)) * 2.0 / 3.0
    ret = ret + (150.0 * math.sin(lng / 12.0 * PI) + 300.0 * math.sin(lng / 30.0 * PI)) * 2.0 / 3.0
    return ret
end

--[[
 * 判断是否在国内，不在国内则不做偏移
 * @param lng
 * @param lat
 * @returns {boolean}
 --]]
function out_of_china(lng, lat)
    return (lng < 72.004 or lng > 137.8347) or ((lat < 0.8293 or lat > 55.8271) or false)
end

--根据经纬度计算距离
function getDisstance(longitude_1, latitude_1, longitude_2, latitude_2)
    local function rad(d)
        return d * math.pi / 180.0;
    end

    longitude_1 = tonumber(longitude_1)
    latitude_1 = tonumber(latitude_1)
    longitude_2 = tonumber(longitude_2)
    latitude_2 = tonumber(latitude_2)

    local radLat1 = rad(latitude_1)
    local radLat2 = rad(latitude_2)
    local a = radLat1 - radLat2
    local b = rad(longitude_1) - rad(longitude_2)

    local s = 2 * math.asin(math.sqrt(math.pow(math.sin(a/2), 2) + math.cos(radLat1)*math.cos(radLat2)*math.pow(math.sin(b/2), 2)))
    s = s * EARTH_RADIUS
    return s
end

--根据经纬度获取地理位置
function getPlayerAddress(longitude, latitude, callback)
    if not longitude or not latitude then
        callback("")
        -- log4misc:warn("[Coordinate::getPlayerAddress] longitude or latitude is nil")
        return
    end

    longitude = tostring(longitude)
    latitude = tostring(latitude)

    if longitude == "" or latitude == "" then
        callback("")
        -- log4misc:warn("[Coordinate::getPlayerAddress] longitude or latitude is nil")
        return
    end

    ui.mgr:open("Net/Connect")

    --百度逆地理编码 http://api.map.baidu.com/geocoder/v2/?callback=renderReverse&location=35.658651,139.745415&output=json&pois=0&ak=您的ak --GET请求
    --是否召回传入坐标周边的poi，0为不召回，1为召回。当值为1时，默认显示周边1000米内的poi。
    --coordtype 坐标的类型，目前支持的坐标类型包括：bd09ll（百度经纬度坐标）、bd09mc（百度米制坐标）、gcj02ll（国测局经纬度坐标，仅限中国）、wgs84ll（ GPS经纬度）
    local ak = "wW37nPUUn104ERRcFW72wovfKS3fSWby"
    local url = string.format("https://api.map.baidu.com/geocoder/v2/?callback=renderReverse&location=%s,%s&coordtype=wgs84ll&output=json&pois=0&extensions_poi=null&ak=%s", latitude, longitude, ak)
    local xhr = cc.XMLHttpRequest:new()

    url = string.gsub(url, " ", "")

    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open("GET", url)

    xhr:registerScriptHandler(function()
        ui.mgr:close("Net/Connect")

        log("xhr.readyState is:" .. xhr.readyState .. " xhr.status is:" .. xhr.status)
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            local data = tostring(xhr.response)
            if data then
                local _start = string.find(data, "%(")
                local _end = string.find(data, "%)")
                if _start and _end then
                    local str = string.sub(data, _start+1, _end-1)
                    local info = json.decode(str)
                    if info.status == 0 then
                        local result = info.result
                        local formatted_address = result.formatted_address
                        local addressComponent = result.addressComponent
                        local country = addressComponent.country --国
                        local province = addressComponent.province --省
                        local city = addressComponent.city --城市
                        local district = addressComponent.district --区
                        local street = addressComponent.street
                        local addressStr = province..city..district
                        callback(addressStr)
                    else
                        callback("")
                    end
                end
            else
                callback("")
            end
        else
            callback("")    
        end

        xhr:unregisterScriptHandler()

    end)

    xhr:send()
end
