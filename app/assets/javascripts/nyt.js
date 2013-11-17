function getSunlightInfo(url) {
    var loc = window.location.href + "?u=" + encodeURIComponent(url);
    var result = $.getJSON(loc, null, function(data, textStatus, xhr) {
        parseResult(data);
    });
}

function parseResult(data) {
    var htmlString = "", item, party, cosponsor_parties;

    for (var i=0; i < data.length; i++) {
        item = data[i];

        htmlString += "<div class='bill'>"
        + "<h1>" + item.bill_number + "</h1>"

        + "<h3>Sponsor</h3>"
        + "<p><a href='https://twitter.com/" + item.sponsor.twitter_id + "'>" + item.sponsor.name + "</a></p>"
        + "<h3>Cosponsors:</h3>";

        cosponsor_parties = Object.keys(item.party);
        htmlString += "<p>";
        for (var j=0; j < cosponsor_parties.length; j++) {
            party = cosponsor_parties[j];
            htmlString +=  item.party[party] + " (" + party + ") ";
        }
        htmlString += "</p>";

        htmlString += "<h3>Bill Title</h3>"
        + "<p>" + item.title + "</p>"
        + "</div>";
    }

    $('#sunlight').html(htmlString);

}

$(document).ready(function(){
    $("button.submit").click(function(){
    	var url = $('input.form-control').val();
        if (url) {
            $('iframe').attr('src', url);
            getSunlightInfo(url);
        } else {
            alert("Please enter a URL");
        }
  });
}); //document ready
