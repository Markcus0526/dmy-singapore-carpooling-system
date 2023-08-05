var currpoint = null;
var infowindow = null;
var currmarker = null;
var geocoder = new google.maps.Geocoder();
var map = null;
var searmarker = null;
var searwindow = null;

var flagIcon_front = new google.maps.MarkerImage(rootUri +  "content/images/taxistand.png");
flagIcon_front.size = new google.maps.Size(35, 46);
flagIcon_front.anchor = new google.maps.Point(17, 46);

// var flagIcon_shadow = new google.maps.MarkerImage("http://googlemaps.googlermania.com/img/marker_shadow.png");
// flagIcon_shadow.size = new google.maps.Size(35, 35);
// flagIcon_shadow.anchor = new google.maps.Point(0, 35);

var MapsGoogle = function () {

    var mapMarker = function () {
        var latLng = new google.maps.LatLng(1.353939, 103.83345);
        map = new google.maps.Map(document.getElementById('gmap_marker'), {
            zoom: 13,
            center: latLng,
            mapTypeId: google.maps.MapTypeId.ROADMAP
        });

        infowindow = new google.maps.InfoWindow();

        searmarker = new google.maps.Marker({
            position: latLng, map: map, draggable: true, animation: google.maps.Animation.DROP
        });

        searwindow = new google.maps.InfoWindow({
            content: '<div id="iw" style="height:100px;"><strong>Instructions:</strong><br /><br />Click and drag this red marker anywhere to know the approximate postal address of that location.</div>'
        });

        searwindow.open(map, searmarker);
        //         google.maps.event.addListener(searmarker, 'dragstart', function (e) {
        //             searwindow.close();
        //         });
        // 
        //         google.maps.event.addListener(searmarker, 'dragend', function (e) {
        //             var point = marker.getPosition();
        //             map.panTo(point);
        //             showGeocode(point);
        //         });

        google.maps.event.addListener(infowindow, 'closeclick', function () {
            if (currpoint != null && currpoint["uid"] == "") {
                currmarker.setMap(null);
            }
        });

        if (typeof taxipoints != 'undefined') {
            for (var i = 0; i < taxipoints.length; i++) {
                var marker = new google.maps.Marker({
                    position: new google.maps.LatLng(taxipoints[i]["latitude"], taxipoints[i]["longitude"]),
                    map: map,
                    icon: flagIcon_front
                    //shadow: flagIcon_shadow,
                });

                google.maps.event.addListener(marker, 'click', (function (marker, i) {
                    return function () {
                        currmarker = marker;
                        currpoint = taxipoints[i];
                        infowindow.setContent(getMarkerHtml(currpoint, "edit"));
                        infowindow.open(map, marker);
                    }
                })(marker, i));
            }
        }

        google.maps.event.addListener(map, 'click', function (e) {
            if (e.latLng) {

                if (currpoint != null && currpoint["uid"] == "") {
                    currmarker.setMap(null);
                }
                var marker = new google.maps.Marker({
                    position: e.latLng,
                    map: map,
                    icon: flagIcon_front
                    //shadow: flagIcon_shadow,
                });

                var newtaxipoint = new Array();
                newtaxipoint["uid"] = "";
                newtaxipoint["stand_no"] = "";
                newtaxipoint["stand_name"] = "";
                newtaxipoint["latitude"] = e.latLng.pb;
                newtaxipoint["longitude"] = e.latLng.ob;
                newtaxipoint["gps_address"] = "";
                newtaxipoint["post_code"] = "";
                newtaxipoint["taxi_stand_type"] = "";

                geocoder.geocode({ latLng: e.latLng }, function (responses) {
                    if (responses && responses.length > 0) {
                        if (responses[0]["address_components"].length > 0) {
                            newtaxipoint["gps_address"] = responses[0].formatted_address;
                            var buffer = responses[0]["address_components"][0]["types"][0];
                            if (buffer.toLowerCase() == "street_number")
                                newtaxipoint["stand_no"] = responses[0]["address_components"][0]["long_name"];
                            var buf = responses[0]["address_components"][responses[0]["address_components"].length - 1]["long_name"];
                            if ($.isNumeric(buf))
                                newtaxipoint["post_code"] = buf;
                        }
                    } else {
                        alert('Error: Google Maps could not determine the address of this location.');
                    }

                    google.maps.event.addListener(marker, 'click', (function (marker, i) {
                        return function () {
                            currmarker = marker;
                            currpoint = newtaxipoint;
                            infowindow.setContent(getMarkerHtml(newtaxipoint, "add"));
                            infowindow.open(map, marker);
                        }
                    })(marker, i));
                    currmarker = marker;
                    currpoint = newtaxipoint;
                    infowindow.setContent(getMarkerHtml(newtaxipoint, "add"));
                    infowindow.open(map, marker);
                });
            }
        });

        $('#target').keypress(function (e) {
            var code = e.keyCode || e.which;
            if (code === 13) {
                e.preventDefault();
                search();
            }
        });
    }

    function getMarkerHtml(taxipoint, actiontype) {
        var detHtml = "<div><div class='stand-title'><h2>" + taxipoint["stand_name"] + "</h2></div>";
        detHtml += "<div><table class='taxistand-detail' width='100%' cellspacing=0 cellpadding=0>";
        detHtml += "<tr><td><label>Tax stand No:&nbsp;&nbsp;<label></td>" +
                                "<td><input type='text' style='width:200px' id='standno_" + taxipoint["uid"] + "' value='" + taxipoint["stand_no"] + "'></input></td>" +
                                "</tr>";
        detHtml += "<tr><td><label>Tax stand Name:&nbsp;&nbsp;<label></td>" +
                                "<td><input type='text' style='width:200px' id='standname_" + taxipoint["uid"] + "' value='" + taxipoint["stand_name"] + "'></input></td>" +
                                "</tr>";
        detHtml += "<tr><td><label>Gps Address:&nbsp;&nbsp;<label></td>" +
                                "<td><input type='text' style='width:200px' id='standaddr_" + taxipoint["uid"] + "' value='" + taxipoint["gps_address"] + "'></input></td>" +
                                "</tr>";
        detHtml += "<tr><td><label>Post code:&nbsp;&nbsp;<label></td>" +
                                "<td><input type='text' style='width:200px' id='standpostcode_" + taxipoint["uid"] + "' value='" + taxipoint["post_code"] + "'></input></td>" +
                                "</tr>";
        detHtml += "<tr><td><label>Latitude:&nbsp;&nbsp;<label></td>" +
                                "<td><input type='text' style='width:200px' id='standlat_" + taxipoint["uid"] + "' value='" + taxipoint["latitude"] + "'></input></td>" +
                                "</tr>";
        detHtml += "<tr><td><label>Longitude:&nbsp;&nbsp;<label></td>" +
                                "<td><input type='text' style='width:200px' id='standlng_" + taxipoint["uid"] + "' value='" + taxipoint["longitude"] + "'></input></td>" +
                                "</tr>";
        detHtml += "<tr><td><label>Taxi stand type:&nbsp;&nbsp;<label></td>" +
                                "<td>" +
                                "<select id='standtype_" + taxipoint["uid"] + "'>" +
                                "<option value='TAXI STAND'" + (taxipoint["taxi_stand_type"] == "TAXI STAND" ? "selected" : "") + ">TAXI STAND</option>" +
                                "<option value='TAXI STOP'" + (taxipoint["taxi_stand_type"] == "TAXI STOP" ? "selected" : "") + ">TAXI STOP</option>" +
                                "<option value='TAXI PICKUP/DROPOFF'" + (taxipoint["taxi_stand_type"] == "TAXI PICKUP/DROPOFF" ? "selected" : "") + ">TAXI PICKUP/DROPOFF</option>" +
                                "</select></td>" +
                                "</tr>";

        detHtml += "</table></div>";
        detHtml += "<div>";
        //        if (actiontype == "add") {
        detHtml += "<input type='button' onclick='SaveTaxiPoint();' style='padding:5px;' id='btnstandadd_" + taxipoint["uid"] + "' value='Save' >&nbsp;&nbsp;";
        //         } else if (actiontype == "edit") {
        //             detHtml += "<input type='button' style='padding:5px;' id='btnstandsave_" + taxipoint["uid"] + "' value='Save' >&nbsp;&nbsp;";
        //         }
        detHtml += "<input type='button' onclick='DeleteTaxiPoint();' style='padding:5px;' id='btnstanddel_" + taxipoint["uid"] + "' value='Delete' >&nbsp;&nbsp;";
        detHtml += "</div>";

        return detHtml;
    }

    return {
        //main function to initiate map samples
        init: function () {
            mapMarker();
        }
    };
} ();

