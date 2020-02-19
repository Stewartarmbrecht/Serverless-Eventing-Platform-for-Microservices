/// <reference types="Cypress" />
describe('Log In', function() {
    it('Successful', function() {
      cy.request('http://localhost:5000/api/health?userId=test@test.com')
        .then(($res) => {
          expect($res.status).to.eq(200);
          expect($res.body.status).to.eq(0);
          expect($res.body.application).to.eq('localhost');
        });
    });
  });