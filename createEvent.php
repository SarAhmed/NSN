<?php 
    //connect to the database
    $conn0 = mysqli_connect('localhost', 'eiad', '123456', 'neighbourhood_social_network');

    if(!$conn0){
        echo 'Connection error' . mysqli_connect_error();
    }
    
        //getting id
        $myID = $_REQUEST['myID'];
        $eventname = $_REQUEST['eventname'];
        $eventdescription = $_REQUEST['eventdescription'];
        $ispublic = $_REQUEST['ispublic'];

        //calling the proc
        $sql = "CALL organizeEvent($myID,'$eventname','$eventdescription',$ispublic)";
    
        //call query
        if(!mysqli_query($conn0,$sql)){
            echo "Couldn't organize event";
        }
    //close the connection
    mysqli_close($conn0);
 ?>