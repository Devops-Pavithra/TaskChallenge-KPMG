function Get-NestedObjectValue {
    param (
        [Parameter(Mandatory = $true)]
        [object] $InputObject,

        [Parameter(Mandatory = $true)]
        [string] $Key
    )

    process {
        if ($InputObject -is [System.Collections.IDictionary]) {
            # If the input object is a dictionary (hash table), check if it contains the key.
            if ($InputObject.ContainsKey($Key)) {
                return $InputObject[$Key]
            }
            else {
                # Recursively search through the values of the dictionary.
                foreach ($value in $InputObject.Values) {
                    $getValue = $value.values
                    $result = Get-NestedObjectValue -InputObject $value -Key $Key
                    if ($result -ne $null) {
                        return $result
                    }
                }
            }
        }
        
    }#process close

} # Function close



$nestedObject = @{
    "key1" = @{
        "key2" = @{
            "key3" = "Challenge 3 -Task Executed"
        }
    }
}

$result = Get-NestedObjectValue -InputObject $nestedObject -Key "key3"
if ($result -ne $null) {
    Write-Host "Value found: $result"
}
else {
    Write-Host "Key not found."
}
