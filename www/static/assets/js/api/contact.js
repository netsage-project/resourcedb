
function sendContactEmail(name, org, email, phone, msg) {
    var url = baseUrl;
    url += 'api/admin/index.cgi?method=send_us_email';

    url += '&name=' + encodeURIComponent(name);
    url += '&org=' + encodeURIComponent(org);
    url += '&email=' + encodeURIComponent(email);
    url += '&phone=' + encodeURIComponent(phone);
    url += '&msg=' + encodeURIComponent(msg);

    console.log(url);

    //-----------
    function successCallback(json) {
        // json may be, eg, {results: 1} or {error_text: "An unknown error occurred", error: 1, results: null}
        console.log("sendContactEmail response json: ");
        console.log(json);

        var msg_sent_div = document.getElementById("msg_sent");

        if (json.error) { 
            msg_sent_div.innerHTML = "<br><p style='color:red;'>Webservice ERROR: " + json.error_text + "</p>";
            alert("There was a problem sending your email.");
        }    
        else { 
            ///msg_sent_div.innerHTML = "<br><p style='color:green;'>Your message has been sent.<br>Thank you!</p>";
            alert("Your message has been sent. Thank you!\nYou will now be returned to the previous page.");
            window.history.back();
        }
    };

    function errorCallback(txt) {
        var msg_sent_div = document.getElementById("msg_sent");
        msg_sent_div.innerHTML = "<br><p style='color:red;'>ERROR: " + txt + "</p>";
        alert("There was a problem sending your email.");
    }
    //-----------

    fetch( url, {
           method: 'get',
           credentials: 'include'

    }).then( function(response) {
        if (response.ok) {
            // we got a response but there could still be an error.
            response.json().then( function(json) {
                successCallback(json);
            });
        } else {
            // 404 errors, etc.
            errorCallback(response.status + " - " + response.statusText);  
        }

    }).catch(function(err) {
        // don't know when this will be executed
        console.log("sendContactEmail error: " + err);  
    });
}
