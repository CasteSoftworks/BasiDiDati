<?php
	session_start();
	ini_set ("display_errors", "On");
	ini_set("error_reporting", E_ALL);
	include_once ('../lib/functions.php');
	
	if(isset($_POST) && isset($_POST['cdf']) && isset($_POST['nome']) && isset($_POST['tipo']) && isset($_POST['psw'])){
        creaUtente($_POST['cdf'], $_POST['nome'], $_POST['tipo'], $_POST['psw']);
     }
?>
<!DOCTYPE HTML>
<html>
	<head>
		<title>CREA LETTORE</title>
		<?php include_once ('lib/header.php'); ?>
	</head>
	<body>
		<h1>CREA LETTORE<h1>
		<form action="<?php echo $_SERVER['PHP_SELF'];?>" method="POST">
        <legend>Inserire i dati del nuovo lettore</legend>

        <div>     
            <input type="text" placeholder="codice fiscale" name="cdf">
        </div>
        <div>     
            <input type="text" placeholder="nome cognome" name="nome">
        </div>
        <div>
            <input type="password" placeholder="password" name="psw">
        </div>
        <div>
        	<p>Inserire tipologia di lettore</p>
        	<select name="tipo" id="tipo">
  			<option value="normale">normale</option>
  			<option value="premium">premium</option>
		</select>
        </div>
        <br>
        <button>crea il lettore</button>
    </form>
	<body>
</html>
