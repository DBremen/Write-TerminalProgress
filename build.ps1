function build {
	Import-Module platyps
	. $PSScriptRoot\Write-TerminalProgress.ps1
	New-MarkdownHelp -command Write-TerminalProgress -OutputFolder $PSScriptRoot
	(Get-Content -Path $PSScriptRoot\Write-TerminalProgress.md | Select-Object -Skip 6) | Set-Content ReadMe.md -Force
	Remove-Item $PSScriptRoot\Write-TerminalProgress.md 
}