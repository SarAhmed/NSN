<?php 
    //connect to the database
    $conn0 = mysqli_connect('localhost', 'eiad', '123456', 'neighbourhood_social_network');

    if(!$conn0){
        echo 'Connection error' . mysqli_connect_error();
    }

    if(isset($_REQUEST['offerResponse'])){
        //getting id & supplyname & supplydescription
        $myID = $_REQUEST['myID'];
        $supplierID = $_REQUEST['supplierID'];
        $requestNum = $_REQUEST['requestNum'];
        $offerResponse = $_REQUEST['offerResponse'];

        //calling proc
        if($offerResponse == 0){
            $sql = "CALL respondToOffer($myID,$supplierID,$requestNum,'accepted',@c)";
        }

        //call query
        if(!mysqli_query($conn0,$sql)){
            echo "Couldn't respond to offer" + mysqli_error($conn0);
        }
    }

    //close the connection
    mysqli_close($conn0);
 ?>