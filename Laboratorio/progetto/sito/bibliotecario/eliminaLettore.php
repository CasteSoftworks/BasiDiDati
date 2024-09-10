<?php
	session_start();
	ini_set ("display_errors", "On");
	ini_set("error_reporting", E_ALL);
	include_once ('../lib/functions.php');
	
	if(isset($_POST) && isset($_POST['cdf'])){
        $msg=eliminaUtente($_POST['cdf']);
     }
?>
<!DOCTYPE HTML>
<html>
	<head>
		<title>ELIMINA LETTORE</title>
		<?php include_once ('../lib/header.php'); ?>
	</head>
	<body>
		<h1>ELIMINA LETTORE</h1>
		<div class="questionario">
  		<form action="<?php echo $_SERVER['PHP_SELF'];?>" method="POST">
          <legend>Inserire il CDF del lettore da eliminare</legend>
  
          <div>     
              <input type="text" placeholder="codice fiscale" name="cdf" required>
          </div>
          <br>
          <button>elimina il lettore</button>
      </form>
    </div>
	<body>
	<?php
    if (!empty($msg)) {
      if(strpos($msg, "eliminato") !== false){
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
</html>
