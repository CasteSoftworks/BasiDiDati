<?php
	session_start();
	ini_set ("display_errors", "on");
	ini_set("error_reporting", E_ERROR);
	include_once ('../lib/functions.php');
	if(isset($_POST) && isset($_POST['titolo'])){
	  $msg=mostraInfoLibroTitolo($_POST['titolo']);
	}
	
?>
<!DOCTYPE HTML>
<html>
	<head>
		<title>RICERCA INFORMAZIONI LIBRO PER TITOLO</title>
		<?php include_once ('../lib/header.php'); ?>
	</head>
	<body>
  	<h1>RICERCA INFORMAZIONI</h1>
  	  <div class="questionario">
  		  <form action="<?php echo $_SERVER['PHP_SELF'];?>" method="POST">
          <legend>Inserisci titolo</legend>
          <div>     
            <input type="text" placeholder="titolo" name="titolo" required>
          </div>
          <br>
          <button>ricerca informazioni</button>
      </form>
    </div>
    <br>
    <?php
    if(isset($msg)){
      if(strpos($msg, "ERRORE") !== false){
          $msg=substr($msg,7);
        ?>
        <div class="errore">
          <p><?php echo $msg; ?></p>
        </div>
      <?php
        }else{?>
        <div class="box_dialogo">
          <p><?php echo $msg; ?></p>
        </div>
      <?php
      }
    }
    ?>
  <body>
</html>
