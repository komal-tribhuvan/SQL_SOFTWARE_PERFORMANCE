create database software_performance_analytics;

use software_performance_analytics;

select * from software$;

# Average Response Time by Endpoint
SELECT 
  Endpoint,
  ROUND(AVG(ResponseTime), 2) AS AvgResponseTime_ms
FROM 
  software$
GROUP BY 
  Endpoint
ORDER BY 
  AvgResponseTime_ms DESC;

# Error Count by Status Code
SELECT 
  ErrorCode,
  COUNT(*) AS ErrorCount
FROM 
  software$
WHERE 
  ErrorCode IS NOT NULL
GROUP BY 
  ErrorCode
ORDER BY 
  ErrorCount DESC;

# Peak Usage Hours (Requests Per Hour)
SELECT 
  DATEPART(HOUR, Timestamp) AS HourOfDay,
  COUNT(*) AS RequestCount
FROM 
  software$
GROUP BY 
  DATEPART(HOUR, Timestamp)
ORDER BY 
  RequestCount DESC;

#CPU and Response Time Correlation (Simplified View)

SELECT 
  Timestamp,
  CPUUsage,
  ResponseTime
FROM 
  software$
ORDER BY 
  Timestamp;

#Response Time Trend Over Time
SELECT 
  CAST(Timestamp AS DATE) AS Date,
  ROUND(AVG(ResponseTime), 2) AS AvgResponseTime_ms
FROM 
  software$
GROUP BY 
  CAST(Timestamp AS DATE)
ORDER BY 
  Date;

#Error Rate by Endpoint/Shows which endpoints are more error-prone
SELECT 
  Endpoint,
  COUNT(CASE WHEN ErrorCode IS NOT NULL THEN 1 END) * 100.0 / COUNT(*) AS ErrorRatePercent
FROM 
 software$
GROUP BY 
  Endpoint
ORDER BY 
  ErrorRatePercent DESC;

#Detect Spike in Response Time (>2× average)/Flag outlier time periods

WITH AvgResponse AS (
  SELECT AVG(response_time_ms) AS OverallAvg
  FROM software$
)
SELECT 
  Timestamp,
  Endpoint,
  response_time_ms
FROM 
  software$, AvgResponse
WHERE 
  response_time_ms > 2 * OverallAvg
ORDER BY 
  response_time_ms DESC;

#Average CPU & Memory by Hour of Day/Identify performance by time of day
SELECT 
  DATEPART(HOUR, Timestamp) AS HourOfDay,
  ROUND(AVG(CPUUsage), 2) AS AvgCPU,
  ROUND(AVG(MemoryUsage), 2) AS AvgMemory
FROM 
  software$
GROUP BY 
  DATEPART(HOUR, Timestamp)
ORDER BY 
  HourOfDay;

#Request Load vs. Errors (per Day)Correlate system pressure and failures.
SELECT 
  CAST(Timestamp AS DATE) AS Date,
  COUNT(*) AS TotalRequests,
  SUM(CASE WHEN ErrorCode IS NOT NULL THEN 1 ELSE 0 END) AS TotalErrors
FROM 
  software$
GROUP BY 
  CAST(Timestamp AS DATE)
ORDER BY 
  Date;

