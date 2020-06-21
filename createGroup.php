<?php 
	//connect to the database
	$conn0 = mysqli_connect('localhost', 'eiad', '123456', 'neighbourhood_social_network');

	if(!$conn0){
		echo 'Connection error' . mysqli_connect_error();
    }
    
    if(isset($_REQUEST['groupname'])){
        //getting id
        $myID = $_REQUEST['myID'];
        $groupname = $_REQUEST['groupname'];

        //calling the proc
        $sql = "CALL createGroup($myID,'$groupname',@c)";
    
        //call query
        if(!mysqli_query($conn0,$sql)){
            echo "Couldn't create group";
        }
    } 
    //close the connection
    mysqli_close($conn0);
 ?>