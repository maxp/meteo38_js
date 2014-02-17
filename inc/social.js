
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


});
