// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Tokenomics is Ownable {
    uint public timeLock =  3 * 365 days;
    uint public start = block.timestamp;
    string[] public initMinters = ['initBurn', 'farm', 'stakeBox', 'ecoPartner', 'airdrop', 'pancakeList', '1stCex', '2ndCex', '3rdCex', 'binanceList'];
    string[] public initLockers = ['futureInvester', 'team', 'marketing'];
    uint[] public initMintersPercent = [100, 60, 100, 40, 10, 100, 100, 100, 140, 50];
    uint[] public initLockersPercent = [60, 70, 70];
    mapping(string => address) public minterAddress;
    mapping(string => address) public lockerAddress;
    mapping(address => uint) public lockerAmount;

    modifier onlyLocker() {
        bool flag;
        for(uint i = 0; i < initLockers.length; i++) {
            if(lockerAddress[initLockers[i]] == _msgSender()) {
                flag == true;
                break;
            }
        }
        require(flag, 'Tokenomics: caller is not the locker');
        _;
    }
    event Init (IERC20 _erc20, uint _amount);
    event Unlock(IERC20 _erc20, address _locker);

    constructor() {
        minterAddress['initBurn'] = 0x88723F606b78A2d98dD51d2AE197cd408D850444;
        minterAddress['farm'] = 0x14CAA5833b4F4d7adfA0b9bcdfD79807d5ee47a2;
        minterAddress['stakeBox'] = 0x8e56574ce6415c8AbAde8470649cdE6003884843;
        minterAddress['ecoPartner'] = 0x7b16ae811f7fb886C650154A4C08694D502D9954;
        minterAddress['airdrop'] = 0xBbDc15d3400CE9CBF4E0683aE72f87EE083Cc900;
        minterAddress['pancakeList'] = 0x1939F114f3D6775d3269125a39d9996C053E3aF7;
        minterAddress['1stCex'] = 0x03EFc9007bD5360d63623e6fdd3b9865842C27ad;
        minterAddress['2ndCex'] = 0x0da6b3f46b2fb3755E3a639898fF333635E5a046;
        minterAddress['3rdCex'] = 0xbE118f252F7c584d894d969E7062E1d986B3090a;
        minterAddress['binanceList'] = 0x8E3d703588707eb77cf6aE4f8959A0B560A4Aed8;

        lockerAddress['futureInvester'] = 0x43a77A02D23BEc1Fdc95CfE4E7E7729a1a44a497;
        lockerAddress['team'] = 0xeEbe5416F98eb7c611740dB492B606913990947e;
        lockerAddress['marketing'] = 0x0e0c3240dd07667Ae80E69B77CaCD6Db928B75A5;
    }
    function init(IERC20 _erc20, uint _amount) public {

        for(uint i = 0; i < initMintersPercent.length; i++){
            uint _total = _amount * initMintersPercent[i] / 1000;
            _erc20.transferFrom(_msgSender(), minterAddress[initMinters[i]], _total);
        }
        for(uint i = 0; i < initLockersPercent.length; i++){
            uint _total = _amount * initLockersPercent[i] / 1000;
            lockerAmount[lockerAddress[initLockers[i]]] = _total;
            _erc20.transferFrom(_msgSender(), address(this), _total);
        }
        emit Init(_erc20, _amount);
    }
    function unlock(IERC20 _erc20) public onlyLocker{
        require(block.timestamp - start >= timeLock, 'Tokenomics: no meet lock time');
        _erc20.transfer(_msgSender(), lockerAmount[_msgSender()]);
        emit Unlock(_erc20, _msgSender());
    }
    function getInitLockers() public view returns(string[] memory){
        return initLockers;
    }
    function getInitLockersPercent() public view returns(uint[] memory){
        return initLockersPercent;
    }
    function getInitMinters() public view returns(string[] memory){
        return initMinters;
    }
    function getInitMintersPercent() public view returns(uint[] memory){
        return initMintersPercent;
    }

    function getChainId() internal view returns (uint) {
        uint256 chainId;
        assembly {chainId := chainid()}
        return chainId;
    }
}