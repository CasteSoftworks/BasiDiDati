<?php
	session_start();
	ini_set ("display_errors", "On");
	ini_set("error_reporting", E_ALL);
	include_once ('../lib/functions.php');
	
	if(isset($_POST) && isset($_POST['cdf'])){
        azzeraritardi($_POST['cdf']);
     }
?>
<!DOCTYPE HTML>
<html>
	<head>
		<title>AZZERA RITARDI</title>
		<?php include_once ('../lib/header.php'); ?>
	</head>
	<body>
		<h1>AZZERA RITARDI</h1>
		<div class="questionario">
  		<form action="<?php echo $_SERVER['PHP_SELF'];?>" method="POST">
          <legend>Azzera i ritardi dell'utente</legend>
  
          <div>     
              <input type="text" placeholder="inseisci il codice fiscale" name="cdf" required>
          </div>
          <br>
          <button>azzera</button>
      </form>
    </div>
	<body>
</html>
