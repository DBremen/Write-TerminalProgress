function Write-TerminalProgress {
    <#
    .SYNOPSIS
        PowerShell function to indicate progress, using cli-spinner icons, during longer running tasks. 

    .DESCRIPTION
       The function utilizes ANSI Escape sequences the build a simple TUI that shows progress using cli-spinners.
       The function works similar to foreach-object in many other aspects.

    .PARAMETER InputObject
         Specifies the input objects. The function runs the script block or operation statement on each input object.
         The argument to this parameter is usually provided by pipeline.

    .PARAMETER IconSet
        The IconSet to be used for the spinner.

    .PARAMETER Begin
        Specifies a script block that runs before this cmdlet processes any input objects.

    .PARAMETER Process
        Specifies the operation that is performed on each input object. 
        This script block is run for every object in the pipeline.

    .PARAMETER End
        Specifies a script block that runs after this cmdlet processes all input objects. 
        This script block is only run once for the entire pipeline.

    .PARAMETER Activity
        A static message that describes the process.

    .PARAMETER CurrentStatus
        Progress output for each iteration of the process block. "_" can be used to refer to the current object.

    .PARAMETER ReturnFullObject
        Switch parameter, if specified the output of the function will be returned in full after the execution.
        This is to workaround the "cutting off" of outputs due the defined scrolling region during the output.

    .EXAMPLE
        $htArgs = @{
            IconSet = 'fistBump'
            Process = { "Doing $_";sleep -Seconds 2 }
            Activity = 'Working hard'
            CurrentStatus = 'Status _'
        }
        1..5 | Write-TerminalProgress @htArgs

    .LINK
        https://github.com/sindresorhus/cli-spinners

    .LINK
   #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory,ValueFromPipeline)]
        $InputObject,
        [Parameter(Mandatory)]
        [ValidateSet('aesthetic','arc','arrow','arrow2','arrow3','balloon','balloon2','betaWave','bluePulse','bounce','bouncingBall','bouncingBar','boxBounce','boxBounce2','christmas','circle','circleHalves','circleQuarters','clock','dots','dots10','dots11','dots12','dots2','dots3','dots4','dots5','dots6','dots7','dots8','dots8Bit','dots9','dqpb','earth','fingerDance','fistBump','flip','grenade','growHorizontal','growVertical','hamburger','hearts','layer','line','line2','material','mindblown','monkey','moon','noise','orangeBluePulse','orangePulse','pipe','point','pong','runner','shark','simpleDots','simpleDotsScrolling','smiley','soccerHeader','speaker','squareCorners','squish','star','star2','timeTravel','toggle','toggle10','toggle11','toggle12','toggle13','toggle2','toggle3','toggle4','toggle5','toggle6','toggle7','toggle8','toggle9','triangle','weather')]
        $IconSet,
        [ScriptBlock]$Begin,
        [Parameter(Mandatory)]
        [ScriptBlock]$Process,
        [ScriptBlock]$End,
        [String]$Activity,
        [String]$CurrentStatus,
        [switch]$ReturnFullOutput
    )
    BEGIN{
        $e = "$([char]27)"
        #clear screen w/o buffer
        "$([char]0x1b)[2J"
        #move cursor down by 6
        [console]::SetCursorPosition(0,[console]::WindowTop+6)
        #move everything down 5 lines to make space
        [console]::MoveBufferArea(0,[console]::WindowTop,[console]::WindowWidth,[console]::WindowTop,0,[console]::WindowTop+5) 
        #hide the cursor
        Write-Host "$e[?25l"  -NoNewline  
        #array list to collect output
        $output = [System.Collections.ArrayList]::new()
        #create a thread safe object to be able to...
        #...communicate across threads
        $currentObject = [System.Collections.Concurrent.ConcurrentDictionary[string,object]]::new()
        #initialize variables
        $progressCounter = 0
        $e = "$([char]27)"
        $path = "$PSScriptRoot\spinners.json"
        $spinners = Get-Content $path | ConvertFrom-Json 
        $frameCount = $spinners.$IconSet.frames.Count
        $frameLength = $spinners.$IconSet.frames[0].Length
        $rightMargin = $frameLength
        if ($Activity.Length -gt $rightMargin) { $rightMargin = $Activity.Length }
        $frameInterval = $spinners.$IconSet.interval
        #define scrolling region making the top 5 rows a no scrolling area
        #see https://docs.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences
        Write-Host "$e[s$($e)[5;r$($e)[u" -NoNewline
        #start the thread that show the progress
        $job= Start-ThreadJob {
            $e = "$([char]27)"
            $iconSet = $using:IconSet
            $rightMargin = $using:rightMargin
            $spinners = $using:spinners
            $frameCount = $using:frameCount
            $frameInterval = $using:frameInterval
            $frameLength = $using:frameLength
            $currentStatus = $using:CurrentStatus
            #activity message
            #safe the current cursor position
            Write-Host "$e[s" -NoNewline
            $xPos = [console]::WindowWidth-$rightMargin-4 
            Write-Host "$e[$([console]::WindowTop+2);$($xPos)H$using:Activity" -NoNewline
            Write-Host "$e[u" -NoNewline
            #run this in an infinite loop until the actual job is done
            while ($true){
                #retrieve the currently processed ...
                #...pipeline variable from the main thread
                $current = $using:currentObject
                Write-Host "$e[s" -NoNewline
                #write the status message
                $msg = $currentStatus.Replace('_',$current.curr)
                Write-Host "$e[$([console]::WindowTop+3);$($xPos)H$($e)[1M" -NoNewline
                Write-Host "$($e)[$($currentStatus.Length+$current.Length)P$msg" -NoNewline
                Write-Host "$e[u" -NoNewline
                #place the cursor at the top left position with some margin and delete current line
                $frame = $spinners.$IconSet.frames[$progressCounter % $frameCount]
                Write-Host "$e[$([console]::WindowTop+4);$($xPos)H$($e)[1M" -NoNewline
                #write the frame
                #Write-Host "$($e)[$($frameLength)P$frame" -NoNewline
                Write-Host "$e[$([console]::WindowTop+4);$($xPos)H$frame" -NoNewline
                Write-Host "$e[u" -NoNewline
                Start-Sleep -Milliseconds $frameInterval
                $progressCounter++
            }
        } -StreamingHost $host
    }
    #process the actual Process scriptblock using foreach object
    #to be able to refer to $_ inside the script block
    PROCESS{
       $currentObject['curr'] = $InputObject
       $InputObject | foreach -Process $Process
    }

    END{
        #clean up the job
        $job | Stop-job -PassThru | Remove-Job        
        #restore scrolling region
        Write-Host "$e[s$($e)[r$($e)[u" -NoNewline
        #delete the progress and activity message
        Write-Host "$e[$([console]::WindowTop+2);$([console]::WindowWidth-$rightMargin-4)H" -NoNewline
        Write-Host "$e[5M$($e)[u" -NoNewline
        #show the cursor
        Write-Host "$e[?25h" -NoNewline  
        if ($End) { $End.Invoke() }
        if ($ReturnFullOutput){
            $output
        }
    }
}