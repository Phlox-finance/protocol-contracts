import { expect } from 'chai'
import { ethers } from 'hardhat'
import { WLYX1 } from '../typechain-types'
import { HardhatEthersSigner } from '@nomicfoundation/hardhat-ethers/signers'

const LSP4_TOKEN_NAME_KEY = '0xdeba1e292f8ba88238e10ab3c7f88bd4be4fac56cad5194b6ecceaf653468af1'
const LSP4_TOKEN_SYMBOL_KEY = '0x2f0a68ab07768e01943a599e73362a0e17a63a72e94dd2e384d2c1d4db932756'

describe('WLYX1', () => {
  let wlyx: WLYX1
  let owner: HardhatEthersSigner
  let addr1: HardhatEthersSigner

  beforeEach(async () => {
    ;[owner, addr1] = await ethers.getSigners()
    const factory = await ethers.getContractFactory('WLYX1')
    wlyx = await factory.deploy()
    await wlyx.waitForDeployment()
  })

  describe('constructor', () => {
    it('has correct name and symbol', async () => {
      const nameData = await wlyx.getData(LSP4_TOKEN_NAME_KEY)
      const symbolData = await wlyx.getData(LSP4_TOKEN_SYMBOL_KEY)
      expect(ethers.toUtf8String(nameData)).to.equal('WrappedLYX1')
      expect(ethers.toUtf8String(symbolData)).to.equal('WLYX1')
    })
  })

  describe('decimals', () => {
    it('returns 18', async () => {
      expect(await wlyx.decimals()).to.equal(18)
    })
  })

  describe('deposit', () => {
    it('increases balance by msg.value', async () => {
      const amount = ethers.parseEther('1')
      await wlyx.deposit({ value: amount })
      expect(await wlyx.balanceOf(owner.address)).to.equal(amount)
    })

    it('emits Deposit event', async () => {
      const amount = ethers.parseEther('1')
      await expect(wlyx.deposit({ value: amount }))
        .to.emit(wlyx, 'Deposit')
        .withArgs(owner.address, amount)
    })
  })

  describe('deposit via receive', () => {
    it('deposits when sending plain LYX', async () => {
      const amount = ethers.parseEther('2')
      await owner.sendTransaction({ to: await wlyx.getAddress(), value: amount })
      expect(await wlyx.balanceOf(owner.address)).to.equal(amount)
    })

    it('emits Deposit event on plain transfer', async () => {
      const amount = ethers.parseEther('2')
      await expect(owner.sendTransaction({ to: await wlyx.getAddress(), value: amount }))
        .to.emit(wlyx, 'Deposit')
        .withArgs(owner.address, amount)
    })
  })

  describe('deposit via fallback', () => {
    it('deposits when sending LYX with calldata', async () => {
      const amount = ethers.parseEther('3')
      await owner.sendTransaction({ to: await wlyx.getAddress(), value: amount, data: '0x1234' })
      expect(await wlyx.balanceOf(owner.address)).to.equal(amount)
    })
  })

  describe('withdraw', () => {
    it('decreases balance and returns LYX', async () => {
      const depositAmount = ethers.parseEther('5')
      const withdrawAmount = ethers.parseEther('2')
      await wlyx.deposit({ value: depositAmount })

      const balanceBefore = await ethers.provider.getBalance(owner.address)
      const tx = await wlyx.withdraw(withdrawAmount)
      const receipt = await tx.wait()
      const gasCost = receipt!.gasUsed * receipt!.gasPrice
      const balanceAfter = await ethers.provider.getBalance(owner.address)

      expect(await wlyx.balanceOf(owner.address)).to.equal(depositAmount - withdrawAmount)
      expect(balanceAfter - balanceBefore + gasCost).to.equal(withdrawAmount)
    })

    it('emits Withdrawal event', async () => {
      const amount = ethers.parseEther('1')
      await wlyx.deposit({ value: amount })
      await expect(wlyx.withdraw(amount)).to.emit(wlyx, 'Withdrawal').withArgs(owner.address, amount)
    })

    it('reverts on insufficient balance', async () => {
      const amount = ethers.parseEther('1')
      await expect(wlyx.withdraw(amount)).to.be.reverted
    })
  })

  describe('totalSupply', () => {
    it('equals contract balance after deposits', async () => {
      const amount = ethers.parseEther('10')
      await wlyx.deposit({ value: amount })
      const contractBalance = await ethers.provider.getBalance(await wlyx.getAddress())
      expect(await wlyx.totalSupply()).to.equal(contractBalance)
    })

    it('equals contract balance after deposit and withdrawal', async () => {
      await wlyx.deposit({ value: ethers.parseEther('10') })
      await wlyx.withdraw(ethers.parseEther('3'))
      const contractBalance = await ethers.provider.getBalance(await wlyx.getAddress())
      expect(await wlyx.totalSupply()).to.equal(contractBalance)
    })

    it('tracks correctly with multiple depositors', async () => {
      await wlyx.deposit({ value: ethers.parseEther('5') })
      await wlyx.connect(addr1).deposit({ value: ethers.parseEther('3') })
      const contractBalance = await ethers.provider.getBalance(await wlyx.getAddress())
      expect(await wlyx.totalSupply()).to.equal(contractBalance)
      expect(await wlyx.totalSupply()).to.equal(ethers.parseEther('8'))
    })
  })
})
