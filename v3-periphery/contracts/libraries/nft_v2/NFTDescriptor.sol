// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.7.6;
pragma abicoder v2;

import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';
import '@uniswap/v3-core/contracts/libraries/TickMath.sol';
import '@uniswap/v3-core/contracts/libraries/BitMath.sol';
import '@uniswap/v3-core/contracts/libraries/FullMath.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/math/SignedSafeMath.sol';
import 'base64-sol/base64.sol';
import '../HexStrings.sol';
import './NFTSVG.sol';
import '../../interfaces/INFTDescriptor.sol';

contract NFTDescriptorV2 is INFTDescriptor {
    using TickMath for int24;
    using Strings for uint256;
    using SafeMath for uint256;
    using SafeMath for uint160;
    using SafeMath for uint8;
    using SignedSafeMath for int256;
    using HexStrings for uint256;

    uint256 constant sqrt10X128 = 1076067327063303206878105757264492625226;

    function constructTokenURI(ConstructTokenURIParams memory params) public pure override returns (bytes memory) {
        string memory feeTier = feeToPercentString(params.fee);
        string memory name = generateName(params, feeTier);
        string memory descriptionPartTwo = generateDescriptionPartTwo(
            params.tokenId.toString(),
            escapeQuotes(params.baseTokenSymbol),
            addressToString(params.quoteTokenAddress),
            addressToString(params.baseTokenAddress),
            feeTier
        );
        string memory rarity = tierToRarity(computeTier(params.tokenId, params.poolAddress));
        string memory imageData = generateImageJSON(params);

        return
            abi.encodePacked(
                'data:application/json;base64,',
                bytes(
                    Base64.encode(
                        abi.encodePacked(
                            '{"LSP4Metadata":{',
                            '"name":"',
                            name,
                            '",',
                            '"description":"',
                            descriptionPartTwo,
                            '",',
                            '"attributes":[{"key":"Rarity","value":"',
                            rarity,
                            '","type":"string"}],',
                            imageData,
                            '}}'
                        )
                    )
                )
            );
    }

    function generateImageJSON(ConstructTokenURIParams memory params) private pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '"images":[[',
                    '{',
                    '"width":200,',
                    '"height":200,',
                    '"url":"',
                    'data:image/svg+xml;base64,',
                    Base64.encode(bytes(generateSVGImage(params))),
                    '",',
                    '"verification":{',
                    '"method":"0x00000000",',
                    '"data":"0x"',
                    '}',
                    '}',
                    ']]'
                )
            );
    }

    function escapeQuotes(string memory symbol) internal pure returns (string memory) {
        bytes memory symbolBytes = bytes(symbol);
        uint256 quotesCount = 0;
        for (uint256 i = 0; i < symbolBytes.length; i++) {
            if (symbolBytes[i] == '"') {
                quotesCount++;
            }
        }
        if (quotesCount > 0) {
            bytes memory escapedBytes = new bytes(symbolBytes.length + (quotesCount));
            uint256 index;
            for (uint256 i = 0; i < symbolBytes.length; i++) {
                if (symbolBytes[i] == '"') {
                    escapedBytes[index++] = '\\';
                }
                escapedBytes[index++] = symbolBytes[i];
            }
            return string(escapedBytes);
        }
        return symbol;
    }

    function generateDescriptionPartTwo(
        string memory tokenId,
        string memory baseTokenSymbol,
        string memory quoteTokenAddress,
        string memory baseTokenAddress,
        string memory feeTier
    ) private pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    ' Address: ',
                    quoteTokenAddress,
                    '\\n',
                    baseTokenSymbol,
                    ' Address: ',
                    baseTokenAddress,
                    '\\nFee Tier: ',
                    feeTier,
                    '\\nToken ID: ',
                    tokenId,
                    '\\n\\n',
                    unicode'⚠️ DISCLAIMER: Due diligence is imperative when assessing this NFT. Make sure token addresses match the expected tokens, as token symbols may be imitated.'
                )
            );
    }

    function generateName(
        ConstructTokenURIParams memory params,
        string memory feeTier
    ) private pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    'Phlox - ',
                    feeTier,
                    ' - ',
                    escapeQuotes(params.quoteTokenSymbol),
                    '/',
                    escapeQuotes(params.baseTokenSymbol),
                    ' - ',
                    tickToDecimalString(
                        !params.flipRatio ? params.tickLower : params.tickUpper,
                        params.tickSpacing,
                        params.baseTokenDecimals,
                        params.quoteTokenDecimals,
                        params.flipRatio
                    ),
                    '<>',
                    tickToDecimalString(
                        !params.flipRatio ? params.tickUpper : params.tickLower,
                        params.tickSpacing,
                        params.baseTokenDecimals,
                        params.quoteTokenDecimals,
                        params.flipRatio
                    )
                )
            );
    }

    struct DecimalStringParams {
        uint256 sigfigs;
        uint8 bufferLength;
        uint8 sigfigIndex;
        uint8 decimalIndex;
        uint8 zerosStartIndex;
        uint8 zerosEndIndex;
        bool isLessThanOne;
        bool isPercent;
    }

    function generateDecimalString(DecimalStringParams memory params) private pure returns (string memory) {
        bytes memory buffer = new bytes(params.bufferLength);
        if (params.isPercent) {
            buffer[buffer.length - 1] = '%';
        }
        if (params.isLessThanOne) {
            buffer[0] = '0';
            buffer[1] = '.';
        }

        for (uint256 zerosCursor = params.zerosStartIndex; zerosCursor < params.zerosEndIndex.add(1); zerosCursor++) {
            buffer[zerosCursor] = bytes1(uint8(48));
        }
        while (params.sigfigs > 0) {
            if (params.decimalIndex > 0 && params.sigfigIndex == params.decimalIndex) {
                buffer[params.sigfigIndex--] = '.';
            }
            buffer[params.sigfigIndex--] = bytes1(uint8(uint256(48).add(params.sigfigs % 10)));
            params.sigfigs /= 10;
        }
        return string(buffer);
    }

    function tickToDecimalString(
        int24 tick,
        int24 tickSpacing,
        uint8 baseTokenDecimals,
        uint8 quoteTokenDecimals,
        bool flipRatio
    ) internal pure returns (string memory) {
        if (tick == (TickMath.MIN_TICK / tickSpacing) * tickSpacing) {
            return !flipRatio ? 'MIN' : 'MAX';
        } else if (tick == (TickMath.MAX_TICK / tickSpacing) * tickSpacing) {
            return !flipRatio ? 'MAX' : 'MIN';
        } else {
            uint160 sqrtRatioX96 = TickMath.getSqrtRatioAtTick(tick);
            if (flipRatio) {
                sqrtRatioX96 = uint160(uint256(1 << 192).div(sqrtRatioX96));
            }
            return fixedPointToDecimalString(sqrtRatioX96, baseTokenDecimals, quoteTokenDecimals);
        }
    }

    function sigfigsRounded(uint256 value, uint8 digits) private pure returns (uint256, bool) {
        bool extraDigit;
        if (digits > 5) {
            value = value.div((10 ** (digits - 5)));
        }
        bool roundUp = value % 10 > 4;
        value = value.div(10);
        if (roundUp) {
            value = value + 1;
        }
        if (value == 100000) {
            value /= 10;
            extraDigit = true;
        }
        return (value, extraDigit);
    }

    function adjustForDecimalPrecision(
        uint160 sqrtRatioX96,
        uint8 baseTokenDecimals,
        uint8 quoteTokenDecimals
    ) private pure returns (uint256 adjustedSqrtRatioX96) {
        uint256 difference = abs(int256(baseTokenDecimals).sub(int256(quoteTokenDecimals)));
        if (difference > 0 && difference <= 18) {
            if (baseTokenDecimals > quoteTokenDecimals) {
                adjustedSqrtRatioX96 = sqrtRatioX96.mul(10 ** (difference.div(2)));
                if (difference % 2 == 1) {
                    adjustedSqrtRatioX96 = FullMath.mulDiv(adjustedSqrtRatioX96, sqrt10X128, 1 << 128);
                }
            } else {
                adjustedSqrtRatioX96 = sqrtRatioX96.div(10 ** (difference.div(2)));
                if (difference % 2 == 1) {
                    adjustedSqrtRatioX96 = FullMath.mulDiv(adjustedSqrtRatioX96, 1 << 128, sqrt10X128);
                }
            }
        } else {
            adjustedSqrtRatioX96 = uint256(sqrtRatioX96);
        }
    }

    function abs(int256 x) private pure returns (uint256) {
        return uint256(x >= 0 ? x : -x);
    }

    function fixedPointToDecimalString(
        uint160 sqrtRatioX96,
        uint8 baseTokenDecimals,
        uint8 quoteTokenDecimals
    ) internal pure returns (string memory) {
        uint256 adjustedSqrtRatioX96 = adjustForDecimalPrecision(sqrtRatioX96, baseTokenDecimals, quoteTokenDecimals);
        uint256 value = FullMath.mulDiv(adjustedSqrtRatioX96, adjustedSqrtRatioX96, 1 << 64);

        bool priceBelow1 = adjustedSqrtRatioX96 < 2 ** 96;
        if (priceBelow1) {
            value = FullMath.mulDiv(value, 10 ** 44, 1 << 128);
        } else {
            value = FullMath.mulDiv(value, 10 ** 5, 1 << 128);
        }

        uint256 temp = value;
        uint8 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        digits = digits - 1;

        (uint256 sigfigs, bool extraDigit) = sigfigsRounded(value, digits);
        if (extraDigit) {
            digits++;
        }

        DecimalStringParams memory dsp;
        if (priceBelow1) {
            dsp.bufferLength = uint8(uint8(7).add(uint8(43).sub(digits)));
            dsp.zerosStartIndex = 2;
            dsp.zerosEndIndex = uint8(uint256(43).sub(digits).add(1));
            dsp.sigfigIndex = uint8(dsp.bufferLength.sub(1));
        } else if (digits >= 9) {
            dsp.bufferLength = uint8(digits.sub(4));
            dsp.zerosStartIndex = 5;
            dsp.zerosEndIndex = uint8(dsp.bufferLength.sub(1));
            dsp.sigfigIndex = 4;
        } else {
            dsp.bufferLength = 6;
            dsp.sigfigIndex = 5;
            dsp.decimalIndex = uint8(digits.sub(5).add(1));
        }
        dsp.sigfigs = sigfigs;
        dsp.isLessThanOne = priceBelow1;
        dsp.isPercent = false;

        return generateDecimalString(dsp);
    }

    function feeToPercentString(uint24 fee) internal pure returns (string memory) {
        if (fee == 0) {
            return '0%';
        }
        uint24 temp = fee;
        uint256 digits;
        uint8 numSigfigs;
        while (temp != 0) {
            if (numSigfigs > 0) {
                numSigfigs++;
            } else if (temp % 10 != 0) {
                numSigfigs++;
            }
            digits++;
            temp /= 10;
        }

        DecimalStringParams memory dsp;
        uint256 nZeros;
        if (digits >= 5) {
            uint256 decimalPlace = digits.sub(numSigfigs) >= 4 ? 0 : 1;
            nZeros = digits.sub(5) < (numSigfigs.sub(1)) ? 0 : digits.sub(5).sub(numSigfigs.sub(1));
            dsp.zerosStartIndex = numSigfigs;
            dsp.zerosEndIndex = uint8(dsp.zerosStartIndex.add(nZeros).sub(1));
            dsp.sigfigIndex = uint8(dsp.zerosStartIndex.sub(1).add(decimalPlace));
            dsp.bufferLength = uint8(nZeros.add(numSigfigs.add(1)).add(decimalPlace));
        } else {
            nZeros = uint256(5).sub(digits);
            dsp.zerosStartIndex = 2;
            dsp.zerosEndIndex = uint8(nZeros.add(dsp.zerosStartIndex).sub(1));
            dsp.bufferLength = uint8(nZeros.add(numSigfigs.add(2)));
            dsp.sigfigIndex = uint8((dsp.bufferLength).sub(2));
            dsp.isLessThanOne = true;
        }
        dsp.sigfigs = uint256(fee).div(10 ** (digits.sub(numSigfigs)));
        dsp.isPercent = true;
        dsp.decimalIndex = digits > 4 ? uint8(digits.sub(4)) : 0;

        return generateDecimalString(dsp);
    }

    function addressToString(address addr) internal pure returns (string memory) {
        return (uint256(addr)).toHexString(20);
    }

    function computeTier(uint256 tokenId, address poolAddress) internal pure returns (uint8) {
        uint256 h = uint256(keccak256(abi.encodePacked(tokenId, poolAddress)));
        uint256 roll = h % 10000;
        if (roll < 300) return 4;
        if (roll < 1000) return 3;
        if (roll < 2500) return 2;
        if (roll < 5000) return 1;
        return 0;
    }

    function tierToRarity(uint8 tier) internal pure returns (string memory) {
        if (tier == 4) return 'Legendary';
        if (tier == 3) return 'Epic';
        if (tier == 2) return 'Rare';
        if (tier == 1) return 'Uncommon';
        return 'Common';
    }

    function tierColors(
        uint8 tier
    ) internal pure returns (string memory color0, string memory color1, string memory color2, string memory color3) {
        if (tier == 0) return ('1F2937', 'FF7801', 'FFD6B3', 'FFBB80');
        if (tier == 1) return ('1F2937', 'FFA04D', 'FF7801', 'FFD6B3');
        if (tier == 2) return ('1F2937', 'B35400', 'FFA04D', 'FF7801');
        if (tier == 3) return ('1F2937', 'E66C00', 'FF7801', 'B35400');
        return ('1F2937', '803C00', 'FF7801', 'E66C00');
    }

    function generateSVGImage(ConstructTokenURIParams memory params) internal pure returns (string memory svg) {
        uint8 tier = computeTier(params.tokenId, params.poolAddress);
        int8 _overRange = overRange(params.tickLower, params.tickUpper, params.tickCurrent);
        (string memory c0, string memory c1, string memory c2, string memory c3) = tierColors(tier);

        NFTSVG.SVGParams memory svgParams = NFTSVG.SVGParams({
            quoteToken: addressToString(params.quoteTokenAddress),
            baseToken: addressToString(params.baseTokenAddress),
            poolAddress: params.poolAddress,
            quoteTokenSymbol: params.quoteTokenSymbol,
            baseTokenSymbol: params.baseTokenSymbol,
            feeTier: feeToPercentString(params.fee),
            tickLower: params.tickLower,
            tickUpper: params.tickUpper,
            tickSpacing: params.tickSpacing,
            overRange: _overRange,
            tokenId: params.tokenId,
            color0: c0,
            color1: c1,
            color2: c2,
            color3: c3,
            x1: '70',
            y1: '170',
            x2: '220',
            y2: '120',
            x3: '160',
            y3: '350',
            tier: tier
        });

        return NFTSVG.generateSVG(svgParams);
    }

    function overRange(int24 tickLower, int24 tickUpper, int24 tickCurrent) private pure returns (int8) {
        if (tickCurrent < tickLower) {
            return -1;
        } else if (tickCurrent > tickUpper) {
            return 1;
        } else {
            return 0;
        }
    }
}
