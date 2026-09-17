-- ============================================================
-- Azure Synapse Serverless SQL
-- Earthquake Analytics Layer
-- ============================================================

-- Database scoped credential using the Synapse workspace
-- managed identity.
CREATE DATABASE SCOPED CREDENTIAL WorkspaceIdentity
WITH IDENTITY = 'Managed Identity';
GO


-- External data source pointing to the Gold layer in ADLS Gen2.
CREATE EXTERNAL DATA SOURCE EarthquakeLake
WITH (
    LOCATION = 'https://earthquakede04.dfs.core.windows.net/earthquake',
    CREDENTIAL = WorkspaceIdentity
);
GO


-- Analytics-ready view over Gold Parquet files.
CREATE OR ALTER VIEW dbo.vw_earthquakes
AS
SELECT *
FROM OPENROWSET(
    BULK 'gold/earthquake_events_gold/run_date=*/*.parquet',
    DATA_SOURCE = 'EarthquakeLake',
    FORMAT = 'PARQUET'
) AS earthquakes;
GO


-- Validation query
SELECT TOP 100 *
FROM dbo.vw_earthquakes
ORDER BY time DESC;
