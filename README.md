# Write-TerminalProgress

PowerShell terminal spinner progress cmdlet. See related [blog post](https://powershellone.wordpress.com/?p=1506.)

## SYNOPSIS
PowerShell function to indicate progress, using cli-spinner icons, during longer running tasks.

## SYNTAX

```
Write-TerminalProgress [-InputObject] <Object> [-IconSet] <Object> [[-Begin] <ScriptBlock>]
 [-Process] <ScriptBlock> [[-End] <ScriptBlock>] [[-Activity] <String>] [[-CurrentStatus] <String>]
 [-ReturnFullOutput]
```

## DESCRIPTION
The function utilizes ANSI Escape sequences the build a simple TUI that shows progress using cli-spinners.
The function works similar to foreach-object in many other aspects.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
$htArgs = @{
```

IconSet = 'fistBump'
    Process = { "Doing $_";sleep -Seconds 2 }
    Activity = 'Working hard'
    CurrentStatus = 'Status _'
}
1..5 | Write-TerminalProgress @htArgs

## PARAMETERS

### -InputObject
Specifies the input objects.
The function runs the script block or operation statement on each input object.
The argument to this parameter is usually provided by pipeline.

```yaml
Type: Object
Parameter Sets: (All)
Aliases: 

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -IconSet
The IconSet to be used for the spinner.

```yaml
Type: Object
Parameter Sets: (All)
Aliases: 

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Begin
Specifies a script block that runs before this cmdlet processes any input objects.

```yaml
Type: ScriptBlock
Parameter Sets: (All)
Aliases: 

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Process
Specifies the operation that is performed on each input object. 
This script block is run for every object in the pipeline.

```yaml
Type: ScriptBlock
Parameter Sets: (All)
Aliases: 

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -End
Specifies a script block that runs after this cmdlet processes all input objects. 
This script block is only run once for the entire pipeline.

```yaml
Type: ScriptBlock
Parameter Sets: (All)
Aliases: 

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Activity
A static message that describes the process.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CurrentStatus
Progress output for each iteration of the process block.
"_" can be used to refer to the current object.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReturnFullOutput
{{Fill ReturnFullOutput Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[https://github.com/sindresorhus/cli-spinners](https://github.com/sindresorhus/cli-spinners)

[]()

