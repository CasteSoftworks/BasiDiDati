<?php
	session_start();
	ini_set ("display_errors", "On");
	ini_set("error_reporting", E_ALL);
	include_once ('../lib/functions.php');
	
	if(isset($_POST) && isset($_POST['isbn'])){
        $msg=rimuoviLibro($_POST['isbn']);
     }
?>
<!DOCTYPE HTML>
<html>
	<head>
		<title>RIMOVI LIBRO</title>
		<?php include_once ('../lib/header.php'); ?>
	</head>
	<body>
		<h1>RIMOVI LIBRO</h1>
  		<div class="questionario">
  		  <form action="<?php echo $_SERVER['PHP_SELF'];?>" method="POST">
        <legend>Inserire i dati del libro da rimuovere</legend>
  
        <div>     
          <input type="text" placeholder="isbn(CON trattini)" name="isbn" required>
        </div>
        <br>
        <button>rimuovi il libro</button>
      </form>
    </div>
    <?php
    if (!empty($msg)) {
      if($msg=='libro rimosso'){
    ?>
    <div class="successo">
        <p><?php echo $msg; ?></p>
    </div>
    <?php
      }else{
    ?>
    <div class="errore">
        <p><?php echo $msg; ?></p>
    </div>
    <?php
      }
    }
    ?>
	<body>
</html>
