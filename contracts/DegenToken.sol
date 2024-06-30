/*
1. Minting new tokens: The platform should be able to create new tokens and distribute them to players as rewards. Only the owner can mint tokens.
2. Transferring tokens: Players should be able to transfer their tokens to others.
3. Redeeming tokens: Players should be able to redeem their tokens for items in the in-game store.
4. Checking token balance: Players should be able to check their token balance at any time.
5. Burning tokens: Anyone should be able to burn tokens, that they own, that are no longer needed.
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract DegenToken is ERC20, Ownable, ERC20Burnable {

    struct Item {
        string name;
        uint8 itemId;
        uint256 price;
    }
    mapping (uint8=>Item) public items;
    uint8 public tokenId;
    
    event ItemPurchased(address indexed buyer, uint8 itemId, string itemName, uint256 price);
    event GameOutcome(address indexed player, uint256 num, bool won, string result);

    constructor (address initialOwner, uint tokenSupply) ERC20("Degen", "DGN") Ownable(initialOwner) {
        mint(initialOwner, tokenSupply);
        
        items[1] = Item("Novice Navigator",1, 100);
        items[2]=Item("Mythic Maverick", 2, 700);
        items[3]=Item("Celestial Crusher", 3, 1200);
        items[4]=Item("Astral Ace", 4, 2200);
        items[5]=Item("Divine Dominator", 5, 2400);
        tokenId=6;

    }

    function decimals() override public pure returns (uint8){
        return 0;
    }

    // Minting tokens

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    // Transferring tokens

    function transferToken(address _recipient, uint _amount) external {
        require(balanceOf(msg.sender)>=_amount, "Insufficient balance");
        transfer(_recipient, _amount);
    }

    // Redeeming tokens

    function welcomeBonus() public {
        require(balanceOf(msg.sender) == 0, "You've already claimed your welcome bonus");
        _mint(msg.sender, 50);
    }

    function addItem(string memory _name, uint256 _price) public onlyOwner {
        items[tokenId] = Item(_name, tokenId,_price);
        tokenId++;
    } 

    function isLessThanFive(bool _prediction, uint256 _betAmount) public {
        uint randomNumber = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % 10;

        if (_prediction ==(randomNumber<5)) {
            _mint(msg.sender, _betAmount*2);
            emit GameOutcome(msg.sender, randomNumber, true, "won");

        } else {
            burn(_betAmount);
            emit GameOutcome(msg.sender, randomNumber, false, "lost");
        }
    }
    
    function purchaseItem(uint8 _itemId) external {
        require(items[_itemId].price != 0, "Item not found");
        require(balanceOf(msg.sender) >= items[_itemId].price, "Insufficient balance");

        burn(items[_itemId].price);

        emit ItemPurchased(msg.sender, _itemId, items[_itemId].name, items[_itemId].price);
    }

    // Checking token balance

    function getBalance() external view returns(uint256){
        return balanceOf(msg.sender);
    }

    // Burning tokens

    function burnToken(uint _amount) external {
        require(balanceOf(msg.sender)>=_amount, "Insufficient amount");
        burn(_amount);
    }

}