// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

abstract contract Proxy {
    
    function _delegate (address implementation) internal virtual returns (bool success) {
        assembly {
            calldatacopy(0, 0, calldatasize())
            success := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)
            returndatacopy(0,0,returndatasize())
            
            switch success
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    function _implementation() internal view virtual returns (address);

    function _fallback() internal virtual {
        _delegate(_implementation());
    }

    fallback() external payable virtual {
        _fallback();
    }
}