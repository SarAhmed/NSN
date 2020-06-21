<?php 
include('server.php');
 ?>

 <!DOCTYPE html>
 <html>
 <head>
 	<title>NSN</title>
 	<!-- Compiled and minified CSS -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/materialize/1.0.0/css/materialize.min.css">
    <style type="text/css">
    	.brand{
    		background: #0000ff !important;
    	}
    	.brand-text{
    		color: #0000ff !important;
    	}
    	form{
    		max-width: 460px;
    		margin: 20px auto;
    		padding: 20px;
    	}
    </style>
    <!-- <link rel="stylesheet" type="text/css" href="style.css"> -->
 </head>
 <body>
 	<div class = "header center">
 		<h2>Register</h2>
 	</div>
 	<form method = "POST" action = "signup-loginpage.php">
 		<div class = "input-group">
 			<label >Username:</label>
 			<input type="text" name="username" required>
 		</div>
 		<div class = "input-group">
 			<label >Password:</label>
 			<input type="password" name="password" required>
 		</div>
 		<div class = "input-group">
 			<label >First Name:</label>
 			<input type="text" name="firstname" required>
 		</div>
 		<div class = "input-group">
 			<label >Last Name:</label>
 			<input type="text" name="lastname" required>
 		</div>
 		<div class = "input-group">
 			<label >House Number:</label>
 			<input type="number" name="housenumber" required>
 		</div>
 		<div class = "input-group">
 			<label >Postal Code:</label>
 			<input type="number" name="postalcode" required>
 		</div>
 		<div class = "input-group">
 			<label >Street Name:</label>
 			<input type="text" name="streetname" required>
 		</div>
 		<div class = "input-group center">
 			<button type = "submit" name = "register" class = "btn">Register</button>
 		</div>
 		<p class = "center">
 			Already a member? <a href="signin.php">Sign in</a>
 		</p>
 	</form>
 
 </body>
 </html>