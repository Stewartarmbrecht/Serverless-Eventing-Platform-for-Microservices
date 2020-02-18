/// <reference types="Cypress" />
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
            url:`https://localhost:7001/api/healthcheck?userId=${$userId}`,
            method: 'GET'
        }).then(($res) => {
            expect($res.body.length).to.eq(4);
            expect($res.body[0].status).to.eq(0);
            expect($res.body[0].application).to.eq('toco-audio-api.azurewebsites.net');
            expect($res.body[1].status).to.eq(0);
            expect($res.body[1].application).to.eq('toco-audio-worker.azurewebsites.net');
            expect($res.body[2].status).to.eq(0);
            expect($res.body[2].application).to.eq('toco-categories-api.azurewebsites.net');
            expect($res.body[3].status).to.eq(0);
            expect($res.body[3].application).to.eq('toco-categories-worker.azurewebsites.net');
        });
    });
  });