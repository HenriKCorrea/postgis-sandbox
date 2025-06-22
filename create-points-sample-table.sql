-- Enable PostGIS extension if not already enabled for spatial data support
CREATE EXTENSION IF NOT EXISTS postgis;
-- Create a table for storing points with a geometry column
DROP TABLE IF EXISTS "points";
CREATE TABLE "points"(
    "id" int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    "name" text,
    "geom" GEOMETRY(point, 4326) -- SRID 4326 for WGS84
);
-- Create a notification function for QGIS to listen to changes
-- NOTE: Enable this feature on QGIS Side: QGIS -> Layer Properties -> Rendering -> "Refresh Layer on notification"
CREATE OR REPLACE FUNCTION notify_points() RETURNS TRIGGER AS $$ BEGIN PERFORM pg_notify('qgis', TG_OP);
RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- Create Trigger to call the function on INSERT, UPDATE, DELETE
CREATE TRIGGER trg_notify_points
AFTER
INSERT
    OR
UPDATE
    OR DELETE ON "points" FOR EACH STATEMENT EXECUTE FUNCTION notify_points();
-- Insert sample points into the table
INSERT INTO "points"("name", "geom")
VALUES (
        'Central Park',
        ST_SetSRID(ST_MakePoint(-73.9654, 40.7829), 4326)
    ),
    (
        'Sample Point',
        ST_SetSRID(ST_MakePoint(-73.9857, 40.7484), 4326)
    ),
    (
        'Times Square',
        ST_SetSRID(ST_MakePoint(-73.9851, 40.7580), 4326)
    );
-- Update the name of the sample point
UPDATE "points"
SET "name" = 'Empire State'
WHERE "name" = 'Sample Point';
-- Delete a point by name
DELETE FROM "points"
WHERE "name" = 'Times Square';
-- Print the contents of the table
SELECT *
FROM "points";