<?php
	session_start();
	ini_set ("display_errors", "On");
	ini_set("error_reporting", E_ALL);
	include_once ('../lib/functions.php');
	
	$a=elencoPrestiti();
	if(isset($_POST) && isset($_POST['cdf']) && isset($_POST['id'])){
        $msg=restituisciLibro($_POST['cdf'], $_POST['id']);
     }
?>
<!DOCTYPE HTML>
<html>
	<head>
		<title>RESTITUZIONE VOLUME</title>
		<?php include_once ('../lib/header.php'); ?>
	</head>
	<body>
    <h1>RESTITUZIONE VOLUME</h1>
    <div class="questionario">
      <form action="<?php echo $_SERVER['PHP_SELF'];?>" method="POST">
        <legend>Inserire i dati del lettore e della copia restituita</legend>
  
        <div>     
          <input type="text" placeholder="cdf del lettore" name="cdf" required>
        </div>
        <div>     
          <input type="text" placeholder="id della copia" name="id" required>
        <br>
        <button>restituisci il libro</button>
      </form>
    </div>
    <?php
    if (!empty($msg)) {
    ?>
    <div class="successo">
        <p><?php echo $msg; ?></p>
    </div>
    <?php
    }
    ?>
    
    
    
	<body>
</html>
