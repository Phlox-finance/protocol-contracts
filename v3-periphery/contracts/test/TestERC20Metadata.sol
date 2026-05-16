// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;

import '@openzeppelin/contracts/drafts/ERC20Permit.sol';

contract TestERC20Metadata is ERC20Permit {
    constructor(uint256 amountToMint, string memory name, string memory symbol) ERC20(name, symbol) ERC20Permit(name) {
        _mint(msg.sender, amountToMint);
    }

    function transfer(address from, address to, uint256 amount, bool, bytes calldata) external {
        if (msg.sender != from) {
            uint256 currentAllowance = allowance(from, msg.sender);
            require(currentAllowance >= amount, 'TestERC20Metadata: insufficient allowance');
            _approve(from, msg.sender, currentAllowance - amount);
        }
        _transfer(from, to, amount);
    }

    function authorizeOperator(address operator, uint256 amount, bytes calldata) external {
        _approve(msg.sender, operator, amount);
    }

    function getData(bytes32) external view returns (bytes memory) {
        return bytes(symbol());
    }
}
