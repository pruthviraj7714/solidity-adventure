// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract TokenSystem {
    address public owner;
    string public name;
    string public symbol;
    uint256 public totalSupply;
    mapping(address => uint256) private accounts;

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Mint(address indexed to, uint256 amount);
    event Burn(uint256 amount);

    constructor(string memory _name, string memory _symbol, uint256 _initialSupply) {
        name = _name;
        symbol = _symbol;
        owner = msg.sender;
        totalSupply = _initialSupply;
        accounts[owner] = _initialSupply;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not authorized owner");
        _;
    }

    function mint(address _address,uint256 _amount) public onlyOwner {
        require(_address != address(0), "Cannot transfer to zero address");
        totalSupply+= _amount;
        accounts[_address] += _amount;
        emit Mint(_address, _amount);
    }

    function getBalance(address _address) public view returns(uint256) {
        return accounts[_address];
    }

    function transfer(address _to, uint256 _amount) public {
        require(_to != address(0), "Cannot transfer to zero address");
        require(accounts[msg.sender] >= _amount, "Insufficient balance");
        accounts[msg.sender] -= _amount;
        accounts[_to] += _amount;
        emit Transfer(msg.sender, _to, _amount);
    }

    function burn(uint256 _amount) public onlyOwner {
        require(totalSupply >= _amount, "Total supply is lower than amount");
        totalSupply-= _amount;
        emit Burn(_amount);
    }

    function getTotalSupply() public view returns(uint256) {
        return totalSupply;
    }
}
