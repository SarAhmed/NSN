<?php
    //connect to database
    $conn0 = mysqli_connect('localhost', 'ahmed', '123456', 'neighbourhood_social_network');

    //temp IDs USE SESSION
    $myId =  $_REQUEST['myId']; 
    //$chattingWithId = $_REQUEST['chattingWithId'];
    $viewedId = $_REQUEST['viewedId'];

    //check connection
    if(!$conn0){
         echo 'Connection error' . mysqli_connect_error();
     }
    
     //call a proc
    $sql = "CALL getFriendshipStatus($myId, $viewedId)";

     //call the query
     $result = mysqli_query($conn0,$sql);

     //fetch rows as array
     $finalresult = mysqli_fetch_all($result,MYSQLI_ASSOC);
 
     //free result from memory
     mysqli_free_result($result);
 
 
     //close the connection
     mysqli_close($conn0);
     $myJSON = json_encode($finalresult);
 
     echo $myJSON;
?>