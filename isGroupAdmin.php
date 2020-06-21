<?php 
	//connect to the database
	$conn0 = mysqli_connect('localhost', 'eiad', '123456', 'neighbourhood_social_network');

	if(!$conn0){
		echo 'Connection error' . mysqli_connect_error();
    }
    
        //getting id
        $myID = $_REQUEST['myID'];
        $groupID = $_REQUEST['groupID'];

        //calling the proc
        $sql = "CALL isGroupAdmin($myID,$groupID,@c)";
    
        //call query
        $result = mysqli_query($conn0,$sql);

        //fetch rows as array
    $finalresult = mysqli_fetch_all($result,MYSQLI_ASSOC);

    //free result from memory
    mysqli_free_result($result);


    //close the connection
    mysqli_close($conn0);
    $myJSON = json_encode($finalresult);

    echo $myJSON;
 ?>