var CURRENT_SESSION_ID;
getCurrentSessionID();
setTimeout(function() {
  viewAvailableEvents();

  viewMyPrivateEvents();
}, 1000);

function getCurrentSessionID() {
  var xmlhttp = new XMLHttpRequest();
  xmlhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      //   alert(this.responseText);
      CURRENT_SESSION_ID = this.responseText;
      // alert(CURRENT_SESSION_ID);
    }
  };
  xmlhttp.open("GET", "getSession.php", true);
  xmlhttp.send();
}

var createEventButton = document.getElementById("createEventButton");
createEventButton.addEventListener("click", function() {
  createEvent();
});

function createEvent() {
  var description = document.getElementById("contentWrapper").value;
  var name = document.getElementById("nameWrapper").value;

  document.getElementById("contentWrapper").value = "";
  document.getElementById("nameWrapper").value = "";

  var ispublic = publicButton.style.backgroundColor == "green" ? 1 : 0;
  publicButton.style.backgroundColor = "green";
  privateButton.style.backgroundColor = "red";

  var xmlhttp = new XMLHttpRequest();
  xmlhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      //  alert(this.responseText);
    }
  };
  xmlhttp.open(
    "GET",
    "createEvent.php?myID=" +
      CURRENT_SESSION_ID +
      "&eventname=" +
      name +
      "&eventdescription=" +
      description +
      "&ispublic=" +
      ispublic,
    true
  );
  xmlhttp.send();
  setTimeout(function() {
    viewAvailableEvents();

    viewMyPrivateEvents();
  }, 500);
}

var publicButton = document.getElementById("publicButton");
var privateButton = document.getElementById("privateButton");

publicButton.addEventListener("click", function() {
  triggerpublic();
});
privateButton.addEventListener("click", function() {
  triggerpublic();
});

function triggerpublic() {
  if (publicButton.style.backgroundColor == "red")
    publicButton.style.backgroundColor = "green";
  else publicButton.style.backgroundColor = "red";

  if (privateButton.style.backgroundColor == "red")
    privateButton.style.backgroundColor = "green";
  else privateButton.style.backgroundColor = "red";
}

var availableEventsWrapper = document.getElementById("availableEvents");

function viewAvailableEvents() {
  var xmlhttp = new XMLHttpRequest();
  xmlhttp.onreadystatechange = function() {
    var availableEvents = document.getElementById("availableEvents");
    availableEvents.innerHTML = "<h5>Public Events: </h5><br>";
    if (this.readyState == 4 && this.status == 200) {
      // alert(this.responseText);
      var arr = JSON.parse(this.responseText);
      var i;
      for (i = 0; i < arr.length; i++) {
        var eventDiv = document.createElement("div");
        var button = document.createElement("div");
        var id = arr[i]["id"];
        var name = arr[i]["event_name"];
        var description = arr[i]["event_description"];
        var time = arr[i]["creation_time"];
        var firstName = arr[i]["first_name"];
        var lastName = arr[i]["last_name"];
        button.id = id + "#eventButton";
        button.innerHTML = "<h5>event name: " + name + "</h5>";
        button.innerHTML += "<h6>description: " + description + "</h6>";
        button.innerHTML += "creator: " + firstName + " " + lastName + "<br>";
        button.innerHTML += "time: " + time;

        eventDiv.appendChild(button);
        eventDiv.style =
          "display:flex;flex-direction:column;background-color:red;";
        availableEvents.appendChild(eventDiv);
      }
    }
  };
  xmlhttp.open(
    "GET",
    "viewMyAvailableEvents.php?myID=" + CURRENT_SESSION_ID,
    true
  );
  xmlhttp.send();
}

function viewMyPrivateEvents() {
  var xmlhttp = new XMLHttpRequest();
  xmlhttp.onreadystatechange = function() {
    var availableEvents = document.getElementById("privateEventsWrapper");
    availableEvents.innerHTML = "<h5>Private Events:</h5><br>";

    if (this.readyState == 4 && this.status == 200) {
      // alert(this.responseText);
      var arr = JSON.parse(this.responseText);
      var i;
      for (i = 0; i < arr.length; i++) {
        var eventDiv = document.createElement("div");
        var button = document.createElement("button");
        var id = arr[i]["event_id"];
        var name = arr[i]["event_name"];
        var description = arr[i]["event_description"];
        var time = arr[i]["creation_time"];
        var firstName = arr[i]["first_name"];
        var lastName = arr[i]["last_name"];

        button.id = id + "#eventButton";

        button.innerHTML = "<h5>event name: " + name + "</h5>";
        button.innerHTML += "<h6>description: " + description + "</h6>";
        button.innerHTML += "creator: " + firstName + " " + lastName + "<br>";
        button.innerHTML += "time: " + time;

        eventDiv.appendChild(button);
        eventDiv.style =
          "display:flex;flex-direction:column;background-color:red;";
        availableEvents.appendChild(eventDiv);
        button.addEventListener("click", function() {
          setEventSession(this);
        });
      }
    }
  };
  xmlhttp.open("GET", "viewMyGoingEvents.php?myID=" + CURRENT_SESSION_ID, true);
  xmlhttp.send();
}

function setEventSession(button) {
  var eventId;
  if (button != null) {
    eventId = button.id.split("#")[0];
    setViewedEventSession(eventId);
    // alert(groupId);
    setTimeout(function() {
      //to be added
      isEventOrganizer(eventId);
    }, 250);
  }
}

function isEventOrganizer(eventId) {
  var xmlhttp = new XMLHttpRequest();
  xmlhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      // alert("isEventOrganizer.php?myID=" + CURRENT_SESSION_ID+"&eventID="+eventId);
      // alert(this.responseText);
      var arr = JSON.parse(this.responseText);
      if (arr[0]["checkBit"] == 1) {
        window.location.href = "http://localhost/nsn/creatorPrivateEvent.php";
      } else {
        window.location.href = "http://localhost/nsn/PrivateEventPage.php";
      }
    }
  };
  xmlhttp.open(
    "GET",
    "isEventOrganizer.php?myID=" + CURRENT_SESSION_ID + "&eventID=" + eventId,
    true
  );
  xmlhttp.send();
}

function setViewedEventSession(viewedEvent) {
  var xmlhttp = new XMLHttpRequest();
  xmlhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
    }
  };
  xmlhttp.open(
    "GET",
    "setViewedEventSession.php?viewedEvent=" + viewedEvent,
    true
  );
  xmlhttp.send();
}
