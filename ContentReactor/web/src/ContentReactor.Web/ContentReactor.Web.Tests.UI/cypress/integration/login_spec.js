/// <reference types="Cypress" />
describe('Log In', function() {
    it('Successful', function() {
      cy.visit('http://localhost:4200');
      cy.get('[data-cy=email-address-input]')
        .should('exist')
        .type('testing@test.com');
      cy.get('[data-cy=sign-in-button]')
        .should('exist')
        .click();
      cy.get('[data-cy=categories-list]')
        .should('exist');
    });
  });