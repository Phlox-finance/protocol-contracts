// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;
pragma abicoder v2;

import '../interfaces/INFTDescriptor.sol';
import '../libraries/nft_v2/NFTDescriptor.sol';

contract NFTDescriptorV2InternalTest is NFTDescriptorV2 {
    function testGenerateSVGImage(
        INFTDescriptor.ConstructTokenURIParams memory params
    ) public pure returns (string memory) {
        return generateSVGImage(params);
    }

    function testComputeTier(uint256 tokenId, address poolAddress) public pure returns (uint8) {
        return computeTier(tokenId, poolAddress);
    }
}
