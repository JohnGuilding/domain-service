// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract DomainService is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    string public topLevelDomain;

    mapping(string => address) public domains;
    mapping(string => string) public records;
    mapping(uint => string) public names;

    error Unauthorized();
    error AlreadyRegistered();
    error InvalidName(string name);

    address payable public owner;

    constructor(string memory _topLevelDomain) ERC721('', '') payable {

    }

    function price(string calldata name) public payable {

    }

    function register(string calldata name) public payable {
    }

    function getAllNames() public view returns (string[] memory) {

    }

    function withdraw() public {

    }
}