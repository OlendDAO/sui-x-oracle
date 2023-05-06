module switchboard_rule::switchboard_registry {

  use std::type_name::{Self, TypeName};
  use sui::object::{Self, ID, UID};
  use sui::table::{Self, Table};
  use sui::tx_context::{Self, TxContext};
  use sui::transfer;
  use switchboard_std::aggregator::Aggregator;

  const SWITCHBOARD_AGGREGATOR_NOT_REGISTERED: u64 = 1;

  struct SwitchboardRegistryWit has drop {}

  struct SwitchboardRegistry has key {
    id: UID,
    table: Table<TypeName, ID>
  }

  struct SwitchboardRegistryCap has key, store {
    id: UID,
  }

  fun init(ctx: &mut TxContext) {
    let registry = SwitchboardRegistry {
      id: object::new(ctx),
      table: table::new(ctx),
    };
    let registry_cap = SwitchboardRegistryCap {
      id: object::new(ctx),
    };
    transfer::share_object(registry);
    transfer::transfer(registry_cap, tx_context::sender(ctx));
  }

  public entry fun register_aggregator<CoinType>(
    _: &SwitchboardRegistryCap,
    registry: &mut SwitchboardRegistry,
    aggregator: &Aggregator,
  ) {
    let coin_type = type_name::get<CoinType>();
    let aggregator_id = object::id(aggregator);
     table::add(&mut registry.table, coin_type, aggregator_id);
  }

  public fun get_aggregator_id(
    registry: &SwitchboardRegistry,
    coin_type: TypeName,
  ): ID {
    *table::borrow(&registry.table, coin_type)
  }

  public fun assert_aggregator(
    registry: &SwitchboardRegistry,
    coin_type: TypeName,
    aggregator: &Aggregator,
  ) {
    let aggregator_id = object::id(aggregator);

    let registry_aggregator_id = table::borrow(
      &registry.table,
      coin_type,
    );
    assert!(aggregator_id == *registry_aggregator_id, SWITCHBOARD_AGGREGATOR_NOT_REGISTERED);
  }
}
