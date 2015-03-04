(function($){
//  var MEETUP_KEY = '5e7e4f791557b5f3843303f103d4';
  var MEETUP_API_BASE_URL = "http://api.meetup.com/2/"
  var MEETUP_API_EVENT_URL = MEETUP_API_BASE_URL + "event";
  var MEETUP_API_EVENTS_URL =  MEETUP_API_BASE_URL +"events";
  var MEETUP_API_RSVP_URL = MEETUP_API_BASE_URL + "rsvps";
 
  var DEFAULT_EVENT_TEMPLATE = 'templates/event.erb';
  var DEFAULT_YES_RSVP_TEMPLATE = 'templates/rsvp_list.erb';
  var DEFAULT_NO_RSVP_TEMPLATE = 'templates/rsvp_list.erb';
  var DEFAULT_EVENT_LIST_TEMPLATE = 'templates/event_list.erb';
  var DEFAULT_RSVP_COUNT_TEMPLATE = 'templates/rsvp_count.erb';
  var DEFAULT_PRIMARY_EVENT_DISPLAY_TAG = '#primaryEvent';
  var DEFAULT_RSVP_COUNT_DISPLAY_TAG = '#rsvpCount';
  var DEFAULT_YES_RSVP_DISPLAY_TAG = '#yesRsvpList';
  var DEFAULT_NO_RSVP_DISPLAY_TAG = '#noRsvpList';
  var DEFAULT_EVENT_LIST_DISPLAY_TAG = '#eventList';
  var DEFAULT_ERROR_TAG = "#errorMessage";
  var DEFAULT_GENERAL_ERROR_MESSAGE = "An Error Has Occured!";
  var DEFAULT_USE_GENERAL_ERROR_MESSAGE = true;

  var DATA_TYPES = ['event_list', 'primary_event', 'yes_rsvps', 'no_rsvps'];
  var DATA_TYPE_EVENT_LIST = DATA_TYPES[0];
  var DATA_TYPE_PRIMARY_EVENT = DATA_TYPES[1];
  var DATA_TYPE_YES_RSVPS = DATA_TYPES[2];
  var DATA_TYPE_NO_RSVPS = DATA_TYPES[4];

  var DEFAULT_NO_PHOTO_SRC = "/images/noPhoto_80.png";
  var DEFAULT_GET_PAY_STATUS = false;
//  var EVENT_TEMPLATE_URL = "templates/event.ejs";
//  var RSVP_TEMPLATE_URL = "templates/rsvps.ejs"
  var LOCAL_TEST_EVENT = 'test_data/event1.json';
  var MEETUP_YES = "yes";
  var MEETUP_NO  = "no";
  var RSVP_TOGGLE_ICON_OPEN = 'glyphicon glyphicon-plus-sign';
  var RSVP_TOGGLE_ICON_CLOSE = 'glyphicon glyphicon-minus-sign';
  var RSVP_YES_LIST_ID = "#event-yes-rsvp-list";
  var RSVP_YES_TOGGLE_ICON_ID = "#rsvp-yes-toggle-icon";
  var RSVP_YES_TOGGLE_ID = "#toggle-yes-rsvps";
  var RSVP_NO_LIST_ID = "#event-no-rsvp-list";
  var RSVP_NO_TOGGLE_ICON_ID = "#rsvp-no-toggle-icon";
  var RSVP_NO_TOGGLE_ID = "#toggle-no-rsvps";
  var REFRESH_RSVP_LIST_ID = "#refresh-rsvp-list";

  var SORT_TYPES = ['name', 'last_rsvp', 'first_rsvp'];
  var SORT_BY_NAME = SORT_TYPES[0];
  var SORT_BY_LAST_RSVP = SORT_TYPES[1];
  var SORT_BY_FIRST_RSVP = SORT_TYPES[2];
  var DEFAULT_SORT_BY = SORT_BY_LAST_RSVP;
  var SORT_SELECT_ID = "#sort_by";

  var DEBUG_LEVEL = 2;
  var DEFAULT_GET_PAY_STATUS = false;
  var PAID = 'paid';

  var LOAD_STATES = ['initial', 'started', 'loading', 'done', 'fail'];
  var LOAD_INITIAL = LOAD_STATES[0];
  var LOAD_STARTED = LOAD_STATES[1];
  var LOAD_LOADING = LOAD_STATES[2];
  var LOAD_DONE =    LOAD_STATES[3];
  var LOAD_FAILED =  LOAD_STATES[4];

  var EXCLUDE_GUESTS = [2022183, 7526580];
  var EXCLUDE_USERS = [7526580];

//  var eventLoadState = LOAD_INITIAL;
  var g_rsvpLoadState = LOAD_INITIAL;
//  var numRsvpLoads = 0;
//  var numEventsToLoad = 0;

 // var firstEvent = null;
 // var eventLinkUrls = null;
 // var rsvpList = null;

  var globalArgs = {};

  if (!Array.prototype.indexOf) {
    Array.prototype.indexOf = function (searchElement , fromIndex) {
      var i,
      pivot = (fromIndex) ? fromIndex : 0,
      length;

      if (!this) {
        throw new TypeError();
      }

      length = this.length;

      if (length === 0 || pivot >= length) {
        return -1;
      }

      if (pivot < 0) {
        pivot = length - Math.abs(pivot);
      }

      for (i = pivot; i < length; i++) {
        if (this[i] === searchElement) {
          return i;
        }
      }
      return -1;
    };
  }

  function debug(msg, level) {
    if (typeof level == 'undefined') { level = DEBUG_LEVEL; }

    if (level <= DEBUG_LEVEL) {
      console.log(msg);
    }
  }

  function logWarning(msg) {
    console.log("WARNING: " + msg);
  }
  
  function notEmpty(obj) {
    var ret = true;
    if (typeof obj == 'undefined' || obj === null || obj === '' || (!obj)){
      ret = false;
    }
    return ret;
  }

  function isEmpty(obj) {
    return !notEmpty(obj);
  }

  function createRsvpUrl(eventId){
    var fields = GET_PAY_STATUS ? "&fields=pay_status" : "";
    return MEETUP_API_RSVP_URL + "?event_id=" + eventId + "&key=" + MEETUP_KEY + fields + "&callback=?";
  }

  function addCallbackToUrl(url) {
    var exists = url.match(/(callback=\?)/);
    if (!exists) {
      debug("**Adding callback", 2);
      url = url + "&callback=?";
    }
    else {
      debug("Callback already exists!", 2);
    }
    return url;
  }

  function getFirstEventIdFromUrl(url) {
    var myRe = /event_id=(\d+)/;
    var result = myRe.exec(url);
    debug("** In getFirstEventIdFromUrl: result =");
    console.log(result);
    var id = result ? result[1] : null;
    debug("ID = " + id);
    return id;
  }

  function DateFmt(fstr) {
    this.formatString = fstr;

    var mthNames = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
    var dayNames = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"];
    var zeroPad = function(number) {
       return ("0"+number).substr(-2,2);
    }

    var dateMarkers = {
      d:['getDate',function(v) { return zeroPad(v)}],
      m:['getMonth',function(v) { return zeroPad(v+1)}],
      n:['getMonth',function(v) { return mthNames[v]; }],
      w:['getDay',function(v) { return dayNames[v]; }],
      y:['getFullYear'],
      H:['getHours'],
      HH:['getHours',function(v) { return zeroPad(v)}],
      h:['getHours',function(v) { return v % 12 || 12 }],
      hh:['getHours',function(v) { return zeroPad(v % 12 || 12) }],
      M:['getMinutes',function(v) { return zeroPad(v)}],
      S:['getSeconds',function(v) { return zeroPad(v)}],
      i:['toISOString'],
      tt:['getHours',function(v) { return v < 12 ? "am" : "pm"}],
      TT:['getHours',function(v) { return v < 12 ? "AM" : "PM"}],
    };

    this.format = function(date) {
      var dateTxt = this.formatString.replace(/%([A-Za-z]{1,2})/g, function(m, p) {
        var rv = date[(dateMarkers[p])[0]]();

        if ( dateMarkers[p][1] != null ) rv = dateMarkers[p][1](rv);

        return rv;

      });
      return dateTxt;
    }
  }

  function formatDate(d) {
    var fmt = new DateFmt("%w %n %d %y - %h:%M %tt");
    var v = fmt.format(d);
    return v;
  }

  function currencyFormat(number) {
    var decimalplaces = 2;
    var decimalcharacter = ".";
    var thousandseparater = ",";
    number = parseFloat(number);
    var sign = number < 0 ? "-" : "";
    var formatted = new String(number.toFixed(decimalplaces));
    if( decimalcharacter.length && decimalcharacter != "." ) { formatted = formatted.replace(/\./,decimalcharacter); }
    var integer = "";
    var fraction = "";
    var strnumber = new String(formatted);
    var dotpos = decimalcharacter.length ? strnumber.indexOf(decimalcharacter) : -1;
    if( dotpos > -1 )
    {
      if( dotpos ) { integer = strnumber.substr(0,dotpos); }
      fraction = strnumber.substr(dotpos+1);
    }
    else { integer = strnumber; }
    if( integer ) { integer = String(Math.abs(integer)); }
    while( fraction.length < decimalplaces ) { fraction += "0"; }
    temparray = new Array();
    while( integer.length > 3 )
    {
      temparray.unshift(integer.substr(-3));
      integer = integer.substr(0,integer.length-3);
    }
    temparray.unshift(integer);
    integer = temparray.join(thousandseparater);
    return sign + integer + decimalcharacter + fraction;
  }

  var Photo = function(args) {
      if (typeof args == 'undefined') { args = {}; }
      this.photo_link = args.photo_link;
      this.highres_link = args.highres_link;
      this.thumb_link = args.thumb_link;
      this.photo_id = args.photo_id;
  }

  var Member = function(args){
    if (typeof args == 'undefined') { args = {}; }
    this.name = args.name;
    this.id = args.member_id;
    this.photo = args.photo;

  };
  
  var Group = function(args){
    if (typeof args == 'undefined') { args = {}; }
    this.id = args.id;
    this.name = args.name;
    this.urlname = args.urlname;
    this.join_mode = args.join_mode;
    this.who = args.who;
    this.group_lat = args.group_lat;
    this.group_lon = args.group_lon;
    this.photo = args.photo;
  };

  var EventVenue = function(args){
    if (typeof args == 'undefined') { args = {}; }
    this.id = args.id;
    this.zip = args.zip;
    this.phone = args.phone;
    this.lon = args.lon;
    this.lat = args.lat;
    this.name = args.name;
    this.state = args.state;
    this.address_1 = args.address_1;
    this.city = args.city;
    this.country = args.country;
  };

  EventVenue.prototype.location = function() {
    if (typeof args == 'undefined') { args = {}; }
    var str = this.address_1 + ", " + this.city + ", " + this.state;
    if (args.includeCountry) {
      str = str + " " + this.country;
    }
    return str;
  };

  var EventFee = function(args){
    if (typeof args == 'undefined') { args = {}; }
    currencyMap = {
      USD: '$',
      CAD: '$',
      AUD: '$',
      EUR: '&euro;',
      GBP: '&163;',
      BRL: '&82;&36;'
    };
    this.amount = args.amount;
    this.description = args.description;
    this.label = args.label;
    this.required = args.required;
    this.accepts = args.accepts;
    this.currency = args.currency;
    this.currencySymbol = (currencyMap[this.currency] ? currencyMap[this.currency] : "$");
  };

  EventFee.prototype.formatAmount = function() {
    if (this.formatedAmount) {
      return this.formatedAmount;
    }
    else if (this.amount) {
      this.formatedAmount = this.currencySymbol + currencyFormat(this.amount);
      return this.formatedAmount;
    }
    else {
      return "";
    }
  }

  var Event = function(args){
    if (typeof args == 'undefined') { args = {}; }
    this.id = args.id;
    this.name = args.name;
    this.description = args.description;
    this.status = args.status;
    this.time = args.time;
    this.duration = args.duration;
    this.utc_offset = args.utc_offset;
    this.updated = args.updated;
    this.created = args.created;
    this.event_url = args.event_url;
    this.yes_rsvp_count = args.yes_rsvp_count;
    this.waitlist_rsvp_count = args.waitlist_rsvp_count;
    this.headcount = args.headcount;
    this.how_to_find_us = args.how_to_find_us;
    if (typeof args.group != 'undefined'){
      this.group = new Group(args.group);
    }
    if (typeof args.venue != 'undefined'){
      this.venue = new EventVenue(args.venue);
    }
    if (typeof args.fee != 'undefined'){
      this.fee = new EventFee(args.fee);
    }
    if (typeof args.displayTitle != 'undefined') {
      this.displayTitle = args.displayTitle;
    }

    if (args.ajax_init) {
      if (typeof this.event_id == 'undefined'){
        throw "Must supply an event_id to populate event via ajax";
      }
      var currUrl = createEventUrl(eventId);
      debug("In Event: currUrl = " + currUrl);
      var jsonData = fetchJsonObject(currUrl);
    }
  };

  Event.prototype.startDate = function(){
    var startDate = new Date(this.time);
    var v = formatDate(startDate);
    //var v = startDate.format("dateAndTime");
    return v;
  };

  Event.prototype.endDate = function(){
    if (typeof this.duration == 'undefined') {
      return null;
    }
    else {
      var d = new Date(this.time);
      d.setSeconds(d.getSeconds() + this.duration);
      //var v = d.format("dateAndTime");
      var v = formatDate(d);
      return v;
    }
  };

  var ApiUrls = function(args) {
    if (typeof args == 'undefined') {
      throw "Must pass in hash of items to ApiUrls.new";
    }
    if (typeof args.allEventsUrl == 'undefined') {
      throw "Must supply 'allEventsUrl' as arg to ApiUrls.new";
    }

    var rsvpUrls = args.rsvpUrls;
    var allRsvpsUrl = args.allRsvpsUrl;
    //Unless allRsvpUrls or rsvpUrls are passed as an arg, 
    //throw an error 
    if (!rsvpUrls) {
      if (!allRsvpsUrl) {
        throw "Must supply 'allRsvpsUrl' or 'rsvpUrls' as an arg to ApiUrls.new"
      }
    }
    else if (!(rsvpUrls.constructor === Array)) {
      throw "rsvpUrls must be an Array of urls";
    }
  
    this.primaryEventUrl = args.primaryEventUrl;
    this.allEventsUrl = args.allEventsUrl;
    this.allRsvpsUrl = args.allRsvpsUrl;
    this.rsvpUrls = args.rsvpUrls;
  }

  ApiUrls.prototype.numRsvpUrls = function() {
    this.rsvpUrls.length;
  }

  var EventList = function(eventList){
    this.eventArray = [];
    if (eventList) {
      if (eventList instanceof Array) {
        for(var i=0, l=eventList.length; i<l; i++){
          this.eventArray.push(new Event(eventList[i]));
        }
      }
      else {
        throw "eventList must be an Array of Event items";
      }
    }
    
  };

  EventList.prototype.logSummery = function(){
    console.log("Num Events: " + this.eventArray.length);
    console.log(this);
  }

  EventList.prototype.getNumEvents = function(){
    return this.eventArray.length;
  }

  EventList.prototype.getEvents = function(){
    return this.eventArray;
  }

  EventList.prototype.getEventById = function(eventId){
    var retEvent = null;
    var currEvent = null;
    var eventArr = this.eventArray;
    debug("About to loop through eventArr. length = " + eventArr.length);
    for(var i=0, l=eventArr.length; i<l; i++){
      currEvent = eventArr[i];
      debug("i = " + i);
      debug("Checking currEvent.id against eventId: '" + currEvent.id + "','" + eventId + "'");
      if (currEvent.id == eventId) {
        retEvent = currEvent;
        break;
      }
    }
    return retEvent;
  }

  EventList.prototype.addEventInfo = function(eventObj){
    if (typeof eventObj == 'undefined') {
      throw "Must pass in an Event"
    }
    if (typeof eventObj.id == 'undefined') {
      throw "Event does not have valid id"
    }
    this.eventArray.push(eventObj);
  }

  var Rsvp = function(args){
    if (typeof args == 'undefined') { args = {}; }
    this.response = args.response;
    this.member = args.member;
    this.member_url = args.member_url;
    this.created = args.created;
    this.mtime = args.mtime;
    this.pay_status = args.pay_status;
    this.guests = args.guests;
    this.rsvp_id = args.rsvp_id;
    this.eventsRsvpdTo = args.eventsRsvpdTo || [];
  };

  var RsvpList = function(){
    this.rsvpYesArray = [];
    this.rsvpNoArray = [];
    this.uniqueYesUserIds = {};
    this.uniqueNoUserIds = {};
    this.numYesDups = 0;
    this.numNoDups = 0;
  };

  RsvpList.prototype.logSummery = function(){
    console.log("Num Yes: " + this.rsvpYesArray.length);
    console.log("Num No: " + this.rsvpNoArray.length);
    console.log("Num Yes Dups: " + this.numYesDups);
    console.log("Num No Dups: " + this.numNoDups);
    console.log(this);
  }

  RsvpList.prototype.getSortedRsvps = function (listType, sortBy) {
    if (typeof listType == "undefined") {
      throw "Must pass in listType as first param to getSortedRsvps";
    }
    if (typeof sortBy == "undefined") {
      throw "Must pass in sortBy as second param to getSortedRsvps";
    }
    var ret;
    switch (listType) {
      case MEETUP_YES:
        ret = this.rsvpYesArray;
        break;
      case MEETUP_NO:
        ret = this.rsvpNoArray;
        break;
      default:
        throw "ERROR: listType must be '" + MEETUP_YES + "' or '" + MEETUP_NO + "'";
    }
    switch (sortBy) {
      case SORT_BY_NAME:
        ret.sort(function(a,b) { return  a.member.name.localeCompare(b.member.name)} );
        break;
      case SORT_BY_FIRST_RSVP:
        ret.sort(function(a,b) { return  a.mtime - b.mtime } );
        break;
      case SORT_BY_LAST_RSVP:
        ret.sort(function(a,b) { return  b.mtime - a.mtime } );
        break;
      default:
        // do nothing
        logWarning(sortBy + " is not a valid sort type");      
      }
      return ret;
  }

  RsvpList.prototype.getYesRsvps = function(args){
    if (typeof args == 'undefined') { args = {}; }
    var ret = this.rsvpYesArray;
    switch (args.sort_by) {
      case SORT_BY_NAME:
        ret.sort(function(a,b) { return  a.member.name.localeCompare(b.member.name)} );
        break;
      case SORT_BY_FIRST_RSVP:
        ret.sort(function(a,b) { return  a.mtime - b.mtime } );
        break;
      case SORT_BY_LAST_RSVP:
        ret.sort(function(a,b) { return  b.mtime - a.mtime } );
        break;
      default:
        // do nothing
    }
    return ret;
  };

  RsvpList.prototype.getNumYesRsvps = function(args){
    return this.rsvpYesArray.length;
  };
  RsvpList.prototype.getNumNoRsvps = function(){
    return this.rsvpNoArray.length;
  };
  RsvpList.prototype.getTotalNumGuests = function(){
    var ret = 0;
    for(var i=0, l=this.rsvpYesArray.length; i<l; i++){
       var currRsvp = this.rsvpYesArray[i];
       var excludeGuests = (EXCLUDE_GUESTS.indexOf(currRsvp.member.id) >= 0);
       if (currRsvp.guests && !excludeGuests ) {
          ret += parseInt(currRsvp.guests);
       }
    }
    return ret;
  };

  RsvpList.prototype.YesRsvpForUserIdExists = function(userId){
    //debug("In YesRsvpForUserIdExists. userId = " + userId + ". unique users val = " + this.uniqueYesUserIds[userId] )
    return (this.uniqueYesUserIds[userId] === undefined ? false : true);
  };

  RsvpList.prototype.NoRsvpForUserIdExists = function(userId){
    return (this.uniqueNoUserIds[userId] === undefined ? false : true)
  };

  RsvpList.prototype.addYesRsvp = function(rsvp){
    if (typeof rsvp.member.id == 'undefined') {
      throw "Rsvp does not have valid member object"
    }
    if (this.YesRsvpForUserIdExists(rsvp.member.id)) {
      debug("Got Dup for id: " + rsvp.member.id);
      this.numYesDups++;
    }
    else {
      this.rsvpYesArray.push(rsvp);
      this.uniqueYesUserIds[rsvp.member.id] = this.rsvpYesArray.length - 1;
    }

  };

  RsvpList.prototype.addNoRsvp = function(rsvp){
    if (typeof rsvp.member.id == 'undefined') {
      throw "Rsvp does not have valid member object"
    }
    if (this.NoRsvpForUserIdExists(rsvp.member.id)) {
      this.numNoDups++;
    }
    else {
      this.rsvpNoArray.push(rsvp);
      this.uniqueNoUserIds[rsvp.member.id] = this.rsvpNoArray.length - 1;
    }

  };

  RsvpList.prototype.addRsvp = function(rsvp){
    if (typeof rsvp.member.id == 'undefined') {
      throw "Rsvp does not have valid member object"
    }
    switch (rsvp.response) {
      case MEETUP_YES:
        debug("Got 'yes' response")
        this.addYesRsvp(rsvp);
        break;
      case MEETUP_NO:
        this.addNoRsvp(rsvp);
        break;
      default:
        var errMsg = "Warning. Inavlid response given: " + rsvp.response
        console.log(errMsg);
    }
  };

  RsvpList.prototype.addRsvpData = function(rsvpData){
    if (typeof rsvpData == 'undefined') {
      throw "No argument passed to addRsvpData"
    }
    var rsvpArgs = {};
    var rsvp = null;
    var currMemberData = rsvpData.member;  
    if (typeof currMemberData == 'undefined'){
      throw "No Member in rsvpData";
    }
    if (typeof rsvpData.response == 'undefined'){
      throw "No response in rsvpData";
    }
    var currResponse = rsvpData.response;
    if ( !( (currResponse === MEETUP_YES) || (currResponse === MEETUP_NO) ) ){
      console.log("WARNING: rsvp response: '" + currResponse + "' invalid. must be '" + MEETUP_YES + "' or '" + MEETUP_NO + "'. invalid");
    }
    if (rsvpData.hasOwnProperty('member_photo')){
      currMemberData['photo'] = new Photo(rsvpData.member_photo);
    }
    else {
      console.log("===== NO PHOTO for user ======");
    }
    var member = new Member(currMemberData);
    var excludeUser = (EXCLUDE_USERS.indexOf(member.id) >= 0);

    if (!excludeUser) {
      rsvpArgs['member'] = member;
      rsvpArgs['response'] = currResponse = rsvpData.response;
      rsvpArgs['created'] = rsvpData.created
      rsvpArgs['mtime'] = rsvpData.mtime;
      rsvpArgs['guests'] = rsvpData.guests;
      rsvpArgs['rsvp_id'] = rsvpData.rsvp_id;
      if (globalArgs.getPayStatus) {
        rsvpArgs['pay_status'] = rsvpData.pay_status;
      }

      if (rsvpData.hasOwnProperty('group')){
        rsvpArgs.eventsRsvpdTo = [rsvpData.group.id];
      }

      rsvp = new Rsvp(rsvpArgs);
      this.addRsvp(rsvp);
    }
  };

  RsvpList.prototype.addRsvpDataList = function(data){
    if ( (typeof data == 'undefined') || !(data.length > 0) ) {
      throw "first argument must be an array of data with at least one element";
    }
    var i=0, l=0;
    var currRsvpData = null;

    for (i=0, l=data.length; i<l; i++){
      currRsvpData = data[i];
      this.addRsvpData(currRsvpData);
    }
  }; 

  function showRsvpInfo(rsvpList, args) {
    if (typeof rsvpList == 'undefined') {
      throw "first argument must be a rsvpList in showRsvpInfo";
    }
    if (typeof args == 'undefined') {
      throw "second argument must be a hash of args in showRsvpInfo";
    }

    var currTemplate, currDisplayTag, countData, showArgs, sortBy, yesList, noList;
    var numYes, numNo, numGuests, numYesWithGuests, toggleRsvps;

    if (args.displayYesRsvps) {
     currTemplate = args.yesRsvpTemplate;
      if (typeof currTemplate == 'undefined' || (!currTemplate)) {
        throw("ERROR! no yesRsvpTemplate defined");
      }
      currDisplayTag = args.yesRsvpDisplayTag;
      if (typeof currDisplayTag == 'undefined' || (!currDisplayTag)) {
        throw("ERROR! no yesRsvpDisplayTag defined");
      }
      sortBy = args.sortYesRsvpsBy ? args.sortYesRsvpsBy : DEFAULT_SORT_BY;
      yesList = rsvpList.getSortedRsvps(MEETUP_YES, sortBy);
      toggleRsvps = (typeof args.toggleYesRsvps == 'undefined') ? false : args.toggleYesRsvps;

      showArgs = {
        rsvpList: yesList,
        rsvpType: MEETUP_YES,
        rsvpTypeLabel: 'Yes',
        toggleRsvps: toggleRsvps,
        noPhotoSrc: DEFAULT_NO_PHOTO_SRC
      }
      if (args.displayYesRsvpCount) {
        numYes = rsvpList.getNumYesRsvps();
        numGuests = rsvpList.getTotalNumGuests();
        numYesWithGuests = numYes + numGuests;
        countData = {
          numRsvps: numYesWithGuests
        }
        if (numGuests > 0) {
          countData.numIndividualRsvps = numYes,
          countData.numGuestRsvps = numGuests
        }
        showArgs.countData = countData;
      }
      showTemplate({
        template: currTemplate,
        displayTag: currDisplayTag,
        templateData: showArgs
      });
    }

    if (args.displayNoRsvps) {
     currTemplate = args.noRsvpTemplate;
      if (typeof currTemplate == 'undefined' || (!currTemplate)) {
        throw("ERROR! no noRsvpTemplate defined");
      }
      currDisplayTag = args.noRsvpDisplayTag;
      if (typeof currDisplayTag == 'undefined' || (!currDisplayTag)) {
        throw("ERROR! no noRsvpDisplayTag defined");
      }
      sortBy = args.sortNoRsvpsBy ? args.sortNoRsvpsBy : DEFAULT_SORT_BY;
      noList = rsvpList.getSortedRsvps(MEETUP_NO, sortBy);
      toggleRsvps = (typeof args.toggleYesRsvps == 'undefined') ? false : args.toggleYesRsvps;

      showArgs = {
        rsvpList: noList,
        rsvpType: MEETUP_NO,
        rsvpTypeLabel: 'No',
        toggleRsvps: toggleRsvps,
        noPhotoSrc: DEFAULT_NO_PHOTO_SRC
      }

      if (args.displayNoRsvpCount) {
        numNo = rsvpList.getNumNoRsvps();
        countData = {
          numRsvps: numNo
        }
        showArgs.countData = countData;
      }
      showTemplate({
        template: currTemplate,
        displayTag: currDisplayTag,
        templateData: showArgs
      });
    }

    if (args.toggleYesRsvps || args.toggleNoRsvps) {
      console.log("=*=*=* setting up rsvp list toggles *=*=*=");
      createRsvpToggles();
    }

    initializeVisiblity({
      defaultShowYesRsvps: args.defaultShowYesRsvps,
      defaultShowNoRsvps: args.defaultShowNoRsvps
    });
  }

  function fetchAllRsvpsInfo_depricated(allRsvpsUrl) {
    if (typeof allRsvpsUrl == 'undefined') {
      throw "first argument must be allRsvpsUrl in fetchAllRsvpsInfo";
    }
    var rsvpList = new RsvpList();
    var promise = $.getJSON(allRsvpsUrl);
    promise.then(
      //success
      function(data) {
        if (data.problem) {
          error = data.problem + " : " + data.details;
          console.log("ERROR! " + error);
          showError(error);
        } 
        else if (data.results.length > 0) {
          console.log("Got data from url " + allRsvpsUrl);
          rsvpList.addRsvpDataList(data.results);
          rsvpList.logSummery();
          globalArgs.rsvpList = rsvpList;
        }
        else {
          console.log("WARNING! got no rsvp results for revpUrl " + rsvpUrl);
        }
      },
      //fail
      function ( jqxhr, textStatus, error ) {
        var err = textStatus + ", " + error;
        console.log( "Request Failed: " + err );
     //   g_rsvpLoadState = LOAD_FAILED;
        showError("Error! " + err);
        throw "Got getJSON error: " + err;
      }
    );

    return rsvpList;
  }

  function loadAndShowRsvpInfo(urlList, args, rsvpList) {
    //loadAndShowRsvpInfo is called recursivly using promises to
    //ensure that the RSVP lists are loaded in the order 
    //specified in urlList
    //NOTE - urlList and rsvpList are modifed by this function
    if (typeof urlList == 'undefined') {
      throw "first argument must be a urlList in loadAndShowRsvpInfo";
    }
    if (typeof args == 'undefined') {
      throw "second argument must be a hash of args in loadAndShowRsvpInfo";
    }
    if (urlList.length <= 0){
      throw "urlList in loadAndShowRsvpInfo must have at least one item";
    }

    if (typeof rsvpList == 'undefined') {
      rsvpList = new RsvpList();
    }
    debug("In loadAndShowRsvpInfo. urlList =");
    debug(rsvpList);

    var rsvpUrl = urlList.shift();
    debug("About to fetch data from url: " + rsvpUrl, 2);
    var promise = $.getJSON(rsvpUrl);
    promise.then(
      //success
      function(data) {
        if (data.results.length > 0) {
          console.log("Got data from url " + rsvpUrl);
          rsvpList.addRsvpDataList(data.results);
          rsvpList.logSummery();
        }
        else {
          console.log("WARNING! got no rsvp results for revpUrl " + rsvpUrl);
        }
        if (urlList.length <= 0) {
          //g_rsvpLoadState = LOAD_DONE;
          globalArgs.rsvpList = rsvpList;
          showRsvpInfo(rsvpList, args);
        }
        else {
          loadAndShowRsvpInfo(urlList, args, rsvpList);
        }
      },
      //fail
      function ( jqxhr, textStatus, error ) {
        var err = textStatus + ", " + error;
        console.log( "Request Failed: " + err );
        g_rsvpLoadState = LOAD_FAILED;
        throw "Got getJSON error: " + err;
      }
    );
  }


  var sort_by = function(field, reverse, primer){

     var key = primer ? 
         function(x) {return primer(x[field])} : 
         function(x) {return x[field]};

     reverse = [-1, 1][+!!reverse];

     return function (a, b) {
         return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
       } 
  }

  function createDataType(dataType, data) {
    var ret = null;

    switch (dataType) {
      case DATA_TYPE_EVENT_LIST:
        ret = new EventList(data.results);        
        break;
      case DATA_TYPE_PRIMARY_EVENT:
        ret = new Event(data);
        break;
      case DATA_TYPE_YES_RSVPS:
        //ret = 
        break;
      default:
        // do nothing
        logWarning("Invalid dataType: " + dataType);
    }
    debug("In createDataType: dataType = " + dataType + "ret =", 2);
    debug(ret, 2);
    return ret;
  }

  function loadData(args) {
    if (typeof args == 'undefined') {
      throw "must pass in hash of args to loadData";
    }
   var loadUrl = args.loadUrl;
   var dataType = args.dataType;
   var loadData = null;

    if (!(loadUrl && dataType)) {
      throw "Must supply values for 'loadUrl' and 'dataType' in loadData";
    }

    var promise = $.getJSON(loadUrl);
    promise.then(
      //success
      function(data){
        loadData = createDataType(dataType, data);
        return loadData;
      },
      //fail
      function ( jqxhr, textStatus, error ) {
        var err = textStatus + ", " + error;
        logWarning( "Request Failed: " + err );
        throw "Got getJSON error: " + err;
      }
    ); 
  }

  function loadAndShowData(args) {
    if (typeof args == 'undefined') {
      throw "must pass in hash of args to loadAndShowData";
    }
    var loadUrl = args.loadUrl;
    var template = args.template;
    var displayTag = args.displayTag;
    var dataType = args.dataType;
    var showFunction = args.showFunction;
    var eventData = null;

    if (!(loadUrl && template && displayTag && dataType)) {
      throw "Must supply values for 'loadUrl', 'template', 'displayTag', and dataType in loadAndShowData";
    }

    var promise = $.getJSON(loadUrl);
    promise.then(
      //success
      function(data){
        eventData = createDataType(dataType, data);
        globalArgs.eventData = eventData;
        showTemplate(
        {
          template: template,
          displayTag: displayTag,    
          templateData: eventData 
        }
        );
        if (typeof showFunction != 'undefined') {
          showFunction(eventData);
        }
      },
      //fail
      function ( jqxhr, textStatus, error ) {
        var err = textStatus + ", " + error;
        logWarning( "Request Failed: " + err );
        throw "Got getJSON error: " + err;
      }
    ); 
  }

  function showTemplate(args) {
    if (typeof args == 'undefined') {
      throw "showTemplate requires an args hash parameter";
    }
  
    var template = args.template;
    var displayTag = args.displayTag;
    var data = args.templateData || {} ;
    if (typeof template == 'undefined' || 
        typeof displayTag == 'undefined') {
      throw "showTemplate requires a parameter hash containing 'template' and 'displayTag'";
    }
    debug("In showTemplate: tempate = " + template, 2);
    debug("displayTag = " + displayTag, 2);
    var displayHtml = new EJS({url: template}).render(data);
    debug("New HTML = " + displayHtml, 3);
    $(displayTag).html(displayHtml);
  }

  function validateIdList(idArray){
    var i;
    var l = idArray.length;
    var matcher = /^\d+$/;
    var currId;
    var badIds = []
    for(i=0; i<l; i++){
      currId = idArray[i];
      if (!(currId.match(matcher))) {
        badIds.push(currId);
      }
    }
    ret = true;
    if (badIds.length > 0) {
      console.log("ERROR! Got " + badIds.length + " bad event ids: " + badIds);
      ret = false
    }

    return ret;
  }

  //strips leading or trailing white space from each element in array
  //NOTE- Modifies idArray
  function stripWhiteSpace(idArray){
    var i;
    var l = idArray.length;
    var matcher = /^\s*(\d+)\s*$/;
    var currId;
    var newId;
    for(i=0; i<l; i++){
      currId = idArray[i];
      newId = currId.replace(matcher, '$1');
      idArray[i] = newId;
    }
  }

  function createEventsUrl(eventIdList, meetupKey, eventFields){
     if (typeof eventIdList == 'undefined' || typeof meetupKey == 'undefined') {
      throw "need to pass in eventIdList and meetupKey to createEventsUrl";
    }
 
    var eventIdListVar = eventIdList.join();
    var fieldsText = "";

    if (notEmpty(eventFields)) {
      fieldsText = "&fields=" + eventFields;
    }
 
    return MEETUP_API_EVENTS_URL + "?event_id=" + eventIdListVar + "&key=" + meetupKey + fieldsText + "&callback=?";
  }

  function createEventUrl(eventId, meetupKey, eventFields){
    if (typeof eventId == 'undefined' || typeof meetupKey == 'undefined') {
      throw "need to pass in eventId and meetupKey to createEventUrl";
    }
    var fieldsText = "";
 
    if (notEmpty(eventFields)) {
      fieldsText = "&fields=" + eventFields;
      console.log("fieldsText = " + fieldsText);
    }
 
    return MEETUP_API_EVENT_URL + "/" + eventId + "?key=" + meetupKey + fieldsText + "&callback=?";
  }

  function createAllRsvpsUrl(eventIdList, meetupKey, eventFields){
     if (typeof eventIdList == 'undefined' || typeof meetupKey == 'undefined') {
      throw "need to pass in eventIdList and meetupKey to createAllRsvpsUrl";
    }
 
    var eventIdListVar = eventIdList.join();
    var fieldsText = "";

    if (notEmpty(eventFields)) {
      fieldsText = "&fields=" + eventFields;
    }
 
    return MEETUP_API_RSVP_URL+ "?event_id=" + eventIdListVar + "&key=" + meetupKey + fieldsText + "&callback=?";
  }

  function createRsvpUrl(eventId, meetupKey, rsvpFields){
    if (typeof eventId == 'undefined' || typeof meetupKey == 'undefined') {
      throw "need to pass in eventId and meetupKey to createRsvpUrl";
    }

    var fieldsText = "";
    //Note to get pay_status field will return paid status
    //if (typeof rsvpFields != 'undefined') {
    if (notEmpty(rsvpFields)) {
      fieldsText = "&fields=" + rsvpFields;
    }
  
    return MEETUP_API_RSVP_URL + "?event_id=" + eventId + "&key=" + meetupKey + fieldsText + "&callback=?";
  }

  function buildApiUrls(args) {
    if (typeof args == 'undefined') {
      throw "Must pass in a hash of args to buildApiUrls";
    }
    var eventIdList = args.eventIdList; 

    var meetupKey  = args.meetupKey;
    var eventApiFields = args.eventApiFields;
    var rsvpApiFields = args.rsvpApiFields;
    var primaryEventId = args.primaryEventId;
    var allRsvpsApiUrl = args.allRsvpsApiUrl;
    var allEventsApiUrl = args.allEventsApiUrl;
    var fetchAllRsvpsAtOnce = args.fetchAllRsvpsAtOnce;

    var retObj = null;
    var retAllEventsUrl = null;
    var retAllRsvpsUrl = null;
    var retRsvpsUrlList = null;
    var retPrimaryEventUrl = null;

    //unless allRsvpsApirUrl and allEventsApiUrl are passed in check to make
    //sure eventIdList && meetupKey are present in the args
    if (!(allRsvpsApiUrl && allEventsApiUrl)) {
      if (!(eventIdList && meetupKey)) {
        throw "Must pass eventIdList and meetupKey as args to buildApiUrls";
      }
    }

    if (fetchAllRsvpsAtOnce) {
      if (allRsvpsApiUrl) {
        retAllRsvpsUrl = addCallbackToUrl(allRsvpsApiUrl);
      }
      else {
        retAllRsvpsUrl = createAllRsvpsUrl(eventIdList, meetupKey, eventApiFields);
      }
    }
    else {
      var retRsvpsUrlList = [];
      var currId;
      var currRsvpUrl;

      for(var i=0, l=eventIdList.length; i<l; i++){
        currId = eventIdList[i];
        currRsvpurl = createRsvpUrl(currId, meetupKey, rsvpApiFields);
        retRsvpsUrlList.push(currRsvpurl);
      }
    }

    if (allEventsApiUrl) {
      retAllEventsUrl = addCallbackToUrl(allEventsApiUrl);
    }
    else {
      retAlleventsUrl = createEventsUrl(eventIdList, meetupKey, eventApiFields);
      console.log("eventsApiUrl = " + eventsApiUrl);
    }

//    if (primaryEventId) {
//      retPrimaryEventUrl = createEventUrl(primaryEventId, meetupKey);
//    }

    console.log("About to create ApiUrls obj. allEventsUrl = " + retAllEventsUrl +
                ". allRsvpsUrl = " + retAllRsvpsUrl + 
                ". rsvpUrls = " + retRsvpsUrlList + 
                ". primaryEventUrl = " + retPrimaryEventUrl );

    var retObj = new ApiUrls ( { 
                                 allEventsUrl: retAllEventsUrl,
                                 allRsvpsUrl: retAllRsvpsUrl,
                                 rsvpUrls: retRsvpsUrlList,
                                 primaryEventUrl: retPrimaryEventUrl
                               });
    return retObj;

  }

  function showEventData(apiUrls, args, allEventsData){
    if (typeof apiUrls == 'undefined') {
      throw "Must pass in apiUrls as first element of ShowEventData";
    }
    if (typeof args == 'undefined') {
      throw "Must pass in args as second element of ShowEventData";
    }
     if (typeof eventData == 'undefined') {
      throw "Must pass in allEventsData as third element of ShowEventData";
    }
    
    var displayEventList = args.displayEventList;
    var displayPrimaryEvent = args.displayPrimaryEvent;
    //console.log("loadData = " + apiUrls.allEventsUrl);

    console.log("*** allEventsData = ");
    console.log(allEventsData);

    //If we want to display the eventList and eventInfoList is passed
    //in to the args, then show directly using the passed in args
    if (displayEventList) {
      var currTemplateData = null;
      var eventInfoList =  args.eventInfoList;
      if (typeof eventInfoList === 'undefined') {
        console.log("*** using allEventsData.");
        currTemplateData = allEventsData
      }
      else {
        currTemplateData = new EventInfoList(eventInfoList);
      }

      showTemplate( { 
        template: args.eventListTemplate,
        displayTag: args.eventListDisplayTag,
        templateData: currTemplateData
      });
    }

    if (displayPrimaryEvent) {
      var primaryEventId = args.primaryEventId;

      if (!primaryEventId) {
        throw "args.primaryEventId missing in showEventData"
      }
      var displayPrimaryEventTitle = args.displayPrimaryEventTitle;
      var primaryEvent = allEventsData.getEventById(primaryEventId)
  
      if (!primaryEvent) {
        throw "Could not get the primary event with id " + primaryEventId ;
      }
      //Display the primary event template
      showTemplate(
      {
        template: args.primaryEventTemplate,
        displayTag: args.primaryEventDisplayTag,
        templateData: primaryEvent
      });

      if (displayPrimaryEventTitle) {
        showTitle(primaryEvent);
      }
    }

  }

  function fetchAndShowEventData(apiUrls, args){
    if (typeof apiUrls == 'undefined') {
      throw "Must pass in apiUrls as first element of fetchAndShowEventData";
    }
    if (typeof args == 'undefined') {
      throw "Must pass in args as second element of fetchAndShowEventData";
    }
 
    var loadUrl = apiUrls.allEventsUrl;

    if (!loadUrl) {
      throw "apiUrls.allEventsUrl is not defined in fetchAndShowEventData";
    }

    var promise = $.getJSON(loadUrl);
    promise.then(
      //success
      function(data){
        if (data.problem) {
          error = data.problem + " : " + data.details;
          console.log("ERROR! " + error);
          showError(error);
        }
        else {
          eventData = createDataType(DATA_TYPE_EVENT_LIST, data);
          globalArgs.eventData = eventData;
          showEventData(apiUrls, args, eventData);
        }
      },
      //fail
      function ( jqxhr, textStatus, error ) {
        var err = textStatus + ", " + error;
        logWarning( "Request Failed: " + err );
        showError("ERROR! " + err);
        throw "Got getJSON error: " + err;
      }
    );    
  }

  function fetchAndShowRsvps(apiUrls, args) {
    if (typeof apiUrls == 'undefined') {
      throw "Must pass in apiUrls as first element of fetchAndShowRsvps";
    }
    if (typeof args == 'undefined') {
      throw "Must pass in args as second element of fetchAndShowRsvps";
    }

    var fetchAllRsvpsAtOnce = args.fetchAllRsvpsAtOnce;

    if (fetchAllRsvpsAtOnce) {
      rsvpList = new RsvpList();
      var allRsvpsUrl = apiUrls.allRsvpsUrl;
      if (!allRsvpsUrl) {
        throw "apiUrls.allRsvpsUrl not defined in fetchAndShowRsvps";
      }
      var promise = $.getJSON(allRsvpsUrl);
      debug("About to get url " + allRsvpsUrl, 2)
      promise.then(
      //success
      function(data){
        console.log("*** Data = ")
        console.log(data)
        var error = null;
        if (data.problem) {
          error = data.problem + " : " + data.details;
          console.log("ERROR! " + error);
          showError(error);
        }
        else if (data.results.length > 0) {
          console.log("Got data from url " + allRsvpsUrl);
          rsvpList.addRsvpDataList(data.results);
          globalArgs.rsvpList = rsvpList;
          rsvpList.logSummery();
          showRsvpInfo(rsvpList, args);
        }
        else {
          console.log("WARNING! got no rsvp results for allRsvpsUrl " + allRsvpsUrl);
        }
        
      },
      //fail
      function ( jqxhr, textStatus, error ) {
        var err = textStatus + ", " + error;
        logWarning( "Request Failed: " + err );
        showError(err);
        throw "Got getJSON error: " + err;
      }
      );    
    }
    else 
    {
      //Make a copy of rsvpUrls
      var rsvpUrls = apiUrls.rsvpUrls.slice(0);
      loadAndShowRsvpInfo(rsvpUrls, args);
    }
  }


  var showTitle = function(event) {
    if (typeof event.name == 'undefined') {
      console.log("WARNING! event.name is undefined in showTitle");
    }
    else {
      $('title').html(event.name);
    }
  }

  var showError = function(error, args) {
    if (typeof error == 'undefined') {
      throw("ERROR! error is undefined in showError");
    }
    if (typeof args == 'undefined') {
      args = {};
    }
    var tag = args.errorTag || DEFAULT_ERROR_TAG;
    var showGen = 
    (typeof globalArgs.useGeneralErrorMessage == 'undefined') ? 
    DEFAULT_USE_GENERAL_ERROR_MESSAGE : globalArgs.useGeneralErrorMessage;
    error = showGen ? DEFAULT_GENERAL_ERROR_MESSAGE : error;
    $(tag).html(error);
  }

  var createRsvpToggles = function() {
    var rsvpToggleIcon, isVisible;
 
    $(RSVP_YES_TOGGLE_ID).click(function (event) {
       debug("**** In toggle-yes-rsvps ***", 4);
       $(RSVP_YES_LIST_ID).toggle();
       isVisible = $(RSVP_YES_LIST_ID).is(":visible");
       rsvpToggleIcon = isVisible ? RSVP_TOGGLE_ICON_CLOSE : RSVP_TOGGLE_ICON_OPEN;
       debug("isVisible = " + isVisible + ". rsvpToggleIcon = " + rsvpToggleIcon, 4);
       $(RSVP_YES_TOGGLE_ICON_ID).attr('class', rsvpToggleIcon);
       event.preventDefault();
    });
   
    $(RSVP_NO_TOGGLE_ID).click(function (event) {
       debug("**** In toggle-no-rsvps ***", 4);
       $(RSVP_NO_LIST_ID).toggle();
       isVisible = $(RSVP_NO_LIST_ID).is(":visible");
       rsvpToggleIcon = isVisible ? RSVP_TOGGLE_ICON_CLOSE : RSVP_TOGGLE_ICON_OPEN;
       $(RSVP_NO_TOGGLE_ICON_ID).attr('class', rsvpToggleIcon);
      event.preventDefault();
    });
  }

  var initializeVisiblity = function(args) {
    if (args.defaultShowYesRsvps) {
      $(RSVP_YES_LIST_ID).show();
      $(RSVP_YES_TOGGLE_ICON_ID).attr('class', RSVP_TOGGLE_ICON_CLOSE);
    }
    else {
      $(RSVP_YES_LIST_ID).hide();
      $(RSVP_YES_TOGGLE_ICON_ID).attr('class', RSVP_TOGGLE_ICON_OPEN);
    }

    if (args.defaultShowNoRsvps) {
      console.log("Showing No!");
      $(RSVP_NO_LIST_ID).show();
      $(RSVP_NO_TOGGLE_ICON_ID).attr('class', RSVP_TOGGLE_ICON_CLOSE);
    }
    else {
      console.log("Hiding No!");
      $(RSVP_NO_LIST_ID).hide();
      $(RSVP_NO_TOGGLE_ICON_ID).attr('class', RSVP_TOGGLE_ICON_OPEN);
    }
  }

  $.fn.loadEventData = function( options ) {
    //Default settings
    var settings = $.extend( {
      displayPrimaryEvent  : true,
      displayPrimaryEventTitle : true,
      displayEventList     : true,
      displayRsvpCount     : true,
      displayYesRsvpCount  : true,
      displayNoRsvpCount   : true,
      displayYesRsvps      : true,
      displayNoRsvps       : true,
      defaultShowYesRsvps  : true,
      defaultShowNoRsvps   : false,
      toggleYesRsvps       : true,
      toggleNoRsvps        : true,
      fetchAllRsvpsAtOnce  : true,
      fetchAllEventsAtOnce : true,
      eventApiFields       : "",
      rsvpApiFields        : "",
      allEventsApiUrl      : "",
      allRsvpsApiUrl       : "",
      sortYesRsvpsBy       : SORT_BY_LAST_RSVP,
      sortNoRsvpsBy       : SORT_BY_LAST_RSVP,
      getPayStatus        : false,
      useGeneralErrorMessage : DEFAULT_USE_GENERAL_ERROR_MESSAGE,
      primaryEventIndex    : 0,
      primaryEventDisplayTag: DEFAULT_PRIMARY_EVENT_DISPLAY_TAG,
      eventListDisplayTag: DEFAULT_EVENT_LIST_DISPLAY_TAG,
      yesRsvpDisplayTag: DEFAULT_YES_RSVP_DISPLAY_TAG,
      noRsvpDisplayTag:  DEFAULT_NO_RSVP_DISPLAY_TAG,
      yesRsvpTemplate:   DEFAULT_YES_RSVP_TEMPLATE,
      noRsvpTemplate:     DEFAULT_NO_RSVP_TEMPLATE,
      primaryEventTemplate:     DEFAULT_EVENT_TEMPLATE,
      eventListTemplate: DEFAULT_EVENT_LIST_TEMPLATE,
    }, options);


    var apiUrls = settings.apiUrls;
    var eventIdList = settings.eventIdList;
    var eventInfoList = settings.eventInfoList;
    var meetupKey = settings.meetupKey;
    var displayEventList = settings.displayEventList;
    var displayPrimaryEvent = settings.displayPrimaryEvent;
    var displayYesRsvps = settings.displayYesRsvps;
    var displayNoRsvps = settings.displayNoRsvps;   
    var pageTitle = settings.pageTitle;
    var displayPrimaryEventTitle = settings.displayPrimaryEventTitle;
    var allRsvpsApiUrl = settings.allRsvpsApiUrl;
    var allEventsApiUrl = settings.allEventsApiUrl;
    var useGeneralErrorMessage = settings.useGeneralErrorMessage;
    var fetchAllRsvpsAtOnce  = settings.fetchAllRsvpsAtOnce;
//    var fetchAllEventsAtOnce = settings.fetchAllEventsAtOnce
 
    var primaryEventId = null;
    var eventList = null;

    globalArgs.getPayStatus = settings.getPayStatus;
    globalArgs.useGeneralErrorMessage = useGeneralErrorMessage;


    if (pageTitle) {
      $('title').html(pageTitle);
      $('#pageTitle').html(pageTitle);
    }

    if (eventIdList) {
      //Make sure a eventIdList is formated corectly if passed in
      if (!validateIdList(eventIdList)) {
        throw "eventIdList must be an array of numbers";
      }
    }

    if (displayPrimaryEvent) {
      console.log("allEventsApiUrl = " + allEventsApiUrl);
      if (settings.primaryEventId) {
        primaryEventId = settings.primaryEventId;
      }
      else {
        if (eventIdList) {
          var ind = settings.primaryEventIndex ? settings.primaryEventIndex : 0;
          primaryEventId = eventIdList[ind];
        }
        else if (allEventsApiUrl) {
          console.log("*** Getting id from allEventsApiUrl");
          primaryEventId = getFirstEventIdFromUrl(allEventsApiUrl);
        }
        console.log("before check. primaryEventId = " + primaryEventId);
        if (!primaryEventId) {
          throw "Could not get primaryEventId from eventIdList or allEventsApiUrl!";
        }
      }
    }

    if (typeof apiUrls == 'undefined') {
      if (!(allRsvpsApiUrl && allEventsApiUrl)) {
        if (typeof eventIdList == 'undefined' || typeof meetupKey == 'undefined') {
          throw "Must supply either apiUrls or eventIdList and meetup_key as options to loadEventData";
        }
      }
  
      apiUrls = buildApiUrls( { eventIdList: eventIdList, 
                                meetupKey:  meetupKey,
                                eventApiFields: settings.eventApiFields,
                                rsvpApiFields: settings.rsvpApiFields,
                                primaryEventId: primaryEventId,
                                allRsvpsApiUrl: allRsvpsApiUrl,
                                allEventsApiUrl: allEventsApiUrl,
                                fetchAllRsvpsAtOnce: fetchAllRsvpsAtOnce,
                              } );
     
    }

    eventArgs = {
      displayEventList: displayEventList,
      eventInfoList: eventInfoList,
      eventListTemplate: settings.eventListTemplate,
      eventListDisplayTag: settings.eventListDisplayTag,
      displayEventList: displayEventList,
      primaryEventId: primaryEventId,
      primaryEventTemplate: settings.primaryEventTemplate,
      primaryEventDisplayTag: settings.primaryEventDisplayTag,
      displayPrimaryEventTitle: displayPrimaryEventTitle,
      displayPrimaryEvent: displayPrimaryEvent
    }

    fetchAndShowEventData(apiUrls, eventArgs);

    if (displayYesRsvps || displayNoRsvps) {
      fetchAndShowRsvps(apiUrls, settings);
    }

    $(REFRESH_RSVP_LIST_ID).click(function (event) {
      event.preventDefault();
//      var newRsvpUrls = apiUrls.rsvpUrls.slice(0);
//      loadAndShowRsvpInfo(newRsvpUrls, settings);
        fetchAndShowRsvps(apiUrls, settings)
      console.log('**** Reloading Rsvp List ***');
    });

    $(SORT_SELECT_ID).change(function() {
      console.log("** #sort_by change event!!!");
      var sortType = $(this).val();
      settings['sortYesRsvpsBy'] = sortType;
      settings['sortNoRsvpsBy'] = sortType;
      if (globalArgs.rsvpList) {
        showRsvpInfo(globalArgs.rsvpList, settings);
      }
      else {
        fetchAndShowRsvps(apiUrls, settings);
      }
    });

  }

})(jQuery);