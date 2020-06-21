<?php 
	//connect to the database
	$conn0 = mysqli_connect('localhost', 'eiad', '123456', 'neighbourhood_social_network');

	if(!$conn0){
		echo 'Connection error' . mysqli_connect_error();
    }
    
    if(isset($_REQUEST['value'])){
        //getting id
        $raterID = $_REQUEST['raterID'];
        $ratedID = $_REQUEST['ratedID'];
        $value = $_REQUEST['value'];

        //calling the proc
        $sql = "CALL rate($raterID,$ratedID,$value)";
    
        //call query
        if(!mysqli_query($conn0,$sql)){
            echo "Couldn't rate";
        }
    } 
    //close the connection
    mysqli_close($conn0);
 ?>