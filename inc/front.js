// Generated by CoffeeScript 1.7.1
(function() {
  var $btn_stlist, load_stlist, x;

  window.util = x = {};

  $btn_stlist = $("#btn_stlist");

  load_stlist = function() {
    $btn_stlist.prop("disabled", 1);
    return $.getJSON("/st_list", function(data) {
      if (!data.st_list) {
        return alert("Ошибка при загрузке данных!");
      }
      $("#stlist").html("");
      return $.each(data.st_list, function(i, v) {
        var item;
        item = $("<div class='item'>").attr("id", v._id);
        item.append($("<div class='title'>").text(v.title));
        item.append($("<div class='addr'>").text(v.addr || v.descr));
        return $("#stlist").append(item);
      });
    }).always(function() {
      return $btn_stlist.removeProp("disabled");
    });
  };

  $btn_stlist.click(load_stlist);

}).call(this);
