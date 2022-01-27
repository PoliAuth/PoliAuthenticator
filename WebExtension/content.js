
if (window.location.href.includes("aunicalogin.polimi.it/aunicalogin/aunicalogin.jsp")) {
	setTimeout(function () {
		try {
            var s = document.createElement('script');
                s.type = 'text/javascript';
                var code = 'function performPoliAuth() { var myDate = new Date(); myDate.setMonth(myDate.getMonth() + 12); document.cookie = "poliAuthenticator=true;expires=" + myDate + ";domain=.polimi.it;path=/"; document.cookie = "poliAuthenticator_redirectUrl=" + window.location.href + ";expires=" + myDate + ";domain=.polimi.it;path=/"; window.location.href= "poliauth://open"; } ';
                try {
                  s.appendChild(document.createTextNode(code));
                  document.body.appendChild(s);
                } catch (e) {
                  s.text = code;
                  document.body.appendChild(s);
                }
			let buttonsContainer = document.getElementsByClassName('ingressoFederato')[0];
			buttonsContainer.innerHTML = buttonsContainer.innerHTML +
			'<br/><a href="#" onclick="performPoliAuth()" class="ingresso-federato-button ingresso-federato-button-size-m button-ingresso-federato"><span class="ingresso-federato-button-icon"><img src="http://matmacsystemfile.altervista.org/immagini/PoliAuthenticator_White.png" alt=""></span><span class="ingresso-federato-button-text">PoliAuthenticator</span></a>';
			///aunicalogin/assets/cie/img/SVG/Logo_CIE_ID.svg
		} catch (e){}


	}, 100);
}


if (window.location.href.includes("webeep.polimi.it/my")) {
            var name = 'poliAuthenticator';
            const value = `; ${document.cookie}`;
            const parts = value.split(`; ${name}=`);
            var c = undefined;
            if (parts.length === 2) {
                c = parts.pop().split(';').shift();
            }
            if(c != undefined){
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
                	if(c != undefined){
											document.cookie = "poliAuthenticator_redirectUrl=no;expires=" + d + ";domain=.polimi.it;path=/";
                    	window.location.href = c;
                	} else {
										window.location.href = window.location.href
									}
								}, 1000);
          	}
}
