// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// импортируем готовые, проверенные аудитами реализации от OpenZeppelin
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// наследуемся сразу от двух контрактов — ERC20 (вся логика токена)
// и Ownable (концепция владельца, которую мы раньше писали руками через modifier)
contract MyToken is ERC20, Ownable {

    // максимальный supply — сколько токенов вообще может существовать
    uint256 public constant MAX_SUPPLY = 1_000_000 * 10 ** 18;
    // умножаем на 10**18, потому что у ERC-20 обычно 18 decimals (как wei у ETH)

    // constructor вызывается один раз при деплое
    // ERC20("Name", "SYMBOL") — задаёт имя и тикер токена
    // Ownable(msg.sender) — деплоер становится владельцем
    constructor() ERC20("MyToken", "MTK") Ownable(msg.sender) {
        // сразу минтим (создаём) часть токенов себе при деплое
        _mint(msg.sender, 100_000 * 10 ** 18);
    }

    // mint — создание новых токенов "из воздуха"
    // onlyOwner — модификатор из Ownable, аналог нашего onlyOwner в Counter
    function mint(address to, uint256 amount) external onlyOwner {
        // защита от бесконечной эмиссии — то, чего нет в дефолтном ERC20
        require(totalSupply() + amount <= MAX_SUPPLY, "Exceeds max supply");
        _mint(to, amount);
    }

    // burn — сжигание токенов. Любой может сжечь СВОИ токены (не чужие)
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }


//функция которая берет 1% комиссии с каждого перевода токенов, кроме mint и burn
   uint256 fee = 1; // state variable, объявлена ВНЕ функции _update

    function _update(address from, address to, uint256 amount) internal override {
        if (from != address(0) && to != address(0)) {
            // обычный transfer — тут удерживаем комиссию
            uint256 feeAmount = amount * fee / 100;
            super._update(from, to, amount - feeAmount);
            super._update(from, address(this), feeAmount);
        } else {
            // mint или burn — комиссию НЕ берём, просто пропускаем как есть
            super._update(from, to, amount);
        }
    }
}

