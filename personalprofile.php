

<style type='text/css'>
body{
    background-color:black;
}
.pageContentWrapper{
    display: flex;
    flex-direction: row;
    width:100%;
    height:100%;

}
.infoWrapper{
    height:140px;
    background-color:blue;
    flex-grow:3;

}
.buttonsWrapper{
    display:flex;

}
button{
    flex-grow:1;
    height:30px;
}
.postWrapper{
    flex-grow :2;

    background-color:red;
    border: black solid 1px;
    height:100%

}
.groupWrapper{
    flex-grow :1;

    background-color:yellow;
    border: black solid 1px;
    height:100%;
}

.thechats{
    margin : 20px !important;
    max-width:350px !important;
    max-height: 600px !important;
    overflow-y:scroll !important;
    padding: 0 55px !important;
}
.col{
    width : 200px !important;
    margin : 20px !important;
}

.card-content{
    padding : 10px !important;
}

.singlechat{
    margin-left:400px !important;
    background-color:white;
    overflow-y:scroll !important;
    width:100px;
    height:500px;
}

.me{
    background-color: green !important;
    float:right;
}

.you{
    color: green !important;
    float:left;
}

.fillIt{
    width: 100% !important;
}
div.sticky {
  position: -webkit-sticky; /* Safari */
  position: sticky;
  top: 0;
}
.postingWindow{
    width:100%;
    height:150px;
    background-color:white;
}
.postViewingWindow{
    width:100%;
    height:100%;
    background-color:black;
}
.popUp{
    position:fixed;
    top:50%;
    margin-left:-150px;
    left:50%;
    width:300px;
    height:65px;
    background-color:white;
    z-index: 1;
    border:1px solid green;
    visibility:hidden;
    display:flex;
    flex-direction:row;
}
.bigInfoWrapper{
    display:flex;
    flex-direction:row;
}
.rateWrapper{
    flex-grow:1;
    background-color:green;
}
.MessagePopUp{
    position:fixed;
    top:50%;
    margin-left:-250px;
    left:50%;
    width:500px;
    height:60px;
    background-color:white;
    z-index: 1;
    border:1px solid green;
    visibility:hidden;
    display:flex;
    flex-direction:row;
}
</style>

<!DOCTYPE html>
<?php include 'templates/header.php'?>
<html lang="en">
<div class='bigDivWrapper'>
<div class="bigInfoWrapper">
<div class ='infoWrapper' id="infoWrapper" >&nbsp</div>
<div class="rateWrapper" id = "rateWrapper">&nbsp</div>
</div>
<div class ='buttonsWrapper'>
<button id ="chatButton">chat</button>
<button id = "addFriendButton">add friend</button>
<button id = "rateButton">rate</button>
<button id ="reportButton">report</button>
<button id="blockButton">block</button>
</div>
<div class='pageContentWrapper'>
<div class = 'postWrapper' id ='postWrapper' >
</div>
<div class = 'groupWrapper' id="groupWrapper">&nbsp</div>

</div>
</div>
<div class="popUp" id="popUp">
<h7>Please Choose Rate Value</h7>
<button id = "rate1">1</button>
<button id = "rate2">2</button>
<button id = "rate3">3</button>
<button id = "rate4">4</button>
<button id = "rate5">5</button>

</div>
<div class="MessagePopUp" id="MessagePopUp">
<h7>Please Type a Message</h7>
<input type="text" id = "messageContentWrapper">
<button id = "sendMessageButton">Send</button>
</div>

<div class="MessagePopUp" id="ReportPopUp">
<h7>Mz3alak fi 2eeh: </h7>
<input type="text" id = "reportContentWrapper">
<button id = "sendReportButton">Send</button>
</div>
<script type="text/javascript" src="personalprofile.js"></script>
</html>