document.addEventListener('DOMContentLoaded', function() {
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
