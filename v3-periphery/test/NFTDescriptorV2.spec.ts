import { Wallet } from 'ethers'
import { waffle, ethers } from 'hardhat'
import { expect } from './shared/expect'
import { NFTDescriptorV2InternalTest } from '../typechain'
import { Fixture } from 'ethereum-waffle'
import fs from 'fs'
import isSvg from 'is-svg'

const TIER_NAMES = ['Common', 'Uncommon', 'Rare', 'Epic', 'Legendary']
const TIER_TOKEN_IDS: Record<number, number> = { 0: 3, 1: 2, 2: 1, 3: 4, 4: 28 }

describe('NFTDescriptorV2', () => {
  let wallets: Wallet[]

  const nftDescriptorV2Fixture: Fixture<{
    nftDescriptorV2: NFTDescriptorV2InternalTest
  }> = async () => {
    const effectsFactory = await ethers.getContractFactory('NFTSVGEffects')
    const effects = await effectsFactory.deploy()
    await effects.deployed()

    const nftsvgFactory = await ethers.getContractFactory('contracts/libraries/nft_v2/NFTSVG.sol:NFTSVG', {
      libraries: { NFTSVGEffects: effects.address },
    })
    const nftsvg = await nftsvgFactory.deploy()
    await nftsvg.deployed()

    const factory = await ethers.getContractFactory('NFTDescriptorV2InternalTest', {
      libraries: {
        'contracts/libraries/nft_v2/NFTSVG.sol:NFTSVG': nftsvg.address,
      },
    })
    const nftDescriptorV2 = (await factory.deploy()) as NFTDescriptorV2InternalTest
    await nftDescriptorV2.deployed()

    return { nftDescriptorV2 }
  }

  let nftDescriptorV2: NFTDescriptorV2InternalTest
  let loadFixture: ReturnType<typeof waffle.createFixtureLoader>

  before('create fixture loader', async () => {
    wallets = await (ethers as any).getSigners()
    loadFixture = waffle.createFixtureLoader(wallets)
  })

  beforeEach('load fixture', async () => {
    ;({ nftDescriptorV2 } = await loadFixture(nftDescriptorV2Fixture))
  })

  describe('#computeTier', () => {
    const poolAddress = `0x${'b'.repeat(40)}`

    it('returns correct tier for known token IDs', async () => {
      for (const [tier, tokenId] of Object.entries(TIER_TOKEN_IDS)) {
        const result = await nftDescriptorV2.testComputeTier(tokenId, poolAddress)
        expect(result).to.eq(Number(tier))
      }
    })

    it('tier distribution is within expected bounds over 1000 samples', async () => {
      const counts = [0, 0, 0, 0, 0]
      for (let tokenId = 1; tokenId <= 1000; tokenId++) {
        const tier = await nftDescriptorV2.testComputeTier(tokenId, poolAddress)
        counts[tier]++
      }
      // Legendary (tier 4): 3% expected → allow 0.5%-8%
      expect(counts[4]).to.be.gte(5)
      expect(counts[4]).to.be.lte(80)
      // Common (tier 0): 50% expected → allow 35%-65%
      expect(counts[0]).to.be.gte(350)
      expect(counts[0]).to.be.lte(650)
    })

    it('is deterministic for same inputs', async () => {
      const tier1 = await nftDescriptorV2.testComputeTier(42, poolAddress)
      const tier2 = await nftDescriptorV2.testComputeTier(42, poolAddress)
      expect(tier1).to.eq(tier2)
    })

    it('returns value between 0 and 4', async () => {
      for (let tokenId = 1; tokenId <= 50; tokenId++) {
        const tier = await nftDescriptorV2.testComputeTier(tokenId, poolAddress)
        expect(tier).to.be.gte(0)
        expect(tier).to.be.lte(4)
      }
    })
  })

  describe('#svgImage', () => {
    const baseTokenAddress = '0xabcdeabcdefabcdefabcdefabcdefabcdefabcdf'
    const quoteTokenAddress = '0x1234567890123456789123456789012345678901'
    const poolAddress = `0x${'b'.repeat(40)}`

    const defaultParams = {
      baseTokenAddress,
      quoteTokenAddress,
      baseTokenSymbol: 'LYX',
      quoteTokenSymbol: 'CHILL',
      baseTokenDecimals: 18,
      quoteTokenDecimals: 18,
      flipRatio: false,
      tickLower: -300,
      tickUpper: 300,
      tickCurrent: 40,
      tickSpacing: 10,
      fee: 500,
      poolAddress,
    }

    for (let tier = 0; tier <= 4; tier++) {
      const tierName = TIER_NAMES[tier]
      const tokenId = TIER_TOKEN_IDS[tier]

      it(`generates valid SVG for Tier ${tier} (${tierName})`, async () => {
        const svg = await nftDescriptorV2.testGenerateSVGImage({ ...defaultParams, tokenId })
        expect(isSvg(svg)).to.eq(true)
      })

      it(`Tier ${tier} (${tierName}) snapshot matches`, async () => {
        const svg = await nftDescriptorV2.testGenerateSVGImage({ ...defaultParams, tokenId })
        expect(svg).toMatchSnapshot()
        fs.writeFileSync(`./test/__snapshots__/NFTDescriptor-Tier${tier}-${tierName}.svg`, svg)
      })
    }
  })
})
