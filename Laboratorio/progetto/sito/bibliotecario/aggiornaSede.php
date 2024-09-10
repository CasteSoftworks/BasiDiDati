<?php
	session_start();
	ini_set ("display_errors", "On");
	ini_set("error_reporting", E_ALL);
	include_once ('../lib/functions.php');
	$cdf=$_SESSION['user'];

	if(isset($_POST) && isset($_POST['id']) && isset($_POST['indirizzo']) && isset($_POST['nome'])){
        $msg=aggiornaSede($_POST['id'], $_POST['indirizzo'],$_POST['nome'],$cdf);
     }
?>
<!DOCTYPE HTML>
<html>
	<head>
		<title>AGGIORNA SEDE</title>
		<?php include_once ('../lib/header.php'); ?>
	</head>
	<body>
		<h1>AGGIORNA SEDE</h1>
		<div class="questionario">
  		<form action="<?php echo $_SERVER['PHP_SELF'];?>" method="POST">
          <legend>Inserire i dati da aggiornare della sede</legend>
  
          <div>     
              <input type="text" placeholder="id" name="id" required>
          </div>
          <div>     
              <input type="text" placeholder="indirizzo" name="indirizzo">
          </div>
          <div>
              <input type="text" placeholder="nome" name="nome">
          </div>
          <br>
          <button>aggiorna la sede</button>
      </form>
    </div>
    <?php
    if (!empty($msg)) {
      if(strpos($msg, "impossibile") !== false){
    ?>
        <div class="errore">
            <p><?php echo $msg; ?></p>
        </div>
    <?php
      }else{
    ?>
        <div class="successo">
          <p><?php echo $msg; ?></p>
        </div> 
    <?php
      }
    }
    ?>
	<body>
</html>
