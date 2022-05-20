// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";
import { StringUtils } from "./libraries/StringUtils.sol";
import { Base64 } from "./libraries/Base64.sol";

contract DomainService is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    string public topLevelDomain;

    string svgPartOne = '<svg xmlns="http://www.w3.org/2000/svg" width="270" height="270" fill="none"><path fill="url(#B)" d="M0 0h270v270H0z"/><defs><filter id="A" color-interpolation-filters="sRGB" filterUnits="userSpaceOnUse" height="270" width="270"><feDropShadow dx="0" dy="1" stdDeviation="2" flood-opacity=".225" width="200%" height="200%"/></filter></defs><path d="M72.863 42.949c-.668-.387-1.426-.59-2.197-.59s-1.529.204-2.197.59l-10.081 6.032-6.85 3.934-10.081 6.032c-.668.387-1.426.59-2.197.59s-1.529-.204-2.197-.59l-8.013-4.721a4.52 4.52 0 0 1-1.589-1.616c-.384-.665-.594-1.418-.608-2.187v-9.31c-.013-.775.185-1.538.572-2.208a4.25 4.25 0 0 1 1.625-1.595l7.884-4.59c.668-.387 1.426-.59 2.197-.59s1.529.204 2.197.59l7.884 4.59a4.52 4.52 0 0 1 1.589 1.616c.384.665.594 1.418.608 2.187v6.032l6.85-4.065v-6.032c.013-.775-.185-1.538-.572-2.208a4.25 4.25 0 0 0-1.625-1.595L41.456 24.59c-.668-.387-1.426-.59-2.197-.59s-1.529.204-2.197.59l-14.864 8.655a4.25 4.25 0 0 0-1.625 1.595c-.387.67-.585 1.434-.572 2.208v17.441c-.013.775.185 1.538.572 2.208a4.25 4.25 0 0 0 1.625 1.595l14.864 8.655c.668.387 1.426.59 2.197.59s1.529-.204 2.197-.59l10.081-5.901 6.85-4.065 10.081-5.901c.668-.387 1.426-.59 2.197-.59s1.529.204 2.197.59l7.884 4.59a4.52 4.52 0 0 1 1.589 1.616c.384.665.594 1.418.608 2.187v9.311c.013.775-.185 1.538-.572 2.208a4.25 4.25 0 0 1-1.625 1.595l-7.884 4.721c-.668.387-1.426.59-2.197.59s-1.529-.204-2.197-.59l-7.884-4.59a4.52 4.52 0 0 1-1.589-1.616c-.385-.665-.594-1.418-.608-2.187v-6.032l-6.85 4.065v6.032c-.013.775.185 1.538.572 2.208a4.25 4.25 0 0 0 1.625 1.595l14.864 8.655c.668.387 1.426.59 2.197.59s1.529-.204 2.197-.59l14.864-8.655c.657-.394 1.204-.95 1.589-1.616s.594-1.418.609-2.187V55.538c.013-.775-.185-1.538-.572-2.208a4.25 4.25 0 0 0-1.625-1.595l-14.993-8.786z" fill="#fff"/><defs><linearGradient id="B" x1="0" y1="0" x2="270" y2="270" gradientUnits="userSpaceOnUse"><stop stop-color="#cb5eee"/><stop offset="1" stop-color="#0cd7e4" stop-opacity=".99"/></linearGradient></defs><text x="32.5" y="231" font-size="27" fill="#fff" filter="url(#A)" font-family="Plus Jakarta Sans,DejaVu Sans,Noto Color Emoji,Apple Color Emoji,sans-serif" font-weight="bold">';
    string svgPartTwo = '</text></svg>';

    mapping(string => address) public domains;
    mapping(string => string) public descriptions;
    mapping(string => string) public emails;
    mapping(string => string) public twitterHandles;
    mapping(string => string) public memes;
    mapping(uint => string) public names;

    struct DomainMetadata {
        string description;
        string email;
        string twitterHandle;
        string meme;
    }

    error Unauthorized();
    error AlreadyRegistered();
    error InvalidName(string _name);

    address payable public owner;

    constructor(string memory _topLevelDomain) ERC721('GM Name Service', 'GNS') payable {
        owner = payable(msg.sender);
        topLevelDomain = _topLevelDomain;
        console.log('%s name service deployed', _topLevelDomain);
    }

    function calculatePrice(string calldata _name) public pure returns (uint price) {
        uint length = StringUtils.strlen(_name);
        require(length > 0, 'Domain name must be 3 or more characters long');
        if (length == 3) {
            // 3 MATIC = 3 000 000 000 000 000 000 (18 decimals). This is 0.3 Matic
            price = 3 * 10**17; 
        } else if (length == 4) {
            price = 2 * 10**17;
        } else if (length == 5) {
            price = 1 * 10**17;
        }
    }

    function register(string calldata _name) public payable {
        if (domains[_name] != address(0)) revert AlreadyRegistered();
        if (!valid(_name)) revert InvalidName(_name);

        uint _price = calculatePrice(_name);
        require(msg.value >= _price, 'Not enough Matic paid');

        string memory encodedName = string(abi.encodePacked(_name, '.', topLevelDomain));
        string memory finalSvg = string(abi.encodePacked(svgPartOne, encodedName, svgPartTwo));
        uint256 newTokenId = _tokenIds.current();
        uint256 length = StringUtils.strlen(_name);
        string memory stringLength = Strings.toString(length);

        console.log('Registering %s.%s on the contract with tokenId %d', _name, topLevelDomain, newTokenId);

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        encodedName,
                        '", "description": "A domain on the GM name service", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(finalSvg)),
                        '","length":"',
                        stringLength,
                        '"}'
                    )
                )
            )
        );

        string memory finalTokenUri = string(abi.encodePacked('data:application/json;base64,', json));

        console.log("\n--------------------------------------------------------");
        console.log("Final tokenURI", finalTokenUri);
        console.log("--------------------------------------------------------\n");

        _safeMint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, finalTokenUri);
        domains[_name] = msg.sender;

        names[newTokenId] = _name;
        _tokenIds.increment();
    }

    function setDomainMetadata(
        string calldata _name,
        string calldata _description,
        string calldata _email,
        string calldata _twitterHandle,
        string calldata _meme
    ) public {
        if (msg.sender != domains[_name]) revert Unauthorized();
        descriptions[_name] = _description;
        emails[_name] = _email;
        twitterHandles[_name] = _twitterHandle;
        memes[_name] = _meme;
    }

    function getAllNames() public view returns (string[] memory) {
        console.log('Getting all names from contract');
        string[] memory allNames = new string[](_tokenIds.current());
        for (uint i = 0; i < _tokenIds.current(); i++) {
            allNames[i] = names[i];
            console.log('Name for token %d is %s', i, allNames[i]);
        }

        return allNames;
    }

    function valid(string calldata _name) public pure returns (bool) {
        uint256 nameLength = StringUtils.strlen(_name);
        return nameLength >= 3 && nameLength <=10;
    }

    function getDomainMetadata(string calldata _name) public view returns (DomainMetadata memory domainMetadata) {
        domainMetadata = DomainMetadata(
            descriptions[_name],
            emails[_name],
            twitterHandles[_name],
            memes[_name]
        );
    }

    function getDomain(string calldata _name) public view returns (address) {
        return domains[_name];
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == owner;
    }

    function withdraw() public onlyOwner {
        uint amount = address(this).balance;

        (bool success, ) = msg.sender.call{value: amount}('');
        require(success, 'Failed to withdraw Matic');
    }
}