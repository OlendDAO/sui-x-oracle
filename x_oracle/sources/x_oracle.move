module x_oracle::x_oracle {
  use std::type_name::{TypeName, get};
  use sui::object::{Self, UID};
  use sui::table::{Self, Table};
  use sui::tx_context::TxContext;

  use x_oracle::price_update_policy::{Self, PriceUpdatePolicy, PriceUpdateRequest};
  use x_oracle::price_feed::{Self, PriceFeed};
  use std::vector;
  use sui::math;

  const PRIMARY_PRICE_NOT_QUALIFIED: u64 = 0;

  struct XOracle has key {
    id: UID,
    primary_price_update_policy: PriceUpdatePolicy,
    secondary_price_update_policy: PriceUpdatePolicy,
    prices: Table<TypeName, PriceFeed>,
    twap_prices: Table<TypeName, PriceFeed>,
  }

  struct XOracleUpdateRequest<phantom T> {
    primary_price_update_request: PriceUpdateRequest<T>,
    secondary_price_update_request: PriceUpdateRequest<T>,
  }

  public fun prices(self: &XOracle): &Table<TypeName, PriceFeed> { &self.prices }
  public fun twap_prices(self: &XOracle): &Table<TypeName, PriceFeed> { &self.twap_prices }

  public fun new(ctx: &mut TxContext): XOracle {
    let x_oracle = XOracle {
      id: object::new(ctx),
      primary_price_update_policy: price_update_policy::new(ctx),
      secondary_price_update_policy: price_update_policy::new(ctx),
      prices: table::new(ctx),
      twap_prices: table::new(ctx),
    };
    x_oracle
  }

  public fun price_update_request<T>(
    self: &XOracle,
  ): XOracleUpdateRequest<T> {
    let primary_price_update_request = price_update_policy::new_request<T>(&self.primary_price_update_policy);
    let secondary_price_update_request = price_update_policy::new_request<T>(&self.secondary_price_update_policy);
    XOracleUpdateRequest {
      primary_price_update_request,
      secondary_price_update_request,
    }
  }

  public fun set_primary_price<T, Rule: drop>(
    rule: Rule,
    request: XOracleUpdateRequest<T>,
    price_feed: PriceFeed,
  ) {
    price_update_policy::add_price_feed(rule, &mut request.primary_price_update_request, price_feed);
  }

  public fun set_secondary_price<T, Rule: drop>(
    rule: Rule,
    request: XOracleUpdateRequest<T>,
    price_feed: PriceFeed,
  ) {
    price_update_policy::add_price_feed(rule, &mut request.secondary_price_update_request, price_feed);
  }

  public fun confirm_price_update_request<T>(
    self: &mut XOracle,
    request: XOracleUpdateRequest<T>
  ) {
    let primary_price_feeds = price_update_policy::confirm_request(
      request.primary_price_update_request,
      &self.primary_price_update_policy
    );
    let secondary_price_feeds = price_update_policy::confirm_request(
      request.secondary_price_update_request,
      &self.secondary_price_update_policy
    );
    let current_price_feed = table::borrow_mut(&mut self.prices, get<T>());
    let price_feed = determine_price(primary_price_feeds, secondary_price_feeds);
    *current_price_feed = price_feed;

    let current_twap_price_feed = table::borrow_mut(&mut self.twap_prices, get<T>());
    let twap_price_feed = determine_twap_price(*current_twap_price_feed, price_feed);
    *current_twap_price_feed = twap_price_feed;
  }

  fun determine_price(
    primary_price_feeds: vector<PriceFeed>,
    secondary_price_feeds: vector<PriceFeed>,
  ): PriceFeed {
    // current we only have one primary price feed
    let primary_price_feed = vector::pop_back(&mut primary_price_feeds);
    let secondary_price_feed_num = vector::length(&secondary_price_feeds);

    // We require the primary price feed to be confirmed by at least half of the secondary price feeds
    let required_secondary_match_num = (secondary_price_feed_num + 1) / 2;
    let matched: u64 = 0;
    let i = 0;
    while (i < secondary_price_feed_num) {
      let secondary_price_feed = vector::pop_back(&mut secondary_price_feeds);
      if (price_feed_match(primary_price_feed, secondary_price_feed)) {
        matched == matched + 1;
      };
      i = i + 1;
    };
    assert!(matched >= required_secondary_match_num, PRIMARY_PRICE_NOT_QUALIFIED);

    // Use the primary price feed as the final price feed
    primary_price_feed
  }

  // Check if two price feeds are within a reasonable range
  // If price_feed1 is within 1% away from price_feed2, then they are considered to be matched
  fun price_feed_match(
    price_feed1: PriceFeed,
    price_feed2: PriceFeed,
  ): bool {
    let value1 = price_feed::value(&price_feed1);
    let decimals1 = price_feed::decimals(&price_feed1);
    let value2 = price_feed::value(&price_feed2);
    let decimals2 = price_feed::decimals(&price_feed2);
    let diff = if (decimals2 > decimals1) {
      (math::pow(10, decimals2 - decimals1 + 2) as u128) * value1 / value2
    } else {
      (math::pow(10, decimals1 - decimals2 + 2) as u128) * value2 / value1
    };
    let reasonable_diff = 1;
    diff <= 100 + reasonable_diff && diff >= 100 - reasonable_diff
  }

  // TODO: implement this
  fun determine_twap_price(
    prev_twap_price_feed: PriceFeed,
    new_price_feed: PriceFeed,
  ): PriceFeed {
    return new_price_feed
  }
}
