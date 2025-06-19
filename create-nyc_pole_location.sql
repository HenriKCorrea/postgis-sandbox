-- Create a table matching the CSV structure
DROP TABLE IF EXISTS nyc_pole_location;
CREATE TABLE nyc_pole_location (
    id SERIAL PRIMARY KEY,
    latitude FLOAT,
    longitude FLOAT,
    on_street TEXT,
    zipcode TEXT,
    installation_date TIMESTAMP
);
-- Import CSV directly from URL
-- COPY nyc_pole_location
-- FROM PROGRAM 'curl -s "https://data.cityofnewyork.us/resource/tbgj-tdd6.csv?$query=SELECT%0A%20%20%60id%60%2C%0A%20%20%60latitude%60%2C%0A%20%20%60longitude%60%2C%0A%20%20%60on_street%60%2C%0A%20%20%60zipcode%60%2C%0A%20%20%60installation_date%60%0AWHERE%0A%20%20caseless_one_of(%60status%60%2C%20%22Installed%22)%0A%20%20AND%20caseless_one_of(%60borough%60%2C%20%22Manhattan%22)"'
-- WITH (FORMAT csv, HEADER true, DELIMITER ',');