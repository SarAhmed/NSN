<?php 
    //connect to the database
    $conn0 = mysqli_connect('localhost', 'eiad', '123456', 'neighbourhood_social_network');

    if(!$conn0){
        echo 'Connection error' . mysqli_connect_error();
    }

    if(isset($_REQUEST['respondstatus'])){
        //getting id & supplyname & supplydescription
        $myID = $_REQUEST['myID'];
        $eventID = $_REQUEST['eventID'];
        $respondstatus = $_REQUEST['respondstatus'];

        //calling proc
        $sql = "CALL respondToEventInvitation($myID,$eventID,'$respondstatus')";

        //call query
        if(!mysqli_query($conn0,$sql)){
            echo "Couldn't respond to a event invite";
        }
    }

    //close the connection
    mysqli_close($conn0);
 ?>