// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;

import '../interfaces/external/IWETH9.sol';

contract TestWETH9 is IWETH9 {
    string public constant name = 'Wrapped Ether';
    string public constant symbol = 'WETH';
    uint8 public constant decimals = 18;

    event Deposit(address indexed dst, uint256 wad);
    event Withdrawal(address indexed src, uint256 wad);

    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) public override allowance;

    receive() external payable {
        deposit();
    }

    function deposit() public payable override {
        balanceOf[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 wad) public override {
        require(balanceOf[msg.sender] >= wad, 'TestWETH9: insufficient balance');
        balanceOf[msg.sender] -= wad;
        (bool success, ) = msg.sender.call{value: wad}('');
        require(success, 'TestWETH9: ETH transfer failed');
        emit Withdrawal(msg.sender, wad);
    }

    function totalSupply() public view override returns (uint256) {
        return address(this).balance;
    }

    function approve(address guy, uint256 wad) public override returns (bool) {
        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function transfer(address dst, uint256 wad) public override returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint256 wad) public override returns (bool) {
        require(balanceOf[src] >= wad, 'TestWETH9: insufficient balance');

        if (src != msg.sender && allowance[src][msg.sender] != uint256(-1)) {
            require(allowance[src][msg.sender] >= wad, 'TestWETH9: insufficient allowance');
            allowance[src][msg.sender] -= wad;
        }

        balanceOf[src] -= wad;
        balanceOf[dst] += wad;

        emit Transfer(src, dst, wad);
        return true;
    }

    function transfer(address from, address to, uint256 amount, bool, bytes calldata) external {
        require(balanceOf[from] >= amount, 'TestWETH9: insufficient balance');

        if (from != msg.sender && allowance[from][msg.sender] != uint256(-1)) {
            require(allowance[from][msg.sender] >= amount, 'TestWETH9: insufficient allowance');
            allowance[from][msg.sender] -= amount;
        }

        balanceOf[from] -= amount;
        balanceOf[to] += amount;

        emit Transfer(from, to, amount);
    }

    function authorizeOperator(address operator, uint256 amount, bytes calldata) external {
        allowance[msg.sender][operator] = amount;
        emit Approval(msg.sender, operator, amount);
    }

    function getData(bytes32) external pure returns (bytes memory) {
        return bytes('WETH');
    }
}
