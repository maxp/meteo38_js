#
#   meteo38.ru: inc/front
#

window.util = x = {}

$btn_stlist = $("#btn_stlist")

star_click = (evt) ->
    if $(this).data("fav")
        $(this).data("fav", 0)
        $(this).children(".glyphicon")
            .removeClass("glyphicon-star").addClass("glyphicon-star-empty")
        #remove from favs()
    else
        $(this).data("fav", 1)
        $(this).children(".glyphicon")
            .removeClass("glyphicon-star-empty").addClass("glyphicon-star")
        #add to favs()
    #
#-

load_stlist = () ->
    $btn_stlist.prop("disabled", 1)
    $.getJSON("/st_list", (data) ->
        return alert("Ошибка при загрузке данных!") if not data.st_list
        $("#stlist").html("")
        $.each(data.st_list, (i,v) ->
            item = $("<div class='item'>")  #.attr("id",v._id)
            item.append( $("<div class='star'>")
                .data("st",v._id).data("fav",0).click(star_click)
                .append("<span class='glyphicon glyphicon-star-empty'></span>")

            )
            item.append( $("<div class='title'>").text(v.title) )
            item.append( $("<div class='addr'>").text(v.addr or v.descr) )
            $("#stlist").append(item)
        )
    ).always () -> $btn_stlist.removeProp("disabled")
#-

$btn_stlist.click load_stlist

#.