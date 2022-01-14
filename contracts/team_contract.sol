// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract itsSalaryDay is Ownable {
    AggregatorV3Interface internal priceFeed;

    // cofounders
    mapping(uint8 => address) public idxToCof;
    mapping(address => uint8) public cofToIdx;
    mapping(address => bool) public isCof;
    mapping(address => uint32) public shares;
    uint8 public numCofounder = 4;

    // members
    uint256 public numMember = 0;
    mapping(uint256 => address) public idxToMem;
    mapping(address => uint256) public memToIdx;
    mapping(address => bool) public isMem;
    mapping(address => uint32) public salaries;

    // mainnet:	0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
    // rinkeby: 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
    constructor(address[] memory cofounders, uint8[] memory _shares) {
        for (uint8 i = 0; i < cofounders.length; i++) {
            cofToIdx[cofounders[i]] = i;
            idxToCof[i] = cofounders[i];
            isCof[cofounders[i]] = true;
            shares[cofounders[i]] = _shares[i];
        }
        priceFeed = AggregatorV3Interface(
            0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
        );
    }

    // -------------------------------------------------------------------------------------------
    // onlyOwner
    // members
    function addMembers(address[] calldata newMems, uint32[] calldata _salaries)
        external
        onlyOwner
    {
        require(newMems.length == _salaries.length, "length mismatch");
        for (uint256 i = 0; i < newMems.length; i++) {
            require(!isMem[newMems[i]], "Member is already in our team");
            memToIdx[newMems[i]] = numMember;
            idxToMem[numMember++] = newMems[i];
            salaries[newMems[i]] = _salaries[i];
            isMem[newMems[i]] = true;
        }
    }

    function removeMembers(address[] calldata memToRemove) external onlyOwner {
        for (uint256 i = 0; i < memToRemove.length; i++) {
            require(isMem[memToRemove[i]], "Member is already not in our team");
            idxToMem[memToIdx[memToRemove[i]]] = address(0);
            memToIdx[memToRemove[i]] = 0;
            salaries[memToRemove[i]] = 0;
            isMem[memToRemove[i]] = false;
        }
    }

    function updateSalary(
        address[] calldata mems,
        uint32[] calldata newSalaries
    ) external onlyOwner {
        require(mems.length == newSalaries.length, "length mismatch");
        for (uint256 i = 0; i < mems.length; i++) {
            require(isMem[mems[i]], "Only members can share profits");
            salaries[mems[i]] = newSalaries[i];
        }
    }

    function transferSalary() external onlyOwner {
        for (uint256 i = 0; i < numMember; i++) {
            if (isMem[idxToMem[i]]) {
                (bool success, ) = idxToMem[i].call{
                    value: ((salaries[idxToMem[i]] * 10**36) / getETH_USD())
                }("");
                require(success, "Transaction unsuccessful");
            }
        }
    }

    // -------------------------------------------------------------------------------------------
    // onlyOwner
    // Cofounders
    function removeCofounder(address cofToRemove) external onlyOwner {
        require(isCof[cofToRemove], "Cofounder is already not in our team");
        idxToCof[cofToIdx[cofToRemove]] = address(0);
        cofToIdx[cofToRemove] = 0;
        shares[cofToRemove] = 0;
        isCof[cofToRemove] = false;
    }

    function updateShare(address[] calldata cofs, uint8[] calldata newShares)
        external
        onlyOwner
    {
        require(cofs.length == newShares.length, "length mismatch");
        for (uint256 i = 0; i < cofs.length; i++) {
            require(isCof[cofs[i]], "Only cofounders can share profits");
            shares[cofs[i]] = newShares[i];
        }
    }

    function transferShare() external onlyOwner {
        uint256 total = (address(this).balance * 85) / 100;
        for (uint8 i = 0; i < numCofounder; i++) {
            if (isCof[idxToCof[i]]) {
                (bool success, ) = idxToCof[i].call{
                    value: (total * shares[idxToCof[i]]) / 100
                }("");
                require(success, "Transaction unsuccessful");
            }
        }
    }

    // -------------------------------------------------------------------------------------------
    // normal
    function changeWallet(address newAddress) external {
        require(
            isMem[msg.sender] || isCof[msg.sender],
            "You are not in members list"
        );
        if (isMem[msg.sender]) {
            salaries[newAddress] = salaries[msg.sender];
            memToIdx[newAddress] = memToIdx[msg.sender];
            idxToMem[memToIdx[msg.sender]] = newAddress;
            isMem[newAddress] = true;

            isMem[msg.sender] = false;
            salaries[msg.sender] = 0;
            memToIdx[msg.sender] = 0;
        } else if (isCof[msg.sender]) {
            shares[newAddress] = shares[msg.sender];
            cofToIdx[newAddress] = cofToIdx[msg.sender];
            idxToCof[cofToIdx[msg.sender]] = newAddress;
            isCof[newAddress] = true;

            isCof[msg.sender] = false;
            cofToIdx[msg.sender] = 0;
            shares[msg.sender] = 0;
        }
    }

    function checkSalary(address addr) external returns (uint32) {
        require(isMem[addr] || isCof[addr], "You are not in our team");
        if (isMem[addr]) {
            return salaries[addr];
        } else if (isCof[addr]) {
            return shares[addr];
        }
    }

    // -------------------------------------------------------------------------------------------
    // Other
    function transferEthToThisContract() external payable {}

    function getETH_USD() internal view returns (uint256) {
        (, int256 temp, , , ) = priceFeed.latestRoundData();
        return uint256(temp * 10**10);
    }

    function withdraw() external onlyOwner {
        (bool success, ) = owner().call{value: address(this).balance}("");
        require(success, "Transaction Unsuccessful");
    }

    function withdrawAmount(uint256 in_eth) external onlyOwner {
        (bool success, ) = owner().call{value: in_eth * 10**18}("");
        require(success, "Transaction Unsuccessful");
    }
}
