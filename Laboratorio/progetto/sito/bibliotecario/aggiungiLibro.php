<?php
	session_start();
	ini_set ("display_errors", "On");
	ini_set("error_reporting", E_ALL);
	include_once ('../lib/functions.php');
	
	if(isset($_POST) && isset($_POST['isbn']) && isset($_POST['titolo']) && isset($_POST['casa_ed']) && isset($_POST['trama'])){
        $msg=aggiungiLibro($_POST['isbn'], $_POST['titolo'], $_POST['casa_ed'], $_POST['trama']);
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
		<div class="questionario">
  		<form action="<?php echo $_SERVER['PHP_SELF'];?>" method="POST">
          <legend>Inserire i dati del nuovo libro</legend>
  
          <div>     
              <input type="text" placeholder="isbn(CON trattini)" name="isbn" required>
          </div>
          <div>     
              <input type="text" placeholder="titolo" name="titolo" required>
          </div>
          <div>
              <input type="text" placeholder="casa editrice" name="casa_ed">
          </div>
          <div>
              <input type="text" placeholder="trama" name="trama">
          </div>
          <br>
          <button>aggiungi il libro</button>
      </form>
    </div>
    <?php
    if (!empty($msg)) {
      if(strpos($msg, "aggiunto") !== false){
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
