<?php
$conn0 = mysqli_connect('localhost', 'eiad', '123456', 'neighbourhood_social_network');

if(!$conn0){
         echo 'Connection error' . mysqli_connect_error();
     }

if(isset($_REQUEST['messageToSend'])){
    //retrieve variables
    $myId = $_REQUEST['myId'];
    $chattingWithId = $_REQUEST['chattingWithId'];
    $sendIt = $_REQUEST['messageToSend'];

    //call a proc
    $sqlSend = "CALL sendMessage('$myId','$chattingWithId','$sendIt',@c);";
    
    //call a query
    if(!mysqli_query($conn0, $sqlSend)){
        echo "Couldn't send message";
    }
}
mysqli_close($conn0);
?>