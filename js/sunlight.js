var jsonstring = "http://congress.api.sunlightfoundation.com/bills?history.active=true&order=last_action_at&apikey=760bd9bd9e064f528ca3cf476c2fb7bd&callback=?";

var promise = $.getJSON(jsonstring);
var messagePromise = promise.then(function(data) {
	var htmlString = "";
	 $.each(data.results, function (i, item) {

	 	htmlString += "<div class=\'bill\'><h3>Number of cosponsors:</h3>	" + item.cosponsors_count + "<h3>Bill Official Title:</h3>" + item.official_title + "<h3>Last active:</h3>" + item.last_action_at 
	 	+ "</div><hr />";

	 });
	 $('#sunlight').html(htmlString);
}); //messagePromise


