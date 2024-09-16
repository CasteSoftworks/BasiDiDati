<?php
	session_start();
	ini_set ("display_errors", "On");
	ini_set("error_reporting", E_ERROR);
	include_once ('../lib/functions.php');
	$cdf=$_SESSION['user'];
	$a=null;
	if(isset($_POST) && isset($_POST['autore'])){
	  $a=ricercaAutore($_POST['autore']);
	}
	if(isset($_POST) && isset($_POST['codice'])){
	  $msg=prendiPrestito($_POST['codice'],$cdf);
	}
?>
<!DOCTYPE HTML>
<html>
	<head>
		<title>RICERCA PER AUTORE</title>
		<?php include_once ('../lib/header.php'); ?>
	</head>
	<body>
		<h1>RICERCA PER AUTORE</h1>
		<br>
		<div class="questionario">
		  <form action="<?php echo $_SERVER['PHP_SELF'];?>" method="POST">
        <legend>Inserisci il nome dell'autore</legend>
        <div>     
            <input type="text" placeholder="nome autore" name="autore">
        </div>
        <br>
        <button>ricerca libro</button>
      </form>
      </div>
		<div class="tabella">
		<table>
        <thead>
            <tr>
                <th>Titolo Del Libro</th>
                <th>Codice della Copia</th>
                <th>Indirizzo della Sede</th>
            </tr>
        </thead>
        <tbody>
            <?php if ($a){
                  foreach ($a as $b){ ?>
                    <tr>
                        <td><?php echo htmlspecialchars($b['title']); ?></td>
                        <td><?php echo htmlspecialchars($b['codice']); ?></td>
                        <td><?php echo htmlspecialchars($b['luogo']); ?></td>
                    </tr>
            <?php }
                  }else{ ?>
                <tr>
                    <td colspan="4">Nessuna copia trovata</td>
                </tr>
            <?php }?>
        </tbody>
    </table>
    </div>
    <br>
    <div class="questionario">
      <form action="<?php echo $_SERVER['PHP_SELF'];?>" method="POST">
        <legend>seleziona la copia che desideri</legend>
        <div>     
            <input type="text" placeholder="codice" name="codice" required>
        </div>
        <br>
        <button>prendi in prestito</button>
      </form>
    </div>
    <div>
      <?php
      if(isset($msg)){
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
    </div>
	<body>
</html>
