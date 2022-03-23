document.addEventListener('DOMContentLoaded', function() {
    if (window.location.href.includes("?webeep=1")) {
        document.getElementById('loadingMessage').innerHTML = 'Launching PoliAuthenticator desktop app, please click allow in the browser\'s window and wait a bit. If you only installed this extension please <a href="https://github.com/poliauth">download the app.</a>';
        setTimeout(function () {
            performPoliAuth();
		}, 100);
    }
    try {
        if (typeof browser === "undefined") {
            var browser = chrome;
        }
        browser.storage.local.get('email', function(data) {
            var txtValue = data.email.toString();
            if (txtValue !== "undefined") {
                document.getElementById('email').value = data.email;
            }
        });
        document.getElementById('submit').addEventListener('click', function() {
            var txtValue = document.getElementById('email').value;
            browser.storage.local.set({ email: txtValue });
        });
        document.getElementById('webeep').addEventListener('click', function() {
            window.open(browser.runtime.getURL('loading.html') + "?webeep=1", "_blank");
        });
    } catch {}
});


function performPoliAuth() {
    var myDate = new Date();
    myDate.setMonth(myDate.getMonth() + 12);
    document.cookie = "poliAuthenticator=true;expires=" + myDate + ";domain=.polimi.it;path=/"; document.cookie = "poliAuthenticator_redirectUrl=" + window.location.href + ";expires=" + myDate + ";domain=.polimi.it;path=/";
    window.location.href= "poliauth://open";
}