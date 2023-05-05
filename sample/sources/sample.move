module sample::sample {

  use x_oracle::x_oracle::{Self, XOracle, XOraclePolicyCap};
  use switchboard_rule::rule::Rule as SwitchboardRule;
  use pyth_rule::rule::Rule as PythRule;
  use supra_rule::rule::Rule as SupraRule;

  public entry fun add_switchboard_rule(
    x_oracle: &mut XOracle,
    cap: &XOraclePolicyCap,
  ) {
    x_oracle::add_primary_price_update_rule<PythRule>(x_oracle, cap);
    x_oracle::add_secondary_price_update_rule<SupraRule>(x_oracle, cap);
    x_oracle::add_secondary_price_update_rule<SwitchboardRule>(x_oracle, cap);
  }
}
