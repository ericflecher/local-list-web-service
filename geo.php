<?php
//Note! using https does not work, because it is not set up through my PHP settings? or maybe Apache? somewhere in WAMP?
$results_places = 'https://maps.googleapis.com/maps/api/place/search/json?parameters?&location='. htmlentities(htmlspecialchars(strip_tags($_GET['latlng']))) . '&rankby=distance&types=bar|restaurant|cafe|food|point_of_interest&language=en&sensor=true&key=AIzaSyDfvlLdmPj5jPMYy54KLcmkgvD68oFt5fM';
//$results_places = 'http://maps.google.com/maps/api/geocode/json?latlng='.htmlentities(htmlspecialchars(strip_tags($_GET['latlng']))).'&sensor=true';

$json_output = file_get_contents($results_places,0,null,null);
$json_obj = json_decode($json_output, true);
$results = array();
foreach ($json_obj['results'] as $result) {
	if (is_array($result)) {
		$new_result = new stdClass();
		foreach ($result as $key => $value) {
			if ($key == "name" || $key == "formatted_address" || $key == "vicinity") {
				//echo 'key: ' . $key . ' val: ' . $value . '<br>';
				$new_result->$key = $value;
			}
		}
		$results[] = $new_result;
	}	
}

echo '{"success":true,"results":' . json_encode($results) . '}';

?>