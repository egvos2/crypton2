const { expect } = require ("chai")
const { ethers } = require ("hardhat")

describe ("Ballot", function () {
    let acc1
    let acc2
    let acc3
    let acc4
    let acc5
    let ballots

    /*befor (async function () {
        [acc1, acc2, acc3, acc4, acc5] = await ethers.getSigners ()
        const Ballots = await ethers.getContractFactory ("Ballot", acc1)
        ballots = await Ballots.deploy ()
        await ballots.deployed ()
        console.log (ballots.address)
    })*/

    it ("should be deployed", async function () {
        [acc1, acc2, acc3, acc4, acc5] = await ethers.getSigners ()
        const Ballots = await ethers.getContractFactory ("Ballot", acc1)
        ballots = await Ballots.deploy ()
        await ballots.deployed ()
        console.log (ballots.address)
        console.log("Success!")
    })
})
