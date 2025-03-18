module switchboard_rule::switchboard_adaptor {
  use sui::object;
  use switchboard::aggregator::{Self, Aggregator};
  use switchboard::decimal;

  public fun get_switchboard_price(
    aggregator: &Aggregator,
  ): (u128, u8, u64) {
    let current_result = aggregator::current_result(aggregator);
    let result = aggregator::result(current_result);
    let (value, negative) = decimal::unpack(*result);
    assert!(!negative, 0);
    (value, 9, aggregator::timestamp_ms(current_result))
  }
}
