var CURRENT_SESSION_ID;
var FIRST_NAME;
getCurrentSessionID();
setTimeout(function() {
  displayInfo();
  setTimeout(function() {
    displayNews();
    displayRate();
    displayMutualGroups();
  }, 250);
}, 500);
function displayInfo() {
  var xmlhttp = new XMLHttpRequest();

  xmlhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      // alert(this.responseText);
      var arr = JSON.parse(this.responseText);

      let firstName = arr[0]["first_name"];
      let lastName = arr[0]["last_name"];
      let username = arr[0]["username"];
      let streetName = arr[0]["street_name"];
      let houseNumber = arr[0]["house_number"];
      let postalCode = arr[0]["postal_code"];

      FIRST_NAME = firstName;
      // alert(FIRST_NAME);

      let id = arr[0]["id"];
      var infoWrapper = document.getElementById("infoWrapper");
      infoWrapper.innerHTML = "<h4>" + firstName + " " + lastName + "</h4>";
      infoWrapper.innerHTML += "<h6>" + username + "</h6>";
      infoWrapper.innerHTML +=
        "<h5>" + streetName + " " + houseNumber + " " + postalCode + "</h5>";
    }
  };
  xmlhttp.open(
    "GET",
    "viewMemberInfo.php?memberID=" + CURRENT_SESSION_ID,
    true
  );
  xmlhttp.send();
}

function displayNews() {
  var xmlhttp = new XMLHttpRequest();

  xmlhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      // alert(this.responseText);
      // alert(this.responseText);
      var arr = JSON.parse(this.responseText);
      var i = 0;
      var postWrapper = document.getElementById("postWrapper");
      postWrapper.innerHTML = "";
      for (i = 0; i < arr.length; i++) {
        var postSmallWrapper = document.createElement("div");

        var postTime = arr[i]["post_time"];
        var postContent = arr[i]["content"];
        var id = arr[i]["post_id"];
        var post = document.createElement("div");
        post.className = "card";
        post.style += "min-height=300px;width:100%;";
        post.innerHTML =
          "<h4>" +
          FIRST_NAME +
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
    "viewMemberPosts.php?subjectId=" +
      CURRENT_SESSION_ID +
      "&objectId=" +
      CURRENT_SESSION_ID,
    true
  );
  xmlhttp.send();
}

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

function displayRate() {
  var rateWrapper = document.getElementById("rateWrapper");
  var xmlhttp = new XMLHttpRequest();

  xmlhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      var arr = JSON.parse(this.responseText);
      var val = arr[0]["val"] == null ? "--" : arr[0]["val"];
      rateWrapper.innerHTML = "<h4>rate value: </h4>" + val;
    }
  };
  xmlhttp.open("GET", "calcRate.php?objectId=" + CURRENT_SESSION_ID, true);
  xmlhttp.send();
}

function displayMutualGroups() {
  var xmlhttp = new XMLHttpRequest();

  xmlhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      var arr = JSON.parse(this.responseText);
      var i;
      var groupWrapper = document.getElementById("groupWrapper");
      groupWrapper.innerHTML = "<div class='center'><h4>MY GROUPS</h4></div>";
      for (i = 0; i < arr.length; i++) {
        var groupId = arr[i]["group_id"];
        var groupName = arr[i]["group_name"];
        var creationDate = arr[i]["creation_date"];
        var groupDiv = document.createElement("div");
        var button = document.createElement("button");
        // groupDiv.className = "card";
        groupDiv.style +=
          "width:100%;display:flex;overflow:auto;background-color:black;";
        button.style = "overflow:auto;height:100px; ";
        button.innerHTML =
          "<h6>" +
          groupName +
          "</h6>" +
          "<br><br>" +
          "<h7>" +
          creationDate +
          "</h7>";

        groupDiv.appendChild(button);
        groupWrapper.appendChild(groupDiv);
        button.id = groupId + "#MUTUALGROUP";
        button.addEventListener("click", function() {
          setGroupSession(this);
        });
      }
    }
  };
  xmlhttp.open(
    "GET",
    "mutualGroups.php?myID=" +
      CURRENT_SESSION_ID +
      "&friendID=" +
      CURRENT_SESSION_ID,
    true
  );
  xmlhttp.send();
}
function setGroupSession(button) {
  var groupId;
  if (button != null) {
    groupId = button.id.split("#")[0];
    setViewedGroupSession(groupId);
    // alert(groupId);
    setTimeout(function() {
      //to be added
      isGroupAdmin(groupId);
    }, 250);
  }
}
function setViewedGroupSession(id) {
  var xmlhttp = new XMLHttpRequest();
  xmlhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
    }
  };
  xmlhttp.open("GET", "setViewedGroupSession.php?viewedGroupId=" + id, true);
  xmlhttp.send();
}

function isGroupAdmin(groupID) {
  var xmlhttp = new XMLHttpRequest();
  xmlhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      // alert(this.responseText);
      var arr = JSON.parse(this.responseText);
      if (arr[0]["checkBit"] == 1) {
        window.location.href = "http://localhost/nsn/adminGroupPage.php";
      } else {
        window.location.href = "http://localhost/nsn/group.php";
      }
    }
  };
  xmlhttp.open(
    "GET",
    "isGroupAdmin.php?myID=" + CURRENT_SESSION_ID + "&groupID=" + groupID,
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
