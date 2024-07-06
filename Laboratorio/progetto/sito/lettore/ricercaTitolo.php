<?php
	session_start();
	ini_set ("display_errors", "On");
	ini_set("error_reporting", E_ALL);
	include_once ('../lib/functions.php');
	$cdf=$_SESSION['user'];
	$a=null;
	if(isset($_POST) && isset($_POST['titolo'])){
	  $a=ricercaTitolo($_POST['titolo']);
	}
	if(isset($_POST) && isset($_POST['codice'])){
	  prendiPrestito($_POST['codice'],$cdf);
	}
?>
<!DOCTYPE HTML>
<html>
	<head>
		<title>RICERCA PER TITOLO</title>
		<?php include_once ('../lib/header.php'); ?>
	</head>
	<body>
		<h1>RICERCA PER TITOLO</h1>
		<div class="questionario">
		  <form action="<?php echo $_SERVER['PHP_SELF'];?>" method="POST">
        <legend>Inserisci ISBN</legend>
        <div>     
            <input type="text" placeholder="titolo" name="titolo">
        </div>
        <br>
        <button>ricerca libro</button>
      </form>
      </div>
		<div style="overflow-y: scroll; max-height:400px; width: auto;">
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
	<body>
</html>
