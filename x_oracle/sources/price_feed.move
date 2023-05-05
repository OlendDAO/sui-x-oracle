module x_oracle::price_feed {

  struct PriceFeed has store, copy, drop {
    value: u128,
    decimals: u8,
    last_updated: u64,
  }

  public fun new(
    value: u128,
    decimals: u8,
    last_updated: u64
  ): PriceFeed {
    PriceFeed { value, decimals, last_updated }
  }

  public fun value(self: &PriceFeed): u128 { self.value }
  public fun decimals(self: &PriceFeed): u8 { self.decimals }
  public fun last_updated(self: &PriceFeed): u64 { self.last_updated }
}
