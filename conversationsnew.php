

<style type='text/css'>

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
div.sticky2 {
  position: -webkit-sticky; /* Safari */
  position: sticky;
  bottom: 0;
}
</style>

<!DOCTYPE html>
<html lang="en">
<?php include 'templates/header.php'; ?>

    <h4>Chats</h4>
    <div class="container thechats left" scrolling="yes">
        <div class="col" id="chatsWrapper">
            
        </div>
    </div>
    <div class="container center singlechat" id="chatContainer">
        <div class="messages">
            <div class="container center" scrolling="yes">
                <div class="col fillIt" id="messagesWrapper">
                    
                </div>
            </div>
        </div>
        <div class="sending bottom sticky2">
            <input type="text" id="messageText" >
            <button id="buttonSend"> Send</button>
        </div>
    </div>
<script type="text/javascript" src="conversartionnew.js"></script>
</html>