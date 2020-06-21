<?php 
include ('server.php');
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
 </head>
 <body>
 	<div class = "header center">
 		<h2>Login</h2>
 	</div>
 	<form method = "POST" action = "signin.php">
 		<div class = "input-group">
 			<label >Username:</label>
 			<input type="text" name="username" required>
 		</div>
 		<div class = "input-group">
 			<label >Password:</label>
 			<input type="password" name="password" required>
 		</div>
 		<div class = "input-group center">
 			<button type = "submit" name = "Login" class = "btn">Login</button>
 		</div>
 		<p class = "center">
 			Not yet a member? <a href="signup-loginpage.php">Sign up</a>
 		</p>
 	</form>
 
 </body>
 </html>