
$(function() {
    (function(d, s, id) {
        var js, fjs = d.getElementsByTagName(s)[0];
        if (d.getElementById(id)) return;
        js = d.createElement(s); js.id = id;
        js.src = "//connect.facebook.net/en_US/all.js#xfbml=1";
        fjs.parentNode.insertBefore(js, fjs);
    }(document, 'script', 'facebook-jssdk'));

    $.getScript("//vk.com/js/api/openapi.js?105", function(){
        VK.init({apiId: 4193529, onlyWidgets: true});
        VK.Widgets.Like("vk_like", {type: "mini", height: 20});
    });

    !function(d, id, did, st) {
        var js = d.createElement("script");
        js.src = "http://connect.ok.ru/connect.js";
        js.onload = js.onreadystatechange = function () {
            if (!this.readyState || this.readyState == "loaded" || this.readyState == "complete") {
                if (!this.executed) {
                    this.executed = true;
                    setTimeout(function () {
                        OK.CONNECT.insertShareWidget(id,did,st);
                    }, 0);
                }
        }};
        d.documentElement.appendChild(js);
    }(document,"ok_shareWidget","http://meteo38.ru/","{width:145,height:30,st:'rounded',sz:20,ck:1}");

});
