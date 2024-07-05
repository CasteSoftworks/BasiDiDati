<?php
	session_start();
	ini_set ("display_errors", "On");
	ini_set("error_reporting", E_ALL);
	include_once ('../lib/functions.php');
	
	if(isset($_POST) && isset($_POST['isbn']) && isset($_POST['titolo']) && isset($_POST['casa']) && isset($_POST['trama'])){
        aggiungiLibro($_POST['isbn'], $_POST['titolo'], $_POST['casa'], $_POST['trama']);
     }
?>
<!DOCTYPE HTML>
<html>
	<head>
		<title>AGGIUNGERE LIBRO</title>
		<?php include_once ('../lib/header.php'); ?>
	</head>
	<body>
		<h1>AGGIUNGERE LIBRO</h1>
		<form action="<?php echo $_SERVER['PHP_SELF'];?>" method="POST">
        <legend>Inserire i dati del nuovo libro</legend>

        <div>     
            <input type="text" placeholder="isbn(CON trattini)" name="isbn">
        </div>
        <div>     
            <input type="text" placeholder="titolo" name="titolo">
        </div>
        <div>
            <input type="text" placeholder="casa editrice" name="casa">
        </div>
        <div>
            <input type="text" placeholder="trama" name="trama">
        </div>
        <br>
        <button>aggiungi il libro</button>
    </form>
	<body>
</html>
