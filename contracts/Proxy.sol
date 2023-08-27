// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @dev An abstract contract named "Proxy". An abstract contract cannot be deployed on its own; it's meant to be inherited by other contracts that provide concrete implementations for its abstract functions.
 */
abstract contract Proxy {
    
    /**
     * An internal virtual function named "_delegate". It takes an "implementation" address as an argument and returns a boolean "success" indicating whether the delegate call was successful.
     */
    function _delegate (address implementation) internal virtual returns (bool success) {
        
        // The "assembly" keyword is used to write inline assembly code. In Solidity, assembly allows low-level interaction with the Ethereum Virtual Machine (EVM).
        assembly {
            /**
             * @dev The calldatacopy function copies the data from the calldata into the contract's memory, starting from the specified location and storing the copied data at a specified memory location.
             * 
             * 'calldatacopy' is a function that instructs the contract to copy the data from the calldata.
             * The first parameter, 0, indicates that copying should start from the beginning (first page) of the memory.
             * The second parameter, also 0, indicates that the copied data should be stored on the first page of the memory.
             * calldatasize() specifies that all of the data in the calldata should be copied.
             */
            calldatacopy(0, 0, calldatasize())

            /**
             * @dev This line performs a delegate call to the "implementation" address using the gas remaining in the current call. The delegate call forwards the calldata and returns a boolean "success" indicating whether the call succeeded.
             * delegatecall(...): This is like sending a delegate to the implementation contract with specific instructions.
             * gas(): This specifies the budget (gas) you're providing for the implementation contract. It's like allocating resources for them to work with.
             * implementation: This is the address of the implementation contract where the task should be performed. It's like telling the delegate where to go.
             * 0: This represents where the instruction data starts in the memory. In this case, it's starting from the beginning (memory location 0).
             * calldatasize(): This tells the implementation contract how much instruction data to read from the memory. It's like indicating how much information they should work with.
             * The two 0s at the end: These indicate where the output data should be stored in memory. In this case, they start at memory location 0.
             */
            success := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)
            
            /**
             * @dev Think of this line as taking the result of the task that was delegated (using delegatecall) to another contract and copying that result from a special space in memory called "return data" to a more accessible location in the contract's memory.
             * 
             * 'returndatacopy' is a function that copies data from the "return data" memory, which holds the result of a function call, to the contract's regular memory.
             * The first parameter (0) specifies where to start copying the data in the contract's memory.
             * The second parameter (0) indicates where to start copying the data from the return data memory. It's usually 0 because you want to copy from the beginning.
             * returndatasize() determines how much data to copy. It's like saying, "Copy this much data from the return data."
             */
            returndatacopy(0,0,returndatasize())
            
            /**
             * @dev This is a switch statement that checks the value of "success". If the delegate call was unsuccessful (success = 0), it reverts the transaction with the returndata from the delegate call. If the delegate call was successful, it returns the returndata to the caller.
             */
            switch success
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    /**
     * @dev This declares an internal view virtual function named "_implementation". It's meant to be overridden by the inheriting contracts to provide the address of the current implementation logic.
     */
    function _implementation() internal view virtual returns (address);

    /**
     * This defines an internal virtual function named "_fallback". It internally calls the "_delegate" function using the address returned by "_implementation". This is used as a fallback mechanism when no other function matches the called function signature.
     */
    function _fallback() internal virtual {
        _delegate(_implementation());
    }

    /**
     * This defines an external payable fallback function that delegates to the "_fallback" function. It allows the contract to receive Ether and handle calls that don't match any other function.
     */
    fallback() external payable virtual {
        _fallback();
    }
}