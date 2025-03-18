module switchboard_rule::switchboard_registry {

  use sui::object;
  use sui::tx_context;
  use sui::transfer;
  use sui::table::{Self, Table};
  use std::type_name::{Self, TypeName};
  use switchboard::aggregator::Aggregator;

  const ERR_ILLEGAL_SWITCHBOARD_AGGREGATOR: u64 = 0;
  const ERR_ILLEGAL_REGISTRY_CAP: u64 = 1;

  public struct SwitchboardRegistry has key {
    id: object::UID,
    pairs: Table<object::ID, SwitchboardPair>,
    table: Table<TypeName, object::ID>
  }

  public struct SwitchboardRegistryCap has key, store {
    id: object::UID,
    for_registry: object::ID
  }

  public struct SwitchboardPair has key, store {
    id: object::UID,
    pair_name: vector<u8>,
    aggregator: object::ID,
    decimals: u8,
  }

  fun init(ctx: &mut tx_context::TxContext) {
    let registry = SwitchboardRegistry {
      id: object::new(ctx),
      pairs: table::new<object::ID, SwitchboardPair>(ctx),
      table: table::new<TypeName, object::ID>(ctx)
    };

    let cap = SwitchboardRegistryCap {
      id: object::new(ctx),
      for_registry: object::id(&registry)
    };

    transfer::share_object(registry);
    transfer::transfer(cap, tx_context::sender(ctx));
  }

  public fun register_pair(
    _: &SwitchboardRegistryCap,
    registry: &mut SwitchboardRegistry,
    switchboard_aggregator: &Aggregator,
    pair_name: vector<u8>,
    decimals: u8,
    ctx: &mut tx_context::TxContext
  ) {
    let pair = SwitchboardPair {
      id: object::new(ctx),
      pair_name,
      aggregator: object::id(switchboard_aggregator),
      decimals
    };
    table::add(&mut registry.pairs, object::id(&pair), pair);
  }

  public fun get_pair(
    registry: &SwitchboardRegistry,
    switchboard_aggregator: &Aggregator,
  ): &SwitchboardPair {
    table::borrow(&registry.pairs, object::id(switchboard_aggregator))
  }

  public entry fun register_switchboard_aggregator<CoinType>(
    switchboard_registry: &mut SwitchboardRegistry,
    switchboard_registry_cap: &SwitchboardRegistryCap,
    switchboard_aggregator: &Aggregator,
  ) {
    assert!(object::id(switchboard_registry) == switchboard_registry_cap.for_registry, ERR_ILLEGAL_REGISTRY_CAP);
    let coin_type = type_name::get<CoinType>();
    if (table::contains(&switchboard_registry.table, coin_type)) {
      table::remove(&mut switchboard_registry.table, coin_type);
    };
    table::add(&mut switchboard_registry.table, coin_type, object::id(switchboard_aggregator));
  }

  public fun assert_switchboard_aggregator<CoinType>(
    switchboard_registry: &SwitchboardRegistry,
    switchboard_aggregator: &Aggregator,
  ) {
    let coin_type = type_name::get<CoinType>();
    let coin_aggregator_id = table::borrow(&switchboard_registry.table, coin_type);
    assert!(object::id(switchboard_aggregator) == *coin_aggregator_id, ERR_ILLEGAL_SWITCHBOARD_AGGREGATOR);
  }
}
