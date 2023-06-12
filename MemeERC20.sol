// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ChangeableToken is ERC20 {
    address private owner;
    string public name;
    string public symbol;
    uint256 public lastChangeTime;
    uint256 private _totalSupply;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _initialSupply) ERC20(_name, _symbol) {
        owner = msg.sender;
        name = _name;
        symbol = _symbol;
        _totalSupply = _initialSupply;
        _mint(msg.sender, _initialSupply);
    }

    function changeNameAndSymbol(string memory _newName, string memory _newSymbol) public {
        require(msg.sender == owner || canChangeNameAndSymbol(), "Cooldown period is not over");
        require(bytes(_newName).length > 0 && bytes(_newSymbol).length > 0, "Name and symbol cannot be empty");

        name = _newName;
        symbol = _newSymbol;
        lastChangeTime = block.timestamp;
    }

    function canChangeNameAndSymbol() public view returns (bool) {
        uint256 burnedPercentage = calculateBurnedPercentage();

        // Calculate cooldown period based on the percentage of tokens burned
        uint256 cooldownPeriod = (_totalSupply * 10 years * burnedPercentage) / (10**18);

        return block.timestamp - lastChangeTime >= cooldownPeriod;
    }

    function calculateBurnedPercentage() public view returns (uint256) {
        uint256 burnedTokens = _totalSupply - balanceOf(address(0)); // Assuming burned tokens are sent to address(0)
        uint256 burnedPercentage = (burnedTokens * (10**18)) / _totalSupply; // Convert to fixed-point decimal

        return burnedPercentage;
    }
}
