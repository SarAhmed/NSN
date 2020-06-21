<?php 
    //connect to the database
    $conn0 = mysqli_connect('localhost', 'eiad', '123456', 'neighbourhood_social_network');

    if(!$conn0){
        echo 'Connection error' . mysqli_connect_error();
    }

    if(isset($_REQUEST['content'])){
        //getting id & supplyname & supplydescription
        $myID = $_REQUEST['myID'];
        $reportedID = $_REQUEST['reportedID'];
        $content = $_REQUEST['content'];

        //calling proc
        $sql = "CALL report($myID,$reportedID,'$content',@c)";

        //call query
        if(!mysqli_query($conn0,$sql)){
            echo "Couldn't report";
        }
    }

    //close the connection
    mysqli_close($conn0);
 ?>