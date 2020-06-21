<?php 
	//connect to the database
	$conn0 = mysqli_connect('localhost', 'eiad', '123456', 'neighbourhood_social_network');

	if(!$conn0){
		echo 'Connection error' . mysqli_connect_error();
    }

    //getting id
    $memberID = $_REQUEST['memberID'];

    //calling the proc
    $sql = "SELECT username,first_name,last_name,street_name,house_number,postal_code FROM nsnmember WHERE id = $memberID";

    //call the query
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