<?php 
    //connect to the database
    $conn0 = mysqli_connect('localhost', 'eiad', '123456', 'neighbourhood_social_network');

    if(!$conn0){
        echo 'Connection error' . mysqli_connect_error();
    }

    if(isset($_REQUEST['price'])){
        //getting id & supplyname & supplydescription
        $myID = $_REQUEST['myID'];
        $requesterID = $_REQUEST['requesterID'];
        $price = $_REQUEST['price'];
        $requestNum = $_REQUEST['requestNum'];

        //calling proc
        $sql = "CALL makeAnOffer($myID,$requesterID,$price,$requestNum,@c)";

        //call query
        if(!mysqli_query($conn0,$sql)){
            echo "Couldn't make an offer";
        }
    }

    //close the connection
    mysqli_close($conn0);
 ?>