#entering the basic connection info like what server and database
$server = Read-Host -Prompt 'Enter the server you want to query (ex. srvnj11)'
$db = Read-Host -Prompt 'Enter the database you want to query (ex. ACME_Hotfix) - spelling matters'
$table = Read-Host -Prompt 'Enter the table you want to query:'

#please ensure that the fields you want to query are in a csv file and only ONE field per row
$inputField = Get-Content 'C:\Users\vmaster\Desktop\input.csv' | ForEach-Object {$_ -replace ",", "" `
                                                                                    -replace "'", "" `
                                                                                    -replace '"', ""  }


#query the database with a user provided table
for($i = 0; $i -lt $inputField.Length; $i++){
    $sql = New-Object System.Data.SqlClient.SqlConnection
    $sql.ConnectionString = "Server = " + $server + "; Database = " +$db +"; Integrated Security = True" 
    $sqlCmd = New-Object System.Data.SqlClient.SqlCommand
    $sqlCmd.CommandText = "select TYPE_NAME, VARLENGTH, COLUMN_NAME, TABLE_NAME from SSI_SysColMetadata where TABLE_NAME = '" + $table + "' and COLUMN_NAME = '" + $inputField[$i] + "'"
    $sqlCmd.Connection = $sql
    $sqlCmd.CommandTimeout = 600
    $sqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
    $sqlAdapter.SelectCommand = $sqlCmd
    $dataSet = New-Object System.Data.DataSet
    $sqlAdapter.Fill($dataSet)

    $dataSet.Tables[0] | Export-Csv -Path 'C:\Users\vmaster\Desktop\output.csv' -NoClobber -Append #Out-File -FilePath 'C:\Users\vmaster\Desktop\output.txt' -Append -NoClobber 
    #$sqlCmd | Out-Host
   

    $sql.Close()
}
