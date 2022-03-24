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
				var str = '<br/><button type="button" id="poliAuthButton" class="ingresso-federato-button ingresso-federato-button-size-m button-ingresso-federato"><span class="ingresso-federato-button-icon"><img src="' + icon + '" alt=""></span><span class="ingresso-federato-button-text">PoliAuthenticator</span></button>';
				buttonsContainer.innerHTML = buttonsContainer.innerHTML + str;
				document.getElementById('poliAuthButton').addEventListener('click', function() {
					drawIFrame();
					setTimeout(function () {
						performPoliAuth();
					}, 100);
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
		drawIFrame();
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
				drawIFrame();
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


if (window.location.href.includes("?webeep=1")) {
	if (typeof browser === "undefined") {
		var browser = chrome;
	}
	performPoliAuth();
	window.location.href = browser.runtime.getURL('loading.html');;
}


function drawIFrame() {
	if (typeof browser === "undefined") {
		var browser = chrome;
	}
	var newStyle = document.createElement('style');
	newStyle.innerHTML = 'html { visibility: hidden; --body-background-image: !important; --body-background-fallback-color: white !important; }';
	document.body.appendChild(newStyle);
	var iframe = document.createElement('iframe');
	iframe.src = browser.runtime.getURL('loading.html');
	iframe.style = 'border:none; height:100%; width:100%; position:absolute; inset:0px; visibility: initial;';
	document.body.appendChild(iframe);
}


function performPoliAuth() {
    var myDate = new Date();
    myDate.setMonth(myDate.getMonth() + 12);
    document.cookie = "poliAuthenticator=true;expires=" + myDate + ";domain=.polimi.it;path=/"; document.cookie = "poliAuthenticator_redirectUrl=" + window.location.href + ";expires=" + myDate + ";domain=.polimi.it;path=/";
    window.location.href= "poliauth://open";
}
