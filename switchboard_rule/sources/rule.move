module switchboard_rule::rule {

  use std::type_name;
  use x_oracle::x_oracle::{ Self, XOraclePriceUpdateRequest };
  use x_oracle::price_feed;
  use switchboard_std::aggregator::{Self, Aggregator};
  use switchboard_std::math as switchboard_math;
  use switchboard_rule::switchboard_registry::{Self, SwitchboardRegistry};

  struct Rule has drop {}

  public fun set_price<T>(
    request: XOraclePriceUpdateRequest<T>,
    price: u64,
    last_updated: u64,
  ) {
    let price_feed = price_feed::new(price, last_updated);
    x_oracle::set_secondary_price(Rule {}, request, price_feed);
  }

  fun get_price_from_aggregator<CoinType>(
    aggregator: &Aggregator,
    registry: &SwitchboardRegistry,
  ) {
    let coin_type = type_name::get<CoinType>();
    switchboard_registry::assert_aggregator(registry, coin_type, aggregator);
    let (price, timestamp) = aggregator::latest_value(aggregator);

    let (result, scale_factor, negative) = switchboard_math::unpack(price);
    // TODO: check the negative flag, how to handle negative price?
    assert!(negative == false, SWITCHBOARD_PRICE_ERROR);

    let price_scale = result * (math::pow(10, PRICE_PRECISION) as u128) / (math::pow(10, scale_factor) as u128);
    assert!(price_scale <= U64_MAX, SWITCHBOARD_PRICE_ERROR);
  }
}
