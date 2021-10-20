// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract BeerWall {
    address topGiver;
    address topTaker;

    constructor() {
        for (uint i = 0; i < 10; i++) {
            beers.push(Beer(msg.sender, "First round on me!"));
        }
        console.log("Beer wall created! There are currently %s beers available.", getTotalBeers());
    }

    event BeerTaken(address beerTakenBy, address beerGivenBy, string giverMessage);
    event BeerGiven(address beerGivenBy, string message);

    mapping (address => uint) beersGivenByUser;
    mapping (address => uint) beersTakenByUser;
    mapping (address => uint) lastBeerGiven;
    mapping (address => uint) lastBeerTaken;

    struct Beer {
        address giver;
        string message;
    }

    Beer[] beers;

    modifier beersAreAvailable() {
        require(
            beers.length > 0,
            "Sorry m8! No beers are left :'( Maybe consider giving a beer for someone to enjoy later ;)"
        );
        _;
    }

    modifier canGiveBeer() {
        require(
            lastBeerGiven[msg.sender] + 2 minutes < block.timestamp,
            "Your generosity is epic, but you should let other people donate beers as well."
        );
        lastBeerGiven[msg.sender] = block.timestamp;
        _;
    }

    modifier canTakeBeer() {
        require(
            lastBeerTaken[msg.sender] + 5 minutes < block.timestamp,
            "Slow down partner! I know they're free, but wait 5 minutes before having another."
        );
        lastBeerTaken[msg.sender] = block.timestamp;
        _;
    }

    function getTotalBeers() public view returns (uint) {
        return beers.length;
    }

    function takeBeer() public beersAreAvailable canTakeBeer {
        beersTakenByUser[msg.sender] += 1;

        updateTopTaker();

        Beer memory beer = getBeerToTake();

        emit BeerTaken(msg.sender, beer.giver, beer.message);
    }

    function giveBeer(string memory _message) public canGiveBeer {
        address sender = msg.sender;

        beers.push(Beer(sender, _message));
        beersGivenByUser[sender] += 1;

        emit BeerGiven(sender, _message);

        updateTopGiver();
    }

    function getTopBeerGiverAndAmount() public view returns (address, uint) {
        return (topGiver, beersGivenByUser[topGiver]);
    }

    function getTopBeerTakerAndAmount() public view returns (address, uint) {
        return (topTaker, beersTakenByUser[topTaker]);
    }

    function getResultsOfAddress(address _address) public view returns (uint, uint) {
        return(beersTakenByUser[_address], beersGivenByUser[_address]);
    }

    function getBeers() public view returns (Beer[] memory) {
        return beers;
    }

    function getBeerToTake() private returns (Beer memory) {
        Beer memory firstBeer = beers[0];
        Beer memory beerToTake = Beer(
            firstBeer.giver,
            firstBeer.message
        );

        removeFirst();

        return beerToTake;
    }

    function removeFirst() private beersAreAvailable {
        for (uint i = 0; i < beers.length - 1; i++) {
            beers[i] = beers[i + 1];
        }
        beers.pop();
    }

    function updateTopTaker() private {
        if (beersTakenByUser[msg.sender] > beersTakenByUser[topTaker]) {
            topTaker = msg.sender;
        }
    }

    function updateTopGiver() private {
        if (beersGivenByUser[msg.sender] > beersGivenByUser[topGiver]) {
            topGiver = msg.sender;
        }
    }
}