import { SUI_CLOCK_OBJECT_ID } from "@mysten/sui/utils"
import { Transaction } from "@mysten/sui/transactions"
import { suiClient, keypair } from "../../ts-scripts/sui-kit"
import { getVaas } from "./get-vaas"

const pkgId = '0x011dc5ab7c7172c991d5d39978cb3c31b84dcb926fd2401a094992b65adae94d';

const warmholeStateId = '0x79ab4d569f7eb1efdcc1f25b532f8593cda84776206772e33b490694cb8fc07a';
const pythStateId = '0xe96526143f8305830a103331151d46063339f7a9946b50aaa0d704c8c04173e5';
const pythPriceInfoObjectId = '0x8899a5649db0099f3a685cf246ed2bd4224bc2078fcaf2c897268764df684d94';

const pythPriceId = 'f9c0172ba10dfa4d19088d94f5bf61d3b54d5bd7483a322a982e1373ee8ea31b';

(async () => {

  const vaaStart = Math.floor(Date.now() / 1000);
  const [vaa] = await getVaas([pythPriceId]);
  const vaaEnd = Math.floor(Date.now() / 1000);
  console.log(`getVaas took ${vaaEnd - vaaStart} seconds`);

  const tx = new Transaction();
  // 分割 SUI 代币作为手续费
  const [coin] = tx.splitCoins(tx.gas, [tx.pure.u64(1)]);
  
  // 调用 Move 函数
  tx.moveCall({
    target: `${pkgId}::test_pyth::get_pyth_price`,
    arguments: [
      tx.object(warmholeStateId),
      tx.object(pythStateId),
      tx.object(pythPriceInfoObjectId),
      coin,
      tx.pure(new Uint8Array(Buffer.from(vaa, "base64"))),
      tx.object(SUI_CLOCK_OBJECT_ID)
    ]
  });
  
  // 设置 Gas 预算
  tx.setGasBudget(10 ** 8);
  
  let start = Math.floor(Date.now() / 1000);
  const res = await suiClient.signAndExecuteTransaction({
    transaction: tx,
    signer: keypair,
    requestType: "WaitForLocalExecution",
    options: {
      showEffects: true,
      showEvents: true,
    },
  });
  console.log(res);
  let end = Math.floor(Date.now() / 1000);
  console.log(`Time elapsed: ${end - start} seconds`);

  // const res: any = await suiKit.signAndSendTxn(suiTxBlock);
  // console.log(res.events[1])
})();
