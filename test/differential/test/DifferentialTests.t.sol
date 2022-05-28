pragma solidity 0.8.13;

import "forge-std/Test.sol";

import "../../../contracts/Gaussian.sol";

contract DifferentialTests is Test {
    enum DifferentialFunctions {
        erfc
    }

    string internal constant DATA_DIR = "test/differential/data/";
    int256 internal constant EPSILON = 1e3;

    int256[129] _inputs;
    int256[129] _outputs;

    function setUp() public {
        generate();
    }

    function generate() public {
        // Run the reference implementation in javascript
        string[] memory runJsInputs = new string[](6);
        runJsInputs[0] = "npm";
        runJsInputs[1] = "--prefix";
        runJsInputs[2] = "differential/scripts/";
        runJsInputs[3] = "--silent";
        runJsInputs[4] = "run";
        runJsInputs[5] = "generate"; // Generates length 129 by default
        vm.ffi(runJsInputs);
    }

    function load(string memory key)
        public
        returns (int256[129] memory inputs, int256[129] memory outputs)
    {
        string[] memory cmds = new string[](2);
        // Get inputs.
        cmds[0] = "cat";
        cmds[1] = string(abi.encodePacked(DATA_DIR, key, "/input"));
        bytes memory result = vm.ffi(cmds);
        inputs = abi.decode(result, (int256[129]));
        _inputs = inputs;
        // Get outputs.
        cmds[0] = "cat";
        cmds[1] = string(abi.encodePacked(DATA_DIR, key, "/output"));
        result = vm.ffi(cmds);
        outputs = abi.decode(result, (int256[129]));
        _outputs = outputs;
    }

    function testDifferentialERFC() public {
        load("erfc");
        run(DifferentialFunctions.erfc);
    }

    function run(DifferentialFunctions fn) public {
        if (fn == DifferentialFunctions.erfc) {
            _run(Gaussian.erfc);
        }
    }

    function _run(function(int256) view returns (int256) method) internal {
        uint256 length = _inputs.length;
        for (uint256 i = 0; i < length; ++i) {
            int256 input = _inputs[i];
            int256 output = _outputs[i];
            int256 computed = method(input);
            assertEq(computed / EPSILON, output / EPSILON);
        }
    }
}
