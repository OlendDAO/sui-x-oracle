/// Fetch price feed VAAs of interest from the Pyth
/// price feed service.
import { HermesClient } from "@pythnetwork/hermes-client";

// 定义 HermesClient 返回的数据结构
interface HermesResponse {
  binary: {
    data: string[];
    encoding: "hex" | "base64";
  };
  parsed?: any; // 如果 parsed 参数设置为 true，则会包含解析后的价格数据
}

export const getVaas = async (priceIds: string[]) => {
  const client = new HermesClient("https://xc-testnet.pyth.network");
  const priceUpdates = await client.getLatestPriceUpdates(priceIds, {
    encoding: "base64",
    parsed: false
  }) as unknown as HermesResponse;
  
  // 返回 VAAs 数组，与原来的接口保持一致
  return priceUpdates.binary.data;
}
