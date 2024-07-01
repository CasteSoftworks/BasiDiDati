<?php 
	ini_set ("display_errors", "On");
	ini_set("error_reporting", E_ALL);
	include_once ('lib/functions.php'); 
?>
<!DOCTYPE html>
<html>
    <head>
        <?php include_once ('lib/header.php'); ?>
        <title>
        BIBLIOTECA
        </title>
    </head>
    <body>
    <div class="contenuto">
    <?php include_once ('lib/navigation.php'); ?>

    <div>
    <div>
        <form action="<?php echo $_SERVER['PHP_SELF'];?>" method="POST">
            <legend>Passaggio di parametri con il metodo POST</legend>

            <div >     
                <label for="movie-title">Titolo</label>
                <div>
                    <input id="movie-title" type="text" placeholder="inserisci il titolo" name="movie[title]">
                </div>
            </div>
            <div>
                <label for="movie-year">Anno</label>
                <div>
                    <input id="movie-year" type="text" placeholder="inserisci l'anno di produzione" name="movie[year]">
                </div>
            </div>
            <div>
                <label for="movie-length">Durata</label>
                <div>
                    <input id="movie-length" step="1" type="number" placeholder=" durata in minuti" name="movie[length]">
                </div>
            </div>
            <div">
                <label for="movie-release">Data di rilascio in Italia</label>
                <div>
                    <input id="movie-release" type="date" placeholder="inserisci la data" name="movie[release]">
                </div>
            </div>
            <div>
                <label for="movie-genre">Genere</label>
                <div>
                    <select id="movie-genre" name="movie[genre]">
                    <option value="" selected="selected">Seleziona una voce</option>
                    <?php 
                    $genres = get_movie_genres();
                    foreach ($genres as $code => $value) {
                    ?>
                        <option value="<?php echo $code; ?>"><?php echo $value; ?></option>
                    <?php
                  	}		
                    ?>
                    </select>
                </div>
            </div>
            <button >Invia</button>
        </form>
    </div>
    </div>

    <?php
    if(isset($_POST['movie'])) {
        $movie = $_POST['movie'];
        // print_r ($movie);
        $title = 'ND';
        if(!empty($movie['title']))
        	$title = $movie['title'];
        $year = 'ND';
        if(!empty($movie['year']))
        	$year = $movie['year'];
        $length = 'ND';
        if(!empty($movie['length']))
        	$length = $movie['length'] . ' minuti';
        $release_date = 'ND';
        if(!empty($movie['release']))
        	$release_date = date('d/m/Y',strtotime($movie['release']));
    ?>
    <hr>
    <div >
        <h3 class="uk-card-title">Sto per inserire i seguenti dati:</h3>
        <div >
            <div>
                <span>Titolo (anno): </span> 
                <?php echo $title . " (" . $year . ")"; ?>
            </div>
            
            <div>
                <span>Durata: </span>
                <?php echo $length; ?><br>
                
                <?php 
                $genre = get_genre_name($movie['genre']);
                if (!is_null($genre)) {
                ?>
                <span>Genere: </span>
                <?php echo $genre; ?>
                <?php
                }
                ?>
            </div>  

            <div>
                <span>Data di rilascio in Italia: </span>
                <?php echo $release_date; ?>
            </div>       
        </div>
    </div>
    <?php
    }
    ?>

    <div">
    <?php
    if (isset($_GET['country'])) {
    	$country = $_GET['country'];
    	
    ?>
    	<h3>Film prodotti in <?php echo $country ?></h3>
		<table>
		<thead>
			<tr>
				<th>Titolo del film</th>
				<th>Anno di produzione</th>
			</tr>
		</thead>
		<tbody>
    
    
    <?php
    	$movies = get_movie_country($country);
    	foreach ($movies as $year => $title) {
    ?>
    	<tr>
            <td><?php echo $title; ?></td>
            <td><?php echo $year; ?></td>
        </tr>
    <?php
    	}
    ?>
        </tbody>
		</table>
    <?php
    } 
    ?>
        <h3">Seleziona il paese di interesse (passaggio di parametri con il metodo GET)</h3>
        Vedi i film prodotti in <a href="<?php echo $_SERVER['PHP_SELF']; ?>?country=ITA">Italia</a>.<br>
        Vedi i film prodotti in <a href="<?php echo $_SERVER['PHP_SELF']; ?>?country=FRA">Francia</a>.<br> 
        Vedi i film prodotti in <a href="<?php echo $_SERVER['PHP_SELF']; ?>?country=USA">Stati Uniti</a>.<br>
    </div>
	</div>
    </body>
</html>
