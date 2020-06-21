<?php
    //temp IDs USE SESSION
    $myId =  $_REQUEST['q']; 
    //$chattingWithId = $_REQUEST['chattingWithId'];
    $chattingWithId = $_REQUEST['chattingWithId'];

    //connect to database
    $conn0 = mysqli_connect('localhost', 'eiad', '123456', 'neighbourhood_social_network');

    //check connection
    if(!$conn0){
         echo 'Connection error' . mysqli_connect_error();
     }
    
     //call a proc
    $sqlConversation = "CALL viewConversation($myId, $chattingWithId);";

    //call query
    $resultConversation = mysqli_query($conn0, $sqlConversation);

    //fetch rows as array
    $conversation = mysqli_fetch_all($resultConversation, MYSQLI_ASSOC);
    
    //free results from memory
    mysqli_free_result($resultConversation);

    //close connection
     mysqli_close($conn0);
     $myJSON = json_encode($conversation);

     echo $myJSON;
?>