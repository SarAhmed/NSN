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
            background-color: gray;
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
            background-color: lightgray;
            border:1px black solid;
        }
        .DescriptionWrappr{
            display: flex;
            flex-direction: row;
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
   
    <div class ="rightWrapper">
        <div class="postingWindow sticky" id = "postingWindow" >
            <p>name: </p><input type="text" name="" id = "nameWrapper">
             <p>description: </p><input type="text" id="contentWrapper" >
            <button id="publicButton" style="background-color: green;height:20px;"> public</button>
            <button id="privateButton" style ="background-color: red;height:20px;"> private</button>
        <button id="createEventButton" style ="background-color: blue;">create</button>

       </div>
        <div class="DescriptionWrappr" id ="DescriptionWrappr">
        <div class ="availableEvents" id ="availableEvents">&nbsp</div>
        <div class ="availableEvents" id ="privateEventsWrapper">&nbsp</div>

        </div>
    </div>

</div>



   
    <script type="text/javascript" src="event.js"></script>
 </body>
 </html>
