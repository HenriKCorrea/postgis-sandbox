---------------------------------------------
-- Table creation
---------------------------------------------
-- Create a table matching the CSV structure
DROP TABLE IF EXISTS nyc_pole_location CASCADE;
CREATE TABLE nyc_pole_location (
    id SERIAL PRIMARY KEY,
    latitude FLOAT,
    longitude FLOAT,
    on_street TEXT,
    zipcode TEXT,
    installation_date TIMESTAMP
);
---------------------------------------------
-- Schema constraints and indexes
---------------------------------------------
-- Ensure latitude and longitude are not null
ALTER TABLE nyc_pole_location
ALTER COLUMN latitude
SET NOT NULL,
    ALTER COLUMN longitude
SET NOT NULL;
-- Ensure zipcode is not null and follows a basic US ZIP code format
ALTER TABLE nyc_pole_location
ALTER COLUMN zipcode
SET NOT NULL;
ALTER TABLE nyc_pole_location
ADD CONSTRAINT check_zipcode_format CHECK (zipcode ~ '^\d{5}(-\d{4})?$');
-- Ensure on_street is not null and not empty
ALTER TABLE nyc_pole_location
ALTER COLUMN on_street
SET NOT NULL;
ALTER TABLE nyc_pole_location
ADD CONSTRAINT check_on_street_not_empty CHECK (on_street <> '');
-- Ensure installation_date is not in the future
ALTER TABLE nyc_pole_location
ADD CONSTRAINT check_installation_date_not_future CHECK (installation_date <= NOW());
-- Optional: Create a composite index for faster lookups by location
CREATE INDEX idx_nyc_pole_location_lat_lon ON nyc_pole_location (latitude, longitude);
---------------------------------------------
-- Trigger for notifications
---------------------------------------------
-- Trigger function to notify changes for external subscribers
-- This function will be called whenever there is an INSERT, UPDATE, or DELETE on the table.
CREATE OR REPLACE FUNCTION notify_nyc_pole_location() RETURNS TRIGGER AS $$ BEGIN PERFORM pg_notify('qgis', TG_OP);
-- TG_OP is the operation type: INSERT, UPDATE, DELETE
RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- Trigger to call the function on INSERT, UPDATE, DELETE
CREATE TRIGGER trg_notify_nyc_pole_location
AFTER
INSERT
    OR
UPDATE
    OR DELETE ON nyc_pole_location FOR EACH STATEMENT EXECUTE FUNCTION notify_nyc_pole_location();
---------------------------------------------
-- Table population
---------------------------------------------
---- Import CSV directly from URL
---- COPY nyc_pole_location
---- FROM PROGRAM 'curl -s "https://data.cityofnewyork.us/resource/tbgj-tdd6.csv?$query=SELECT%0A%20%20%60id%60%2C%0A%20%20%60latitude%60%2C%0A%20%20%60longitude%60%2C%0A%20%20%60on_street%60%2C%0A%20%20%60zipcode%60%2C%0A%20%20%60installation_date%60%0AWHERE%0A%20%20caseless_one_of(%60status%60%2C%20%22Installed%22)%0A%20%20AND%20caseless_one_of(%60borough%60%2C%20%22Manhattan%22)"'
---- WITH (FORMAT csv, HEADER true, DELIMITER ',');