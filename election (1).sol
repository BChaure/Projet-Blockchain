pragma solidity ^0.6.12;

// SPDX-License-Identifier: GPL-3.0

import "./Ownable.sol";
import "./SafeMath.sol";

contract Election is President {

using SafeMath for uint256;

    struct Seance {
        string description;
        // Store accounts that have voted
        mapping(address => bool) voted;
        bool[] votes;
        uint end;
        bool adopted;
    }
    
    uint public cptID;
    
    address public scrutateur;
    address public secretaire;
    uint public votingTimeInMinutes;
     mapping (address => bool) public candidates;
    mapping(uint => Seance) public seances;
    // Store Candidates Count
    uint public candidatesCount;
    // Store Seances Count
    uint public seancesCount;
    
    
    modifier isOpen(uint index) {
        require(now < seances[index].end);
        _;
    }
    modifier isClosed(uint index) {
        require(now > seances[index].end);
        _;
    }
    modifier didNotVoteYet(uint index) {
        require(!seances[index].voted[msg.sender]);
        _;
    }



    function addCandidate (address candidate) public {
        candidatesCount ++;
        candidates[candidate] = true;
    }
    
    function remCandidate (address candidate) public {
        delete candidates[candidate];
        candidatesCount --;
    }
    
    function addSeance (string memory description) public onlyPresident {
        cptID ++;
        Seance memory s;
        
        s.description = description;
        
        s.end = now + votingTimeInMinutes * 1 minutes;
        
        seances[cptID] = s;
        
        seancesCount ++;
    }
    
    // Fonction de modification du temps
    function setVotingTime(uint newVotingTime) public onlyPresident {
        votingTimeInMinutes = newVotingTime;
    }
    
    function setScrutateur(address candidate) public onlyPresident {
        scrutateur = candidate;
    }
    
    function setSecretaire(address candidate) public onlyPresident {
        secretaire = candidate;
    }

    function vote (uint seanceId, bool candidate_vote) public didNotVoteYet(seanceId) onlyWhitelisted{
        seances[seanceId].votes.push(candidate_vote);
        seances[seanceId].voted[msg.sender] = true;
        
    }
    
    modifier onlyScrutateur() {
        require(msg.sender == scrutateur);
        _;
    }
    
    function result(uint index) public onlyScrutateur {
        uint yes;
        uint no;
        bool[] memory votes = seances[index].votes;

        // On compte les pour et les contre
        for(uint counter = 0; counter < votes.length; counter++) {
            if(votes[counter]) {
                yes++;
            } else {
                no++;
            }
        }
        if(yes > no) {
           seances[index].adopted = true; 
        }
    }
    
    mapping(address => bool) whitelist;
    event AddedToWhitelist(address indexed account);
    event RemovedFromWhitelist(address indexed account);

    modifier onlyWhitelisted() {
        require(isWhitelisted(msg.sender));
        _;
    }

    function addWhiteList(address _address) public onlyPresident {
        whitelist[_address] = true;
        emit AddedToWhitelist(_address);
    }

    function removeWhiteList(address _address) public onlyPresident {
        whitelist[_address] = false;
        emit RemovedFromWhitelist(_address);
    }

    function isWhitelisted(address _address) public view returns(bool) {
        return whitelist[_address];
    }
}