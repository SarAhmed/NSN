
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

        }
        .rightWrapper{
            flex-grow:3;
            height:100%;
            background-color:gainsboro;
              overflow: scroll;

        }
        .eventsWrapper{
            background-color:gray;
            height:100%;

        }
        .neighboursWrapper{
            background-color:gray;
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
            background-color: gainsboro;
        }
        
   .GroupCreationPopUp{
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
 </head>
 <body>
    <?php
    include 'templates/header.php';
    ?>
    <div class = "header center">
        <h3>Home Page</h3>
        <button id="createGroupButton">Create Group</button>
    </div>

<div class="bigWrapper">
    <div class ="leftWrapper">
        <div class ="neighboursWrapper" id ="neighboursWrapper">&nbsp</div>
        <div class ="eventsWrapper" id = "eventsWrapper">
            <div class = "eventRequests" id = "eventRequests">
                &nbsp
            </div>
            <div class = "groupRequest" id = "groupRequest">
                &nbsp
            </div>
        </div>
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
<div class="GroupCreationPopUp" id="GroupCreationPopUp">
<h7>Group Name: </h7>
<input type="text" id = "groupNameWrapper">
<button id = "groupCreateButton">Create</button>
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

   
    <script type="text/javascript" src="index2.js"></script>
 </body>
 </html>