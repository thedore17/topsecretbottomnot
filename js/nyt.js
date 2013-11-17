
$(document).ready(function(){
    $("button.submit").click(function(){
    	var url = $('input.form-control').val();
    	url = url.slice( 0, url.indexOf('?') );
    	$('input.form-control').val(url);
        $('iframe').attr('src', url);
  
/*
   
    var nytstring = "http://api.nytimes.com/svc/search/v2/articlesearch.json?fq=web_url:(%22" + url + "%22)&api-key=1EE1CEE78A6C9B24EB377103925A1285:0:56741594";

var promise = $.getJSON(nytstring);
var messagePromise = promise.then(function(data) {
	var nytString = "";
	 $.each(data.results, function (i, item) {

	 	nytString += "<div class=\'bill\'><h3>Number of cosponsors:</h3>	" 
	 	+ item.docs[0] + "<h3>Bill Official Title:</h3>" 
	 	+ "</div><hr />";

	 });
	 $('#nyt').html("hellow");
	
}); //messagePromise
*/
  });







}); //document ready

