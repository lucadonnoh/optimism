//SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import { CommonTest } from "./CommonTest.t.sol";
import { Hashing } from "../libraries/Hashing.sol";
import { Encoding } from "../libraries/Encoding.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

contract Hashing_Test is CommonTest {
    function test_hashDepositSource() external {
        bytes32 sourceHash = Hashing.hashDepositSource(
            0xd25df7858efc1778118fb133ac561b138845361626dfb976699c5287ed0f4959,
            0x1
        );

        assertEq(
            sourceHash,
            0xf923fb07134d7d287cb52c770cc619e17e82606c21a875c92f4c63b65280a5cc
        );
    }

    function test_hashCrossDomainMessage_differential(
        uint256 _nonce,
        address _sender,
        address _target,
        uint256 _value,
        uint256 _gasLimit,
        bytes memory _data
    ) external {
        // Discard any fuzz tests with an invalid version
        (, uint16 version) = Encoding.decodeVersionedNonce(_nonce);
        vm.assume(version < 2);

        string[] memory cmds = new string[](9);
        cmds[0] = "node";
        cmds[1] = "dist/scripts/differential-testing.js";
        cmds[2] = "hashCrossDomainMessage";
        cmds[3] = vm.toString(_nonce);
        cmds[4] = vm.toString(_sender);
        cmds[5] = vm.toString(_target);
        cmds[6] = vm.toString(_value);
        cmds[7] = vm.toString(_gasLimit);
        cmds[8] = vm.toString(_data);

        bytes32 hash = Hashing.hashCrossDomainMessage(
            _nonce,
            _sender,
            _target,
            _value,
            _gasLimit,
            _data
        );

        bytes memory result = vm.ffi(cmds);
        assertEq(
            hash,
            abi.decode(result, (bytes32))
        );
    }

    function test_hashDepositTransaction() external {
        bytes32 digest = Hashing.hashDepositTransaction(
            0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266,
            0xB79f76EF2c5F0286176833E7B2eEe103b1CC3244,
            0xde0b6b3a7640000,
            0xe043da617250000,
            0x2dc6c0,
            false,
            hex"",
            0xd25df7858efc1778118fb133ac561b138845361626dfb976699c5287ed0f4959,
            0x1
        );

        assertEq(
            digest,
            0xf58e30138cb01330f6450b9a5e717a63840ad2e21f17340105b388ad3c668749
        );
    }

    function test_hashWithdrawal_differential(
        uint256 _nonce,
        address _sender,
        address _target,
        uint256 _value,
        uint256 _gasLimit,
        bytes memory _data
    ) external {
        bytes32 hash = Hashing.hashWithdrawal(
            _nonce,
            _sender,
            _target,
            _value,
            _gasLimit,
            _data
        );

        string[] memory cmds = new string[](9);
        cmds[0] = "node";
        cmds[1] = "dist/scripts/differential-testing.js";
        cmds[2] = "hashWithdrawal";
        cmds[3] = vm.toString(_nonce);
        cmds[4] = vm.toString(_sender);
        cmds[5] = vm.toString(_target);
        cmds[6] = vm.toString(_value);
        cmds[7] = vm.toString(_gasLimit);
        cmds[8] = vm.toString(_data);

        bytes memory result = vm.ffi(cmds);
        assertEq(
            hash,
            abi.decode(result, (bytes32))
        );
    }

    function test_hashOutputRootProof_differential(
        bytes32 _version,
        bytes32 _stateRoot,
        bytes32 _withdrawerStorageRoot,
        bytes32 _latestBlockhash
    ) external {
        Hashing.OutputRootProof memory proof = Hashing.OutputRootProof({
            version: _version,
            stateRoot: _stateRoot,
            withdrawerStorageRoot: _withdrawerStorageRoot,
            latestBlockhash: _latestBlockhash
        });

        bytes32 hash = Hashing.hashOutputRootProof(proof);

        string[] memory cmds = new string[](7);
        cmds[0] = "node";
        cmds[1] = "dist/scripts/differential-testing.js";
        cmds[2] = "hashOutputRootProof";
        cmds[3] = Strings.toHexString(uint256(_version));
        cmds[4] = Strings.toHexString(uint256(_stateRoot));
        cmds[5] = Strings.toHexString(uint256(_withdrawerStorageRoot));
        cmds[6] = Strings.toHexString(uint256(_latestBlockhash));

        bytes memory result = vm.ffi(cmds);
        assertEq(
            hash,
            abi.decode(result, (bytes32))
        );
    }

    // TODO(tynes): foundry bug cannot serialize
    // bytes32 as strings with vm.toString
    function test_hashDepositTransaction_differential(
        address _from,
        address _to,
        uint256 _mint,
        uint256 _value,
        uint64 _gas,
        bytes memory _data,
        uint256 _logIndex
    ) external {
        bytes32 digest = Hashing.hashDepositTransaction(
            _from,
            _to,
            _value,
            _mint,
            _gas,
            false, // isCreate
            _data,
            bytes32(uint256(0)),
            _logIndex
        );

        bytes memory result;

        {
            string[] memory cmds = new string[](11);
            cmds[0] = "node";
            cmds[1] = "dist/scripts/differential-testing.js";
            cmds[2] = "hashDepositTransaction";
            cmds[3] = "0x0000000000000000000000000000000000000000000000000000000000000000";
            cmds[4] = vm.toString(_logIndex);
            cmds[5] = vm.toString(_from);
            cmds[6] = vm.toString(_to);
            cmds[7] = vm.toString(_mint);
            cmds[8] = vm.toString(_value);
            cmds[9] = vm.toString(_gas);
            cmds[10] = vm.toString(_data);
            result = vm.ffi(cmds);
        }

        assertEq(
            abi.decode(result, (bytes32)),
            digest
        );
    }
}
