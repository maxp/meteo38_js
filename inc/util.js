// Generated by CoffeeScript 1.12.7
(function() {
  var d02, htmlq_chars, htmlq_regex, x;

  window.util = x = {};

  if (!String.prototype.trim) {
    String.prototype.trim = function() {
      return this.replace(/^\s+|\s+$/g, "");
    };
  }

  if (!Array.prototype.forEach) {
    Array.prototype.forEach = function(action, that) {
      var i, n;
      i = 0;
      n = this.length;
      while (i < n) {
        action.call(that, this[i], i, this);
        i++;
      }
      return null;
    };
  }

  if (!Array.prototype.indexOf) {
    Array.prototype.indexOf = function(obj, start) {
      var i, n;
      i = start || 0;
      n = this.length;
      while (i < n) {
        if (this[i] === obj) {
          return i;
        }
        i++;
      }
      return -1;
    };
  }

  x.post = function(url, data, success, error, complete) {
    var xhr;
    xhr = $.ajax({
      url: url,
      type: 'POST',
      dataType: 'json',
      contentType: 'application/json',
      data: JSON.stringify(data),
      beforeSend: function(xhr) {
        if (window._csrf) {
          return xhr.setRequestHeader('x-csrf-token', window._csrf);
        }
      }
    });
    if (success) {
      xhr.success(success);
    }
    if (error) {
      xhr.error(error);
    }
    if (complete) {
      xhr.complete(complete);
    }
    return xhr;
  };

  x.trace = function(param) {
    return setTimeout(function() {
      return $.ajax({
        url: '/_trace',
        type: 'POST',
        dataType: 'json',
        contentType: 'application/json',
        data: JSON.stringify(param),
        done: function() {}
      });
    }, 10);
  };

  x.int = function(s, def) {
    var i;
    if (def == null) {
      def = 0;
    }
    i = parseInt(s, 10);
    if (isNaN(i)) {
      return def;
    } else {
      return i;
    }
  };

  x.str = function(s) {
    if ((s == null) || (typeof s === "number" && isNaN(s))) {
      return "";
    } else {
      return "" + s;
    }
  };

  x.randInt = function(n) {
    return Math.floor(Math.random() * n);
  };

  x.now = function() {
    return new Date().getTime();
  };

  x.htmlq = function(s) {
    return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
  };

  htmlq_chars = {
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;'
  };

  htmlq_regex = /[&<>"]/g;

  x.htmlq_re = function(s) {
    return s.replace(htmlq_regex, function(c) {
      return htmlq_chars[c] || c;
    });
  };

  x.trim = function(s) {
    return s.replace(/^\s+/g, "").replace(/\s+$/g, "");
  };

  x.local_get = function(key) {
    var e;
    try {
      return localStorage[key];
    } catch (error1) {
      e = error1;
    }
  };

  x.local_set = function(key, val) {
    var e;
    try {
      return localStorage[key] = val;
    } catch (error1) {
      e = error1;
    }
  };

  x.truncate = function(s, n) {
    if (!s) {
      return "";
    }
    if (s.length > n) {
      return s.slice(0, n) + " ...";
    }
    return s;
  };

  x.latlng1 = function(ll) {
    return [ll[1], ll[0]];
  };

  x.latlng2 = function(lat, lng) {
    return [lat, lng];
  };

  d02 = function(d) {
    if (d < 10) {
      return "0" + d;
    } else {
      return "" + d;
    }
  };

  x.ddmmyyyy = function(date) {
    if (!date) {
      return "??.??.????";
    }
    return d02(date.getDate()) + "." + d02(date.getMonth() + 1) + "." + date.getFullYear();
  };

  x.hhmm = function(date) {
    if (!date) {
      return "??:??";
    }
    return d02(date.getHours()) + ":" + d02(date.getMinutes());
  };

  x.hhmmss = function(date) {
    if (!date) {
      return "??:??:??";
    }
    return d02(date.getHours()) + ":" + d02(date.getMinutes()) + ":" + d02(date.getSeconds());
  };

  x.ddmmyyyy_hhmm = function(date) {
    return x.ddmmyyyy(date) + " " + x.hhmm(date);
  };

  x.ddmmyyyy_hhmmss = function(date) {
    return x.ddmmyyyy(date) + " " + x.hhmmss(date);
  };

  x.ll_text = function(ll) {
    var lat, lng;
    if (!ll) {
      return "";
    }
    lat = parseFloat(ll[1]);
    lng = parseFloat(ll[0]);
    if (isNaN(lat) || isNaN(lng)) {
      return "";
    }
    return lat.toFixed(6) + " " + lng.toFixed(6);
  };

  x.append_opts = function($select, opts_array) {
    $select.html("");
    return opts_array.forEach(function(opt) {
      return $select.append($("<option>").attr("value", opt[0]).text(opt[1]));
    });
  };

  x.parse_ll = function(s) {
    var lat, ll, lng;
    if (!s) {
      return null;
    }
    ll = ("" + s).trim().split(/[\,\s]+/);
    if (ll.length !== 2) {
      return null;
    }
    lat = parseFloat(ll[0]);
    lng = parseFloat(ll[1]);
    if (isNaN(lat) || isNaN(lng)) {
      return null;
    }
    return [lng, lat];
  };

  x.ymaps_load = function() {
    return $.getScript("//api-maps.yandex.ru/2.0-stable/?lang=ru-RU" + "&load=package.standard&coordorder=longlat&onload=ymaps_onload");
  };

}).call(this);
