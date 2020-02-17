/// <reference types="Cypress" />
describe('Crud category', function() {
    function makeid(length) {
        var result           = '';
        var characters       = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        var charactersLength = characters.length;
        for ( var i = 0; i < length; i++ ) {
           result += characters.charAt(Math.floor(Math.random() * charactersLength));
        }
        return result;
     }
     

    it('successful', function() {
        var $name1 = 'Dog';
        var $name2 = 'Cat';
        var $ids = {
            "id1": "",
            "id2": ""
        }
        var $userId = makeid(5);
        // Add 1
        cy.request({ 
            url:`https://localhost:7071/api/categories?userId=${$userId}`,
            method: 'POST',
            body: `{ "name": "${$name1}" }`
        })
        // Add 2
        .then(($res) => {
            $ids.id1 = $res.body.id;
            return cy.request({
                url:`https://localhost:7071/api/categories?userId=${$userId}`,
                method: 'POST',
                body: `{ "name": "${$name2}" }`
            }).then(($res) => {
                $ids.id2 = $res.body.id;
                return cy.wrap($ids);
            });
        })
        // Get 1
        .then(($ids) => {
            return cy.request({
                url:`https://localhost:7071/api/categories/${$ids.id1}?userId=${$userId}`,
                method: 'GET'
            }).then(($getRes) => {
                expect($getRes.body.id).to.eq($ids.id1);
                expect($getRes.body.name).to.eq($name1);
                return cy.wrap($ids);
            });
        })
        // Update 1
        .then(($ids) => {
            return cy.request({
                url:`https://localhost:7071/api/categories/${$ids.id1}?userId=${$userId}`,
                method: 'PATCH',
                body: `{ "name": "${$name1} Updated" }`
            }).then(($res) => {
                expect($res.status).to.eq(204);
                return cy.wrap($ids);
            });
        })
        // Get 1 Updated
        .then(($ids) => {
            return cy.request({
                url:`https://localhost:7071/api/categories/${$ids.id1}?userId=${$userId}`,
                method: 'GET'
            }).then(($getRes) => {
                expect($getRes.body.id).to.eq($ids.id1);
                expect($getRes.body.name).to.eq(`${$name1} Updated`);
                return cy.wrap($ids);
            });
        })
        // Get 2 to Validate Image and Synonyms
        .then(($ids) => {
            return cy.request({
                url:`https://localhost:7071/api/categories/${$ids.id2}?userId=${$userId}`,
                method: 'GET'
            }).then(($getRes) => {
                expect($getRes.body.imageUrl).to.not.be.null;
                expect($getRes.body.synonyms.length).to.be.gt(2);
                return cy.wrap($ids);
            });
        })
        // Get List
        .then(($ids) => {
            return cy.request({
                url:`https://localhost:7071/api/categories?userId=${$userId}`,
                method: 'GET'
            }).then(($res) => {
                expect(Object.keys($res.body).length).to.eq(2);
                return cy.wrap($ids);
            });
        })
        // Delete 1
        .then(($ids) => {
            return cy.request({
                url:`https://localhost:7071/api/categories/${$ids.id1}?userId=${$userId}`,
                method: 'DELETE'
            }).then(($res) => {
                expect($res.status).to.eq(204);
                return cy.wrap($ids);
            });
        })
        // Delete 2
        .then(($ids) => {
            return cy.request({
                url:`https://localhost:7071/api/categories/${$ids.id2}?userId=${$userId}`,
                method: 'DELETE'
            }).then(($res) => {
                expect($res.status).to.eq(204);
                return cy.wrap($ids);
            });
        })
        // Get List
        .then(($ids) => {
            return cy.request({
                url:`https://localhost:7071/api/categories?userId=${$userId}`,
                method: 'GET'
            }).then(($res) => {
                expect(Object.keys($res.body).length).to.eq(0);
                return cy.wrap($ids);
            });
        })
    });
  });