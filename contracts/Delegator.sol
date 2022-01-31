//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

enum Directive {
  CREATE_VALIDATOR, // unused
  EDIT_VALIDATOR,   // unused
  DELEGATE,
  UNDELEGATE,
  COLLECT_REWARDS
}

abstract contract StakingPrecompilesSelectors {
  function Delegate(address delegatorAddress,
                    address validatorAddress,
                    uint256 amount) public virtual;
  function Undelegate(address delegatorAddress,
                      address validatorAddress,
                      uint256 amount) public virtual;
  function CollectRewards(address delegatorAddress) public virtual;
}

contract StakingPrecompiles {
  function _delegate(address validatorAddress, uint256 amount) internal returns (uint256 result) {
    bytes memory encodedInput = abi.encodeWithSelector(StakingPrecompilesSelectors.Delegate.selector,
                                    msg.sender,
                                    validatorAddress,
                                    amount);
    assembly {
      // estimated gas consumption of 25k per precompile
      result := delegatecall(25000,
        0xfc,

        add(encodedInput, 32),
        mload(encodedInput),
        mload(0x40),
        0x20
      )
    }
  }

  function _undelegate(address validatorAddress, uint256 amount) internal returns (uint256 result) {
    bytes memory encodedInput = abi.encodeWithSelector(StakingPrecompilesSelectors.Undelegate.selector,
                                    msg.sender,
                                    validatorAddress,
                                    amount);
    assembly {
      // estimated gas consumption of 25k per precompile
      result := delegatecall(25000,
        0xfc,

        add(encodedInput, 32),
        mload(encodedInput),
        mload(0x40),
        0x20
      )
    }
  }

  function _collectRewards() internal returns (uint256 result) {
    bytes memory encodedInput = abi.encodeWithSelector(StakingPrecompilesSelectors.CollectRewards.selector,
                                    msg.sender);
    assembly {
      // estimated gas consumption of 25k per precompile
      result := delegatecall(25000,
        0xfc,

        add(encodedInput, 32),
        mload(encodedInput),
        mload(0x40),
        0x20
      )
    }
  }
}

// user facing contract "Delegator"

contract Delegator is StakingPrecompiles {

    event StakingPrecompileCalled(uint8 directive, bool success);

    function delegate(address validatorAddress, uint256 amount) public returns (bool success) {
        uint256 result = _delegate(validatorAddress, amount);
        success = result != 0;
        emit StakingPrecompileCalled(uint8(Directive.DELEGATE), success);
    }

    function undelegate(address validatorAddress, uint256 amount) public returns (bool success) {
        uint256 result = _undelegate(validatorAddress, amount);
        success = result != 0;
        emit StakingPrecompileCalled(uint8(Directive.UNDELEGATE), success);
    }

    function collectRewards() public returns (bool success) {
        uint256 result = _collectRewards();
        success = result != 0;
        emit StakingPrecompileCalled(uint8(Directive.COLLECT_REWARDS), success);
    }
}
