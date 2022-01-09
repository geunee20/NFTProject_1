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
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// tokenId: prime 0 ~999,                       vital 0~9999
//          reserved prime: 10000~10099,        reserved vital: 10100 ~ 11000
contract nft_dropsV2 is ERC721, Ownable {
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

    uint256 public TIME_LIMIT = 7 days;
    uint256 public DEADLINE;

    uint256 public PRICE_VITAL_PASS = 0.1 ether;
    uint256 public PRICE_PRIME_PASS = 0.1 ether;

    string public BASE_URI;

    bool public activeVitalPublic = false;
    bool public activePrimePublic = false;
    bool public activeVitalWhitelist = false;
    bool public activePrimeWhitelist = false;

    mapping(address => uint8) public balanceVital;
    mapping(address => uint8) public balancePrime;
    event BaseURIChanged(string BASE_URI);

    constructor() ERC721("qwef159", "qwvsda") {
        MAX_VITAL_PASSES = 9000;
        MAX_PRIME_PASSES = 1000;
        MAX_VITAL_WHITELIST = 900;
        MAX_PRIME_WHITELIST = 180;
        MAX_RESERVED_VITAL_PASS = 900;
        MAX_RESERVED_PRIME_PASS = 100;
        MAX_VITAL_PER_WALLET = 10;
        MAX_PRIME_PER_WALLET = 10;
        counterVitalPass = 0;
        counterPrimePass = 0;
        counterVitalReserved = 0;
        counterPrimeReserved = 0;
    }

    // ------------------------------------------------------------------------------------------
    // Public Minting
    function mintVital(uint8 amount) external payable {
        if (block.timestamp >= DEADLINE) {
            closeMint();
        }
        require(
            activeVitalPublic == true,
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
        if (counterVitalPass >= MAX_VITAL_PASSES) {
            activeVitalPublic = false;
        }
    }

    function mintPrime(uint8 amount) external payable {
        if (block.timestamp >= DEADLINE) {
            closeMint();
        }
        require(
            activePrimePublic == true,
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
        if (counterPrimePass >= MAX_PRIME_PASSES) {
            activePrimePublic = false;
        }
    }

    // ------------------------------------------------------------------------------------------
    // Whitelist Minting
    function mintVitalWhitelist(uint8 amount) external payable {
        if (block.timestamp >= DEADLINE) {
            closeMint();
        }
        require(
            activeVitalWhitelist == true,
            "Whitelist vital pass minting is closed"
        );
        require(
            balanceVital[msg.sender] + amount <= MAX_VITAL_PER_WALLET,
            "You exceed maximum vital pass amount per a wallet"
        );
        require(
            counterVitalPass + amount <= MAX_VITAL_WHITELIST,
            "Whitelist vital pass minting is closed"
        );
        require(msg.value == amount * PRICE_VITAL_PASS, "Value does not match");

        for (uint8 i = 0; i < amount; i++) {
            _safeMint(msg.sender, 1000 + counterVitalPass++);
        }
        balanceVital[msg.sender] += amount;
        payable(owner()).transfer(msg.value);
        if (counterVitalPass >= MAX_VITAL_WHITELIST) {
            activeVitalWhitelist = false;
        }
    }

    function mintPrimeWhitelist(uint8 amount) external payable {
        if (block.timestamp >= DEADLINE) {
            closeMint();
        }
        require(
            activePrimeWhitelist == true,
            "Whitelist prime minting is closed"
        );
        require(
            balancePrime[msg.sender] + amount <= MAX_PRIME_PER_WALLET,
            "You exceed maximum amount per a wallet"
        );
        require(
            counterVitalPass + amount <= MAX_PRIME_WHITELIST,
            "Whitelist prime pass minting is closed"
        );
        require(msg.value == PRICE_PRIME_PASS, "Value does not match");

        for (uint8 i = 0; i < amount; i++) {
            _safeMint(msg.sender, counterPrimePass++);
        }
        balancePrime[msg.sender] += amount;
        payable(owner()).transfer(msg.value);
        if (counterPrimePass >= MAX_PRIME_WHITELIST) {
            activePrimeWhitelist = false;
        }
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
    function openMint() external onlyOwner {
        activeVitalPublic = true;
        activePrimePublic = true;
        DEADLINE = block.timestamp + TIME_LIMIT;
    }

    function openWhitelistMint() external onlyOwner {
        activeVitalWhitelist = true;
        activePrimeWhitelist = true;
        DEADLINE = block.timestamp + TIME_LIMIT;
    }

    function closeMint() public onlyOwner {
        activeVitalPublic = false;
        activePrimePublic = false;
        activeVitalWhitelist = false;
        activePrimeWhitelist = false;
    }

    function changePassPrice(
        uint256 _PRICE_VITAL_PASS,
        uint256 _PRICE_PRIME_PASS
    ) external onlyOwner {
        PRICE_VITAL_PASS = _PRICE_VITAL_PASS;
        PRICE_PRIME_PASS = _PRICE_PRIME_PASS;
    }

    function changeTimeLimit(uint256 in_days) public onlyOwner {
        TIME_LIMIT = in_days * 1 days;
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
