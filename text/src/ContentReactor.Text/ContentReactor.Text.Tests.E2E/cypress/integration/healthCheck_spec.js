/// <reference types="../../node_modules/Cypress" />
describe('Health Check', function() {
    function makeid(length) {
        var result           = '';
        var characters       = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        var charactersLength = characters.length;
        for ( var i = 0; i < length; i++ ) {
           result += characters.charAt(Math.floor(Math.random() * charactersLength));
        }
        return result;
    }
    it('API successful', function() {
        var $userId = makeid(5);
        cy.request({ 
            url:`https://localhost:7077/api/healthcheck?userId=${$userId}`,
            method: 'GET'
        }).then(($res) => {
            expect($res.body.status).to.eq(0);
            expect($res.body.application).to.eq('localhost');
        });
    });
  });