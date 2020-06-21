var CURRENT_SESSION_ID;
var groupId = null;
getCurrentSessionID();
setTimeout(function() {
  viewMyNeighbours();
  displayNeighboursNews();
  getEventRequests();
  getGroupRequest();
}, 500);

var viewMyNeighboursButton = document.getElementById("viewMyNeighboursButton");
// viewMyNeighboursButton.addEventListener("click", function() {
//   viewMyNeighbours();
// });
function viewMyNeighbours() {
  var neighboursWrapper = document.getElementById("neighboursWrapper");
  var xmlhttp = new XMLHttpRequest();
  neighboursWrapper.innerHTML = "<h4>Neighbours</h4>";
  xmlhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      var arr = JSON.parse(this.responseText);
      var i;
      for (i = 0; i < arr.length; i++) {
        let firstName = arr[i]["first_name"];
        let lastName = arr[i]["last_name"];
        let username = arr[i]["username"];
        let id = arr[i]["id"];
        let button = document.createElement("button");
        button.innerHTML = firstName + " " + lastName + "<br>";
        button.innerHTML += username;
        button.id = id + "#neighboursButton";
        button.addEventListener("click", function() {
          viewNeighbourProfile(this);
        });
        neighboursWrapper.appendChild(button);
      }
    }
  };
  var myId = CURRENT_SESSION_ID;
  xmlhttp.open("GET", "viewNeighbours.php?myId=" + myId, true);
  xmlhttp.send();
}

function getCurrentSessionID() {
  var xmlhttp = new XMLHttpRequest();
  xmlhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      //   alert(this.responseText);
      CURRENT_SESSION_ID = this.responseText;
    }
  };
  xmlhttp.open("GET", "getSession.php", true);
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
var buttonShare = document.getElementById("buttonShare");
buttonShare.addEventListener("click", function() {
  postNews();
  setTimeout(function() {
    displayNeighboursNews();
  }, 250);
});
function postNews() {
  var xmlhttp = new XMLHttpRequest();
  var contentWrapper = document.getElementById("content");
  var content = contentWrapper.value;

  xmlhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
    }
  };
  xmlhttp.open(
    "GET",
    "postNews.php?myID=" + CURRENT_SESSION_ID + "&content=" + content,
    true
  );
  xmlhttp.send();
  contentWrapper.value = "";
}

function displayNeighboursNews() {
  var xmlhttp = new XMLHttpRequest();

  xmlhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      var arr = JSON.parse(this.responseText);
      var i = 0;
      var postWrapper = document.getElementById("postWrapper");
      postWrapper.innerHTML = "";
      for (i = 0; i < arr.length; i++) {
        var postSmallWrapper = document.createElement("div");

        var postTime = arr[i]["post_time"];
        var postContent = arr[i]["content"];
        var firstName = arr[i]["first_name"];
        var id = arr[i]["post_id"];
        var post = document.createElement("div");
        post.className = "card";
        post.style += "min-height=300px;width:100%;";
        post.innerHTML =
          "<h4>" +
          firstName +
          "</h4>" +
          postContent +
          "<br><br>" +
          "<h7>" +
          postTime +
          "</h7>";
        postSmallWrapper.appendChild(post);
        // var likeButton = document.createElement("button");
        var commentButton = document.createElement("button");
        var displayCommentButton = document.createElement("button");

        // likeButton.id = id + "#likeButton";
        commentButton.id = id + "#commentButton";
        displayCommentButton.id = id + "#displayCommentButton";

        // likeButton.innerHTML = "Like";
        commentButton.innerHTML = "Comment";
        displayCommentButton.innerHTML = "Display Comments";
        var commentContent = document.createElement("input");
        commentContent.setAttribute("type", "text");
        post.appendChild(commentContent);
        commentContent.id = id + "#commentContent";
        commentContent.setAttribute("placeholder", "comment area");

        // postSmallWrapper.appendChild(likeButton);
        postSmallWrapper.appendChild(commentButton);
        postSmallWrapper.appendChild(displayCommentButton);

        // likeButton.addEventListener("click", function() {
        //   likePost(this);
        // });
        commentButton.addEventListener("click", function() {
          commentOnPost(this);
        });

        displayCommentButton.addEventListener("click", function() {
          displayCommentsOnPost(this);
        });

        postWrapper.appendChild(postSmallWrapper);
      }
    }
  };
  xmlhttp.open(
    "GET",
    "viewNeighboursNews.php?myID=" + CURRENT_SESSION_ID,
    true
  );
  xmlhttp.send();
}
function displayCommentsOnPost(button) {
  var postId = button.id.split("#")[0];
  var xmlhttp = new XMLHttpRequest();

  xmlhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      // alert(this.responseText);
      var arr = JSON.parse(this.responseText);
      var i;
      var strBig = "";
      var b = false;
      for (i = 0; i < arr.length; i++) {
        b = true;
        var first_name = arr[i]["first_name"];
        var last_name = arr[i]["last_name"];
        var comment_content = arr[i]["comment_contenet"];
        var comment_time = arr[i]["comment_time"];
        var str =
          first_name +
          " " +
          last_name +
          ": " +
          comment_content +
          "\n" +
          comment_time +
          "\n\n";
        strBig += str;
      }
      if (!b) {
        strBig = "No comments yet!";
      }
      alert(strBig);
    }
  };
  xmlhttp.open("GET", "viewCommentOnPost.php?postId=" + postId, true);
  xmlhttp.send();
}

