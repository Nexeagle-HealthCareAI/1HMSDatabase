-- Rollback for db/schema/migrations/agent_monitoring_2026_10.sql (deploy the previous NexeagleCMSAPI first).
IF OBJECT_ID('dbo.AgentModelVersions','U') IS NOT NULL DROP TABLE dbo.AgentModelVersions;
IF OBJECT_ID('dbo.AgentLearningItems','U') IS NOT NULL DROP TABLE dbo.AgentLearningItems;
IF OBJECT_ID('dbo.AgentDecisions','U') IS NOT NULL DROP TABLE dbo.AgentDecisions;
GO
