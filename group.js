var CURRENT_SESSION_ID;
var GROUP_SESSION_ID;
getCurrentSessionID();
getGroupSessionID();
setTimeout(function() {
  viewGroupJoinedMembers();
  displayGroupNews();
}, 250);
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
function getGroupSessionID() {
  var xmlhttp = new XMLHttpRequest();
  xmlhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      //   alert(this.responseText);
      GROUP_SESSION_ID = this.responseText;
      // alert(GROUP_SESSION_ID);
    }
  };
  xmlhttp.open("GET", "getViewedGroupSession.php", true);
  xmlhttp.send();
}

function viewGroupJoinedMembers() {
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
        button.id = id + "#groupMembersButton";
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
    "viewGroupJoinedMembers.php?myID=" +
      CURRENT_SESSION_ID +
      "&groupID=" +
      GROUP_SESSION_ID,
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

function displayGroupNews() {
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
        var first_name = arr[i]["first_name"];
        var id = arr[i]["post_id"];
        var post = document.createElement("div");
        post.className = "card";
        post.style += "min-height=300px;width:100%;";
        post.innerHTML =
          "<h4>" +
          first_name +
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
    "viewGroupPosts.php?myID=" +
      CURRENT_SESSION_ID +
      "&groupID=" +
      GROUP_SESSION_ID,
    true
  );
  xmlhttp.send();
}

var buttonShare = document.getElementById("buttonShare");
buttonShare.addEventListener("click", function() {
  postNews();
});

function postNews() {
  var xmlhttp = new XMLHttpRequest();
  var contentWrapper = document.getElementById("content");
  var content = contentWrapper.value;
  // alert(content);

  xmlhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      // alert(this.responseText);
    }
  };
  xmlhttp.open(
    "GET",
    "postNewsInGroup.php?myID=" +
      CURRENT_SESSION_ID +
      "&content=" +
      content +
      "&groupID=" +
      GROUP_SESSION_ID,
    true
  );
  xmlhttp.send();
  contentWrapper.value = "";
  setTimeout(function() {
    displayGroupNews();
  }, 250);
}

var leaveButton = document.getElementById("leaveButton");
leaveButton.addEventListener("click", function() {
  leaveGroup();
});
function leaveGroup() {
  var xmlhttp = new XMLHttpRequest();

  xmlhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      window.location.href = "http://localhost/nsn/index.php";
    }
  };
  xmlhttp.open(
    "GET",
    "leaveGroup.php?myID=" +
      CURRENT_SESSION_ID +
      "&groupID=" +
      GROUP_SESSION_ID,
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
      // alert(this.responseText);
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
