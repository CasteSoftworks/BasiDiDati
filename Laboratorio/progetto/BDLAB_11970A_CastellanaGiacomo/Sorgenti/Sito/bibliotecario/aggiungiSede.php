<?php
	session_start();
	ini_set ("display_errors", "On");
	ini_set("error_reporting", E_ALL);
  include_once ('../lib/functions.php');
  $cdf=$_SESSION['user'];
	if(isset($_POST) && isset($_POST['indirizzo']) && isset($_POST['nome'])){
        $msg=aggiungiSede($_POST['indirizzo'],$_POST['nome'],$cdf);
     }
?>
<!DOCTYPE HTML>
<html>
	<head>
		<title>AGGIUNGERE SEDE</title>
		<?php include_once ('../lib/header.php'); ?>
	</head>
	<body>
		<h1>AGGIUNGERE SEDE</h1>
		<div class="questionario">
  		<form action="<?php echo $_SERVER['PHP_SELF'];?>" method="POST">
          <legend>Inserire i dati della nuova sede</legend>
          <div>     
              <input type="text" placeholder="indirizzo" name="indirizzo" required>
          </div>
          <div>     
              <input type="text" placeholder="nome" name="nome" required>
          </div>
  
          <br>
          <button>aggiungi la sede</button>
      </form>
    </div>
    <?php
    if(isset($msg)){
      if ($msg=="sede aggiunta") {
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