function commentOnPost(button) {
  var postId = button.id.split("#")[0];
  var xmlhttp = new XMLHttpRequest();
  var content = document.getElementById(postId + "#commentContent").value;
  document.getElementById(postId + "#commentContent").value = "";
  xmlhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
    }
  };
  xmlhttp.open(
    "GET",
    "commentOnNews.php?myID=" +
      CURRENT_SESSION_ID +
      "&comment=" +
      content +
      "&postID=" +
      postId,
    true
  );
  xmlhttp.send();
}

var createGroupButton = document.getElementById("createGroupButton");
createGroupButton.addEventListener("click", function() {
  createGroupShowPopUp();
});

var groupCreateButton = document.getElementById("groupCreateButton");
groupCreateButton.addEventListener("click", function() {
  createGroup();
});

function createGroupShowPopUp() {
  var GroupCreationPopUp = document.getElementById("GroupCreationPopUp");
  GroupCreationPopUp.style.visibility = "visible";
}
function createGroup() {
  var xmlhttp = new XMLHttpRequest();
  var groupNameWrapper = document.getElementById("groupNameWrapper");
  var content = groupNameWrapper.value;
  groupNameWrapper.value = "";

  xmlhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
    }
  };
  xmlhttp.open(
    "GET",
    "createGroup.php?myID=" + CURRENT_SESSION_ID + "&groupname=" + content,
    true
  );
  xmlhttp.send();
  var GroupCreationPopUp = document.getElementById("GroupCreationPopUp");
  GroupCreationPopUp.style.visibility = "hidden";
}

function getEventRequests() {
  var xmlhttp = new XMLHttpRequest();

  xmlhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      var arr = JSON.parse(this.responseText);
      var i = 0;
      var eventRequests = document.getElementById("eventRequests");
      eventRequests.innerHTML = "<h6>Event Invitations</h6>";
      for (i = 0; i < arr.length; i++) {
        var id = arr[i]["event_id"];
        var eventName = arr[i]["event_name"];
        var firstName = arr[i]["first_name"];
        var lastName = arr[i]["last_name"];
        var description = arr[i]["event_description"];

        var div = document.createElement("div");
        var post = document.createElement("div");
        post.style += "min-height=300px;width:100%;";
        post.innerHTML =
          "<h6>Organizer: " +
          firstName +
          " " +
          lastName +
          "</h6>" +
          " event name: " +
          eventName +
          "<br>" +
          "description: " +
          description;

        div.appendChild(post);
        var button = document.createElement("button");
        button.style = "background-color:green;";
        button.innerHTML = "accept";
        var button2 = document.createElement("button");
        button2.style = "background-color:red;";
        button2.innerHTML = "reject";
        button2.id = arr[i]["event_id"] + "#rejectedEventInvitation";
        button.id = arr[i]["event_id"] + "#acceptedEventInvitation";

        div.appendChild(button);
        div.appendChild(button2);

        eventRequests.appendChild(div);
        button.addEventListener("click", function() {
          respondToEventInvitaion(this);
        });
        button2.addEventListener("click", function() {
          respondToEventInvitaion(this);
        });
      }
    }
  };
  xmlhttp.open(
    "GET",
    "viewMyInvitedEvents.php?myID=" + CURRENT_SESSION_ID,
    true
  );
  xmlhttp.send();
}

function respondToEventInvitaion(button) {
  var xmlhttp = new XMLHttpRequest();
  var eventID = button.id.split("#")[0];
  var response;
  if (button.innerHTML == "reject") response = "rejected";
  else response = "accepted";
  button.parentElement.remove();
  xmlhttp.open(
    "GET",
    "respondToEventInvitation.php?myID=" +
      CURRENT_SESSION_ID +
      "&eventID=" +
      eventID +
      "&respondstatus=" +
      response,
    true
  );
  xmlhttp.send();
}
function getGroupRequest() {
  var xmlhttp = new XMLHttpRequest();

  xmlhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      var arr = JSON.parse(this.responseText);
      var i = 0;
      var groupReq = document.getElementById("groupRequest");
      groupReq.innerHTML = "<h6>Group Invitations</h6>";
      for (i = 0; i < arr.length; i++) {
        var id = arr[i]["group_id"];
        var groupName = arr[i]["group_name"];

        var div = document.createElement("div");
        var post = document.createElement("div");
        post.style += "min-height=300px;width:100%;";
        post.innerHTML = "group name: " + groupName + "<br>";

        div.appendChild(post);
        var button = document.createElement("button");
        button.style = "background-color:green;";
        button.innerHTML = "accept";
        var button2 = document.createElement("button");
        button2.style = "background-color:red;";
        button2.innerHTML = "reject";
        button2.id = id + "#rejectedEventInvitation";
        button.id = id + "#acceptedEventInvitation";

        div.appendChild(button);
        div.appendChild(button2);

        groupReq.appendChild(div);
        button.addEventListener("click", function() {
          respondToGroupInvitaion(this);
        });
        button2.addEventListener("click", function() {
          respondToGroupInvitaion(this);
        });
      }
    }
  };
  xmlhttp.open(
    "GET",
    "viewMyInvitedGroups.php?myID=" + CURRENT_SESSION_ID,
    true
  );
  xmlhttp.send();
}

function respondToGroupInvitaion(button) {
  var xmlhttp = new XMLHttpRequest();
  var eventID = button.id.split("#")[0];
  var response;
  if (button.innerHTML == "reject") response = "rejected";
  else response = "accepted";
  button.parentElement.remove();
  xmlhttp.open(
    "GET",
    "respondToGroupInvitation.php?myID=" +
      CURRENT_SESSION_ID +
      "&groupID=" +
      eventID +
      "&response=" +
      response,
    true
  );
  xmlhttp.send();
}
