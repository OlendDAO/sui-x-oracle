module x_oracle_v2::price_update_policy {

  use std::type_name::{Self, TypeName};
  use std::vector::{Self as vector};
  use sui::object::{Self, ID, UID};
  use sui::tx_context::TxContext;
  use sui::vec_set::{Self, VecSet};

  use x_oracle_v2::price_feed::PriceFeed;

  const REQUIRE_ALL_RULES_FOLLOWED: u64 = 0;
  const REQUST_NOT_FOR_THIS_POLICY: u64 = 1;
  const WRONG_POLICY_CAP: u64 = 2;

  public struct PriceUpdateRequest<phantom T> {
    for_policy: ID,
    receipts: VecSet<TypeName>,
    price_feeds: vector<PriceFeed>,
  }

  public struct PriceUpdatePolicy has key, store {
    id: UID,
    rules: VecSet<TypeName>,
  }

  public struct PriceUpdatePolicyCap has key, store {
    id: UID,
    for_policy: ID,
  }

  public fun new(ctx: &mut TxContext): (PriceUpdatePolicy, PriceUpdatePolicyCap) {
    let policy = PriceUpdatePolicy {
      id: object::new(ctx),
      rules: vec_set::empty(),
    };
    let cap = PriceUpdatePolicyCap {
      id: object::new(ctx),
      for_policy: object::id(&policy),
    };
    (policy, cap)
  }

  public fun new_request<T>(policy: &PriceUpdatePolicy): PriceUpdateRequest<T> {
    PriceUpdateRequest {
      for_policy: object::id(policy),
      receipts: vec_set::empty(),
      price_feeds: vector::empty(),
    }
  }

  public fun add_rule<Rule>(
    policy: &mut PriceUpdatePolicy,
    cap: &PriceUpdatePolicyCap,
  ) {
    assert!(object::id(policy) == cap.for_policy, WRONG_POLICY_CAP);
    vec_set::insert(&mut policy.rules, type_name::get<Rule>());
  }

  public fun add_price_feed<CoinType, Rule: drop>(
    _rule: Rule,
    request: &mut PriceUpdateRequest<CoinType>,
    feed: PriceFeed,
  ) {
    vec_set::insert(&mut request.receipts, type_name::get<Rule>());
    vector::push_back(&mut request.price_feeds, feed);
  }

  public fun confirm_request<CoinType>(request: PriceUpdateRequest<CoinType>, policy: &PriceUpdatePolicy): vector<PriceFeed> {
    let PriceUpdateRequest { receipts, for_policy, price_feeds } = request;
    assert!(for_policy == object::id(policy), REQUST_NOT_FOR_THIS_POLICY);

    let mut receipts = vec_set::into_keys(receipts);
    let completed = vector::length(&receipts);
    assert!(completed == vec_set::size(&policy.rules), REQUIRE_ALL_RULES_FOLLOWED);
    let mut i = 0;
    while(i < completed) {
      let receipt = vector::pop_back(&mut receipts);
      assert!(vec_set::contains(&policy.rules, &receipt), REQUIRE_ALL_RULES_FOLLOWED);
      i = i + 1;
    };
    price_feeds
  }
}
