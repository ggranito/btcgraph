# CoinPrices schema
 
# --- !Ups
 
CREATE TABLE coin_prices (
    id SERIAL PRIMARY KEY,
    recorded_at timestamp NOT NULL,
    btc double precision NOT NULL,
    mcx double precision NOT NULL,
    msc double precision NOT NULL,
    btb double precision NOT NULL,
    ltc double precision NOT NULL,
    uno double precision NOT NULL,
    pts double precision NOT NULL,
    nvc double precision NOT NULL,
    btg double precision NOT NULL
);

# --- !Downs
drop table if exists coin_prices;