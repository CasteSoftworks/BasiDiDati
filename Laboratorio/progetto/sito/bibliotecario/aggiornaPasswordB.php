<?php
	session_start();
	ini_set ("display_errors", "On");
	ini_set("error_reporting", E_ALL);
	include_once ('../lib/functions.php');
	$cdf=$_SESSION['user'];
	if(isset($_POST) && isset($cdf) && isset($_POST['new1'])&& isset($_POST['new2'])){
        $msg=aggiornaPasswordB($cdf,$_POST['new1'],$_POST['new2']);
     }
?>
<!DOCTYPE HTML>
<html>
	<head>
		<title>AGGIORNA PASSWORD</title>
		<?php include_once ('../lib/header.php'); ?>
	</head>
	<body>
		<h1>AGGIORNA PASSWORD</h1>
		<div class="questionario">
  		<form action="<?php echo $_SERVER['PHP_SELF'];?>" method="POST">
          <legend>Aggiorna la password</legend>
          <div>     
              <input type="password" placeholder="inseisci la nuova password" name="new1" required>
          </div>
          <div>     
              <input type="password" placeholder="reinseisci la nuova password" name="new2" required>
          </div>
          <br>
          <button>aggiorna password</button>
      </form>
    </div>
    <?php
    if (!empty($msg)) {
      if(strpos($msg, "ERRORE") !== false){
    ?>
        <div class="errore">
          <p><?php echo $msg; ?></p>
        </div>
    <?php
      }else{
    ?>
        <div class="successo">
          <p><?php echo("cambio password avvenuto con successo"); ?></p>
        </div>
    <?php
      }
    }
    ?>
	<body>
</html>
