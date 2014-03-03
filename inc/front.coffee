#
#   meteo38.ru: inc/front
#

lib = window.util

# globals
#
# window.fav_ids: [] - inited in main html
# window.st_data: {} - inited in main html
window.map = map = null

$btn_stlist = $("#btn_stlist")

REFRESH_INTERVAL = 4*60*1000

ZOOM_INIT = 13

# duplicated in main.coffe
#
TRENDS_INTERVAL = 60*60*1000
#
format_t = (last, trends) ->
    return "" if not last.t?
    t = Math.round(last.t)
    [cls,sign] = if t > 0 then ["pos","+"] else if t < 0 then ["neg","-"] else ["zer",""]
    t = -t if t < 0 

    tr = " &nbsp;"
    acls = ""
    if trends?.t
        tts = new Date(trends.ts).getTime()
        if tts > lib.now() - TRENDS_INTERVAL
            if trends.t.last >= (trends.t.avg + 1)
                tr = "&uarr;" 
                acls = "pos"
            if trends.t.last <= (trends.t.avg - 1)
                tr = "&darr;" 
                acls = "neg"
        #
    #
    return " <span class='#{cls}'>#{sign}<i>#{t}</i></span>&deg;"+
            "<span class='arr #{acls}'>#{tr}</span>"
#-

refresh_data = (delay) ->
    clearTimeout(window.refresh_tout) if window.refresh_tout
    window.refresh_tout = setTimeout(
        () ->
            $("#btn_refresh").prop("disabled", 1)
            st_list = window.fav_ids
            $.getJSON( "/st_data", 
                {st_list:st_list.join(','), ts:lib.now()}
                (resp) ->
                    window.st_data = resp.data or {}
                    if not resp.ok
                        alert "Ошибка при обращении к серверу."
                        return
                    #
                    for s in st_list
                        d = resp.data[s]
                        if d 
                            $("#favst_#{d._id} .data").html(format_t(d.last, d.trends)) 
                        else
                            $("#favst_#{s} .data").html("")
                    #
                    $("#btn_refresh").children(".hhmm").text(resp.hhmm or "??:??")
                    $("#btn_refresh").removeProp("disabled")
                    refresh_data(REFRESH_INTERVAL)
                #-
            )
        #-
        delay
    )
#-

save_favs = (favs) ->
    window.util.post("/st_favs", {favs:favs}, (data) -> )
    refresh_data(500)
#-

favs_add = (st, title, addr) ->
    if st not in window.fav_ids
        window.fav_ids.push(st)

        # duplicated in main.jade
        $item = $("<div class='item'></div>").attr("id", "favst_"+st).data("st",st)
        $item.append( "<div class='data pull-right'></div>" )
        $item.append( $("<div class='text'></div>")
            .append( $("<div class='title'></div>").text(title) )
            .append( $("<div class='addr'></div>").text(addr) )
        )
        $("#fav_items").append($item)
        save_favs(window.fav_ids)
    #
#-

favs_remove = (st) ->
    $("#favst_#{st}").remove()
    window.fav_ids = (id for id in window.fav_ids when id isnt st)
    save_favs(window.fav_ids)
#-


ll2coords = (ll) -> return [ll[1], ll[0]] if ll?.length is 2

fav_item_click = (evt) ->
    st = window.st_data?[$(this).data("st")]
    return if not st?.ll or not window.map

    zoom = map.getZoom()
    map.setCenter(
        ll2coords(st.ll),  
        if zoom < ZOOM_INIT then ZOOM_INIT+1 else zoom
    )
#-

star_click = (evt) ->
    $this = $(this)
    if $this.data("fav")
        $this.data("fav", 0)
        $this.children(".glyphicon")
            .removeClass("glyphicon-star").addClass("glyphicon-star-empty")
        favs_remove($this.data("st"))
    else
        $this.data("fav", 1)
        $this.children(".glyphicon")
            .removeClass("glyphicon-star-empty").addClass("glyphicon-star")
        favs_add($this.data("st"),$this.data("title"),$this.data("addr"))
    #
#-

load_stlist = () ->
    $stlist = $("#pane_opts")
    $stlist.html("<div class='loading'></div>")
    $.getJSON("/st_list", (data) ->
        $stlist.html("")
        return alert("Ошибка при загрузке данных!") if not data.st_list
        $.each( data.st_list, (i,v) ->
            item = $("<div class='item'></div>")  #.attr("id",v._id)
            $star = $("<div class='star'></div>").click(star_click)
                .data({st:v._id, title:v.title, addr:v.addr or v.descr})
            if v._id in window.fav_ids
                $star.data("fav",1).append(
                    "<span class='glyphicon glyphicon-star'></span>")
            else
               $star.data("fav",0).append(
                    "<span class='glyphicon glyphicon-star-empty'></span>")
            #
            item.append( $star )
            item.append( $("<div class='title'></div>").text(v.title) )
            item.append( $("<div class='addr'></div>").text(v.addr or v.descr) )
            $stlist.append(item)
        )
    )
#-


show_map = () ->
    if not window.map
        window.ymaps_onload = () ->
            $("#pane_map").html("<div class='map' id='map'></div>")
            st0 = $($("#fav_items .item").get(0)).data("st")
            center = ll2coords(window.st_data[st0]?.ll) or [52.27,104.26]
            window.map = map = new ymaps.Map("map", {center: center, zoom: ZOOM_INIT});
            map.controls.add('zoomControl', {noTips:true, top:7, left:7})
            map.controls.add('typeSelector')    

            # window.markers = new ymaps.GeoObjectCollection()
            # window.map.geoObjects.add window.markers

            # place_marker(obj) for obj in _objs
            show_map()
        #-
        $.getScript(
            "//api-maps.yandex.ru/2.0-stable/?lang=ru-RU&load=package.standard&onload=ymaps_onload"
        )
        return
    #

    # TODO: readd mrkers

#-

show_graph = () ->
    console.log("load graph")
#-


#--- bind controls

$("#btn_refresh").click () -> refresh_data(0)

$("a.tablink").each( (i, a) -> $(a).click( () ->
    $li = $(this).parent()
    return false if $li.hasClass("active")
    $("a.tablink").parent().removeClass("active")
    $li.addClass("active")
    $(".tab_pane").hide()
    pane = $(this).data("pane")
    $("#pane_"+pane).show()
    {graph:show_graph, map:show_map, opts:load_stlist}[pane].call()
))

$( () -> 
    $("#fav_items").on("click", ".item", fav_item_click)
    $("a.tablink")[0].click()
    refresh_data(REFRESH_INTERVAL) 
)

#.