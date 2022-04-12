// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Bank {
    address public owner;
    uint256 public bankBalance = address(this).balance;

    mapping(address=>uint256) public addressToBalance;
    mapping(address=>bool) public addressToUser;
    mapping(address=>Person) public addressToPerson;

    uint256 public peopleCount;
    Person[] public people;

    struct Person {
        uint256 id;
        string name;
    }

    //Contract's events
    event ViewedTransaction(address _from);
    event Deposit(address _from, uint256 _amount);
    event Withdraw(address _to, uint256 _amount);
    
    //Modifiers to only allow specific people/addresses to use certain functions
    modifier onlyOwner {
        require(msg.sender == owner, "Invalid, only owner can access this function");
        _;
    }

    modifier onlyPerson {
        //Require you to have been a previous user
        require(addressToUser[msg.sender] == true, "Invalid, you have not signed up with the bank");
        _;
    }

    constructor() {
        //Whenever contract is first deployed the deployer is the owner
        owner = msg.sender;  
    }

    //Fallback function will get executed when a function that doesnt exist is called from the contract
    fallback() external payable{} 
    receive() external payable{}

    //Viewing the contract's balance
    function viewBankBalance() public view returns(uint256) {
        return bankBalance;
    }
 
    //Only the owner(contract deployer) can add a person to the database
    function addPerson(address payable _addr, string memory _name) public onlyOwner{
        //Increment people count
        peopleCount+=1;
        addressToPerson[_addr] = Person(peopleCount-1, _name);
        people.push(Person(peopleCount-1, _name));
        addressToUser[_addr] = true;
    }

    //User can view their own bank balance
    function viewBalance() public view returns(uint256){
        return addressToBalance[msg.sender];
    }

    //User can deposit into the bank 
    function deposit() external payable onlyPerson{
        (bool sent, bytes memory data) = payable(address(this)).call{value: msg.value}("");
        addressToBalance[msg.sender] = msg.value;
        bankBalance+=msg.value;
        require(sent, "Invalid transaction");
        emit Deposit(msg.sender, msg.value);
    }

    //User can withdraw their own balance
    function withdraw() public payable onlyPerson{
        require(msg.value<=addressToBalance[msg.sender], "Insufficient funds");
        (bool sent, bytes memory data) = msg.sender.call{value: msg.value}("");
        require(sent, "Invalid transaction");
        addressToBalance[msg.sender]-=msg.value;
        bankBalance -= msg.value;
        emit Withdraw(msg.sender, msg.value);
    }
}
