var CURRENT_SESSION_ID;

var buttonSend = document.getElementById("buttonSend");

// caution danger zone!!!!!!!!!!
var chattingWithId;
var chattingWithName;

buttonSend.addEventListener("click", function() {
  sendMessageEventListener();
  setTimeout(function() {
    viewConversations();

    viewChats();
  }, 500);
});

// to get the current session id
getCurrentSessionID();
setTimeout(function() {
  // alert(CURRENT_SESSION_ID);
  viewChats();
}, 500);
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
function sendMessageEventListener() {
  var xmlhttp = new XMLHttpRequest();

  var messageText = document.getElementById("messageText");
  //   alert(messageText.value);
  xmlhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
    }
  };
  var myId = CURRENT_SESSION_ID;
  var messageToSend = messageText.value;
  messageText.value = "";
  xmlhttp.open(
    "GET",
    "sendMessage.php?myId=" +
      myId +
      "&chattingWithId=" +
      chattingWithId +
      "&messageToSend=" +
      messageToSend,
    true
  );
  xmlhttp.send();
}

//viewConversations();
function viewConversations(button = null) {
  var messageText = document.getElementById("messagesWrapper");
  if (button != null) {
    chattingWithId = button.id.split("#")[0];
  }
  //   alert(chattingWithId);
  messageText.innerHTML = "";
  var xmlhttp = new XMLHttpRequest();
  var stickyDiv = document.createElement("div");
  stickyDiv.className = "sticky";
  stickyDiv.innerHTML = "<h3>" + chattingWithName + "</h3>";
  messageText.appendChild(stickyDiv);
  xmlhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      // alert(this.responseText);
      let arr = JSON.parse(this.responseText);
      //   alert(arr);
      var i;
      for (i = 0; i < arr.length; i++) {
        let senderID = arr[i]["sender_id"];
        let messageContent = arr[i]["message_content"];
        let messageTime = arr[i]["message_time"];

        let div_wrapper = document.createElement("div");
        div_wrapper.classList.add("row");
        div_wrapper.classList.add("s6");
        div_wrapper.classList.add("md3");

        let card = document.createElement("div");
        if (senderID == CURRENT_SESSION_ID) {
          card.className = "card z-depth-1 me";
        } else {
          card.className = "card z-depth-1 you";
        }

        let card_content = document.createElement("div");
        card_content.classList.add("card-content");
        card_content.classList.add("center");

        let h6 = document.createElement("h6");
        h6.classList.add("left");
        h6.innerHTML = messageContent;

        let timeWrapper = document.createElement("div");
        timeWrapper.classList.add("card-action");
        timeWrapper.classList.add("right-align");

        let message_time_p = document.createElement("p");
        message_time_p.classList.add("center-align");
        message_time_p.innerHTML = messageTime;

        div_wrapper.appendChild(card);
        card.appendChild(card_content);
        card_content.appendChild(h6);
        card_content.innerHTML += "<br><br>";
        card_content.appendChild(timeWrapper);
        timeWrapper.appendChild(message_time_p);

        messageText.appendChild(div_wrapper);
      }
      var window = document.getElementById("chatContainer");
      window.scrollTo(0, window.scrollHeight);
    }
  };
  xmlhttp.open(
    "GET",
    "getConversation.php?q=" +
      CURRENT_SESSION_ID +
      "&chattingWithId=" +
      chattingWithId,
    true
  );
  xmlhttp.send();
}

function viewChats() {
  var xmlhttp = new XMLHttpRequest();
  var chatsWrapper = document.getElementById("chatsWrapper");
  chatsWrapper.innerHTML = "";
  xmlhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      //   alert("hii");

      var arr = JSON.parse(this.responseText);
      //   alert(this.responseText);
      var i;
      for (i = 0; i < arr.length; i++) {
        let senderId = arr[i]["sender_id"];
        let senderFirstName = arr[i]["sender_first_name"];
        let senderLastName = arr[i]["sender_last_name"];
        let receiverId = arr[i]["receiver_id"];
        let receiverFirstName = arr[i]["receiver_first_name"];
        let receiverLastName = arr[i]["receiver_last_name"];
        let messageContent = arr[i]["message_content"];
        let messageTime = arr[i]["message_time"];

        let otherId, otherFirstName, otherLastName;
        if (CURRENT_SESSION_ID == senderId) {
          otherId = receiverId;
          otherFirstName = receiverFirstName;
          otherLastName = receiverLastName;
        } else {
          otherId = senderId;
          otherFirstName = senderFirstName;
          otherLastName = senderLastName;
        }

        let div_wrapper = document.createElement("div");
        div_wrapper.classList.add("row");
        div_wrapper.classList.add("s6");
        div_wrapper.classList.add("md3");

        let card = document.createElement("div");
        card.className = "card z-depth-1";

        let card_content = document.createElement("div");
        card_content.className = "card-content";

        let h6 = document.createElement("h6");
        h6.classList.add("left");
        h6.innerHTML = otherFirstName + " " + otherLastName;

        let message_time_p = document.createElement("p");
        message_time_p.classList.add("right-align");
        message_time_p.innerHTML = messageTime;

        let card_action = document.createElement("div");
        card_action.className = "card-action right-align";

        let content_p = document.createElement("p");
        content_p.className = "center-align";
        content_p.innerHTML = senderFirstName + ": " + messageContent;

        let viewingButton = document.createElement("button");
        viewingButton.id = otherId + "#chats";
        viewingButton.innerHTML = "VIEW";

        chatsWrapper.appendChild(div_wrapper);
        div_wrapper.appendChild(card);
        card.appendChild(card_content);
        card_content.appendChild(h6);
        card_content.innerHTML += "<br><br>";
        card_content.appendChild(content_p);
        card_content.appendChild(card_action);
        card_action.appendChild(message_time_p);
        card_action.appendChild(viewingButton);

        viewingButton.addEventListener("click", function() {
          chattingWithName = otherFirstName + " " + otherLastName;
          viewConversations(this);
        });
      }
    }
  };
  xmlhttp.open("GET", "getChats.php?q=" + CURRENT_SESSION_ID, true);
  xmlhttp.send();
}

// TO DO
/*
sort chats by time
*/
