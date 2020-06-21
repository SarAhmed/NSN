<?php 
include('server.php');
 ?>

 <!DOCTYPE html>
 <html>

 <head>
    <title>NSN</title>
    <!-- Compiled and minified CSS -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/materialize/1.0.0/css/materialize.min.css">
    <style type="text/css">
        .brand{
            background: #0000ff !important;
        }
        .brand-text{
            color: #0000ff !important;
        }
        form{
            max-width: 460px;
            margin: 20px auto;
            padding: 20px;
        }
        .bigWrapper{
            display:flex;
            width:100%;
            flex-direction:row;
            border: black solid 1px;
            height:627px;;

        }
        .leftWrapper{
            flex-grow:1;
            height:100%;
            display:flex;
            flex-direction:column;
            background-color: purple;
        }
        .rightWrapper{
            flex-grow:3;
            height:100%;
            background-color:blue;
              overflow: scroll;

        }
        .eventsWrapper{
            background-color:green;
            height:100%;

        }
        .neighboursWrapper{
            background-color:red;
            height:100%;
            display:flex;
            flex-direction:column;       
        }
 
        .postingWindow{
            width:100%;
            height:150px;
            background-color:white
        }
        .postWrapper{
            background-color: yellow;
        }
        .membersWrapper{
            display:flex;
            flex-direction:column;    
            flex-grow:1;   
        }
        .inviteMemWrapper{
            display:flex;
            flex-direction:column;       
            flex-grow:1;   
            background-color: white;
            overflow: scroll;

        }
        	
  
</style>
 </head>
 <body>
    <?php
    include 'templates/header.php';
    ?>
    <div class = "header center">
        <h3>Group Page</h3>
        <button id="deleteButton" style='background-color: red;'>Delete group</button>
        <button id="leaveButton" style='background-color: red;'>leave</button>
    </div>

<div class="bigWrapper">
    <div class ="leftWrapper">
        &nbsp
        <div class ="membersWrapper" id ="membersWrapper">&nbsp</div>
        <div class = "inviteMemWrapper" id = "inviteMemWrapper">&nbsp</div>
    </div>
    <div class ="rightWrapper">
        <div class="postingWindow sticky" id = "postingWindow" >
            <input type="text" id="content" style="width:100%;height:80%">
            <button id="buttonShare" style="height:20%;"> Share</button>
        </div>
        <div class="postWrapper" id ="postWrapper">
            &nbsp
        </div>
    </div>

</div>

<!-- ----------------------------------------------------------------- -->
        <!-- <?php if(isset($_SESSION["username"])): ?>
            <p class = "center">Welcome <strong><?php echo $_SESSION['username']; ?></strong></p>

        <?php endif ?>  -->

        <!-- <div>
            <button onclick="window.location.href = 'http://localhost/NSN/createevent.php';">Start creating your event now!</button>
            <button onclick="window.location.href = 'http://localhost/NSN/updateclientinfo.php';" >Update Your Info</button>
            <button onclick="window.location.href = 'http://localhost/NSN/createpost.php';" >Post Something</button>
            <button onclick="window.location.href = 'http://localhost/NSN/creategroup.php';" >Start Making Spicey Groups</button>
            <button onclick="window.location.href = 'http://localhost/NSN/conversationsnew.php';" >Chat with friends</button>
            <button class="trigger" id="viewMyNeighboursButton" >View your neighbours</button>
            
        </div> -->
<!-- ----------------------------------------------------------------- -->

   
    <script type="text/javascript" src="adminGroupPage.js"></script>
 </body>
 </html>