<?php 
    //connect to the database
    $conn0 = mysqli_connect('localhost', 'eiad', '123456', 'neighbourhood_social_network');

    if(!$conn0){
        echo 'Connection error' . mysqli_connect_error();
    }

        //getting ids
        $myID = $_REQUEST['myID'];
        $memberID = $_REQUEST['blockedID'];
        

        //calling proc
        $sql = "CALL blockNeighbour($myID,$memberID,@c)";

        //call query
        if(!mysqli_query($conn0,$sql)){
            echo "Couldn't block member";
        }

    //close the connection
    mysqli_close($conn0);
 ?>