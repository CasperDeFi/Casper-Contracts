/**
 *Submitted for verification at FtmScan.com on 2021-07-15
*/

// SPDX-License-Identifier: MIT

//   ,ad8888ba,                                                         88888888ba,                 ad88 88
//  d8"'    `"8b                                                        88      `"8b               d8"   ""
// d8'                                                                  88        `8b              88
// 88            ,adPPYYba, ,adPPYba, 8b,dPPYba,   ,adPPYba, 8b,dPPYba, 88         88  ,adPPYba, MM88MMM 88
// 88            ""     `Y8 I8[    "" 88P'    "8a a8P_____88 88P'   "Y8 88         88 a8P_____88   88    88
// Y8,           ,adPPPPP88  `"Y8ba,  88       d8 8PP""""""" 88         88         8P 8PP"""""""   88    88
//  Y8a.    .a8P 88,    ,88 aa    ]8I 88b,   ,a8" "8b,   ,aa 88         88      .a8P  "8b,   ,aa   88    88
//   `"Y8888Y"'  `"8bbdP"Y8 `"YbbdP"' 88`YbbdP"'   `"Ybbd8"' 88         88888888Y"'    `"Ybbd8"'   88    88
//                                    88
//                                    88

pragma solidity ^0.8.6;

contract CasperLaunchpad {
    struct Sale {
        bool exists;
        string saleSlug;
        address tokenAddress;
        uint256 tokenAmount;
        uint256 rate;
    }

    mapping(string => Sale) public existingSales;

    bool paused = false;
    address deployer;

    event Purchase(address buyer, uint256 amount, string sale);
    event SaleCreated(string saleSlug);
    event SaleEnded(string saleSlug);

    constructor() {
        deployer = msg.sender;
    }

    modifier onlyDeployer() {
        require(msg.sender == deployer);
        _;
    }

    modifier pauseable() {
        require(paused == false, 'contract is paused');
        _;
    }

    function pause() public onlyDeployer {
        paused = true;
    }

    function unpause() public onlyDeployer {
        paused = false;
    }

    function withdraw() public onlyDeployer pauseable {
        address payable admin = payable(msg.sender);
        admin.transfer(address(this).balance);
    }

    function createSale(
        string memory saleSlug,
        address tokenAddress,
        uint256 rate
    ) public onlyDeployer pauseable {
        ERC20 token = ERC20(tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, 'you must deposit token before creating a sale');
        existingSales[saleSlug] = Sale(true, saleSlug, tokenAddress, balance, rate);
        emit SaleCreated(saleSlug);
    }

    function endSale(string memory saleSlug) public onlyDeployer pauseable {
        Sale memory sale = existingSales[saleSlug];
        require(sale.exists == true, 'that sale does not exist');
        ERC20 token = ERC20(sale.tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        token.transfer(msg.sender, balance);
        delete existingSales[saleSlug];
        emit SaleEnded(saleSlug);
    }

    function buyToken(string memory saleSlug) public payable pauseable {
        Sale memory sale = existingSales[saleSlug];
        require(sale.exists == true, 'that sale does not exist');
        uint256 amountOfTokens = msg.value / sale.rate;
        ERC20 tokenAddress = ERC20(sale.tokenAddress);
        tokenAddress.transfer(msg.sender, amountOfTokens);
        emit Purchase(msg.sender, amountOfTokens, sale.saleSlug);
    }
}

abstract contract ERC20 {
    function transfer(address to, uint256 value) public virtual;

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public virtual;

    function balanceOf(address owner) public virtual returns (uint256 balance);
}
