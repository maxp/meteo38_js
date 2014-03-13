// Generated by CoffeeScript 1.7.1
(function() {
  var $btn_stlist, CENTER_INIT, REFRESH_INTERVAL, TRENDS_INTERVAL, ZOOM_INIT, add_marker, fav_item_click, favs_add, favs_remove, format_t, lib, ll2coords, load_stlist, map, markers, refresh_data, save_favs, show_graph, show_map, star_click, update_stdata,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  lib = window.util;

  window.map = map = null;

  markers = null;

  $btn_stlist = $("#btn_stlist");

  REFRESH_INTERVAL = 4 * 60 * 1000;

  CENTER_INIT = [52.27, 104.26];

  ZOOM_INIT = 13;

  TRENDS_INTERVAL = 60 * 60 * 1000;

  format_t = function(last, trends) {
    var acls, cls, sign, t, tr, tts, _ref;
    if (last.t == null) {
      return "";
    }
    t = Math.round(last.t);
    _ref = t > 0 ? ["pos", "+"] : t < 0 ? ["neg", "-"] : ["zer", ""], cls = _ref[0], sign = _ref[1];
    if (t < 0) {
      t = -t;
    }
    tr = " &nbsp;";
    acls = "";
    if (trends != null ? trends.t : void 0) {
      tts = new Date(trends.ts).getTime();
      if (tts > lib.now() - TRENDS_INTERVAL) {
        if (trends.t.last >= (trends.t.avg + 1)) {
          tr = "&uarr;";
          acls = "pos";
        }
        if (trends.t.last <= (trends.t.avg - 1)) {
          tr = "&darr;";
          acls = "neg";
        }
      }
    }
    return (" <span class='" + cls + "'>" + sign + "<i>" + t + "</i></span>&deg;") + ("<span class='arr " + acls + "'>" + tr + "</span>");
  };

  update_stdata = function(v) {
    var d, k, _i, _len, _results;
    if (!v._id) {
      return;
    }
    d = window.st_data[v._id];
    if (!d) {
      return (window.st_data[v._id] = v);
    }
    _results = [];
    for (_i = 0, _len = v.length; _i < _len; _i++) {
      k = v[_i];
      _results.push(d[k] = v[k]);
    }
    return _results;
  };

  refresh_data = function(delay) {
    if (window.refresh_tout) {
      clearTimeout(window.refresh_tout);
    }
    return window.refresh_tout = setTimeout(function() {
      var st_list;
      $("#btn_refresh").prop("disabled", 1);
      st_list = window.fav_ids;
      return $.getJSON("/st_data", {
        st_list: st_list.join(','),
        ts: lib.now()
      }, function(resp) {
        var d, k, s, v, _i, _len, _ref;
        if (!resp.ok) {
          alert("Ошибка при обращении к серверу.");
          return;
        }
        _ref = resp.data;
        for (k in _ref) {
          v = _ref[k];
          update_stdata(v);
        }
        for (_i = 0, _len = st_list.length; _i < _len; _i++) {
          s = st_list[_i];
          d = resp.data[s];
          if (d) {
            $("#favst_" + d._id + " .data").html(format_t(d.last, d.trends));
          } else {
            $("#favst_" + s + " .data").html("");
          }
        }
        $("#btn_refresh").children(".hhmm").text(resp.hhmm || "??:??");
        $("#btn_refresh").removeProp("disabled");
        return refresh_data(REFRESH_INTERVAL);
      });
    }, delay);
  };

  save_favs = function(favs) {
    window.util.post("/st_favs", {
      favs: favs
    }, function(data) {});
    return refresh_data(500);
  };

  favs_add = function(st, title, addr) {
    var $item;
    if (__indexOf.call(window.fav_ids, st) < 0) {
      window.fav_ids.push(st);
      $item = $("<div class='item'></div>").attr("id", "favst_" + st).data("st", st);
      $item.append("<div class='data pull-right'></div>");
      $item.append($("<div class='text'></div>").append($("<div class='title'></div>").text(title)).append($("<div class='addr'></div>").text(addr)));
      $("#fav_items").append($item);
      return save_favs(window.fav_ids);
    }
  };

  favs_remove = function(st) {
    var id;
    $("#favst_" + st).remove();
    window.fav_ids = (function() {
      var _i, _len, _ref, _results;
      _ref = window.fav_ids;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        id = _ref[_i];
        if (id !== st) {
          _results.push(id);
        }
      }
      return _results;
    })();
    return save_favs(window.fav_ids);
  };

  ll2coords = function(ll) {
    if ((ll != null ? ll.length : void 0) === 2) {
      return [ll[1], ll[0]];
    }
  };

  fav_item_click = function(evt) {
    var st, zoom, _ref;
    st = (_ref = window.st_data) != null ? _ref[$(this).data("st")] : void 0;
    if (!(st != null ? st.ll : void 0) || !window.map) {
      return;
    }
    zoom = map.getZoom();
    return map.setCenter(ll2coords(st.ll), zoom < ZOOM_INIT ? ZOOM_INIT + 1 : zoom);
  };

  star_click = function(evt) {
    var $this;
    $this = $(this);
    if ($this.data("fav")) {
      $this.data("fav", 0);
      $this.children(".glyphicon").removeClass("glyphicon-star").addClass("glyphicon-star-empty");
      return favs_remove($this.data("st"));
    } else {
      $this.data("fav", 1);
      $this.children(".glyphicon").removeClass("glyphicon-star-empty").addClass("glyphicon-star");
      return favs_add($this.data("st"), $this.data("title"), $this.data("addr"));
    }
  };

  load_stlist = function() {
    var $stlist;
    $stlist = $("#pane_opts");
    $stlist.html("<div class='loading'></div>");
    return $.getJSON("/st_list", function(data) {
      $stlist.html("");
      if (!data.st_list) {
        return alert("Ошибка при загрузке данных!");
      }
      return $.each(data.st_list, function(i, v) {
        var $star, item, _ref;
        update_stdata(v);
        item = $("<div class='item'></div>");
        $star = $("<div class='star'></div>").click(star_click).data({
          st: v._id,
          title: v.title,
          addr: v.addr || v.descr
        });
        if (_ref = v._id, __indexOf.call(window.fav_ids, _ref) >= 0) {
          $star.data("fav", 1).append("<span class='glyphicon glyphicon-star'></span>");
        } else {
          $star.data("fav", 0).append("<span class='glyphicon glyphicon-star-empty'></span>");
        }
        item.append($star);
        item.append($("<div class='title'></div>").text(v.title));
        item.append($("<div class='addr'></div>").text(v.addr || v.descr));
        return $stlist.append(item);
      });
    });
  };

  add_marker = function(d) {
    var c;
    if (!(c = ll2coords(d.ll))) {
      return;
    }
    return markers.add(new ymaps.Placemark(c, {
      iconContent: d.title
    }, {
      preset: 'twirl#greyStretchyIcon'
    }));
  };

  show_map = function() {
    var k, st0, _i, _len, _ref, _ref1, _results;
    if (!window.map) {
      window.ymaps_onload = function() {
        $("#pane_map").html("<div class='map' id='map'></div>");
        window.map = map = new ymaps.Map("map", {
          center: CENTER_INIT,
          zoom: ZOOM_INIT
        });
        map.controls.add(new ymaps.control.ZoomControl({
          noTips: true
        }), {
          top: 7,
          left: 7
        });
        map.controls.add('typeSelector');
        map.geoObjects.add(markers = new ymaps.GeoObjectCollection());
        return show_map();
      };
      $.getScript("//api-maps.yandex.ru/2.0-stable/?lang=ru-RU&load=package.standard&onload=ymaps_onload");
      return;
    }
    markers.removeAll();
    st0 = $($("#fav_items .item").get(0)).data("st");
    map.setCenter(ll2coords((_ref = window.st_data[st0]) != null ? _ref.ll : void 0) || CENTER_INIT);
    _ref1 = window.fav_ids;
    _results = [];
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      k = _ref1[_i];
      _results.push(add_marker(window.st_data[k]));
    }
    return _results;
  };

  show_graph = function() {
    var $gpane;
    $gpane = $("#pane_graph");
    $gpane.html("<div class='loading'></div>");
    return $.getJSON("/st_graph", {
      d: 0,
      n: 3,
      st: ["uiii", "npsd", "markova"]
    }, function(data) {
      var canv;
      return $gpane.html("").append(canv = $("<canvas></canvas>").addClass("graph_canv"));
    });
  };

  $("#btn_refresh").click(function() {
    return refresh_data(0);
  });

  $("a.tablink").each(function(i, a) {
    return $(a).click(function() {
      var $li, pane;
      $li = $(this).parent();
      if ($li.hasClass("active")) {
        return false;
      }
      $("a.tablink").parent().removeClass("active");
      $li.addClass("active");
      $(".tab_pane").hide();
      pane = $(this).data("pane");
      $("#pane_" + pane).show();
      return {
        graph: show_graph,
        map: show_map,
        opts: load_stlist
      }[pane].call();
    });
  });

  $(function() {
    $("#fav_items").on("click", ".item", fav_item_click);
    $("a.tablink")[0].click();
    return refresh_data(REFRESH_INTERVAL);
  });

}).call(this);
