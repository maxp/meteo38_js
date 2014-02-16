#
#   meteo38.ru: inc/front
#

window.util = x = {}

$btn_stlist = $("#btn_stlist")

load_stlist = () ->
    $btn_stlist.prop("disabled", 1)
    $.getJSON("/st_list", (data) ->
        return alert("Ошибка при загрузке данных!") if not data.st_list
        $("#stlist").html("")
        $.each(data.st_list, (i,v) ->
            item = $("<div class='item'>").attr("id",v._id)
            item.append( $("<div class='title'>").text(v.title) )
            item.append( $("<div class='addr'>").text(v.addr or v.descr) )
            $("#stlist").append(item)
        )
    ).always () -> $btn_stlist.removeProp("disabled")
#-

$btn_stlist.click load_stlist

#.