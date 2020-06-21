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
              display: flex;
              flex-direction: column;

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
            background-color:white;
            display:flex;
            flex-direction: column;
        }
        .postWrapper{
            background-color: yellow;
        }
        .membersWrapper{
            height:100%;
            display:flex;
            flex-direction:column;       
        }
        .availableEvents{
            display: flex;
            flex-direction: column;
            background-color: yellow;
            border:1px black solid;
        }
        .DescriptionWrappr{
            display: flex;
            flex-direction: column;
        }.membersWrapper{
            display:flex;
            flex-direction:column; 
            background: yellow;   
            height: 50%;
        }
        .inviteMemWrapper{
            display:flex;
            flex-direction:column;       
            flex-grow:1;   
            background-color: black;
            height: 50%;

        }
            

</style>
 </head>
 <body>
    <?php
    include 'templates/header.php';
    ?>
    <div class = "header center">
        <h3>Event Page</h3>
    </div>

<div class="bigWrapper">
   <div class = "leftWrapper">
        <div class ="membersWrapper" id ="membersWrapper">&nbsp</div>
        <div class = "inviteMemWrapper" id = "inviteMemWrapper">&nbsp</div>

   </div>
    <div class ="rightWrapper">
       
        <div class="DescriptionWrappr" id ="DescriptionWrapper">
        space
        </div>
    </div>

</div>



   
    <script type="text/javascript" src="PrivateEventPage.js"></script>
 </body>
 </html>
