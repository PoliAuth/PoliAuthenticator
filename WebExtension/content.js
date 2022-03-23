if (window.location.href.includes("aunicalogin.polimi.it/aunicalogin/aunicalogin.jsp")) {
	var done = false;
	while (!done) {
		done = setTimeout(function () {
			try {
				if (typeof browser === "undefined") {
					var browser = chrome;
				}
				var buttonsContainer = document.getElementsByClassName('ingressoFederato')[0];
				var icon = browser.runtime.getURL('assets/images/PoliAuthenticator_White.png');
				var str = '<br/><button id="poliAuthButton" class="ingresso-federato-button ingresso-federato-button-size-m button-ingresso-federato"><span class="ingresso-federato-button-icon"><img src="' + icon + '" alt=""></span><span class="ingresso-federato-button-text">PoliAuthenticator</span></button>';
				buttonsContainer.innerHTML = buttonsContainer.innerHTML + str;
				document.getElementById('poliAuthButton').addEventListener('click', function() {
					window.location.href = browser.runtime.getURL('loading.html') + "?webeep=1";
				});
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
		if (typeof browser === "undefined") {
			var browser = chrome;
		}
		document.getElementsByTagName("html")[0].innerHTML = '';
		var iframe = document.createElement('iframe');
		iframe.src = browser.runtime.getURL('loading.html');
		iframe.style = 'width: 100%; height: 10000px; border: none;';
		document.body.appendChild(iframe);
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
				browser.storage.local.get('email', function(data) {
					var txtValue = data.email.toString();
					if (txtValue !== "undefined") {
						document.getElementById('IDToken1').value = txtValue;
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
