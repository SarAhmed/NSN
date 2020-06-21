<?php 
	session_start();
	$username = "";
	$password = "";
	$firstname = "";
	$lastname = "";
	$streetname = "";
	$eventname = "";
	$description = "";
	$ispublic = "";
	$newpassword = "";
	$oldpassword = "";
	$newfirstname = "";
	$newlastname = "";
	$postcontent = "";
	$group = "";
	// $errors = array();
	 
	// connecting to the DB
	$db = mysqli_connect("localhost","eiad","123456","neighbourhood_social_network");
	// if the register button is clicked
	if(isset($_POST['register'])){
		$username = $_POST['username'];
		$password = $_POST['password'];
		$firstname = $_POST['firstname'];
		$lastname = $_POST['lastname'];
		$housenumber = $_POST['housenumber'];
		$postalcode = $_POST['postalcode'];
		$streetname = $_POST['streetname'];

		$sql = "CALL signUp('$username','$password','$firstname','$lastname','$housenumber','$postalcode','$streetname',@c)";
		mysqli_query($db,$sql);
		$_SESSION['username'] = $username;
		$_SESSION['success'] = "You are now logged in";
		header('location: index.php'); //redircet to the home page
	}

	if(isset($_POST['Login'])){
		$username = $_POST['username'];
		$password = $_POST['password'];
		$result = "SELECT * FROM nsnmember WHERE username = '$username' AND isDeleted = 0";
		$result2 = mysqli_query($db,$result);
		$array = mysqli_fetch_array($result2);
		$_SESSION["id"] = $array['id'];

		$sql = "SELECT * FROM nsnmember where username = '$username' AND user_password = '$password'";
		$result = mysqli_query($db,$sql);
		if(mysqli_num_rows($result) == 1){
			$_SESSION['username'] = $username;
			$_SESSION['success'] = "You are now logged in";
			header('location: index.php'); //redircet to the home page
		}else{
			header('location: signin.php');
		}
	}
	// creating the event
	if(isset($_POST['createevent'])){
		$eventname = $_POST['eventname'];
		$description = $_POST['description'];
		$ispublic = $_POST['public'];
		$sql = "CALL organizeEvent({$_SESSION['id']},'$eventname','$description','$ispublic')";
		$result = mysqli_query($db,$sql);
		header("location: index.php");
		
	}
	// update the password
	if(isset($_POST['updatepassword'])){
		$oldpassword = $_POST['oldpass'];
		$newpassword = $_POST['newpass'];
		$sql = "CALL updatePassword({$_SESSION['id']},'$oldpassword','$newpassword',@c)";
		$result = mysqli_query($db,$sql);
		header("location: index.php");
	}

	// update the first and last name
	if(isset($_POST['updatename'])){
		$newfirstname = $_POST['newfirstname'];
		$newlastname = $_POST['newlastname'];
		$sql = "CALL updateName({$_SESSION['id']},'$newfirstname','$newlastname')";
		$result = mysqli_query($db,$sql);
		header("location: index.php");
	}

	// post a post on the nsn
	if(isset($_POST['createposts'])){
		$postcontent = $_POST['postcontent'];
		$group = $_POST['group'];
		$sql = "CALL PostNews({$_SESSION['id']},'$postcontent','$group',@c)";
		$result = mysqli_query($db,$sql);
		header("location: index.php");
	}
	// create a group
	if(isset($_POST['creategroup'])){
		$group = $_POST['groupname'];
		$sql = "CALL createGroup({$_SESSION['id']},'$group',@c)";
		$result = mysqli_query($db,$sql);
		header("location: index.php");
	}

	// log the user out of the session
	if(isset($_GET['logout'])){
		session_destroy();
		unset($_SESSION['username']);
		header('location: signin.php');
	}
 ?>