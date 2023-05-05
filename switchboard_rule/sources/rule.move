module switchboard_rule::rule {

  use x_oracle::x_oracle::{ Self, XOraclePriceUpdateRequest };
  use x_oracle::price_feed;

  struct Rule has drop {}

  public fun set_price<T>(
    request: XOraclePriceUpdateRequest<T>,
    price: u64,
    last_updated: u64,
  ) {
    let price_feed = price_feed::new(price, last_updated);
    x_oracle::set_secondary_price(Rule {}, request, price_feed);
  }
}
