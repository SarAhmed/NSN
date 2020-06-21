<?php 
	//connect to the database
	$conn0 = mysqli_connect('localhost', 'eiad', '123456', 'neighbourhood_social_network');

	if(!$conn0){
		echo 'Connection error' . mysqli_connect_error();
    }
    
    if(isset($_REQUEST['response'])){
        //getting id
        $myID = $_REQUEST['myID'];
        $groupID = $_REQUEST['groupID'];
        $response = $_REQUEST['response'];

        //calling the proc
        $sql = "CALL respondToGroupInvitation($myID,$groupID,'$response',@c)";
    
        //call query
        if(!mysqli_query($conn0,$sql)){
            echo "Couldn't respond to invitation";
        }
    } 
    //close the connection
    mysqli_close($conn0);
 ?>