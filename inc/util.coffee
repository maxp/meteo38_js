#
#   meteo38.ru: inc/ common client ui stuff
#

window.util = x = {}

# ES5 emulation
unless String::trim then String::trim = -> @replace(/^\s+|\s+$/g, "")

unless Array::forEach then Array::forEach = (action, that) ->
    i = 0; n = this.length
    while i < n
        action.call(that, this[i], i, this)
        i++
    return null
#-

unless Array::indexOf then Array::indexOf = (obj, start) ->
    i = start or 0; n = this.length
    while i < n
        return i if this[i] is obj
        i++
    return -1
#-


x.post = (url, data, success, error, complete)->
    xhr = $.ajax {
      url: url, type: 'POST', dataType: 'json',
      contentType: 'application/json', data: JSON.stringify(data),
      beforeSend: (xhr) ->
        xhr.setRequestHeader('x-csrf-token', window._csrf) if window._csrf
    }
    xhr.success  success  if success
    xhr.error    error    if error
    xhr.complete complete if complete
    return xhr
#-

x.trace = (param) -> 
    setTimeout( 
        () ->
            $.ajax {
              url: '/_trace', type: 'POST', dataType: 'json', 
              contentType: 'application/json', data: JSON.stringify(param), 
              done: () -> 
            }
        ,
        10
    )
#-

x.int = (s, def=0) ->
    i = parseInt(s, 10)
    return if isNaN(i) then def else i
#-

x.str = (s) -> if (not s?) or (typeof s == "number" and isNaN(s)) then "" else ""+s

x.randInt = (n)-> Math.floor(Math.random()*n)

x.now = () -> new Date().getTime()

x.htmlq = (s) -> 
    s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;')
#-

htmlq_chars = '&':'&amp;', '<':'&lt;', '>':'&gt;', '"': '&quot;'
htmlq_regex = /[&<>"]/g

x.htmlq_re = (s) -> s.replace(htmlq_regex, (c)-> htmlq_chars[c] or c) 

x.trim = (s) -> s.replace(/^\s+/g, "").replace(/\s+$/g, "")

x.local_get = (key) ->
    try
        return localStorage[key]
    catch e
        # no localStorage
#-

x.local_set = (key, val) ->
    try
        return localStorage[key] = val
    catch e
        # no localStorage 
#-    

x.truncate = (s, n) ->
    return "" if not s
    return s.slice(0, n)+" ..." if s.length > n
    return s
#-  


x.latlng1 = (ll) -> [ll[1], ll[0]]
x.latlng2 = (lat, lng) -> [lat, lng]


d02 = (d) -> if d < 10 then "0"+d else ""+d

x.ddmmyyyy = (date) ->
    return "??.??.????" if not date
    return d02(date.getDate())+"."+d02(date.getMonth()+1)+"."+date.getFullYear()
#-

x.hhmm = (date) ->
      return "??:??" if not date
      d02(date.getHours())+":"+d02(date.getMinutes())
#-

x.hhmmss = (date) ->
      return "??:??:??" if not date
      d02(date.getHours())+":"+d02(date.getMinutes())+":"+d02(date.getSeconds())
#-

x.ddmmyyyy_hhmm = (date) -> return x.ddmmyyyy(date)+" "+x.hhmm(date)
x.ddmmyyyy_hhmmss = (date) -> return x.ddmmyyyy(date)+" "+x.hhmmss(date)

x.ll_text = (ll) ->
    return "" if not ll
    lat = parseFloat(ll[1])
    lng = parseFloat(ll[0])
    return "" if isNaN(lat) or isNaN(lng)
    return lat.toFixed(6)+" "+lng.toFixed(6)
#-

x.append_opts = ($select, opts_array) ->
    $select.html ""
    opts_array.forEach (opt) -> $select.append $("<option>").attr("value", opt[0]).text opt[1]
#-

x.parse_ll = (s) ->
    return null if not s
    ll = (""+s).trim().split(/[\,\s]+/)
    return null if ll.length isnt 2
    lat = parseFloat(ll[0])
    lng = parseFloat(ll[1])
    return null if isNaN(lat) or isNaN(lng)
    return [lng, lat]
#-

x.ymaps_load = () ->
    $.getScript "//api-maps.yandex.ru/2.0-stable/?lang=ru-RU"+
        "&load=package.standard&coordorder=longlat&onload=ymaps_onload"

        
#.