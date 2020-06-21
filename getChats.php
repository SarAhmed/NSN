<?php 
    //connect to database
    $conn0 = mysqli_connect('localhost', 'eiad', '123456', 'neighbourhood_social_network');
    //temp IDs USE SESSION
    $myId =  $_REQUEST['q'];

    //check connection
    if(!$conn0){
        echo 'Connection error' . mysqli_connect_error();
    }

     //call a proc
     $sqlChats = "CALL viewChats($myId);";

     //call query
    $resultChats = mysqli_query($conn0, $sqlChats);

    //fetch rows as array
    $chats = mysqli_fetch_all($resultChats, MYSQLI_ASSOC);

    //free results from memory
    mysqli_free_result($resultChats);

    //close connection
     mysqli_close($conn0);
     $myJSON = json_encode($chats);

     echo $myJSON;
?>