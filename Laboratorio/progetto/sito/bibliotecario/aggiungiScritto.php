<?php
	session_start();
	ini_set ("display_errors", "On");
	ini_set("error_reporting", E_ERROR);
	include_once ('../lib/functions.php');
	
	
	if(isset($_POST) && isset($_POST['autore']) && isset($_POST['isbn'])){
        $msg=aggiungiScritto($_POST['autore'], $_POST['isbn']);
     }
?>
<!DOCTYPE HTML>
<html>
  <head>
    <title>AGGIUNGERE UNA RELAZIONE AUTORE-LIBRO</title>
    <?php include_once ('../lib/header.php'); ?>
  </head>
  <body>
    <h1>AGGIUNGERE UNA RELAZIONE AUTORE-LIBRO</h1>
    <div style="display: flex;">
      <div style="flex: 1;">
  	      <?php include_once("./elencaAutori.php"); ?>
      </div>
      <div style="flex: 1;">
  	      <?php include_once("./elencaLibri.php"); ?>
      </div>
    </div>
    <br>
    <div class="questionario">
    <form action="<?php echo $_SERVER['PHP_SELF'];?>" method="POST">
      <legend>Inserire l'id dell'autore e l'isbn del libro da lui scritto</legend>
  
      <div>     
        <input type="text" placeholder="id autore" name="autore" required>
      </div>
          
      <div>
        <input type="text" placeholder="isbn libro (xxx-xx-xx-xxxxx-x)" name="isbn">
      </div>
      <br>
      <button>aggiungi la relazione</button>
    </form>
  </div>
    <?php
    if (!empty($msg)) {
      if($msg=='scritto aggiunto con successo'){
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
