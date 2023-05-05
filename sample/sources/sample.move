module sample::sample {

  use x_oracle::x_oracle::{Self, XOracle, XOraclePolicyCap};
  use switchboard_rule::switchboard_rule::Rule as SwitchboardRule;

  public entry fun add_switchboard_rule(
    x_oracle: &mut XOracle,
    cap: &XOraclePolicyCap,
  ) {
    x_oracle::add_secondary_price_update_rule<SwitchboardRule>(x_oracle, cap);
  }
}
