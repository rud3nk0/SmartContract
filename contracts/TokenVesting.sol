// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
// импортируем готовые, проверенные аудитами реализации от OpenZeppelin
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract TokenVesting {
    IERC20 public token;          // ссылка на контракт MyToken — чтобы вызывать transfer
    address public beneficiary;   // кто получит токены
    uint256 public totalAmount;   // сколько всего причитается
    uint256 public startTime;     // когда начался отсчёт (момент деплоя)
    uint256 public cliff;         // через сколько секунд после startTime открывается первая выдача
    uint256 public vestingDuration; // общий срок вестинга (в секундах)
    uint256 public claimedAmount; // сколько уже забрано (изначально 0)

    constructor(
        address _token,
        address _beneficiary,
        uint256 _totalAmount,
        uint256 _cliffDuration,
        uint256 _vestingDuration
    ) {
        token = IERC20(_token);
        beneficiary = _beneficiary;
        totalAmount = _totalAmount;
        startTime = block.timestamp;
        cliff = _cliffDuration;
        vestingDuration = _vestingDuration;
    }

    function vestedAmount() public view returns (uint256) {
    uint256 elapsedTime = block.timestamp - startTime;

    if (elapsedTime < cliff) {
            return 0;              
        } else if (elapsedTime >= vestingDuration) {
            return totalAmount;              
        } else {
            return (totalAmount * elapsedTime / vestingDuration);   // подсказка: формула пропорции, которую мы считали на примере 12_000 * 91 / 365
    }
    }
}