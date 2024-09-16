<?php
	session_start();
	ini_set ("display_errors", "On");
	ini_set("error_reporting", E_ERROR);
	include_once ('../lib/functions.php');
	
	$a=elencoPrestiti();
	if(isset($_POST) && isset($_POST['cdf']) && isset($_POST['id'])){
        $msg=prorogaPrestito($_POST['cdf'], $_POST['id']);
     }
?>
<!DOCTYPE HTML>
<html>
	<head>
		<title>PROROGA PRESTITO</title>
		<?php include_once ('../lib/header.php'); ?>
	</head>
	<body>
    <h1>PROROGA PRESTITO</h1>
    <div>
      <?php include_once("visualizzaPrestati.php");?>
    </div>
    <div class="questionario">
      <form action="<?php echo $_SERVER['PHP_SELF'];?>" method="POST">
        <legend>Inserire i dati del lettore e della copia di cui prorogare il prestito</legend>
  
        <div>     
          <input type="text" placeholder="cdf del lettore" name="cdf" required>
        </div>
        <div>     
          <input type="text" placeholder="id della copia" name="id" required>
        </div>
        <br>
        <button>proroga il prestito</button>
      </form>
    </div>
    <?php
    if (isset($msg)){
      if(strpos($msg, "ERROR") !== false){
        $msg=substr($msg,7);
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
