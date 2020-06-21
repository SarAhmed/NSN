var CURRENT_SESSION_ID;
var VIEWED_MEMBER_ID;
var REQUEST_ID;
var HEADING;
var buttonOffer = document.getElementById("buttonOffer");

// caution danger zone!!!!!!!!!!-------------------
var chattingWithId;
var chattingWithName;
//-------------------------------------------------

buttonOffer.addEventListener("click", function() {
  acceptOffer();
  setTimeout(function() {
    viewSupplies();
    viewOffers();
  }, 500);
});

// to get the current session id
getCurrentSessionID();
setTimeout(function() {
  // alert(CURRENT_SESSION_ID);
  viewSupplies();
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
function acceptOffer() {
  var xmlhttp = new XMLHttpRequest();

  var offerText = document.getElementById("offerInt");
  //   alert(messageText.value);
  xmlhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      // alert(this.responseText);
    }
  };
  var myId = CURRENT_SESSION_ID;
  if (VIEWED_MEMBER_ID == null) {
    alert("No offer selected!");
  } else {
    alert("You response has been submitted");
  }
  xmlhttp.open(
    "GET",
    "respondToOffer.php?myID=" +
      CURRENT_SESSION_ID +
      "&supplierID=" +
      VIEWED_MEMBER_ID +
      "&requestNum=" +
      REQUEST_ID +
      "&offerResponse=" +
      0,
    true
  );
  xmlhttp.send();
}

//viewConversations();
function viewOffers(button = null) {
  var offers = document.getElementById("offersWrapper");
  if (button != null) {
    REQUEST_ID = button.id.split("#")[0];
  }
  //   alert(chattingWithId);
  offers.innerHTML = "";
  var xmlhttp = new XMLHttpRequest();
  var stickyDiv = document.getElementById("title");
  xmlhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      // alert(this.responseText);
      let arr = JSON.parse(this.responseText);
      var i;
      HEADING = null;
      for (i = 0; i < arr.length; i++) {
        let messageTime = arr[i]["message_time"];
        let price = arr[i]["price"];
        let offer_status = arr[i]["offer_status"];
        let name = arr[i]["first_name"] + " " + arr[i]["last_name"];
        HEADING = arr[i]["supply_name"];

        let a = document.createElement("a");
        a.classList.add("collection-item");

        let span = document.createElement("span");
        span.className = "badge";
        span.innerHTML = price + "€ " + offer_status;
        offers.appendChild(a);
        a.appendChild(span);
        a.innerHTML += name;
        a.id = arr[i]["request_num"] + "#" + arr[i]["supplier_id"];

        a.addEventListener("click", function() {
          REQUEST_ID = a.id.split("#")[0];
          VIEWED_MEMBER_ID = a.id.split("#")[1];
        });
      }
      if (HEADING != null) {
        stickyDiv.innerHTML = HEADING;
      } else {
        stickyDiv.innerHTML = "No Offers received yet!";
      }
    }
  };
  xmlhttp.open(
    "GET",
    "viewOffersOnARequest.php?myId=" +
      CURRENT_SESSION_ID +
      "&neighbourID=" +
      CURRENT_SESSION_ID +
      "&request_num=" +
      REQUEST_ID,
    true
  );
  xmlhttp.send();
}

function showUpdater(button) {
  REQUEST_ID = button.id.split("#")[0];
  var form = document.getElementById("myUpdater");
  if (form.style.visibility == "visible") {
    form.style.visibility = "hidden";
  } else {
    form.style.visibility = "visible";
  }
}

