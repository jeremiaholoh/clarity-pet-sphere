import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Can create and like posts",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    const wallet_2 = accounts.get("wallet_2")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("posts", "create-post", [
        types.utf8("My first post about my pet!"),
        types.none()
      ], wallet_1.address)
    ]);
    
    assertEquals(block.receipts.length, 1);
    assertEquals(block.height, 2);
    assertEquals(block.receipts[0].result.expectOk(), true);

    block = chain.mineBlock([
      Tx.contractCall("posts", "like-post", [
        types.uint(1)
      ], wallet_2.address)
    ]);

    assertEquals(block.receipts[0].result.expectOk(), true);

    let hasLiked = chain.callReadOnlyFn(
      "posts",
      "has-liked",
      [types.uint(1), types.principal(wallet_2.address)],
      wallet_2.address
    );

    assertEquals(hasLiked.result, types.bool(true));
  },
});
