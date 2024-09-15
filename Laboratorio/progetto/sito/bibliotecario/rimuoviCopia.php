<?php
	session_start();
	ini_set ("display_errors", "On");
	ini_set("error_reporting", E_ALL);
	include_once ('../lib/functions.php');
	
	if(isset($_POST) && isset($_POST['id'])){
        $msg=rimuoviCopia($_POST['id']);
     }
?>
<!DOCTYPE HTML>
<html>
	<head>
		<title>RIMUOVI COPIA</title>
		<?php include_once ('../lib/header.php'); ?>
	</head>
	<body>
		<h1>RIMUOVI COPIA</h1>
		<?php include_once ('elencaCopie.php'); ?>
		<br>
		<div class="questionario">
  		  <form action="<?php echo $_SERVER['PHP_SELF'];?>" method="POST">
        <legend>Inserire i dati della copia da rimuovere</legend>
  
        <div>     
          <input type="text" placeholder="id" name="id" required>
        </div>
        <br>
        <button>rimuovi la copia</button>
      </form>
    </div>
    <?php
    if (!empty($msg)) {
    
      if($msg=="copia rimossa"){?>
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
