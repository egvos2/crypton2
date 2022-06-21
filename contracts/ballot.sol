// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

contract Ballot {

    address public owner; // Contract owner
    address public contract_addr; // Contract address

    // Voter
    struct Voter {
        uint id; // Voter ID
        address addr; // Address of voter
        bool voted;  // if true, that person already voted
        uint voteCount; // number of accumulated votes
    }

    // Vote
    struct Vote {
        uint id; // Vote ID
        uint startTime; // Vote creation time (in sec)
        bool closed; // if true, that vote already closed
        uint balance; // Vote depo
        uint numVoters; // Voters number
        mapping (uint => Voter) voters; // Voters list
    }

    uint public numVotes; // Votes number
    mapping (uint => Vote) public votes; // Votes list

    // Constructor
    constructor () {
        owner = msg.sender;
        contract_addr = address(this);
    }

    // Create vote
    function createVote () public {
        require (msg.sender == owner, "Rejected! Only contract owner can create new vote!");
        // Add new Vote
        Vote storage v = votes[numVotes];
        v.id = numVotes;
        v.startTime = block.timestamp;
        // Inc counter
        numVotes++;
    }

    // Send vote depo by vote ID
    function sendDepo (uint ID) public payable {
        require (msg.value == 10000000000000000, "Rejected! Send exactly 0.01 ether to vote!");
        // Add new voter
        uint newID = votes[ID].numVoters;
        Voter storage v = votes[ID].voters[newID];
        v.id = newID;
        v.addr = msg.sender;
        // Inc voters counter
        votes[ID].numVoters++;
        // Inc vote balance
        votes[ID].balance += msg.value;
    }

    // Get votes IDs
    function getVotes () public view returns (uint[] memory) {
        uint[] memory ret = new uint[](numVotes);
        for (uint i = 0; i < numVotes; i++) {
            if (!votes[i].closed) // Not closed
			    ret[i] = votes[i].id;
		}
		return ret;
    }

    // Get voters IDs by vote ID
    function getVoters (uint ID) public view returns (uint[] memory) {
        uint[] memory ret = new uint[](votes[ID].numVoters);
        for (uint i = 0; i < votes[ID].numVoters; i++) {
			ret[i] = votes[ID].voters[i].id;
		}
		return ret;
    }

    // Get contract balance, vote balance by vote ID, winner reward and owner reward
    function getVoteInfo (uint ID) public view returns (uint[] memory) {
        uint[] memory ret = new uint[](4);
        ret[0] = contract_addr.balance;
        ret[1] = votes[ID].balance;
        ret[2] = votes[ID].balance/10;
        ret[3] = votes[ID].balance - votes[ID].balance/10;
		return ret;
    }

    // Send vote by Vote ID (ID1) and Voter ID (ID2)
    function sendVote (uint ID1, uint ID2) public {
        require (ID1 >= 0 && ID1 < numVotes, "Rejected! Vote ID is out of range!");
        require (ID2 >= 0 && ID2 < votes[ID1].numVoters, "Rejected! Voter ID is out of range!");
        // Find and check voter who send this vote
        bool can_voting = false; // If true then can vote
        uint voter_id;
        for (uint i = 0; i < votes[ID1].numVoters; i++) {
			if (msg.sender == votes[ID1].voters[i].addr) {
                if (!votes[ID1].voters[i].voted) {
                    can_voting = true;
                    voter_id = i;
                    break;
                }
            }
		}
        // If can voting then find ID2 voter
        require (can_voting == true, "Rejected! Can't vote!");
        if (can_voting) {
            for (uint i = 0; i < votes[ID1].numVoters; i++) {
                if (votes[ID1].voters[i].id == ID2) {
                    votes[ID1].voters[i].voteCount++; // Inc number of accumulated votes
                    votes[ID1].voters[voter_id].voted = true; // Now already voted
                    break;
                }
            }
        }
    }

    // Time info
    function getTimeInfo (uint ID) public view returns (uint[] memory) {
        uint[] memory ret = new uint[](2);
        ret[0] = votes[ID].startTime;
        ret[1] = block.timestamp;
		return ret;
    }

    // Close vote
    function closeVote (uint ID) public {
        require (ID >= 0 && ID < numVotes, "Rejected! Vote ID is out of range!");
        require (block.timestamp - votes[ID].startTime > 1/*259200*/, "Rejected! Three days have not yet passed!"); // 3 day in sec: 60*60*24*3
        // Find voter id with max vote count
        uint max_id = 0;
        if (votes[ID].numVoters > 1) {
            for (uint i = 1; i < votes[ID].numVoters; i++) {
                if (votes[ID].voters[i].voteCount > votes[ID].voters[max_id].voteCount) {
                    max_id = i;
                }
            }
        }
        // Close vote
        votes[ID].closed = true;
        // Calculate rewards
        uint owner_reward = votes[ID].balance/10;
        uint winner_reward = votes[ID].balance - owner_reward;
        //uint test_reward = 1000;
        // Pay the winner
        address payable pay_winner = payable(votes[ID].voters[max_id].addr);
        pay_winner.transfer(winner_reward);
        // Pay the owner
        address payable pay_owner = payable(owner);
        pay_owner.transfer(owner_reward);
        // Zero balance
        votes[ID].balance = 0;
    }

}