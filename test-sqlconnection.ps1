[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [String]$ConnectionString,
    $Count = 0,
    $WaitFor = 1000
)

function TestSQLConnection {
    $Error.Clear()
    $response = [pscustomobject]@{Timestamp = $(Get-Date); Success = $true; ResponseTimeInMilliseconds = $null;}
    $response.Success = $true
    $sqlConnection = New-Object System.Data.SqlClient.SqlConnection $ConnectionString;
    $command = New-Object System.Data.SQLClient.SQLCommand
    $command.CommandText = "SELECT 1 WHERE 1=1";
    $stopwatch = New-Object System.Diagnostics.Stopwatch
    $stopwatch.Start()
    try {
        $sqlConnection.Open();
        $command.Connection = $sqlConnection
        $command.ExecuteNonQuery() | Out-Null
        $sqlConnection.Close();
        $stopwatch.Stop()
        $response.ResponseTimeInMilliseconds = $stopwatch.Elapsed.TotalMilliseconds
    }
    catch {
        Write-Error $_.Exception
        $stopwatch.Stop()
        $response.ResponseTimeInMilliseconds = $stopwatch.Elapsed.TotalMilliseconds
        $response.Success = $false
        $response.Timestamp = $(Get-Date)
    }
    $response.ResponseTimeInMilliseconds = $stopwatch.Elapsed.TotalMilliseconds
    
    Return $response
}
if ($Count -eq 0) {
    while (1 -eq 1) {
        TestSQLConnection
        Start-Sleep -m $WaitFor
    }
}
else {
    for ($i = 0; $i -le $Count; $i++) {
        TestSQLConnection
        Start-Sleep -m $WaitFor
    }
}