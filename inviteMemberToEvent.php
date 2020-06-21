<?php 
    //connect to the database
    $conn0 = mysqli_connect('localhost', 'eiad', '123456', 'neighbourhood_social_network');

    if(!$conn0){
        echo 'Connection error' . mysqli_connect_error();
    }

        //getting id & supplyname & supplydescription
        $invitedID = $_REQUEST['invitedID'];
        $creatorID = $_REQUEST['creatorID'];
        $eventID = $_REQUEST['eventID'];

        //calling proc
        $sql = "CALL inviteMember($invitedID,$eventID,$creatorID,@c)";

        //call query
        if(!mysqli_query($conn0,$sql)){
            echo "Couldn't invite member";
        }

    //close the connection
    mysqli_close($conn0);
 ?>