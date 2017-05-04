// Generated by CoffeeScript 1.12.2
(function() {
  var $, Home,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    hasProp = {}.hasOwnProperty;

  $ = require('jquery');

  Home = (function() {
    module.exports = Home;

    function Home(stream, store, Data, room1, pict) {
      this.stream = stream;
      this.store = store;
      this.Data = Data;
      this.room = room1;
      this.pict = pict;
      this.onHome = bind(this.onHome, this);
      this.onMakeRes = bind(this.onMakeRes, this);
      this.rooms = this.room.rooms;
      this.roomUIs = this.room.roomUIs;
    }

    Home.prototype.ready = function(book) {
      this.book = book;
      $('#MakeRes').click(this.onMakeRes);
      $('#HomeBtn').click(this.onHome);
      $('#MapDirs').click((function(_this) {
        return function() {
          return Util.toPage('rooms/X.html');
        };
      })(this));
      $('#Contact').click((function(_this) {
        return function() {
          return Util.toPage('rooms/Y.html');
        };
      })(this));
      $('#Head').append(this.headHtml());
      this.listRooms();
      this.pict.createSlideShow('Slides', 'M', 600, 600);
      $('#VideoSee').click(this.pict.onVideo);
    };

    Home.prototype.headHtml = function() {
      return "<ul class=\"Head1\">\n <li>Trout Fishing</li>\n <li>Bring your Pet</li>\n <li>Owner On Site</li>\n</ul>\n<ul class=\"Head2\">\n  <li>Hiking</li>\n  <li>Free Wi-Fi</li>\n  <li>Cable TV</li>\n</ul>\n<ul class=\"Head3\">\n  <li>Private Parking Spaces</li>\n  <li>Kitchens in Every Cabin</li>\n  <li>3 Private Spas</li>\n</ul>\n<ul class=\"Head4\">\n  <li>Private Barbecue Grills</li>\n  <li>All Non-Smoking Cabins</li>\n  <li>Wood Burning Fireplaces</li>\n</ul>";
    };

    Home.prototype.listRooms = function() {
      var htm, ref, room, roomId;
      $('#Slides').css({
        left: "22%",
        width: "78%"
      });
      htm = "<div class=\"HomeSee\">Enjoy Everything Skyline Has to Offer</div>";
      htm += "<div class=\"RoomSee\">See Our Cabins</div>";
      htm += "<div class=\"FootSee\">Skyline Cottages Where the River Meets the Mountains</div>";
      htm += "<ul  class=\"RoomUL\">";
      ref = this.rooms;
      for (roomId in ref) {
        if (!hasProp.call(ref, roomId)) continue;
        room = ref[roomId];
        htm += "<li class=\"RoomLI\"><a href=\"rooms/" + roomId + ".html\">" + room.name + "</a></li>";
      }
      htm += "</ul>";
      $("#View").append(htm);
      $("#View").append("<button id=\"VideoSee\" class=\"btn btn-primary\"\">View Video</button>");
    };

    Home.prototype.hideMkt = function() {
      $('#MakeRes').hide();
      $('#HomeBtn').hide();
      $('#MapDirs').hide();
      $('#Contact').hide();
      $('#Caption').hide();
      $('#Head').hide();
      return $('#View').hide();
    };

    Home.prototype.showMkt = function() {
      $('#MakeRes').show();
      $('#HomeBtn').hide();
      $('#MapDirs').show();
      $('#Contact').show();
      $('#Caption').show();
      $('#Head').show();
      return $('#View').show();
    };

    Home.prototype.showConfirm = function() {
      $('#MakeRes').hide();
      $('#HomeBtn').show();
      $('#MapDirs').show();
      $('#Contact').show();
      $('#Caption').hide();
      $('#Head').hide();
      return $('#View').hide();
    };

    Home.prototype.onMakeRes = function() {
      this.hideMkt();
      this.book.ready();
    };

    Home.prototype.onHome = function() {
      this.showMkt();
    };

    return Home;

  })();

}).call(this);
