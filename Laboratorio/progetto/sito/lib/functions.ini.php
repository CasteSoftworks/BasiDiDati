<?php
$genres = Array(
	'1375666' => 'Sci-Fi', 
	'0816692' => 'Drama', 
	'0816692' => 'Adventure', 
	'1345836' => 'Thriller', 
	'0770828' => 'Action'
);

$movies_usa = Array(
	'2017' => 'Dunkirk', 
	'2012' => 'Django Unchained'
);

$movies_ita = Array(
	'2013' => 'La grande bellezza',
 	'2011' => 'Habemus Papam'
);

$movies_fra = Array(
	'2013' => 'Il capitale umano',
	'2011' => 'This Must Be the Place'
);

$movie_production = Array(
	'USA' => $movies_usa,
	'ITA' => $movies_ita, 
	'FRA' => $movies_fra
);

$menu_entries = Array (
	'list' => 'Film disponibili',
	'insert' => 'Nuovo film',
	'stats' => 'Statistiche'
);


/*
returns the array of keys associated with stats 
*/
function get_stats_entries(){
global $stats_entries;

return $stats_entries;

}

/*
returns the stats according to the given stat_choice
the $k parameter is used in the topk stats to set the size of topk
*/
function get_stats($stat_choice, $k = 10){

// completare la funzione per caricare il risultato opportuno in base alla statistica richiesta nel parametro $stat_choice

}

function get_movies(){

// carica le pellicole disponibili dal db

}

function get_genres(){

// carica i generi disponibili dal db

}

/*
returns the array of existing movie genres
*/
function get_movie_genres(){
global $genres;

return $genres;

}

/*
returns the array of existing menu entries
*/
function get_menu_entries(){
global $menu_entries;

return $menu_entries;

}

/*
returns the array of existing movies
*/
function get_all_movies(){
global $movie_production;

return $movie_production;

}

/*
returns the genre name given a genre id
*/
function get_genre_name($genre_id){
global $genres;

$genre_name = null;

if (isset($genres[$genre_id]))
	$genre_name = $genres[$genre_id];

return $genre_name;

}

/*
returns the movies produced in a given country 
*/
function get_movie_country($country){
global $movie_production;

$movie_country = null;

if (isset($movie_production[$country]))
	$movie_country = $movie_production[$country];

return $movie_country;

}

/*
Open connection with PostgreSQL server
*/
function open_pg_connection() {
	include_once('conf/conf.php');
    
    $connection = "host=".myhost." dbname=".mydb." user=".myuser." password=".mypsw;
    
    return pg_connect ($connection);
    
}

/*
Close connection with PostgreSQL server
*/
function close_pg_connection($db) {
        
    return pg_close ($db);
    
}

/*
check the validity of given credentials
*/
function login($user, $psw, $tipo) {
    
    $logged = null;

    $db = open_pg_connection();

    if($tipo = "lettore"){

      $sql = "SELECT cdf FROM biblioteca.lettore WHERE cdf = $1 AND pass = $2";
    }else{
      $sql = "SELECT cdf FROM biblioteca.bibliotecario WHERE cdf = $1 AND pass = $2";
    }
    $params = array(
    	$user,
    	$psw
    );

    $result = pg_prepare($db, "check_user", $sql);
    $result = pg_execute($db, "check_user", $params);

    if($row = pg_fetch_assoc($result)){
    	$logged = $row['cdf'];
    }

    close_pg_connection($db);

    return [$logged,$tipo];
    
}

?>
