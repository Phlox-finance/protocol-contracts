// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.6;
pragma abicoder v2;

/// @title NFTSVGEffects
/// @notice Tier-conditional visual effects for Phlox NFT SVGs (glow, particles, holographic)
library NFTSVGEffects {
    // ---- GLOW FILTERS ----

    function generateGlowFilters(uint8 tier) public pure returns (string memory) {
        if (tier == 0) return '';
        string memory result = generateGlowBorderFilter(tier);
        if (tier >= 2) {
            result = string(abi.encodePacked(result, generateGlowCurveFilter(tier), generateGlowCircleFilter(tier)));
        }
        if (tier == 4) {
            result = string(abi.encodePacked(result, generateGlowSparkleFilter()));
        }
        return result;
    }

    function generateGlowBorderFilter(uint8 tier) private pure returns (string memory) {
        if (tier == 1) {
            return
                '<filter id="glow-border" x="-20%" y="-20%" width="140%" height="140%">'
                '<feGaussianBlur in="SourceGraphic" stdDeviation="3" result="blur" />'
                '<feColorMatrix in="blur" type="matrix" values="1 0 0 0 0  0.5 0.3 0 0 0  0 0 0 0 0  0 0 0 0.4 0" result="glow" />'
                '<feMerge><feMergeNode in="glow" /><feMergeNode in="SourceGraphic" /></feMerge></filter>';
        }
        if (tier == 2) {
            return
                '<filter id="glow-border" x="-20%" y="-20%" width="140%" height="140%">'
                '<feGaussianBlur in="SourceGraphic" stdDeviation="5" result="blur" />'
                '<feColorMatrix in="blur" type="matrix" values="1 0 0 0 0  0.6 0.4 0 0 0  0 0 0 0 0  0 0 0 0.6 0" result="glow" />'
                '<feMerge><feMergeNode in="glow" /><feMergeNode in="SourceGraphic" /></feMerge></filter>';
        }
        if (tier == 3) {
            return
                '<filter id="glow-border" x="-25%" y="-25%" width="150%" height="150%">'
                '<feGaussianBlur in="SourceGraphic" stdDeviation="8" result="blur" />'
                '<feColorMatrix in="blur" type="matrix" values="1 0 0 0 0  0.47 0.12 0 0 0  0 0 0 0 0  0 0 0 0.8 0" result="glow" />'
                '<feMerge><feMergeNode in="glow" /><feMergeNode in="SourceGraphic" /></feMerge></filter>';
        }
        return
            '<filter id="glow-border" x="-30%" y="-30%" width="160%" height="160%">'
            '<feGaussianBlur in="SourceGraphic" stdDeviation="12" result="blur" />'
            '<feColorMatrix in="blur" type="matrix" values="1 0 0 0 0  0.47 0 0 0 0  0 0 0.2 0 0  0 0 0 1 0" result="glow" />'
            '<feMerge><feMergeNode in="glow" /><feMergeNode in="SourceGraphic" /></feMerge></filter>';
    }

    function generateGlowCurveFilter(uint8 tier) private pure returns (string memory) {
        if (tier == 2) {
            return
                '<filter id="glow-curve" x="-30%" y="-30%" width="160%" height="160%">'
                '<feGaussianBlur in="SourceGraphic" stdDeviation="4" result="blur" />'
                '<feColorMatrix in="blur" type="matrix" values="1 0 0 0 0  0.6 0.25 0 0 0  0 0 0 0 0  0 0 0 0.5 0" />'
                '<feMerge><feMergeNode /><feMergeNode in="SourceGraphic" /></feMerge></filter>';
        }
        if (tier == 3) {
            return
                '<filter id="glow-curve" x="-40%" y="-40%" width="180%" height="180%">'
                '<feGaussianBlur in="SourceGraphic" stdDeviation="6" result="blur" />'
                '<feColorMatrix in="blur" type="matrix" values="1 0 0 0 0  0.47 0.12 0 0 0  0 0 0 0 0  0 0 0 0.7 0" />'
                '<feMerge><feMergeNode /><feMergeNode in="SourceGraphic" /></feMerge></filter>';
        }
        return
            '<filter id="glow-curve" x="-50%" y="-50%" width="200%" height="200%">'
            '<feGaussianBlur in="SourceGraphic" stdDeviation="8" result="blur" />'
            '<feColorMatrix in="blur" type="matrix" values="1 0 0 0 0  0.47 0 0 0 0  0 0 0.1 0 0  0 0 0 0.9 0" />'
            '<feMerge><feMergeNode /><feMergeNode in="SourceGraphic" /></feMerge></filter>';
    }

    function generateGlowCircleFilter(uint8 tier) private pure returns (string memory) {
        if (tier == 2) {
            return
                '<filter id="glow-circle" x="-100%" y="-100%" width="300%" height="300%" filterUnits="objectBoundingBox">'
                '<feGaussianBlur in="SourceGraphic" stdDeviation="3" result="blur" />'
                '<feColorMatrix in="blur" type="matrix" values="1 0 0 0 0  0.6 0.3 0 0 0  0 0 0 0 0  0 0 0 0.6 0" />'
                '<feMerge><feMergeNode /><feMergeNode in="SourceGraphic" /></feMerge></filter>';
        }
        if (tier == 3) {
            return
                '<filter id="glow-circle" x="-100%" y="-100%" width="300%" height="300%" filterUnits="objectBoundingBox">'
                '<feGaussianBlur in="SourceGraphic" stdDeviation="4" result="blur" />'
                '<feColorMatrix in="blur" type="matrix" values="1 0 0 0 0  0.6 0.3 0 0 0  0 0 0 0 0  0 0 0 0.8 0" />'
                '<feMerge><feMergeNode /><feMergeNode in="SourceGraphic" /></feMerge></filter>';
        }
        return
            '<filter id="glow-circle" x="-100%" y="-100%" width="300%" height="300%" filterUnits="objectBoundingBox">'
            '<feGaussianBlur in="SourceGraphic" stdDeviation="5" result="blur" />'
            '<feColorMatrix in="blur" type="matrix" values="1 0 0 0 0  0.6 0.3 0 0 0  0 0 0 0 0  0 0 0 1 0" />'
            '<feMerge><feMergeNode /><feMergeNode in="SourceGraphic" /></feMerge></filter>';
    }

    function generateGlowSparkleFilter() private pure returns (string memory) {
        return
            '<filter id="glow-sparkle" x="-60%" y="-60%" width="220%" height="220%">'
            '<feGaussianBlur in="SourceGraphic" stdDeviation="4" result="blur" />'
            '<feColorMatrix in="blur" type="matrix" values="1 0 0 0 0  0.8 0.5 0 0 0  0.2 0.1 0 0 0  0 0 0 1 0" />'
            '<feMerge><feMergeNode /><feMergeNode in="SourceGraphic" /></feMerge></filter>';
    }

    // ---- SHIMMER / EMBER / PLATINUM DEFS ----

    function generateShimmerFilter(uint8 tier) public pure returns (string memory) {
        if (tier == 3) return generateEmberDefs();
        if (tier == 4) return generatePlatinumEmberDefs();
        return '';
    }

    function generateEmberDefs() private pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<filter id="ember-glow" x="-200%" y="-200%" width="500%" height="500%">'
                    '<feGaussianBlur stdDeviation="3" />'
                    '<feColorMatrix type="matrix" values="1 0 0 0 0  0.4 0.15 0 0 0  0 0 0 0 0  0 0 0 1 0" />'
                    '</filter>'
                    '<style>'
                    '@keyframes ember-flicker{'
                    '0%{opacity:0}'
                    '15%{opacity:1}'
                    '30%{opacity:0.3}'
                    '50%{opacity:0.9}'
                    '65%{opacity:0.15}'
                    '80%{opacity:0.85}'
                    '100%{opacity:0}}'
                    '.ember{animation:ember-flicker ease-in-out infinite}'
                    '</style>'
                )
            );
    }

    function generatePlatinumEmberDefs() private pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<filter id="plat-glow" x="-200%" y="-200%" width="500%" height="500%">'
                    '<feGaussianBlur stdDeviation="4" />'
                    '<feColorMatrix type="matrix" values="0.6 0.1 0.3 0 0.15  0.6 0.1 0.3 0 0.15  0.7 0.2 0.4 0 0.2  0 0 0 1 0" />'
                    '</filter>'
                    '<style>'
                    '@keyframes twinkle{'
                    '0%{opacity:0}'
                    '12%{opacity:0.9}'
                    '28%{opacity:0.2}'
                    '45%{opacity:1}'
                    '58%{opacity:0.1}'
                    '72%{opacity:0.85}'
                    '88%{opacity:0.3}'
                    '100%{opacity:0}}'
                    '.plat{animation:twinkle ease-in-out infinite}'
                    '</style>'
                )
            );
    }

    // ---- HOLOGRAPHIC DEFS (Legendary only) ----

    function generateHolographicDefs(uint8 tier) public pure returns (string memory) {
        if (tier != 4) return '';
        return string(abi.encodePacked(generateBorderGrad(), generateHoloSweep(), generateHoloRainbowAndPulse()));
    }

    function generateBorderGrad() private pure returns (string memory) {
        return
            '<linearGradient id="border-grad" gradientUnits="userSpaceOnUse" x1="0" y1="0" x2="290" y2="500">'
            '<stop offset="0%" stop-color="#FF7801"><animate attributeName="stop-color" values="#FF7801;#FFaa33;#FF4500;#FF7801" dur="16s" repeatCount="indefinite" /></stop>'
            '<stop offset="50%" stop-color="#FFaa33"><animate attributeName="stop-color" values="#FFaa33;#FF4500;#FF7801;#FFaa33" dur="16s" repeatCount="indefinite" /></stop>'
            '<stop offset="100%" stop-color="#FF4500"><animate attributeName="stop-color" values="#FF4500;#FF7801;#FFaa33;#FF4500" dur="16s" repeatCount="indefinite" /></stop>'
            '</linearGradient>';
    }

    function generateHoloSweep() private pure returns (string memory) {
        return
            '<linearGradient id="holo-sweep" x1="0" y1="0.05" x2="1" y2="0.95" gradientUnits="objectBoundingBox">'
            '<stop offset="0%" stop-color="rgba(255,120,1,0)" /><stop offset="35%" stop-color="rgba(255,120,1,0)" />'
            '<stop offset="43%" stop-color="rgba(255,200,100,0.15)" /><stop offset="48%" stop-color="rgba(255,255,255,0.35)" />'
            '<stop offset="53%" stop-color="rgba(255,200,100,0.15)" /><stop offset="60%" stop-color="rgba(255,120,1,0)" />'
            '<stop offset="100%" stop-color="rgba(255,120,1,0)" />'
            '<animateTransform attributeName="gradientTransform" type="translate" values="-0.6 -0.6;1.2 1.2" dur="16s" repeatCount="indefinite" />'
            '</linearGradient>';
    }

    function generateHoloRainbowAndPulse() private pure returns (string memory) {
        return string(abi.encodePacked(generateHoloRainbow(), generateHoloPulse()));
    }

    function generateHoloRainbow() private pure returns (string memory) {
        return
            '<linearGradient id="holo-rainbow" x1="0" y1="0" x2="0.5" y2="1">'
            '<stop offset="0%" stop-color="#ff000033" /><stop offset="16%" stop-color="#ff880033" />'
            '<stop offset="33%" stop-color="#ffff0028" /><stop offset="50%" stop-color="#00ff0028" />'
            '<stop offset="66%" stop-color="#0088ff28" /><stop offset="83%" stop-color="#8800ff28" />'
            '<stop offset="100%" stop-color="#ff00ff28" />'
            '<animateTransform attributeName="gradientTransform" type="rotate" values="0 0.5 0.5;360 0.5 0.5" dur="20s" repeatCount="indefinite" />'
            '</linearGradient>';
    }

    function generateHoloPulse() private pure returns (string memory) {
        return
            '<radialGradient id="holo-pulse" cx="50%" cy="50%" r="60%">'
            '<stop offset="0%" stop-color="rgba(255,180,80,0.18)">'
            '<animate attributeName="stop-color" values="rgba(255,180,80,0.18);rgba(255,120,1,0.1);rgba(255,220,150,0.22);rgba(255,180,80,0.18)" dur="10s" repeatCount="indefinite" /></stop>'
            '<stop offset="100%" stop-color="rgba(255,120,1,0)" />'
            '<animate attributeName="r" values="40%;65%;40%" dur="10s" repeatCount="indefinite" />'
            '</radialGradient>';
    }

    // ---- CLIP GROUP OVERLAYS ----

    function generateClipGroupOverlays(uint8 tier) public pure returns (string memory) {
        string memory overlays = '';
        if (tier == 4) {
            overlays = string(
                abi.encodePacked(
                    '<rect x="0" y="0" width="290" height="500" fill="url(#holo-rainbow)" />',
                    '<rect x="0" y="0" width="290" height="500" fill="url(#holo-sweep)" />',
                    '<rect x="0" y="0" width="290" height="500" fill="url(#holo-pulse)" />',
                    generatePlatinumEmberParticles()
                )
            );
        } else if (tier == 3) {
            overlays = generateEmberParticles();
        }
        return
            string(
                abi.encodePacked(
                    overlays,
                    ' <g style="filter:url(#top-region-blur); transform:scale(1.5); transform-origin:center top;">',
                    '<rect fill="none" x="0px" y="0px" width="290px" height="500px" />',
                    '<ellipse cx="50%" cy="0px" rx="180px" ry="120px" fill="#000" opacity="0.85" /></g>'
                )
            );
    }

    // ---- EMBER PARTICLES ----

    function generateEmberParticles() private pure returns (string memory) {
        return string(abi.encodePacked(generateEmberParticlesPart1(), generateEmberParticlesPart2()));
    }

    function generateEmberParticlesPart1() private pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<g opacity="0.9">',
                    '<circle class="ember" cx="40" cy="85" r="2.5" fill="#FF9020" filter="url(#ember-glow)" style="animation-duration:7s;animation-delay:0s"/>',
                    '<circle class="ember" cx="85" cy="160" r="2" fill="#FFB040" filter="url(#ember-glow)" style="animation-duration:9s;animation-delay:-2.5s"/>',
                    '<circle class="ember" cx="130" cy="310" r="3" fill="#FF7010" filter="url(#ember-glow)" style="animation-duration:6s;animation-delay:-5s"/>',
                    '<circle class="ember" cx="170" cy="55" r="1.8" fill="#FFA030" filter="url(#ember-glow)" style="animation-duration:11s;animation-delay:-1s"/>',
                    '<circle class="ember" cx="210" cy="230" r="2.2" fill="#FF8020" filter="url(#ember-glow)" style="animation-duration:8s;animation-delay:-7s"/>',
                    '<circle class="ember" cx="250" cy="400" r="2" fill="#FFB050" filter="url(#ember-glow)" style="animation-duration:10s;animation-delay:-3.5s"/>',
                    '<circle class="ember" cx="60" cy="445" r="1.5" fill="#FF6000" filter="url(#ember-glow)" style="animation-duration:12s;animation-delay:-9s"/>',
                    '<circle class="ember" cx="110" cy="120" r="2.8" fill="#FF9530" filter="url(#ember-glow)" style="animation-duration:7s;animation-delay:-4s"/>',
                    '<circle class="ember" cx="155" cy="370" r="1.5" fill="#FFAA40" filter="url(#ember-glow)" style="animation-duration:9s;animation-delay:-6s"/>'
                )
            );
    }

    function generateEmberParticlesPart2() private pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<circle class="ember" cx="195" cy="195" r="2.5" fill="#FF7520" filter="url(#ember-glow)" style="animation-duration:5s;animation-delay:-2s"/>',
                    '<circle class="ember" cx="235" cy="340" r="1.8" fill="#FF8530" filter="url(#ember-glow)" style="animation-duration:11s;animation-delay:-8s"/>',
                    '<circle class="ember" cx="25" cy="270" r="2" fill="#FFAA30" filter="url(#ember-glow)" style="animation-duration:8s;animation-delay:-3s"/>',
                    '<circle class="ember" cx="75" cy="475" r="3.2" fill="#FF6510" filter="url(#ember-glow)" style="animation-duration:10s;animation-delay:-4.5s"/>',
                    '<circle class="ember" cx="145" cy="140" r="1.5" fill="#FFB060" filter="url(#ember-glow)" style="animation-duration:13s;animation-delay:-10s"/>',
                    '<circle class="ember" cx="185" cy="420" r="2.3" fill="#FF8020" filter="url(#ember-glow)" style="animation-duration:7s;animation-delay:-1s"/>',
                    '<circle class="ember" cx="260" cy="260" r="1.8" fill="#FF9540" filter="url(#ember-glow)" style="animation-duration:9s;animation-delay:-6s"/>',
                    '<circle class="ember" cx="100" cy="480" r="2" fill="#FF7020" filter="url(#ember-glow)" style="animation-duration:11s;animation-delay:-5.5s"/>',
                    '<circle class="ember" cx="220" cy="70" r="2.5" fill="#FFA050" filter="url(#ember-glow)" style="animation-duration:6s;animation-delay:-3s"/>',
                    '</g>'
                )
            );
    }

    // ---- PLATINUM PARTICLES ----

    function generatePlatinumEmberParticles() private pure returns (string memory) {
        return string(abi.encodePacked(generatePlatinumParticlesPart1(), generatePlatinumParticlesPart2()));
    }

    function generatePlatinumParticlesPart1() private pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<g opacity="0.9">',
                    '<circle class="plat" cx="42" cy="85" r="2" fill="#E0E8F0" filter="url(#plat-glow)" style="animation-duration:4s;animation-delay:0s"/>',
                    '<circle class="plat" cx="248" cy="130" r="1.5" fill="#C8D8E8" filter="url(#plat-glow)" style="animation-duration:5.5s;animation-delay:-1.2s"/>',
                    '<circle class="plat" cx="130" cy="200" r="2.5" fill="#D0D0D8" filter="url(#plat-glow)" style="animation-duration:3.8s;animation-delay:-2.5s"/>',
                    '<circle class="plat" cx="65" cy="310" r="1.8" fill="#B8C8D8" filter="url(#plat-glow)" style="animation-duration:6s;animation-delay:-0.8s"/>',
                    '<circle class="plat" cx="210" cy="260" r="2.2" fill="#D8E0E8" filter="url(#plat-glow)" style="animation-duration:4.5s;animation-delay:-3.5s"/>',
                    '<circle class="plat" cx="155" cy="380" r="1.5" fill="#C0D0E0" filter="url(#plat-glow)" style="animation-duration:7s;animation-delay:-1.8s"/>',
                    '<circle class="plat" cx="25" cy="440" r="2" fill="#A8B8C8" filter="url(#plat-glow)" style="animation-duration:5s;animation-delay:-4.2s"/>',
                    '<circle class="plat" cx="180" cy="65" r="2.8" fill="#E8E8F0" filter="url(#plat-glow)" style="animation-duration:3.5s;animation-delay:-2s"/>',
                    '<circle class="plat" cx="100" cy="460" r="1.5" fill="#D0D8E8" filter="url(#plat-glow)" style="animation-duration:6.5s;animation-delay:-3s"/>'
                )
            );
    }

    function generatePlatinumParticlesPart2() private pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<circle class="plat" cx="260" cy="400" r="2.5" fill="#C0C8D0" filter="url(#plat-glow)" style="animation-duration:4.2s;animation-delay:-1s"/>',
                    '<circle class="plat" cx="50" cy="170" r="1.8" fill="#D8D8E0" filter="url(#plat-glow)" style="animation-duration:5.8s;animation-delay:-4.8s"/>',
                    '<circle class="plat" cx="230" cy="50" r="2" fill="#B0C0D0" filter="url(#plat-glow)" style="animation-duration:4s;animation-delay:-2.2s"/>',
                    '<circle class="plat" cx="85" cy="240" r="3" fill="#E0E0E8" filter="url(#plat-glow)" style="animation-duration:3.5s;animation-delay:-0.5s"/>',
                    '<circle class="plat" cx="200" cy="340" r="1.5" fill="#C8D0E0" filter="url(#plat-glow)" style="animation-duration:6.2s;animation-delay:-5.5s"/>',
                    '<circle class="plat" cx="145" cy="120" r="2.3" fill="#D0D8D8" filter="url(#plat-glow)" style="animation-duration:4.8s;animation-delay:-3.2s"/>',
                    '<circle class="plat" cx="35" cy="360" r="1.8" fill="#B8C0D0" filter="url(#plat-glow)" style="animation-duration:5.2s;animation-delay:-1.5s"/>',
                    '<circle class="plat" cx="240" cy="220" r="2" fill="#E8E0F0" filter="url(#plat-glow)" style="animation-duration:3.8s;animation-delay:-4s"/>',
                    '<circle class="plat" cx="120" cy="430" r="2.5" fill="#D0D0E0" filter="url(#plat-glow)" style="animation-duration:5s;animation-delay:-2.8s"/>',
                    '</g>'
                )
            );
    }

    // ---- CLIP GROUP BORDER ----

    function generateClipGroupBorder(uint8 tier) public pure returns (string memory) {
        if (tier == 0) {
            return
                '<rect x="0" y="0" width="290" height="500" rx="42" ry="42" fill="rgba(0,0,0,0)" stroke="rgba(255,255,255,0.2)" />';
        }
        if (tier == 1) {
            return
                string(
                    abi.encodePacked(
                        '<rect x="0" y="0" width="290" height="500" rx="42" ry="42" fill="rgba(0,0,0,0)" stroke="rgba(255,153,51,0.25)" stroke-width="1.5" style="filter: url(#glow-border)" />',
                        '<rect x="0" y="0" width="290" height="500" rx="42" ry="42" fill="rgba(0,0,0,0)" stroke="rgba(255,255,255,0.2)" />'
                    )
                );
        }
        if (tier == 2) {
            return
                string(
                    abi.encodePacked(
                        '<rect x="0" y="0" width="290" height="500" rx="42" ry="42" fill="rgba(0,0,0,0)" stroke="rgba(255,160,64,0.4)" stroke-width="2" style="filter: url(#glow-border)" />',
                        '<rect x="0" y="0" width="290" height="500" rx="42" ry="42" fill="rgba(0,0,0,0)" stroke="rgba(255,200,100,0.35)" />'
                    )
                );
        }
        if (tier == 3) {
            return
                string(
                    abi.encodePacked(
                        '<rect x="0" y="0" width="290" height="500" rx="42" ry="42" fill="rgba(0,0,0,0)" stroke="rgba(255,120,1,0.6)" stroke-width="2.5" style="filter: url(#glow-border)" />',
                        '<rect x="0" y="0" width="290" height="500" rx="42" ry="42" fill="rgba(0,0,0,0)" stroke="rgba(255,200,100,0.5)" />'
                    )
                );
        }
        return
            string(
                abi.encodePacked(
                    '<rect x="0" y="0" width="290" height="500" rx="42" ry="42" fill="rgba(0,0,0,0)" stroke="url(#border-grad)" stroke-width="3" style="filter: url(#glow-border)" />',
                    '<rect x="0" y="0" width="290" height="500" rx="42" ry="42" fill="rgba(0,0,0,0)" stroke="url(#border-grad)" stroke-width="1.5" />'
                )
            );
    }

    // ---- RARE SPARKLE ----

    function generateSVGRareSparkle(uint8 tier) public pure returns (string memory svg) {
        if (tier < 3) return '';
        svg = string(
            abi.encodePacked(
                '<g style="transform:translate(226px, 392px)"><rect width="36px" height="36px" rx="8px" ry="8px" fill="none" stroke="',
                tier == 3 ? 'rgba(255,200,100,0.3)' : 'rgba(255,200,100,0.4)',
                '" /><g style="',
                tier == 3 ? 'filter: url(#glow-curve)' : 'filter: url(#glow-sparkle)',
                '"><path style="transform:translate(6px,6px)" d="M12 0L12.6522 9.56587L18 1.6077L13.7819 10.2181L22.3923 6L14.4341 ',
                '11.3478L24 12L14.4341 12.6522L22.3923 18L13.7819 13.7819L18 22.3923L12.6522 14.4341L12 24L11.3478 14.4341L6 22.39',
                '23L10.2181 13.7819L1.6077 18L9.56587 12.6522L0 12L9.56587 11.3478L1.6077 6L10.2181 10.2181L6 1.6077L11.3478 9.56587L12 0Z" fill="',
                tier == 3 ? 'rgba(255,200,100,1)' : 'rgba(255,220,150,1)',
                '" /><animateTransform attributeName="transform" type="rotate" from="0 18 18" to="360 18 18" dur="',
                tier == 3 ? '10s' : '6s',
                '" repeatCount="indefinite"/></g></g>'
            )
        );
    }
}
