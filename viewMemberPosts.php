<?php 
    //connect to database
    $conn0 = mysqli_connect('localhost', 'eiad', '123456', 'neighbourhood_social_network');
    //temp IDs USE SESSION
    $subjectId =  $_REQUEST['subjectId'];
    $objectId =  $_REQUEST['objectId'];

    //check connection
    if(!$conn0){
        echo 'Connection error' . mysqli_connect_error();
    }

     //call a proc
     $sqlPosts = "CALL viewMemberNews($subjectId, $objectId, @c);";

     //call query
    $resultPosts = mysqli_query($conn0, $sqlPosts);

    //fetch rows as array
    $posts = mysqli_fetch_all($resultPosts, MYSQLI_ASSOC);

    //free results from memory
    mysqli_free_result($resultPosts);

    //close connection
     mysqli_close($conn0);
     $myJSON = json_encode($posts);

     echo $myJSON;
?>