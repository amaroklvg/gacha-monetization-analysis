# Data dictionary — Gacha Monetization Dataset v2.1

The exported files are intentionally dirty and represent data available to an analyst. Psychological simulation parameters and precomputed payer segments are not exported. Empty strings represent controlled missing values.

## Relationships
- All facts link to `dim_users.user_id`.
- Banner-related facts link to `dim_banners.banner_id`. Blank banner IDs are allowed for currency sources unrelated to a banner.
- `fact_purchases.item_id` links to `dim_shop_items.item_id`.
- `dim_banners.character_name` and nonblank `fact_pulls.character_obtained` link to `dim_characters.character_name`. The standard banner intentionally has no featured character.

## Tables
### dim_users
`user_id` user key; `registration_date` account creation date; `country` ISO-like market code; `platform` client platform; `acquisition_channel` acquisition source.

### dim_banners
Banner identity, featured character (blank for standard), type, and availability dates.

### dim_characters
Character attributes supplied by the project owner. `power_score` is an in-game strength score, not a behavioral label.

### dim_shop_items
Shop SKU, display name, USD list price, and premium currency granted.

### fact_logins
One row per active user-day: date, session minutes/count, and banner active that day.

### fact_pulls
One row per pull. `pity_before/after` describe the five-star pity counter; `won_5050` is blank for non-five-star pulls; `pull_phase` is Launch, Mid Banner, or Last Days.

### fact_purchases
One row per purchase. `purchase_number` is chronological per user in the clean underlying simulation; trigger is an observable event context, not a psychological trait.

### fact_currency
Premium-currency ledger. `direction` is source or sink; `amount` is stored as a positive magnitude; `category` explains the flow.

## Intended analyses
ARPU, ARPPU, payer conversion, observed LTV, time to first purchase, repeat purchase rate, whale concentration derived from spend, DAU/MAU, D1/D7/D30 retention, post-loss purchase behavior, pity-triggered conversion, sink-to-source ratio, banner phase, character, role, and visual-archetype performance.


## Version 2.0 additions

### dim_staff
Fictional staff and artists. Department and seniority are administrative HR attributes; no hidden talent or performance score is exported.

### bridge_character_staff
Many-to-many assignment of staff to characters, with observable work dates, contribution role, and allocated project cost.

### dim_character_campaigns
Character-specific marketing campaigns with dates, primary channel, and campaign cost.

### fact_purchases version note
`purchase_trigger` and `purchase_phase` are not exported. Banner phase and possible behavioral context must be derived analytically from timestamps.
