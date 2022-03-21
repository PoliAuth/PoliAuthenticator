if (window.location.href.includes("aunicalogin.polimi.it/aunicalogin/aunicalogin.jsp")) {
	var done = false;
	while (!done) {
		done = setTimeout(function () {
			try {
				if (typeof browser === "undefined") {
					var browser = chrome;
				}
				var s = document.createElement('script');
				s.setAttribute('src', browser.runtime.getURL('helper.js'));
				document.body.appendChild(s);
				var buttonsContainer = document.getElementsByClassName('ingressoFederato')[0];
				var fullURL = browser.runtime.getURL('assets/images/PoliAuthenticator_White.png');
				var str = '<br/><a href="#" onclick="performPoliAuth()" class="ingresso-federato-button ingresso-federato-button-size-m button-ingresso-federato"><span class="ingresso-federato-button-icon"><img src="' + fullURL + '" alt=""></span><span class="ingresso-federato-button-text">PoliAuthenticator</span></a>';
				buttonsContainer.innerHTML = buttonsContainer.innerHTML + str;
				return true;
			} catch (e) {
				return false;
			}
		}, 10);
	}
}


if (window.location.href.includes("webeep.polimi.it/my")) {
	var name = 'poliAuthenticator';
	const value = `; ${document.cookie}`;
	const parts = value.split(`; ${name}=`);
	var c = undefined;
	if (parts.length === 2) {
		c = parts.pop().split(';').shift();
	}
	if (c != undefined){
		var newHTML = document.open("text/html", "replace");
		newHTML.write("<h1>Redirect...</h1>");
		newHTML.close();
		setTimeout(function() {
			var d = new Date()
			d.setHours(d.getHours() - 2);
			document.cookie = "poliAuthenticator=false;expires=" + d + ";domain=.polimi.it;path=/";
			c = undefined;
			name = 'poliAuthenticator_redirectUrl';
			const value = `; ${document.cookie}`;
			const parts = value.split(`; ${name}=`);
			var c = undefined;
			if (parts.length === 2) {
				c = parts.pop().split(';').shift();
			}
			if (c != undefined) {
				document.cookie = "poliAuthenticator_redirectUrl=no;expires=" + d + ";domain=.polimi.it;path=/";
				window.location.href = c;
			} else {
				window.location.href = window.location.href;
			}
		}, 1000);
	}
}


if (window.location.href.includes("idbroker.webex.com/idb/saml2/jsp/doSSO.jsp")) {
	var done = false;
	while (!done) {
		done = setTimeout(function () {
			try {
				if (typeof browser === "undefined") {
					var browser = chrome;
				}
				browser.storage.sync.get('email', function(data) {
					var txtValue = data.email.toString();
					if (txtValue !== "undefined") {
						document.getElementById('IDToken1').value = data.email;
					}
				});
				setTimeout(function () {
					var submitButton = document.getElementById('IDButton2');
					submitButton.removeAttribute('disabled');
					submitButton.click();
				}, 100);
				return true;
			} catch (e) {
				return false;
			}
		}, 10);
	}
}
