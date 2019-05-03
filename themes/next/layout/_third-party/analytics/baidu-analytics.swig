{% if theme.baidu_analytics.tracking_id %}
  <script>
    var host = window.location.hostname;
    if (host !== 'localhost' || !{{theme.baidu_analytics.localhost_ignored}}) {
      var _hmt = _hmt || [];
      (function() {
        var hm = document.createElement("script");
        hm.src = "https://hm.baidu.com/hm.js?{{ theme.baidu_analytics.tracking_id }}";
        var s = document.getElementsByTagName("script")[0];
        s.parentNode.insertBefore(hm, s);
      })();
    }
  </script>
{% endif %}
