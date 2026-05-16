// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;
pragma abicoder v2;

import '../interfaces/INFTDescriptor.sol';
import '../libraries/NFTDescriptor.sol';
import '../libraries/NFTSVG.sol';
import '../libraries/HexStrings.sol';

contract NFTDescriptorTest {
    using HexStrings for uint256;

    NFTDescriptor public descriptor;

    constructor() {
        descriptor = new NFTDescriptor();
    }

    function constructTokenURI(
        INFTDescriptor.ConstructTokenURIParams calldata params
    ) public view returns (bytes memory) {
        return descriptor.constructTokenURI(params);
    }

    function getGasCostOfConstructTokenURI(
        INFTDescriptor.ConstructTokenURIParams calldata params
    ) public view returns (uint256) {
        uint256 gasBefore = gasleft();
        descriptor.constructTokenURI(params);
        return gasBefore - gasleft();
    }

    function rangeLocation(int24 tickLower, int24 tickUpper) public pure returns (string memory, string memory) {
        return NFTSVG.rangeLocation(tickLower, tickUpper);
    }

    function isRare(uint256 tokenId, address poolAddress) public pure returns (bool) {
        return NFTSVG.isRare(tokenId, poolAddress);
    }
}

contract NFTDescriptorInternalTest is NFTDescriptor {
    using HexStrings for uint256;

    function testTickToDecimalString(
        int24 tick,
        int24 tickSpacing,
        uint8 token0Decimals,
        uint8 token1Decimals,
        bool flipRatio
    ) public pure returns (string memory) {
        return tickToDecimalString(tick, tickSpacing, token0Decimals, token1Decimals, flipRatio);
    }

    function testFixedPointToDecimalString(
        uint160 sqrtRatioX96,
        uint8 token0Decimals,
        uint8 token1Decimals
    ) public pure returns (string memory) {
        return fixedPointToDecimalString(sqrtRatioX96, token0Decimals, token1Decimals);
    }

    function testFeeToPercentString(uint24 fee) public pure returns (string memory) {
        return feeToPercentString(fee);
    }

    function testAddressToString(address _address) public pure returns (string memory) {
        return addressToString(_address);
    }

    function testGenerateSVGImage(
        INFTDescriptor.ConstructTokenURIParams memory params
    ) public pure returns (string memory) {
        return generateSVGImage(params);
    }

    function testTokenToColorHex(address token, uint256 offset) public pure returns (string memory) {
        return tokenToColorHex(uint256(token), offset);
    }

    function testSliceTokenHex(address token, uint256 offset) public pure returns (uint256) {
        return sliceTokenHex(uint256(token), offset);
    }
}
