// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract IfelseTry is ERC721Enumerable, Ownable {
  using Strings for uint256;

  string baseURI;
  string public baseExtension = ".json";
  string public notRevealedUri;
  uint256 public whitelistCost = 1 ether;
  uint256 public preSaleCost = 1.25 ether;
  uint256 public normalCost = 1.75 ether;
  uint256 public maxSupply = 5555;
  uint256 public maxMintAmount = 5;
  //0-> Gold   whitelist 30 address 10 maxMint 300 NFT cost 1.00
  //1->Silver whitelist 50 address  8 maxMint  400 NFT cost 1.00
  //2->Bronze whitelist 100 address 6 maxMint  600 NFT cost 1.00
  //3->Presale                      5 maxMint  890 NFT cost 1.25
  //4->Public sale                  5 maxMint 2980 NFT cost 1.75
  uint256 public saleMode;
  uint256 public saleModeMaxCount;
  uint256 public saleModeCount;
  bool public paused = false;
  bool public revealed = false;
  bool inPreSale =true;
  bool public onlyWhitelisted = true;
  address[] public whitelistedAddresses;
  mapping(address => uint256) public addressMintedBalance;
 

  constructor(
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI,
    string memory _initNotRevealedUri
  ) ERC721(_name, _symbol) {
    setBaseURI(_initBaseURI);
    setNotRevealedURI(_initNotRevealedUri);
    
  }

  // internal
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  // public
  function mint(uint256 _mintAmount) public payable {
    uint256 supply = totalSupply();
    require(!paused);
    require(_mintAmount > 0);
    require(supply + _mintAmount <= 5400);
    if(saleMode < 3){
       require(msg.value >= whitelistCost * _mintAmount); 
       require(isWhitelisted(msg.sender), "user is not whitelisted");
       
    }else if(saleMode == 3){
       require(msg.value >= preSaleCost * _mintAmount);
    }else if(saleMode == 4){
       require(msg.value >= normalCost * _mintAmount);
    }
    
    uint256 ownerMintedCount = addressMintedBalance[msg.sender];
    require(ownerMintedCount + _mintAmount <= maxMintAmount, "max NFT per address exceeded");
    require(saleModeCount + _mintAmount <= saleModeMaxCount, "max NFT per sale mode exceeded");
    
    saleModeCount += _mintAmount;

    for (uint256 i = 1; i <= _mintAmount; i++) {
        addressMintedBalance[msg.sender]++;
        _safeMint(msg.sender, supply + i);
    }
  }

    function isWhitelisted(address _user) public view returns (bool) {
    for (uint i = 0; i < whitelistedAddresses.length; i++) {
      if (whitelistedAddresses[i] == _user) {
          return true;
      }
    }
    return false;
  }
  
  function mintForOwner(uint256 _mintAmount) public onlyOwner payable{
    uint256 supply = totalSupply();
    require(!paused);
    require(_mintAmount > 0);
    require(_mintAmount <= 155);
    require(supply + _mintAmount <= maxSupply);

    for (uint256 i = 1; i <= _mintAmount; i++) {
      _safeMint(msg.sender, supply + i);
    }
  }

  function walletOfOwner(address _owner)
    public
    view
    returns (uint256[] memory)
  {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory tokenIds = new uint256[](ownerTokenCount);
    for (uint256 i; i < ownerTokenCount; i++) {
      tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
    }
    return tokenIds;
  }

  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );
    
    if(revealed == false) {
        return notRevealedUri;
    }

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
        : "";
  }

   function whitelistUsers(address[] calldata _users) public onlyOwner {
    delete whitelistedAddresses;
    whitelistedAddresses = _users;
  }

  //only owner
  function reveal() public onlyOwner {
      revealed = true;
  }
  
  function setsaleMode(uint256 _newsaleMode, uint256 _newsaleModeMaxCount, uint256 _newmaxMintAmount) public onlyOwner {
    saleMode = _newsaleMode;
    saleModeMaxCount = _newsaleModeMaxCount;
    maxMintAmount = _newmaxMintAmount;
    saleModeCount = 0;
  }

  

  function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
    maxMintAmount = _newmaxMintAmount;
  }
  
  function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
    notRevealedUri = _notRevealedURI;
  }

  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
    baseExtension = _newBaseExtension;
  }

  function pause(bool _state) public onlyOwner {
    paused = _state;
  }

  function endPreSale() public onlyOwner {
    inPreSale = false;
  }
 
  function withdraw() public payable onlyOwner {
      uint256 money = address(this).balance;

    (bool hs, ) = payable(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2).call{value: money * 5 / 100}("");
    require(hs);
    (bool ahmet, ) = payable(0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db).call{value: money * 5 / 100}("");
    require(ahmet);
    (bool mehmet, ) = payable(0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB).call{value: money * 5 / 100}("");
    require(mehmet);
     (bool hasan, ) = payable(0x617F2E2fD72FD9D5503197092aC168c91465E7f2).call{value: money * 5 / 100}("");
    require(hasan);
     (bool huseyin, ) = payable(0x617F2E2fD72FD9D5503197092aC168c91465E7f2).call{value: money * 5 / 100}("");
    require(huseyin);
    (bool os, ) = payable(owner()).call{value: address(this).balance}("");
    require(os);
  }
}
