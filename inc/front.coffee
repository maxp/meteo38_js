#
#   meteo38.ru: inc/front
#

lib = window.util

$btn_stlist = $("#btn_stlist")

REFRESH_INTERVAL = 4*60*1000

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
    #? update cookie locally
    window.util.post("/st_favs", {favs:favs}, (data) -> )
    refresh_data(500)
#-

favs_add = (st, title, addr) ->
    if st not in window.fav_ids
        window.fav_ids.push(st)

        # duplicated in main.jade
        $item = $("<div class='item'></div>").attr("id", "favst_"+st)
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
    $btn_stlist.prop("disabled", 1)
    $.getJSON("/st_list", (data) ->
        return alert("Ошибка при загрузке данных!") if not data.st_list
        $("#stlist").html("")
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
            $("#stlist").append(item)
        )
    ).always () -> $btn_stlist.removeProp("disabled")
#-

$("#btn_refresh").click () -> refresh_data(0)

$btn_stlist.click (evt) ->
    $b = $(evt.target)
    if $b.data("open")
        $b.data("open", 0)
        $("#stlist").html("")      
    else
        $b.data("open", 1)
        load_stlist()
    #
#-    

$("#btn_help").click (evt) ->
    $b = $(evt.target)
    if $b.data("open")
        $b.data("open", 0)
        $("#help-text").html("")      
    else
        $b.data("open", 1)
        $("#help-text").load("/help")
    #
#-    

$( () -> refresh_data(REFRESH_INTERVAL) )

#.