import assert from "node:assert/strict";
import {describe, it} from "node:test";
import time from "@nomicfoundation/hardhat-network-helpers";

import {network} from "hardhat";

describe("TokenVesting", async function () {
   const {viem, networkHelpers} = await network.create();

   // продвинуть время на 91 день вперёд
   //await networkHelpers.time.increase(91 * 24 * 60 * 60);

   it("деплоится корректно", async function () {
      const [owner, addr1] = await viem.getWalletClients();

      const token = await viem.deployContract("MyToken");

      const vesting = await viem.deployContract("TokenVesting", [
         token.address, // адрес token — какое у контракта token есть свойство для его адреса?
         addr1.account.address, // beneficiary
         12_000n * 10n ** 18n, // totalAmount
         90n * 24n * 60n * 60n, // cliff в секундах (90 дней)
         365n * 24n * 60n * 60n, // vestingDuration в секундах (год)
      ]);
      const beneficiary = await vesting.read.beneficiary();
      assert.equal(
         beneficiary.toUpperCase(),
         addr1.account.address.toUpperCase(),
      );
   });
});
