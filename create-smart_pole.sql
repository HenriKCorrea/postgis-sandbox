-- This script creates a new table smart_pole that extends the nyc_pole_location structure
-- by adding additional fields for air quality index and semaphore status.
-- It also ensures the PostGIS extension is enabled for spatial data handling.
---------------------------------------------
-- Table creation
---------------------------------------------
BEGIN;
-- Ensure the PostGIS extension is enabled
CREATE EXTENSION IF NOT EXISTS postgis;
-- Create smart_pole geometry table, extending nyc_pole_location structure
DROP TABLE IF EXISTS smart_pole;
CREATE TABLE smart_pole (
    id INT PRIMARY KEY,
    geom GEOMETRY(Point, 4326),
    on_street TEXT,
    zipcode TEXT,
    installation_date TIMESTAMP,
    air_quality_index INT,
    semaphore_status BOOLEAN
);
---------------------------------------------
-- Schema constraints and indexes
---------------------------------------------
-- Add spatial index for efficient querying
CREATE INDEX idx_smart_pole_geom ON smart_pole USING GIST (geom);
-- Add a foreign key constraint to ensure id references the nyc_pole_location table
ALTER TABLE smart_pole
ADD CONSTRAINT fk_nyc_pole_location_id FOREIGN KEY (id) REFERENCES nyc_pole_location (id) ON DELETE CASCADE;
-- Add a unique constraint on the geom column to prevent duplicate entries
ALTER TABLE smart_pole
ADD CONSTRAINT unique_geom UNIQUE (geom);
-- Add a check constraint to ensure installation_date is not in the future
ALTER TABLE smart_pole
ADD CONSTRAINT check_installation_date_not_future CHECK (installation_date <= NOW());
-- Add a check constraint to ensure zipcode is not null and follows a basic format
ALTER TABLE smart_pole
ADD CONSTRAINT check_zipcode_format CHECK (
        zipcode IS NOT NULL
        AND zipcode ~ '^\d{5}(-\d{4})?$'
    );
-- Add a check constraint to ensure on_street is not null and not empty
ALTER TABLE smart_pole
ADD CONSTRAINT check_on_street_not_empty CHECK (
        on_street IS NOT NULL
        AND on_street <> ''
    );
-- Add a check constraint to ensure geom is not null
ALTER TABLE smart_pole
ADD CONSTRAINT check_geom_not_null CHECK (geom IS NOT NULL);
-- Add a check constraint to ensure air_quality_index is null or within a reasonable range (0 to 500)
ALTER TABLE smart_pole
ADD CONSTRAINT check_air_quality_index_range CHECK (
        air_quality_index IS NULL
        OR (
            air_quality_index >= 0
            AND air_quality_index <= 500
        )
    );
-- Add a check constraint to ensure semaphore_status is null or boolean
ALTER TABLE smart_pole
ADD CONSTRAINT check_semaphore_status_null_or_boolean CHECK (
        semaphore_status IS NULL
        OR semaphore_status IN (TRUE, FALSE)
    );
-- Add a comment to the table for clarity
COMMENT ON TABLE smart_pole IS 'Table containing smart pole data with spatial information, air quality index, and semaphore status.';
-- Add comments to the columns for clarity
COMMENT ON COLUMN smart_pole.id IS 'Unique identifier for the smart pole, matching the nyc_pole_location id.';
COMMENT ON COLUMN smart_pole.geom IS 'Geographic location of the smart pole as a Point in WGS 84 coordinate system.';
COMMENT ON COLUMN smart_pole.on_street IS 'Street name where the smart pole is installed.';
COMMENT ON COLUMN smart_pole.zipcode IS 'Zip code where the smart pole is located.';
COMMENT ON COLUMN smart_pole.installation_date IS 'Date when the smart pole was installed.';
COMMENT ON COLUMN smart_pole.air_quality_index IS 'Air quality index associated with the smart pole, if available.';
COMMENT ON COLUMN smart_pole.semaphore_status IS 'Status of the semaphore associated with the smart pole, indicating operational state.';
---------------------------------------------
-- Trigger for notifications
---------------------------------------------
-- Trigger function to notify changes for external subscribers
-- This function will be called whenever there is an INSERT, UPDATE, or DELETE on the table.
DROP FUNCTION IF EXISTS notify_smart_pole();
CREATE OR REPLACE FUNCTION notify_smart_pole() RETURNS TRIGGER AS $$ BEGIN PERFORM pg_notify('qgis', TG_OP);
-- TG_OP is the operation type: INSERT, UPDATE, DELETE
RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- Trigger to call the function on INSERT, UPDATE, DELETE
DROP TRIGGER IF EXISTS trg_notify_smart_pole ON smart_pole;
CREATE TRIGGER trg_notify_smart_pole
AFTER
INSERT
    OR
UPDATE
    OR DELETE ON smart_pole FOR EACH STATEMENT EXECUTE FUNCTION notify_smart_pole();
---------------------------------------------
-- Table population
---------------------------------------------
-- Insert existing nyc_pole_location records into smart_pole
INSERT INTO smart_pole (
        geom,
        id,
        on_street,
        zipcode,
        installation_date,
        air_quality_index,
        semaphore_status
    )
SELECT ST_SetSRID(
        ST_MakePoint(longitude, latitude),
        4326
    ),
    id,
    on_street,
    zipcode,
    installation_date,
    NULL AS air_quality_index,
    NULL AS semaphore_status
FROM nyc_pole_location;
COMMIT;