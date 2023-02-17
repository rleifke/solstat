// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "forge-std/Test.sol";

import {Gaussian} from "../Gaussian.sol";

contract TestPpf is Test {
    function testDiff_ppf(int256 x) public {
        vm.assume(x > 0.0000001 ether);
        vm.assume(x < 1 ether);
        string[] memory inputs = new string[](3);
        inputs[0] = "./gaussian";
        inputs[1] = "ppf";
        inputs[2] = vm.toString(x);
        bytes memory res = vm.ffi(inputs);
        int256 ref = abi.decode(res, (int256));
        int256 y = Gaussian.ppf(x);
        // Results have a 0.000000500210885734% difference
        assertApproxEqAbs(ref, y, 500210885734);
    }
}
