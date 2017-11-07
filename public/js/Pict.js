// Generated by CoffeeScript 1.6.3
(function() {
  var $, Pict,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  $ = Util.requireModule('jquery', 'skyline');

  Pict = (function() {
    window.Pict = Pict;

    Pict.page = function(title, prev, curr, next) {
      var pict;
      pict = new Pict();
      Util.ready(function() {
        pict.roomPageHtml(title, prev, next);
        pict.createSlideShow('RoomSlides', curr, 600, 600);
      });
    };

    function Pict() {
      this.onSlides = __bind(this.onSlides, this);
      this.onVideo = __bind(this.onVideo, this);
      this.slide = null;
    }

    Pict.prototype.roomPageHtml = function(title, prev, next) {
      var htm, nextPage, prevPage;
      prevPage = " '" + prev + ".html' ";
      nextPage = " '" + next + ".html' ";
      htm = "<button class=\"home\" onclick=\"Util.toPage('../guest.html');\">Home Page</button>\n<button class=\"prev\" onclick=\"Util.toPage(" + prevPage + ");\"    >Prev Cabin</button>\n<span   class=\"room\">" + title + "</span>\n<button class=\"next\" onclick=\"Util.toPage(" + nextPage + ");\"    >Next Cabin</button>";
      $('#top').append(htm);
    };

    Pict.prototype.createSlideShow = function(parentId, roomId, w, h) {
      var images, url,
        _this = this;
      $('#' + parentId).append(this.wrapperHtml());
      images = function(Img) {
        var dir, htm, pic, _i, _len, _ref;
        htm = "";
        dir = Img[roomId].dir;
        _ref = Img[roomId]['pics'];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          pic = _ref[_i];
          htm += _this.li(pic, dir);
        }
        $('#slideshow').append(htm);
        return _this.initTINY(w, h);
      };
      url = parentId === 'RoomSlides' ? '../img/img.json' : 'img/img.json';
      $.getJSON(url, images);
    };

    Pict.prototype.li = function(pic, dir) {
      return "<li><h3>" + pic.name + "</h3><span>" + dir + pic.src + "</span><p>" + pic.p + "</p><a href=\"#\"><img src=\"" + dir + pic.src + "\" width=\"100\" height=\"70\" alt=\"" + pic.name + "\"/></a></li>";
    };

    Pict.prototype.onVideo = function() {
      window.slideshow.auto = false;
      $('#Slides').hide();
      $('#Video').show();
      $('#ViewVid').show();
      $('#VideoSee').text('View Slides').click(this.onSlides);
    };

    Pict.prototype.onSlides = function() {
      $('#ViewVid').hide();
      $('#Slides').show();
      window.slideshow.auto = true;
      $('#VideoSee').text('View Video').click(this.onVideo);
    };

    Pict.prototype.wrapperHtml = function() {
      return "<ul id=\"slideshow\"></ul>\n<div id=\"wrapper\">\n  <div id=\"fullsize\">\n    <div id=\"imgprev\" class=\"imgnav\" title=\"Previous Image\"></div>\n    <div id=\"imglink\"></div>\n    <div id=\"imgnext\" class=\"imgnav\" title=\"Next Image\"></div>\n    <div id=\"image\"></div>\n    <div id=\"information\">\n      <h3></h3>\n      <p></p>\n    </div>\n  </div>\n  <div id=\"thumbnails\">\n    <div id=\"slideleft\" title=\"Slide Left\"></div>\n    <div id=\"slidearea\">\n      <div id=\"slider\"></div>\n    </div>\n    <div id=\"slideright\" title=\"Slide Right\"></div>\n  </div>\n</div>";
    };

    Pict.prototype.resizeSlideView = function(w, h) {
      $('#wrapper').css({
        width: w,
        height: h
      });
      $('#fullsize').css({
        width: w,
        height: h - 100
      });
      $('#slidearea').css({
        width: w - 45,
        height: 61
      });
      $('#image').css({
        width: w - 100,
        height: h - 200
      });
      $('#image img').css({
        width: w - 100,
        height: h - 200
      });
      slideshow.width = w - 100;
      slideshow.height = h - 200;
    };

    Pict.prototype.initTINY = function(w, h) {
      var slideshow;
      Util.noop(w, h);
      TINY.ElemById('slideshow').style.display = 'none';
      TINY.ElemById('wrapper').style.display = 'block';
      window.slideshow = new TINY.slideshow("slideshow");
      slideshow = window.slideshow;
      slideshow.auto = false;
      slideshow.speed = 10;
      slideshow.link = "linkhover";
      slideshow.info = "information";
      slideshow.thumbs = "slider";
      slideshow.left = "slideleft";
      slideshow.right = "slideright";
      slideshow.scrollSpeed = 4;
      slideshow.spacing = 5;
      slideshow.active = "#fff";
      return slideshow.init("slideshow", "image", "imgprev", "imgnext", "imglink");
    };

    Pict.prototype.initSlide = function(w, h) {
      var slide;
      Util.noop(w, h);
      slide = new Slide("slideshow");
      Slide.ElemById('slideshow').style.display = 'none';
      Slide.ElemById('wrapper').style.display = 'block';
      slide.auto = false;
      slide.speed = 10;
      slide.link = "linkhover";
      slide.info = "information";
      slide.thumbs = "slider";
      slide.left = "slideleft";
      slide.right = "slideright";
      slide.scrollSpeed = 4;
      slide.spacing = 5;
      slide.active = "#fff";
      slide.init("slide", "image", "imgprev", "imgnext", "imglink");
      return slide;
    };

    return Pict;

  })();

}).call(this);
