// SPDX-License-Identifier: MIT

// only one kind of token
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract nft_drops is ERC721, ERC721Holder, Ownable, VRFConsumerBase {
    uint256 public constant MAX_PASSES = 10000;
    uint256 public constant MAX_MINT_PER_TX = 10;
    uint256 public constant PASS_PRICE = 0.1 ether;
    uint256 public deadline;
    uint256 public passCounter = 0;
    uint256 private constant phaseTimeLimit = 7 days;
    uint256 private constant stakeTimeLimit = 7 days;

    string public CONTRACT_URI;
    string public baseURI;

    uint256 public primeOne;
    uint256 public primeTwo;
    uint256 public primeThree;

    bool public mintActive = false;
    bool public primeNumberset = false;

    uint256 private constant chainlinkFee = 0.1 ether;
    bytes32 private constant keyHash =
        0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311;
    uint256 private RANDOM_NUMBER;

    mapping(uint256 => address) public stakers;
    mapping(uint256 => bool) public isStaked;
    mapping(uint256 => uint256) public StakedTime;

    event statusChanged(bool mintActive);
    event Primeset(bool primeNumberset);
    event BaseURIChanged(string baseURI);

    // VRFComsumerBase(VRT Coordinator, LinkToken)
    constructor()
        ERC721("qwef159", "qwvsda")
        VRFConsumerBase(
            0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B,
            0x01BE23585060835E02B77ef475b0Cc51aA1e0709
        )
    {}

    function mint(uint256 amount) external payable {
        if (block.timestamp >= deadline) {
            setMintStatus(false);
        }
        require(amount > 0, "Amount is Zeor");
        require(mintActive == true, "Minting is closed");
        require(
            amount <= MAX_MINT_PER_TX,
            "Mint amount exceeds maximum amount per tx"
        );
        require(
            passCounter + amount <= MAX_PASSES,
            "No more passes can be minted"
        );
        require(msg.value == amount * PASS_PRICE, "Value does not match");

        for (uint256 i = 1; i <= amount; i++) {
            _safeMint(msg.sender, passCounter++);
        }
        if (passCounter >= MAX_PASSES) {
            setMintStatus(false);
        }
    }

    function drawingLots(
        ERC721 _nft,
        uint256 _startTokenId,
        uint256 _endTokenId
    ) external onlyOwner {
        ERC721 nft = ERC721(_nft);
        require(nft.balanceOf(address(this)) > 0, "No nft in wallet");
        require(_endTokenId - _startTokenId >= 0, "Switch inputs");

        for (
            uint256 tokenId = _startTokenId;
            tokenId <= _endTokenId;
            tokenId++
        ) {
            require(nft.ownerOf(tokenId) == address(this), "No nft in wallet");
            nft.safeTransferFrom(
                address(this),
                drawWinner(RANDOM_NUMBER),
                tokenId
            );
        }
    }

    function ethLottery(uint256 winners, uint256 amountInWei)
        external
        onlyOwner
    {
        require(
            address(this).balance > winners * amountInWei,
            "Not enough ETH"
        );
        for (uint256 i = 1; i <= winners; i++) {
            (bool success, ) = drawWinner(RANDOM_NUMBER).call{
                value: amountInWei
            }("");
            require(success, "Withdraw unsuccessful");
        }
    }

    function drawWinner(uint256 _randomness) internal returns (address) {
        RANDOM_NUMBER = linearCongruential(_randomness);
        if (isStaked[RANDOM_NUMBER % passCounter]) {
            return stakers[RANDOM_NUMBER % passCounter];
        } else {
            return drawWinner(RANDOM_NUMBER);
        }
    }

    function linearCongruential(uint256 _randomness)
        internal
        returns (uint256)
    {
        _randomness = ((_randomness * primeOne + primeTwo) % primeThree);
        return _randomness;
    }

    function setRandomNumberSeed() external onlyOwner {
        require(
            LINK.balanceOf(address(this)) >= chainlinkFee,
            "Out of Link Token"
        );
        bytes32 requestId = requestRandomness(keyHash, chainlinkFee);
    }

    function fulfillRandomness(bytes32 _requestId, uint256 _randomness)
        internal
        override
    {
        RANDOM_NUMBER = linearCongruential(
            _randomness % (primeOne + primeTwo + primeThree)
        );
    }

    function setMintStatus(bool _mintActive) public onlyOwner {
        require(
            primeNumberset == true,
            "Prime numbers should be set before start minting"
        );
        mintActive = _mintActive;
        if (_mintActive == true) {
            setDeadline();
        }
        emit statusChanged(mintActive);
    }

    function setDeadline() internal {
        deadline = block.timestamp + phaseTimeLimit;
    }

    // PrimeOne will be random 30 digits prime number
    // Cannot change prime numbers after set once
    function setPrimeNumbers(
        uint256 _primeOne,
        uint256 _primeTwo,
        uint256 _primeThree
    ) external onlyOwner {
        require(primeNumberset == false, "Prime numbers are already set");
        primeOne = _primeOne;
        primeTwo = _primeTwo;
        primeThree = _primeThree;
        primeNumberset = true;
        emit Primeset(primeNumberset);
    }

    function donateInEther() external payable {}

    function withdraw() external onlyOwner {
        (bool success, ) = owner().call{value: address(this).balance}("");
        require(success, "Withdraw unsuccessful");
    }

    function setContractURI(string memory newContractURI) external onlyOwner {
        CONTRACT_URI = newContractURI;
    }

    function contractURI() external view returns (string memory) {
        return CONTRACT_URI;
    }

    function setBaseURI(string memory newBaseURI) external onlyOwner {
        baseURI = newBaseURI;
        emit BaseURIChanged(baseURI);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function stakePass(uint256 passId) public {
        require(isStaked[passId] == false, "Pass is already Staked");
        require(
            ownerOf(passId) == msg.sender,
            "You do not have the pass to stake"
        );
        safeTransferFrom(msg.sender, address(this), passId);
        isStaked[passId] = true;
        stakers[passId] = msg.sender;
        StakedTime[passId] = block.timestamp;
    }

    function unstakePass(uint256 passId) public {
        require(isStaked[passId] == true, "Pass is not Staked");
        require(stakers[passId] == msg.sender, "Check your pass ID");
        require(
            block.timestamp - StakedTime[passId] >= stakeTimeLimit,
            "You cannot unstake yet"
        );
        this.safeTransferFrom(address(this), msg.sender, passId);
        isStaked[passId] = false;
        stakers[passId] = address(0);
        StakedTime[passId] = 0;
    }

    // Delete later
    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        return
            "https://ipfs.io/ipfs/QmQZLcBLgyKufY3s5EJtRA3PrM1txc5AAK6fwKPMPVPp6S?filename=0.json";
    }

    // // Will use this code later with Web3.js
    // function stakePasses(uint256[] memory passIds) public {
    //     for (uint256 i = 0; i < passIds.length; i++) {
    //         require(isStaked[passIds[i]] == false, "Pass is already Staked");
    //         require(
    //             ownerOf(passIds[i]) == msg.sender,
    //             "You do not have the pass to stake"
    //         );
    //         safeTransferFrom(msg.sender, address(this), passIds[i]);
    //         isStaked[passIds[i]] = true;
    //         stakers[passIds[i]] = msg.sender;
    //         StakedTime[passIds[i]] = block.timestamp;
    //     }
    // }
    //
    // function unstakePasses(uint256[] memory passIds) public {
    //     for (uint256 i = 0; i < passIds.length; i++) {
    //         require(isStaked[passIds[i]] == true, "Pass is not Staked");
    //         require(stakers[passIds[i]] == msg.sender, "Check your pass ID");
    //         require(
    //             block.timestamp - StakedTime[passIds[i]] >= stakeTimeLimit,
    //             "You cannot unstake yet"
    //         );
    //         this.safeTransferFrom(address(this), msg.sender, passIds[i]);
    //         isStaked[passIds[i]] = false;
    //         stakers[passIds[i]] = address(0);
    //         StakedTime[passIds[i]] = 0;
    //     }
    // }
}
