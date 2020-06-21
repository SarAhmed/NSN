var CURRENT_SESSION_ID;
getCurrentSessionID();
var CURRENT_EVENT_ID;
getViewedEventSession();
setTimeout(function() {
  viewGoingMembers();
  displayDescription();
  displayToBeInvited();
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
      membersWrapper.innerHTML = "<h4>Event Attenders</h4>";
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

function displayToBeInvited() {
  var inviteMemWrapper = document.getElementById("inviteMemWrapper");
  inviteMemWrapper.innerHTML = "<h6>Invite More Members</h6>";
  var neighbours;
  var joined;

  var xmlhttp1 = new XMLHttpRequest();
  xmlhttp1.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      // alert(this.responseText+"neighbours");
      neighbours = JSON.parse(this.responseText);
    }
  };
  xmlhttp1.open("GET", "viewNeighbours.php?myId=" + CURRENT_SESSION_ID, true);
  xmlhttp1.send();

  var xmlhttp = new XMLHttpRequest();
  xmlhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      // alert(this.responseText+"alreadymaugodenn");
      joined = JSON.parse(this.responseText);
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
  setTimeout(function() {
    var i = 0;
    var neighboursId = [];
    for (i = 0; i < neighbours.length; i++) {
      neighboursId.push(neighbours[i]["id"]);
    }
    var joinedId = [];
    for (i = 0; i < joined.length; i++) {
      joinedId.push(joined[i]["id"]);
    }

    for (i = 0; i < neighboursId.length; i++) {
      if (!joinedId.includes(neighboursId[i])) {
        let firstName = neighbours[i]["first_name"];
        let lastName = neighbours[i]["last_name"];
        let username = neighbours[i]["username"];
        let id = neighbours[i]["id"];
        let button = document.createElement("button");
        let buttonDiv = document.createElement("div");
        let inviteButton = document.createElement("button");

        button.innerHTML = firstName + " " + lastName + "<br>";
        button.innerHTML += username;
        button.id = id + "#inviteMembersButton";
        if (id == CURRENT_SESSION_ID) {
          button.addEventListener("click", function() {
            window.location.href = "http://localhost/nsn/mypersonalprofile.php";
          });
        } else {
          button.addEventListener("click", function() {
            viewNeighbourProfile(this);
          });
        }

        inviteMemWrapper.appendChild(buttonDiv);
        buttonDiv.appendChild(button);
        buttonDiv.appendChild(inviteButton);

        inviteButton.style = "flex-grow:1;background-color:green;";
        button.style = "flex-grow:4;";
        buttonDiv.style = "display:flex;";

        inviteButton.innerHTML = "invite";
        inviteButton.id = id + "#inviteToGroup";
        inviteButton.addEventListener("click", function() {
          inviteMemberToEvent(this);
        });
      }
    }
  }, 500);
}
function inviteMemberToEvent(button) {
  var xmlhttp = new XMLHttpRequest();
  var memberID = button.id.split("#")[0];
  xmlhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      // alert(this.responseText);
      // alert("assignGroupAdmin.php?myID=" + CURRENT_SESSION_ID+"&groupID="+GROUP_SESSION_ID+"&memberID="+memId);
    }
  };
  xmlhttp.open(
    "GET",
    "inviteMemberToEvent.php?creatorID=" +
      CURRENT_SESSION_ID +
      "&invitedID=" +
      memberID +
      "&eventID=" +
      CURRENT_EVENT_ID,
    true
  );
  xmlhttp.send();
}
