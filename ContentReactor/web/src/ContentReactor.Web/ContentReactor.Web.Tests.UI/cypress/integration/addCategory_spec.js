/// <reference types="Cypress" />
describe('Add category', function() {
    it('successful', function() {
        cy.visit('http://localhost:4200');
        cy.get('[data-cy=email-address-input]')
            .should('exist')
            .type('testing@test.com');
        cy.get('[data-cy=sign-in-button]')
            .should('exist')
            .click();
        cy.get('[data-cy=category-list]')
            .should('exist');
        cy.get('[data-cy=new-category-name-input')
            .should('exist')
            .type('Testing');
        cy.get('[data-cy=add-category-button]')
            .should('exist')
            .click();
        cy.get('[data-cy=category-list]')
            .should('exist');
        cy.get('[data-cy=category-name]')
            .should('have.text', 'Testing');
    });
  });