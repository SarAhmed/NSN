var CURRENT_SESSION_ID;
getCurrentSessionID();
var CURRENT_EVENT_ID;
getViewedEventSession();
setTimeout(function() {
  viewGoingMembers();
  displayDescription();
}, 500);

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

function getViewedEventSession() {
  var xmlhttp = new XMLHttpRequest();
  xmlhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      //   alert(this.responseText);
      CURRENT_EVENT_ID = this.responseText;
      // alert(CURRENT_EVENT_ID);
    }
  };
  xmlhttp.open("GET", "getViewedEventSession.php", true);
  xmlhttp.send();
}

function viewGoingMembers() {
  var xmlhttp = new XMLHttpRequest();
  xmlhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      //   alert(this.responseText);
      // alert(this.responseText);
      var arr = JSON.parse(this.responseText);
      var i;
      var membersWrapper = document.getElementById("membersWrapper");
      membersWrapper.innerHTML = "<h4>Group Members</h4>";
      for (i = 0; i < arr.length; i++) {
        let firstName = arr[i]["first_name"];
        let lastName = arr[i]["last_name"];
        let username = arr[i]["username"];
        let id = arr[i]["id"];
        let button = document.createElement("button");

        button.innerHTML = firstName + " " + lastName + "<br>";
        button.innerHTML += username;
        button.id = id + "#EventMembersButton";
        if (id == CURRENT_SESSION_ID) {
          button.addEventListener("click", function() {
            window.location.href = "http://localhost/nsn/mypersonalprofile.php";
          });
        } else {
          button.addEventListener("click", function() {
            viewNeighbourProfile(this);
          });
        }

        membersWrapper.appendChild(button);
      }
    }
  };
  xmlhttp.open(
    "GET",
    "viewGoingMembers.php?myID=" +
      CURRENT_SESSION_ID +
      "&eventID=" +
      CURRENT_EVENT_ID,
    true
  );
  xmlhttp.send();
}

function viewNeighbourProfile(button) {
  var neighbourID;
  if (button != null) {
    neighbourID = button.id.split("#")[0];
    setViewedMemberSession(neighbourID);
    setTimeout(function() {
      window.location.href = "http://localhost/nsn/personalprofile.php";
    }, 500);
  }
}

function setViewedMemberSession(id) {
  var xmlhttp = new XMLHttpRequest();
  xmlhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
    }
  };
  xmlhttp.open("GET", "setViewedMember.php?viewedMemberId=" + id, true);
  xmlhttp.send();
}

function displayDescription() {
  var DescriptionWrapper = document.getElementById("DescriptionWrapper");
  var xmlhttp = new XMLHttpRequest();
  xmlhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      DescriptionWrapper.innerHTML = "<h4>Event Info</h4>";
      var arr = JSON.parse(this.responseText);
      var name = arr[0]["event_name"];
      var description = arr[0]["event_description"];
      var time = arr[0]["creation_time"];
      var firstName = arr[0]["first_name"];
      var lastName = arr[0]["last_name"];
      DescriptionWrapper.innerHTML += "<h5>event name: " + name + "</h5>";
      DescriptionWrapper.innerHTML += "Creator: " + firstName + " " + lastName;
      DescriptionWrapper.innerHTML +=
        "<h6>description: " + description + "</h6>";
      DescriptionWrapper.innerHTML += "time: " + time;
    }
  };
  xmlhttp.open("GET", "getEventInfo.php?eventID=" + CURRENT_EVENT_ID, true);
  xmlhttp.send();
}
