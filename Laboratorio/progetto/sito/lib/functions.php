<?php
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
/*
function topk_movie($k){
	$db = open_pg_connection();
	$sql="SELECT * from imdb.movie inner join imdb.rating on movie.id=ratings.movie order by rating.score desc limit($1)"
	

}*/

function get_stats($stat_choice, $k = 10){

$db = open_pg_connection();

switch ($stat_choice) {
	case 'topk':
    	//$sql = "SELECT * FROM imdb.topk_movie($1)";
		$sql = "SELECT * from imdb.movie inner join imdb.rating on movie.id=rating.movie order by rating.score desc limit($1)";
    	$params = array($k);
    break;
    case 'movies':
    	$sql = "SELECT genre, count(*) FROM imdb.movie inner join imdb.genre on movie.id=genre.movie group by genre";
    	$params = array();
    break;
    case 'persons':
    	$sql = "SELECT p_role, count(*) FROM imdb.persons inner join imdb.crew on person.id=crew.person group by (p_role)";
    	$params = array();
    break;
}

$result = pg_prepare($db, "get_data", $sql);
$result = pg_execute($db, "get_data", $params);

close_pg_connection($db);

return pg_fetch_all($result, PGSQL_NUM);

}

function get_movies(){

$sql = "SELECT id, CONCAT(official_title, ' ', year) FROM imdb.movie";

$db = open_pg_connection();

$result = pg_prepare($db, "get_movies", $sql);
$result = pg_execute($db, "get_movies", array());

close_pg_connection($db);

return pg_fetch_all($result, PGSQL_NUM);

}

function get_genres(){

$sql = "SELECT DISTINCT genre FROM imdb.genre";

$db = open_pg_connection();

$result = pg_prepare($db, "get_genres", $sql);
$result = pg_execute($db, "get_genres", array());

close_pg_connection($db);

return pg_fetch_all($result, PGSQL_NUM);

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
function loginLet($user, $psw) {
    
    $logged = null;

    $db = open_pg_connection();
    
    $sql = "SELECT cdf FROM biblioteca.lettore WHERE cdf = $1 AND pass = $2";

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

    return $logged;
    
}

function loginBib($user, $psw) {
    
    $logged = null;

    $db = open_pg_connection();
    
    $sql = "SELECT cdf FROM biblioteca.bibliotecario WHERE cdf = $1 AND pass = $2";

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

    return $logged;
    
}

?>
