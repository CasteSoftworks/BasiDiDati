<?php
	session_start();
	ini_set ("display_errors", "On");
	ini_set("error_reporting", E_ALL);
	include_once ('../lib/functions.php');
	
	if(isset($_POST) && isset($_POST['isbn']) && isset($_POST['dove']) && isset($_POST['quanti'])){
        $msg=aggiungiCopie($_POST['isbn'], $_POST['dove'], $_POST['quanti']);
     }
?>
<!DOCTYPE HTML>
<html>
	<head>
		<title>AGGIUNGERE COPIE</title>
		<?php include_once ('../lib/header.php'); ?>
	</head>
	<body>
		<h1>AGGIUNGERE COPIE</h1>
		<div class="questionario">
  		<form action="<?php echo $_SERVER['PHP_SELF'];?>" method="POST">
          <legend>Inserire i dati del libro di cui registrare le copie</legend>
  
          <div>     
              <input type="text" placeholder="isbn(CON trattini)" name="isbn" required>
          </div>
          <div>
              <input type="text" placeholder="dove vuoi registarlo (id sede)" name="dove" required>
          </div>
          <div>
              <input type="number" placeholder="#copie" name="quanti" required>
          </div>
          <br>
          <button>aggiungi le copie</button>
      </form>
    </div>
    <?php
    if (!empty($msg)) {
      if($msg=='copie aggiunte'){
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
