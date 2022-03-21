document.addEventListener('DOMContentLoaded', function() {
    if (window.location.href.includes("?webeep=1")) {
        performPoliAuth();
    }
    try {
        if (typeof browser === "undefined") {
            var browser = chrome;
        }
        var submitButton = document.getElementById('submit');
        browser.storage.local.get('email', function(data) {
            var txtValue = data.email.toString();
            if (txtValue !== "undefined") {
                document.getElementById('email').value = data.email;
            }
        });
        submitButton.addEventListener('click', function() {
            var txtValue = document.getElementById('email').value;
            browser.storage.local.set({ email: txtValue });
        });
        var weBeepButton = document.getElementById('webeep');
        weBeepButton.addEventListener('click', function() {
            window.open(window.location.href + "?webeep=1", "_blank");
        });
    } catch {}
});


function performPoliAuth() {
    var myDate = new Date();
    myDate.setMonth(myDate.getMonth() + 12);
    document.cookie = "poliAuthenticator=true;expires=" + myDate + ";domain=.polimi.it;path=/"; document.cookie = "poliAuthenticator_redirectUrl=" + window.location.href + ";expires=" + myDate + ";domain=.polimi.it;path=/";
    window.location.href= "poliauth://open";
}