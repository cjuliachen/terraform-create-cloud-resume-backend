/// <reference types="cypress" />

describe('End-to-End Test', () => {
  it('check if API call returns data', () => {
    cy.request('POST', 'YOUR API URL').then((resp) => {
      const data = resp.body;
      expect(resp.status).to.eq(200)
      expect(data.count).to.not.be.oneOf([null, "", undefined])
    })
  })
  it('check resume page and confirm if visitorCount exists', () => {
    cy.visit('https://YOUR RESUME URL/index.html')
    cy.title().should('eq','Resume' )
    cy.get('#visitorCount').contains(/^[0-9]*$/)
  })
})
