<?php 
    //connect to the database
    $conn0 = mysqli_connect('localhost', 'eiad', '123456', 'neighbourhood_social_network');

    if(!$conn0){
        echo 'Connection error' . mysqli_connect_error();
    }

    if(isset($_REQUEST['new_name']) AND isset($_REQUEST['new_description'])){
        //getting id & supplyname & supplydescription
        $myID = $_REQUEST['myID'];
        $new_name = $_REQUEST['new_name'];
        $new_description = $_REQUEST['new_description'];
        $requestNum = $_REQUEST['requestNum'];

        //calling proc
        $sql = "CALL updateSupplyInfo('$new_name','$new_description',$requestNum,$myID)";

        //call query
        if(!mysqli_query($conn0,$sql)){
            echo "Couldn't update supply info" + mysqli_error($conn0);
        }
    }

    //close the connection
    mysqli_close($conn0);
 ?>