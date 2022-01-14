// SPDX-License-Identifier: MIT

//
//
//      `7MN.   `7MF'  `7MM"""YMM   MMP""MM""YMM   `7MM"""Yb.
//        MMN.    M      MM    `7   P'   MM   `7     MM    `Yb.
//        M YMb   M      MM   d          MM          MM     `Mb   ,6"Yb.   ,pW"Wq.
//        M  `MN. M      MM""MM          MM          MM      MM  8)   MM  6W'   `Wb
//        M   `MM.M      MM   Y          MM          MM     ,MP   ,pm9MM  8M     M8
//        M     YMM      MM              MM          MM    ,dP'  8M   MM  YA.   ,A9
//      .JML.    YM    .JMML.          .JMML.      .JMMmmmdP'    `Moo9^Yo .`Ybmd9'
//
//

// two kinds of token
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";

// tokenId: prime 0 ~ 999,                       vital 0 ~ 9999
//          reserved prime 10000 ~ 10099,        reserved vitl 10100 ~ 11000
contract nft_dropsV2 is ERC721Enumerable, Ownable {
    uint16 public immutable MAX_VITAL_PASSES;
    uint16 public immutable MAX_PRIME_PASSES;
    uint16 public immutable MAX_VITAL_WHITELIST;
    uint16 public immutable MAX_PRIME_WHITELIST;
    uint16 public immutable MAX_RESERVED_VITAL_PASS;
    uint16 public immutable MAX_RESERVED_PRIME_PASS;

    uint8 public immutable MAX_VITAL_PER_WALLET;
    uint8 public immutable MAX_PRIME_PER_WALLET;

    uint16 public counterVitalPass;
    uint16 public counterPrimePass;
    uint16 public counterVitalReserved;
    uint16 public counterPrimeReserved;

    uint256 public period;

    uint256 public PRICE_VITAL_PASS = 0.2 ether;
    uint256 public PRICE_PRIME_PASS = 0.8 ether;

    string public BASE_URI;

    uint256 public vitalPublicStart;
    uint256 public primePublicStart;
    uint256 public vitalWhitelistStart;
    uint256 public primeWhitelistStart;

    mapping(address => uint8) public balanceVital;
    mapping(address => uint8) public balancePrime;
    event BaseURIChanged(string BASE_URI);

    modifier onlyWhitelist(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) {
        require(MerkleProof.verify(proof, root, leaf) == true);
        _;
    }

    constructor(
        uint256 _vitalPublicStart,
        uint256 _primePublicStart,
        uint256 _vitalWhitelistStart,
        uint256 _primeWhitelistStart,
        uint256 _period
    ) ERC721("qwef159", "qwvsda") {
        MAX_VITAL_PASSES = 8000;
        MAX_PRIME_PASSES = 2000;
        MAX_VITAL_WHITELIST = 3000;
        MAX_PRIME_WHITELIST = 1000;
        MAX_RESERVED_VITAL_PASS = 900;
        MAX_RESERVED_PRIME_PASS = 100;
        MAX_VITAL_PER_WALLET = 5;
        MAX_PRIME_PER_WALLET = 1;
        counterVitalPass = 0;
        counterPrimePass = 0;
        counterVitalReserved = 0;
        counterPrimeReserved = 0;
        vitalPublicStart = 0;
        primePublicStart = 0;
        vitalWhitelistStart = 0;
        primeWhitelistStart = 0;
        period = _period;
    }

    // ------------------------------------------------------------------------------------------
    // Public Minting
    function mintVital(uint8 amount) external payable {
        require(
            block.timestamp >= vitalPublicStart &&
                block.timestamp <= vitalPublicStart + period,
            "Public vital pass minting is closed"
        );
        require(
            balanceVital[msg.sender] + amount <= MAX_VITAL_PER_WALLET,
            "You exceed maximum vital pass amount per a wallet"
        );
        require(
            counterVitalPass + amount <= MAX_VITAL_PASSES,
            "No more vital pass can be minted"
        );
        require(msg.value == amount * PRICE_VITAL_PASS, "Value does not match");

        for (uint8 i = 0; i < amount; i++) {
            _safeMint(msg.sender, 1000 + counterVitalPass++);
        }
        balanceVital[msg.sender] += amount;
        payable(owner()).transfer(msg.value);
    }

    function mintPrime(uint8 amount) external payable {
        require(
            block.timestamp >= primePublicStart &&
                block.timestamp <= primePublicStart + period,
            "Public prime pass minting is closed"
        );
        require(
            balancePrime[msg.sender] + amount <= MAX_PRIME_PER_WALLET,
            "You exceed maximum prime pass amount per a wallet"
        );
        require(
            counterPrimePass + amount <= MAX_PRIME_PASSES,
            "No more prime pass can be minted"
        );
        require(msg.value == PRICE_PRIME_PASS, "Value does not match");

        for (uint8 i = 0; i < amount; i++) {
            _safeMint(msg.sender, counterPrimePass++);
        }
        balancePrime[msg.sender] += amount;
        payable(owner()).transfer(msg.value);
    }

    // ------------------------------------------------------------------------------------------
    // Whitelist Minting
    function mintVitalWhitelist(
        bytes32[] calldata proof,
        bytes32 root,
        bytes32 leaf
    ) external payable onlyWhitelist(proof, root, leaf) {
        require(
            block.timestamp >= vitalWhitelistStart &&
                block.timestamp <= vitalWhitelistStart + period,
            "Whitelist vital pass minting is closed"
        );
        require(counterVitalPass < MAX_VITAL_WHITELIST, "It is over");
        require(balanceVital[msg.sender] == 0, "You already minted vital pass");
        require(
            counterVitalPass < MAX_VITAL_WHITELIST,
            "Whitelist vital pass minting is closed"
        );
        require(msg.value == PRICE_VITAL_PASS, "Value does not match");

        _safeMint(msg.sender, 1000 + counterVitalPass++);
        balanceVital[msg.sender]++;
        payable(owner()).transfer(msg.value);
    }

    function mintPrimeWhitelist(
        bytes32[] calldata proof,
        bytes32 root,
        bytes32 leaf
    ) external payable onlyWhitelist(proof, root, leaf) {
        require(
            block.timestamp >= primeWhitelistStart &&
                block.timestamp <= primeWhitelistStart + period,
            "Whitelist prime minting is closed"
        );
        require(counterPrimePass < MAX_PRIME_WHITELIST, "It is over");
        require(balancePrime[msg.sender] == 0, "You already minted prime pass");
        require(msg.value == PRICE_PRIME_PASS, "Value does not match");

        _safeMint(msg.sender, counterPrimePass++);
        balancePrime[msg.sender]++;
        payable(owner()).transfer(msg.value);
    }

    // ------------------------------------------------------------------------------------------
    // Reserved Minting
    function mintVitalReserved(address to, uint8 amount) external onlyOwner {
        require(counterVitalReserved + amount <= MAX_RESERVED_VITAL_PASS, "");
        for (uint8 i = 0; i < amount; i++) {
            _safeMint(to, 10100 + counterVitalReserved++);
        }
        balanceVital[to] += amount;
    }

    function mintPrimeReserved(address to, uint8 amount) external onlyOwner {
        require(counterPrimeReserved + amount <= MAX_RESERVED_PRIME_PASS, "");
        for (uint8 i = 0; i < amount; i++) {
            _safeMint(to, 10000 + counterPrimeReserved++);
        }
        balancePrime[to] += amount;
    }

    // ------------------------------------------------------------------------------------------
    // Change Mint Status
    function changePublicPeriod(
        uint256 _vitalPublicStart,
        uint256 _primePublicStart,
        uint256 _period
    ) external onlyOwner {
        vitalPublicStart = _vitalPublicStart;
        primePublicStart = _primePublicStart;
        period = _period;
    }

    function changePassPrice(
        uint256 _PRICE_VITAL_PASS,
        uint256 _PRICE_PRIME_PASS
    ) external onlyOwner {
        PRICE_VITAL_PASS = _PRICE_VITAL_PASS;
        PRICE_PRIME_PASS = _PRICE_PRIME_PASS;
    }

    // ------------------------------------------------------------------------------------------
    // URI
    function setBaseURI(string memory newBaseURI) external onlyOwner {
        BASE_URI = newBaseURI;
        emit BaseURIChanged(BASE_URI);
    }

    function _baseURI() internal view override returns (string memory) {
        return BASE_URI;
    }

    // ------------------------------------------------------------------------------------------
    // Other
    function donate_in_ether() external payable {}
}
