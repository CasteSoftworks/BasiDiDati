<?php
	ini_set ("display_errors", "On");
	ini_set("error_reporting", E_ALL);
	include_once ('../lib/functions.php');
	$a=elencoPrestiti();
?>
<!DOCTYPE HTML>
<html>
	<head>
		<?php include_once ('../lib/header.php'); ?>
	</head>
	<body>
		<div class="tabella">
		  <table>
        <thead>
            <tr>
                <th>Lettore</th>
                <th>Copia in Prestito</th>
                <th>Scadenza</th>
            </tr>
        </thead>
        <tbody>
        <?php if ($a){
          foreach ($a as $b){ ?>
            <tr>
                <td><?php echo htmlspecialchars($b['persona']); ?></td>
                <td><?php echo htmlspecialchars($b['volume']); ?></td>
                <td><?php echo htmlspecialchars($b['d_fine']); ?></td>
            </tr>
          <?php 
          }
        }else{ ?>
            <tr>
              <td colspan="4">Nessun prestito trovato</td>
            </tr>
          <?php } ?>
        </tbody>
      </table>
    </div>
	<body>
</html>