function search() {
    geocoder.geocode(
            { 'address': $("#target").val() },
            function (results, status) {
                if (status == google.maps.GeocoderStatus.OK) {
                    var loc = results[0].geometry.location;
                    searmarker.setPosition(loc);
                    showGeocode(loc);
                }
                else {
                    alert("Not found: " + status);
                }
            }
        );
};

function showGeocode(position) {
    geocoder.geocode({
        latLng: position
    }, function (responses) {
        var html = '';
        if (responses && responses.length > 0) {
            html += '<strong>Postal Address:</strong><hr/>' + responses[0].formatted_address;
            //_gaq.push(['_trackEvent', 'Maps', 'Drag', responses[0].formatted_address, 0, true]);
        } else {
            html += 'Sorry but Google Maps could not determine the approximate postal address of this location.';
        }

        html += '<br /><br /><strong>Geo Co-ordinates</strong><hr />' + 'Latitude : ' + searmarker.getPosition().lat() + '<br/>Longitude: ' + searmarker.getPosition().lng();
        map.panTo(searmarker.getPosition());
        searwindow.setContent("<div id='iw'>" + html + "</div>");
        searwindow.open(map, searmarker);
    });
}

function DeleteTaxiPoint() {
    if (currpoint["uid"] == 0) {
        currmarker.setMap(null);
        return true;
    }

    if (confirm("Are you sure to delete current taxi stand?")) {
        $.ajax({
            type: "POST",
            url: rootUri + "TaxiLocations/DeletePoint",
            dataType: "json",
            data: {
                uid: currpoint["uid"]
            },
            success: function (res) {

                if (res.success == "ok") {
                    alert("Successfully deleted!");
                    currmarker.setMap(null);
                }
            },
            error: function (res) {
                alert(res.status);
            }
        });
    }
}

