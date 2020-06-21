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
        $sql = "CALL leaveGroup($myID,$groupID,@c)";
    
        //call query
        if(!mysqli_query($conn0,$sql)){
            echo "Couldn't leave group";
        }
         
    //close the connection
    mysqli_close($conn0);
 ?>