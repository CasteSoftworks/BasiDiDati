<?php
	session_start();
	ini_set ("display_errors", "On");
	ini_set("error_reporting", E_ALL);
	include_once ('../lib/functions.php');
	
	if(isset($_POST) && isset($_POST['nome'])){
        $msg=aggiungiAutore($_POST['nome'], $_POST['d_nascita'], $_POST['d_morte'], $_POST['bio']);
     }
?>
<!DOCTYPE HTML>
<html>
	<head>
		<title>AGGIUNGERE AUTORE</title>
		<?php include_once ('../lib/header.php'); ?>
	</head>
	<body>
		<h1>AGGIUNGERE AUTORE</h1>
		<div class="questionario">
  		<form action="<?php echo $_SERVER['PHP_SELF'];?>" method="POST">
          <legend>Inserire i dati del nuovo autore</legend>
  
          <div>     
              <input type="text" placeholder="nome" name="nome" required>
          </div>
          <div>     
              <input type="date" placeholder="data di nascita" name="d_nascita" required>
          </div>
          <div>
              <input type="date" placeholder="data di morte" name="d_morte">
          </div>
          <div>
              <input type="text" placeholder="biografia" name="bio">
          </div>
          <br>
          <button>aggiungi l'autore</button>
      </form>
    </div>
    <?php
    if (!empty($msg)) {
      if($msg=='autore aggiunto con successo'){
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