function SaveTaxiPoint() {
    if (checkInputStandInfo()) {
        if (currpoint["uid"] == 0) {
            $.ajax({
                type: "POST",
                url: rootUri + "TaxiLocations/AddPoint",
                dataType: "json",
                data: {
                    stand_no: currpoint["stand_no"],
                    stand_name: currpoint["stand_name"],
                    gps_address: currpoint["gps_address"],
                    post_code: currpoint["post_code"],
                    longitude: currpoint["longitude"],
                    latitude: currpoint["latitude"],
                    taxi_stand_type: currpoint["taxi_stand_type"]
                },
                success: function (res) {

                    if (res.success == "ok") {
                        currpoint["uid"] = res.uid;
                        infowindow.close();
                        alert("Successfully Added!");
                    }
                },
                error: function (res) {
                    alert("Add failed:" + res.status);
                    currmarker.setMap(null);
                }
            });
        } else {
            $.ajax({
                type: "POST",
                url: rootUri + "TaxiLocations/EditPoint",
                dataType: "json",
                data: {
                    uid: currpoint["uid"],
                    stand_no: currpoint["stand_no"],
                    stand_name: currpoint["stand_name"],
                    gps_address: currpoint["gps_address"],
                    post_code: currpoint["post_code"],
                    longitude: currpoint["longitude"],
                    latitude: currpoint["latitude"],
                    taxi_stand_type: currpoint["taxi_stand_type"]
                },
                success: function (res) {

                    if (res.success == "ok") {
                        //currpoint["uid"] = res.uid;
                        infowindow.close();
                        alert("Successfully saved!");
                    }
                },
                error: function (res) {
                    alert("Edit failed: " + res.status);
                    currmarker.setMap(null);
                }
            });
        }
    }
}

function checkInputStandInfo() {
    var standno = $("#standno_" + currpoint["uid"]);
    var standname = $("#standname_" + currpoint["uid"]);
    var standaddr = $("#standaddr_" + currpoint["uid"]);
    var standpostcode = $("#standpostcode_" + currpoint["uid"]);
    var standlat = $("#standlat_" + currpoint["uid"]);
    var standlng = $("#standlng_" + currpoint["uid"]);
    var standtype = $("#standtype_" + currpoint["uid"]);

    if ($.trim(standname.val()) == "") {
        alert("Taxi stand name cannot empty, Please input taxi stand name!");
        return false;
    }

    if ($.trim(standaddr.val()) == "") {
        alert("Taxi stand address cannot empty, Please input address!");
        return false;
    }

    currpoint["stand_no"] = standno.val();
    currpoint["stand_name"] = standname.val();
    currpoint["gps_address"] = standaddr.val();
    currpoint["post_code"] = standpostcode.val();
    currpoint["latitude"] = standlat.val();
    currpoint["longitude"] = standlng.val();
    currpoint["taxi_stand_type"] = standtype.val();

    return true;
}