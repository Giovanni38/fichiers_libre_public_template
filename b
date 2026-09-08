SELECT
    j.name AS JobName,
    s.step_id,
    s.step_name,
    s.subsystem,
    s.database_name,
    s.command
FROM msdb.dbo.sysjobs j
INNER JOIN msdb.dbo.sysjobsteps s
    ON j.job_id = s.job_id
WHERE j.name IN (
    'EntRelation_Charge_PMEIaControler',
    'PILOTAGE_TCO_Virement_sefcare_evenement',
    'RGA_Alex',
    '6258_Journal_TIM_BK31',
    'OWA_VRC',
    'OWA_IAR'
)
ORDER BY j.name, s.step_id;



SELECT
    j.name AS JobName,
    s.step_id,
    s.step_name,
    s.database_name,
    s.command
FROM msdb.dbo.sysjobs j
JOIN msdb.dbo.sysjobsteps s
    ON j.job_id = s.job_id
WHERE
       s.command LIKE '%ACE.OLEDB%'
    OR s.command LIKE '%OPENROWSET%'
    OR s.command LIKE '%OPENDATASOURCE%'
    OR s.command LIKE '%sp_addlinkedserver%'
    OR s.command LIKE '%xlsx%'
    OR s.command LIKE '%xls%'
    OR s.command LIKE '%Tnull%'
ORDER BY j.name, s.step_id;


SELECT TOP 200
    j.name AS JobName,
    h.step_name,
    msdb.dbo.agent_datetime(h.run_date, h.run_time) AS ExecutionDate,
    h.run_status,
    h.sql_message_id,
    LEFT(h.message, 1000) AS Message
FROM msdb.dbo.sysjobhistory h
JOIN msdb.dbo.sysjobs j
    ON j.job_id = h.job_id
WHERE
    h.step_id > 0
    AND (
        h.sql_message_id IN (7303,7339,7412)
        OR h.message LIKE '%ACE.OLEDB%'
    )
ORDER BY ExecutionDate DESC;