function viewSupplies() {
  var xmlhttp = new XMLHttpRequest();
  var suppliesWrapper = document.getElementById("suppliesWrapper");
  suppliesWrapper.innerHTML = "";
  xmlhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      var arr = JSON.parse(this.responseText);
      var i;
      for (i = 0; i < arr.length; i++) {
        let request_num = arr[i]["request_num"];
        let member_id = arr[i]["member_id"];
        let first_name = arr[i]["first_name"];
        let last_name = arr[i]["last_name"];
        let username = arr[i]["username"];
        let house_number = arr[i]["house_number"];
        let supply_name = arr[i]["supply_name"];
        let supply_description = arr[i]["supply_description"];
        let requested_time = arr[i]["requested_time"];
        let request_status = arr[i]["request_status"];

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
        h4.innerHTML = supply_name;

        let desc_p = document.createElement("p");
        desc_p.classList.add("left");
        desc_p.innerHTML = supply_description;

        let request_p = document.createElement("p");
        request_p.classList.add("right-align");
        request_p.innerHTML = requested_time + "   " + request_status;

        let card_action = document.createElement("div");
        card_action.className = "card-action right-align";

        //  let content_p = document.createElement("p");
        //  content_p.className = "center-align";
        //  content_p.innerHTML = senderFirstName + ": " + messageContent;

        let viewingButton = document.createElement("button");
        viewingButton.id = request_num + "#" + CURRENT_SESSION_ID + "#supplies";
        viewingButton.innerHTML = "VIEW OFFERS";

        let updateButton = document.createElement("Button");
        updateButton.id = request_num + "#" + CURRENT_SESSION_ID + "#supplies";
        updateButton.innerHTML = "UPDATE SUPPLY";

        suppliesWrapper.appendChild(div_wrapper);
        div_wrapper.appendChild(card);
        card.appendChild(card_content);
        card_content.appendChild(h4);
        card_content.innerHTML += "<br>";
        // card_content.appendChild(desc_p);
        card_content.innerHTML += "<br>";
        card_content.appendChild(desc_p);
        card_content.appendChild(card_action);
        card_action.appendChild(request_p);
        card_action.appendChild(viewingButton);
        card_action.appendChild(updateButton);

        viewingButton.addEventListener("click", function() {
          viewOffers(this);
        });

        updateButton.addEventListener("click", function() {
          showUpdater(this);
        });
      }
    }
  };
  xmlhttp.open("GET", "viewMyRequests.php?myID=" + CURRENT_SESSION_ID, true);
  xmlhttp.send();
}
var showFormBtn = document.getElementById("showForm");
showFormBtn.addEventListener("click", function() {
  var form = document.getElementById("myForm");
  if (form.style.visibility == "visible") {
    form.style.visibility = "hidden";
  } else {
    form.style.visibility = "visible";
  }
});

var makeReq = document.getElementById("reqBtn");
makeReq.addEventListener("click", function() {
  var xmlhttp = new XMLHttpRequest();
  xmlhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      theName.value = "";
      theDescription.value = "";
      // alert(this.responseText);
      viewSupplies();
      var hideIt = document.getElementById("myForm");
      hideIt.style.visibility = "hidden";
    }
  };
  var theName = document.getElementById("supply_name");
  var theDescription = document.getElementById("supply_description");

  varNtext = theName.value;
  varDtext = theDescription.value;
  xmlhttp.open(
    "GET",
    "requestItem.php?myID=" +
      CURRENT_SESSION_ID +
      "&supplyname=" +
      theName.value +
      "&supplydescription=" +
      theDescription.value,
    true
  );
  xmlhttp.send();
});

var performUpdate = document.getElementById("updateBtn");
performUpdate.addEventListener("click", function() {
  var xmlhttp = new XMLHttpRequest();
  xmlhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      theName.value = "";
      theDescription.value = "";
      // alert(this.responseText);
      viewSupplies();
      var hideIt = document.getElementById("myUpdater");
      hideIt.style.visibility = "hidden";
    }
  };
  var theName = document.getElementById("supply_name_update");
  var theDescription = document.getElementById("supply_description_update");

  varNtext = theName.value;
  varDtext = theDescription.value;
  xmlhttp.open(
    "GET",
    "updateSupplyInfo.php?myID=" +
      CURRENT_SESSION_ID +
      "&new_name=" +
      theName.value +
      "&new_description=" +
      theDescription.value +
      "&requestNum=" +
      REQUEST_ID,
    true
  );
  xmlhttp.send();
});
