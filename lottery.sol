pragma solidity >=0.5.0 < 0.9.0;

contract Lottery {
    address payable[] public players;
    address public manager;

    constructor() {
        manager = msg.sender;
    }

    receive() external payable {
        require(msg.value == 0.05 ether);
        players.push(payable(msg.sender));
    }

    modifier onlyManager() {
        require(msg.sender == manager);
        _;
    }

    function getBalance() public onlyManager view returns(uint) {
        return address(this).balance;
    }

    function random() internal view returns(uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
    }

    function pickWinner() public onlyManager {
        require(players.length >= 3);

        uint r = random();
        address payable winner;

        uint index = r % players.length;
        winner = players[index];
        
        uint managerFee = (getBalance() * 10 ) / 100; // manager fee is 10%
        uint winnerPrize = (getBalance() * 90 ) / 100;     // winner prize is 90%

        // transferring 90% of contract's balance to the winner
        winner.transfer(winnerPrize);
        
        // transferring 10% of contract's balance to the manager
        payable(manager).transfer(managerFee);
        
        // resetting the lottery for the next round
        players = new address payable[](0);
    }
}
