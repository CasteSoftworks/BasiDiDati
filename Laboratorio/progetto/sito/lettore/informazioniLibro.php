<?php
	session_start();
	ini_set ("display_errors", "on");
	ini_set("error_reporting", E_ERROR);
	include_once ('../lib/functions.php');
	$cdf=$_SESSION['user'];
	if(isset($_POST) && isset($_POST['isbn'])){
	  $msg=mostraInfoLibro($_POST['isbn']);
	}
	
?>
<!DOCTYPE HTML>
<html>
	<head>
		<title>RICERCA INFORMAZIONI LIBRO </title>
		<?php include_once ('../lib/header.php'); ?>
	</head>
	<body>
  	<h1>RICERCA INFORMAZIONI</h1>
  	  <div class="questionario">
  		  <form action="<?php echo $_SERVER['PHP_SELF'];?>" method="POST">
          <legend>Inserisci ISBN</legend>
          <div>     
            <input type="text" placeholder="isbn(con trattini)" name="isbn" required>
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
