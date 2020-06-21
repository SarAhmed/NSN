var CURRENT_SESSION_ID;
var VIEWED_MEMBER_ID;
var REQUEST_ID;
var HEADING;
var buttonOffer = document.getElementById("buttonOffer");

// caution danger zone!!!!!!!!!!-------------------
var chattingWithId;
var chattingWithName;
//-------------------------------------------------

// to get the current session id
getCurrentSessionID();
setTimeout(function() {
  // alert(CURRENT_SESSION_ID);
  viewfriendRequests();
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

function viewfriendRequests() {
  var xmlhttp = new XMLHttpRequest();
  var suppliesWrapper = document.getElementById("suppliesWrapper");
  suppliesWrapper.innerHTML = "";
  xmlhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      // alert(this.responseText);

      var arr = JSON.parse(this.responseText);
      // alert(this.responseText);
      var i;
      for (i = 0; i < arr.length; i++) {
        let member_id = arr[i]["adder_id"];
        let first_name = arr[i]["first_name"];
        let last_name = arr[i]["last_name"];
        let username = arr[i]["username"];
        let add_status = arr[i]["add_status"];

        let div_wrapper = document.createElement("div");
        div_wrapper.classList.add("row");
        div_wrapper.classList.add("s6");
        div_wrapper.classList.add("md3");

        let card = document.createElement("div");
        card.className = "card z-depth-1";

        let card_content = document.createElement("div");
        card_content.className = "card-content";

        let h4 = document.createElement("h4");
        h4.classList.add("center-align");
        h4.innerHTML = first_name + " " + last_name;

        let desc_p = document.createElement("p");
        desc_p.classList.add("left");
        desc_p.innerHTML = username;

        let request_p = document.createElement("p");
        request_p.classList.add("right-align");
        request_p.innerHTML = add_status;

        let card_action = document.createElement("div");
        card_action.className = "card-action right-align";

        //  let content_p = document.createElement("p");
        //  content_p.className = "center-align";
        //  content_p.innerHTML = senderFirstName + ": " + messageContent;

        let addButton = document.createElement("button");
        addButton.id = member_id + "#supplies";
        addButton.innerHTML = "Accept";

        let removeButton = document.createElement("Button");
        removeButton.id = member_id + "#supplies2";
        removeButton.innerHTML = "Remove";

        if (add_status != "accepted") {
          suppliesWrapper.appendChild(div_wrapper);
        }
        div_wrapper.appendChild(card);
        card.appendChild(card_content);
        card_content.appendChild(h4);
        card_content.innerHTML += "<br>";
        // card_content.appendChild(desc_p);
        card_content.innerHTML += "<br>";
        card_content.appendChild(desc_p);
        card_content.appendChild(card_action);
        card_action.appendChild(request_p);

        card_action.appendChild(addButton);
        card_action.appendChild(removeButton);

        addButton.addEventListener("click", function() {
          //viewOffers(this);
        });

        removeButton.addEventListener("click", function() {
          //showUpdater(this);
        });
      }
    }
  };
  xmlhttp.open(
    "GET",
    "viewRequestsReceived.php?myID=" + CURRENT_SESSION_ID,
    true
  );
  xmlhttp.send();
}
