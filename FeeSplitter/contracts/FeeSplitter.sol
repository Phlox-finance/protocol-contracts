// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

interface IUniversalReceiver {
    function gridOwner() external view returns (address);
}

interface ILSP7 {
    function transfer(address from, address to, uint256 amount, bool force, bytes calldata data) external;
    function balanceOf(address account) external view returns (uint256);
}


contract FeeSplitter {

    bytes32 constant _TYPEID_LSP7_TOKENSRECIPIENT = 0x20804611b3e2ea21c480dc465142210acf4a2485947541770ec1fb87dee4a55c;
    bytes4 constant _INTERFACEID_LSP1 = 0x6bb56a14;

    address public universalReceiverAddress;
    address public owner;
    uint public feePercentageInBps = 2500; // 25%

    event FeeReceiverUpdated(address indexed feeReceiver);
    event FeePercentageUpdated(uint indexed feePercentageInBps);
    event OwnerUpdated(address indexed owner);
    event UniversalReceiverUpdated(address indexed universalReceiver);
    event FeeTransferred(address indexed feeReceiver, uint indexed amount);
    event FeeToOwnerTransferred(address indexed feeReceiver,uint indexed amount);

    constructor(address _universalReceiver, address _owner) payable {
        universalReceiverAddress = _universalReceiver;
        owner = _owner;
    }

    function universalReceiver(bytes32 typeId, bytes calldata data) public returns (bytes memory) {
        if (typeId == _TYPEID_LSP7_TOKENSRECIPIENT) {
            address feeReceiver = IUniversalReceiver(universalReceiverAddress).gridOwner();

            if (feeReceiver != address(0)) {
                uint256 balance = ILSP7(msg.sender).balanceOf(address(this));
                uint256 amountToTransferToFeeReceiver = balance * feePercentageInBps / 10_000;
                ILSP7(msg.sender).transfer(address(this), feeReceiver, amountToTransferToFeeReceiver, true, "");
                emit FeeTransferred(feeReceiver, amountToTransferToFeeReceiver);
            }

            uint256 balanceAfterTransfer = ILSP7(msg.sender).balanceOf(address(this));
            ILSP7(msg.sender).transfer(address(this), owner, balanceAfterTransfer, true, "");
            emit FeeToOwnerTransferred(owner, balanceAfterTransfer);
        }

        return abi.encodePacked(true);
    }

    function setFeePercentageInBps(uint _feePercentageInBps) public {
        if (msg.sender != owner) {
            revert("Only the owner can set the fee percentage");
        }
        feePercentageInBps = _feePercentageInBps;
        emit FeePercentageUpdated(_feePercentageInBps);
    }

    function setUniversalReceiver(address _universalReceiver) public {
        if (msg.sender != owner) {
            revert("Only the owner can set the universal receiver");
        }
        universalReceiverAddress = _universalReceiver;
        emit UniversalReceiverUpdated(_universalReceiver);
    }

    function updateOwner(address _owner) public {
        if (msg.sender != owner) {
            revert("Only the owner can update the owner");
        }
        owner = _owner;
        emit OwnerUpdated(_owner);
    }

    function supportsInterface(bytes4 interfaceId) public pure returns (bool) {
        return interfaceId == _INTERFACEID_LSP1 || interfaceId == _TYPEID_LSP7_TOKENSRECIPIENT;
    }
}
