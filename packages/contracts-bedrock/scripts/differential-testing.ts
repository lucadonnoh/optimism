import { BigNumber, utils } from 'ethers'
import {
  decodeVersionedNonce,
  hashCrossDomainMessage,
  DepositTx,
  SourceHashDomain,
  encodeCrossDomainMessage,
  hashWithdrawal,
  hashOutputRootProof,
} from '@eth-optimism/core-utils'

const args = process.argv.slice(2)
const command = args[0]

switch (command) {
  case 'decodeVersionedNonce': {
    const input = BigNumber.from(args[1])
    const [nonce, version] = decodeVersionedNonce(input)

    const output = utils.defaultAbiCoder.encode(
      ['uint256', 'uint256'],
      [nonce.toHexString(), version.toHexString()]
    )
    process.stdout.write(output)
    break
  }
  case 'encodeCrossDomainMessage': {
    const nonce = BigNumber.from(args[1])
    const sender = args[2]
    const target = args[3]
    const value = BigNumber.from(args[4])
    const gasLimit = BigNumber.from(args[5])
    const data = args[6]

    const encoding = encodeCrossDomainMessage(
      nonce,
      sender,
      target,
      value,
      gasLimit,
      data
    )

    const output = utils.defaultAbiCoder.encode(['bytes'], [encoding])
    process.stdout.write(output)
    break
  }
  case 'hashCrossDomainMessage': {
    const nonce = BigNumber.from(args[1])
    const sender = args[2]
    const target = args[3]
    const value = BigNumber.from(args[4])
    const gasLimit = BigNumber.from(args[5])
    const data = args[6]

    const hash = hashCrossDomainMessage(
      nonce,
      sender,
      target,
      value,
      gasLimit,
      data
    )
    const output = utils.defaultAbiCoder.encode(['bytes32'], [hash])
    process.stdout.write(output)
    break
  }
  case 'hashDepositTransaction': {
    // The solidity transaction hash computation currently only works with
    // user deposits. System deposit transaction hashing is not supported.
    const l1BlockHash = args[1]
    const logIndex = BigNumber.from(args[2])
    const from = args[3]
    const to = args[4]
    const mint = BigNumber.from(args[5])
    const value = BigNumber.from(args[6])
    const gas = BigNumber.from(args[7])
    const data = args[8]

    const tx = new DepositTx({
      l1BlockHash,
      logIndex,
      from,
      to,
      mint,
      value,
      gas,
      data,
      domain: SourceHashDomain.UserDeposit,
    })

    const digest = tx.hash()
    const output = utils.defaultAbiCoder.encode(['bytes32'], [digest])
    process.stdout.write(output)
    break
  }
  case 'hashWithdrawal': {
    const nonce = BigNumber.from(args[1])
    const sender = args[2]
    const target = args[3]
    const value = BigNumber.from(args[4])
    const gas = BigNumber.from(args[5])
    const data = args[6]

    const hash = hashWithdrawal(nonce, sender, target, value, gas, data)
    const output = utils.defaultAbiCoder.encode(['bytes32'], [hash])
    process.stdout.write(output)
    break
  }
  case 'hashOutputRootProof': {
    const version = utils.hexZeroPad(BigNumber.from(args[1]).toHexString(), 32)
    const stateRoot = utils.hexZeroPad(
      BigNumber.from(args[2]).toHexString(),
      32
    )
    const withdrawerStorageRoot = utils.hexZeroPad(
      BigNumber.from(args[3]).toHexString(),
      32
    )
    const latestBlockhash = utils.hexZeroPad(
      BigNumber.from(args[4]).toHexString(),
      32
    )

    const hash = hashOutputRootProof({
      version,
      stateRoot,
      withdrawerStorageRoot,
      latestBlockhash,
    })
    const output = utils.defaultAbiCoder.encode(['bytes32'], [hash])
    process.stdout.write(output)
    break
  }
}
