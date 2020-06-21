<?php 
    //connect to the database
    $conn0 = mysqli_connect('localhost', 'eiad', '123456', 'neighbourhood_social_network');

    if(!$conn0){
        echo 'Connection error' . mysqli_connect_error();
    }

    if(isset($_REQUEST['supplyname']) AND isset($_REQUEST['supplydescription'])){
        //getting id & supplyname & supplydescription
        $myID = $_REQUEST['myID'];
        $supplyname = $_REQUEST['supplyname'];
        $supplydescription = $_REQUEST['supplydescription'];

        //calling proc
        $sql = "CALL requestItem($myID,'$supplyname','$supplydescription')";

        //call query
        if(!mysqli_query($conn0,$sql)){
            echo "Couldn't request an item";
        }
    }

    //close the connection
    mysqli_close($conn0);
 ?>