<?php
	session_start();
	ini_set ("display_errors", "On");
	ini_set("error_reporting", E_ALL);
	include_once ('../lib/functions.php');
	
	if(isset($_POST) && isset($_POST['isbn']) && isset($_POST['dove']) && isset($_POST['casa']) && isset($_POST['trama'])){
        aggiungiLibro($_POST['isbn'], $_POST['titolo'], $_POST['casa'], $_POST['trama']);
     }
?>
<!DOCTYPE HTML>
<html>
	<head>
		<title>AGGIUNGERE COPIA</title>
		<?php include_once ('../lib/header.php'); ?>
	</head>
	<body>
		<h1>AGGIUNGERE COPIA</h1>
		<form action="<?php echo $_SERVER['PHP_SELF'];?>" method="POST">
        <legend>Inserire i dati delle nuove copie</legend>

        <div>     
            <input type="text" placeholder="isbn(CON trattini)" name="isbn">
        </div>
        <div>     
            <input type="text" placeholder="dove la vuoi (codice sede)" name="dove">
        </div>
        <div>
            <input type="number" placeholder="quanti ne vuoi aggiungere" name="quanti">
        </div>
        <br>
        <button>aggiungi le copie</button>
    </form>
	<body>
</html>
