import assert from "node:assert/strict";
import {describe, it} from "node:test";

import {network} from "hardhat";

describe("MyToken", async function () {
   const {viem} = await network.create();

   it("владелец получает начальные 100,000 токенов при деплое", async function () {
      const [owner] = await viem.getWalletClients();
      const token = await viem.deployContract("MyToken");

      const balance = await token.read.balanceOf([owner.account.address]);
      assert.equal(balance, 100_000n * 10n ** 18n);
   });

   it("owner может заминтить новые токены", async function () {
      const [owner, addr1] = await viem.getWalletClients();
      const token = await viem.deployContract("MyToken");

      await token.write.mint([addr1.account.address, 500n * 10n ** 18n], {
         account: owner.account,
      });

      const balance = await token.read.balanceOf([addr1.account.address]);
      assert.equal(balance, 500n * 10n ** 18n);

      const treasuryBalance = await token.read.balanceOf([token.address]);
      assert.equal(treasuryBalance, 0n);
   });

   it("НЕ owner не может минтить — должно упасть с ошибкой", async function () {
      const [, addr1] = await viem.getWalletClients();
      const token = await viem.deployContract("MyToken");

      await assert.rejects(
         token.write.mint([addr1.account.address, 500n * 10n ** 18n], {
            account: addr1.account,
         }),
      );
   });

   it("нельзя заминтить больше MAX_SUPPLY", async function () {
      const [owner] = await viem.getWalletClients();
      const token = await viem.deployContract("MyToken");

      const tooMuch = 2_000_000n * 10n ** 18n;
      await assert.rejects(
         token.write.mint([owner.account.address, tooMuch], {
            account: owner.account,
         }),
      );
   });

   it("пользователь может сжечь свои токены", async function () {
      const [owner] = await viem.getWalletClients();
      const token = await viem.deployContract("MyToken");

      await token.write.burn([1_000n * 10n ** 18n], {account: owner.account});

      const balance = await token.read.balanceOf([owner.account.address]);
      assert.equal(balance, 99_000n * 10n ** 18n);

      const treasuryBalance = await token.read.balanceOf([token.address]);
      assert.equal(treasuryBalance, 0n);
   });

   it("при transfer удерживается 1% комиссии", async function () {
      const [owner, addr1] = await viem.getWalletClients();
      const token = await viem.deployContract("MyToken");

      const transferAmount = 1_000n * 10n ** 18n;

      await token.write.transfer([addr1.account.address, transferAmount], {
         account: owner.account,
      });

      const recipientBalance = await token.read.balanceOf([
         addr1.account.address,
      ]);
      const treasuryBalance = await token.read.balanceOf([token.address]);
      const ownerBalance = await token.read.balanceOf([owner.account.address]);

      assert.equal(recipientBalance, 990n * 10n ** 18n); // получил 99%
      assert.equal(treasuryBalance, 10n * 10n ** 18n); // казна получила 1%
      assert.equal(ownerBalance, 99_000n * 10n ** 18n); // у owner списалось ровно 1000, не больше
   });
});
