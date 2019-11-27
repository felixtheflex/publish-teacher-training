
// const url = 'https://www.qa.publish-teacher-training-courses.service.gov.uk';
const jsdom = require("jsdom");
const { JSDOM } = jsdom;

const urlBase = "https://localhost:3000";
const _ = Cypress._;

describe("login", function () {

  Cypress.Commands.add('loginWithSignIn', (username, password) => {
    Cypress.Cookies.debug(true);

    var step1_option = {
      method: 'GET',
      url: `${urlBase}/auth/dfe`,
      followRedirect: false
    };
    console.log("1");
    console.log(step1_option.url);

    // var extractGuidFromUrl = (url) => {
    //   var re = new RegExp("/([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})/");

    //   return re.exec(url)[1];
    // };

    cy.clearCookies()

    debugger;

    return cy.request(step1_option)
      .then((resp) => {
        return cy.request({
          method: 'GET',
          url: resp.redirectedToUrl,
          followRedirect: true
        });
      })
      .then(response => {
        var postURL = new URL(
          response.allRequestResponses[response.allRequestResponses.length - 1]["Request URL"]
        );
        console.log(postURL);
        // cy.request({
        //   method: 'POST',
        //   url: '/login',
        //   failOnStatusCode: false, // dont fail so we can make assertions
        //   form: true, // we are submitting a regular form body
        //   body: {
        //     username,
        //     password,
        //     _csrf: csrfToken // insert this as part of form body
        //   }
        // })


        const $html = Cypress.$(response.body);
        const csrfToken = $html.find("input[name=_csrf]").val();
        const clientId = $html.find("input[name=clientId]").val();
        const redirectUri = $html.find("input[name=redirectUri]").val();
        const responses = response["allRequestResponses"];
        const cookiesSet = responses[responses.length - 1]["Response Headers"]["set-cookie"];
        // 0: "_csrf=KDonEKj24XFEwGcOE8ndYfRr; Path=/; HttpOnly; Secure"
        // 1: "session=eyJyZWRpcmVjdFVyaSI6bnVsbH0=; path=/; secure; httponly"
        // 2: "session.sig=SaZR0Tt8DIt3oKMJyJ8qA58_iBw; path=/; secure; httponly"
        const cookieWholeRE = new RegExp("^([^;]+);");
        var cookieHeaders = [];
        if(cookiesSet != undefined) {
          cookieHeaders = cookiesSet.map((cookie) => { return cookieWholeRE.exec(cookie)[1]; });
          const cookiePartsRE = new RegExp("^(.+?)=(.+?);");
          cookiesSet.forEach((cookie) => {
            var matches = cookiePartsRE.exec(cookie);
            console.log("Setting cookie: " + matches[1]);
            cy.setCookie(
              matches[1],
              matches[2],
              {
                domain: postURL.hostname,
              }
            );
          });
        } else {
          console.log("cookies not set: " + cookiesSet);
        }

        logger(response);

        debugger;

        console.log(`curl -b '${cookieHeaders.join("; ")}' -d username=${username} -d password='${password} -d _csrf='${csrfToken} -d cliendId='${clientId} -d redirectUri='${redirectUri}' '${postURL}'`);

        cy.request({
          method: 'POST',
          url: postURL.toString(),
          failOnStatusCode: false,
          form: true,
          body: {
            username: username,
            password: password,
            _csrf: csrfToken,
            clientId: clientId,
            redirectUri: redirectUri,
          },
        }).then((response) => {
            logger(response);
            debugger;
          });

  });

  it("logging in ", function () {
    cy.loginWithSignIn("tim.abell+4@digital.education.gov.uk", 'omgsquirrel!88')
    //   .then((resp) => {
    //     debugger;
    //     expect(resp.status).to.eq(200);
    //     expect(resp.url).to.eq('https://localhost:3000/');
    // });
    cy.visit(urlBase);
  });
});


function logger(thing) {
  console.log(JSON.parse(JSON.stringify(thing)));
}

