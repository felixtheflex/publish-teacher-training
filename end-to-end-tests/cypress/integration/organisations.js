const baseUrl = Cypress.config().baseUrl;

describe("login", function () {
  it("viewing organisation list ", function () {
    cy.signIn()
      .visit(baseUrl);

    cy.url().should('eq', baseUrl);
    cy.get('h1').contains('Organisations');
    cy.get('footer').scrollIntoView({ duration: 2000 });

    // cy.request(`${baseUrl}/signout`);

    ////////////////////////////////////////////////////////////////

    Cypress.Cookies.debug(true);

    const url = `${baseUrl}/signout`;

    const params = {
      method: 'GET',
      url: url,
      followRedirect: false,
    };

    cy.log('initialRequestOptions', params);

    cy.request(params)
      .then((response) => {
        if (response.status == 302) {
          cy.request(response.headers.location)
            .then((response) => {
              const form = getForm(response.body);
              const formInputs = arrayToObject(form.querySelectorAll('input'));

              cy.log("logout url: " + form.action);
              const params = {
                method: 'POST',
                url: form.action,
                failOnStatusCode: false,
                followRedirect: false,
                form: true,
                body: formInputs,
              };

              cy.log('loginPostRequestOptions', params);

              return cy.request(params);
            });
          cy.visit(baseUrl);
        };
      });
  });
});

function arrayToObject(inputs, overrides) {
  inputs = Array.from(inputs);
  const reducer = (obj, item) => {
    obj[item.name] = item.value;
    return obj;
  };
  return Object.assign(inputs.reduce(reducer, {}), overrides);
};

function getForm(body) {
  return Cypress.$(body).find('form')[0];
};

