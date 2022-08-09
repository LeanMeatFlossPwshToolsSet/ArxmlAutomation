param(
    [Parameter(ValueFromPipeline,Mandatory)]
    [string]
    $ModuleName
)
$initLocation=Get-Location
Set-Location "$PSScriptRoot/../"
New-Item -Path "./ArxmlAutomation/ArxmlAutomation-$ModuleName" -ItemType Directory -Force
New-Item -Path "./ArxmlAutomation/ArxmlAutomation-$ModuleName/ArxmlAutomation-$ModuleName.Tests.ps1" -ItemType File -Force
New-Item -Path "./ArxmlAutomation/ArxmlAutomation-$ModuleName/Module" -ItemType Directory -Force
New-Item -Path "./ArxmlAutomation/ArxmlAutomation-$ModuleName/Module/ArxmlAutomation-$ModuleName.psm1" -ItemType File -Force
New-ModuleManifest -Path "./ArxmlAutomation/ArxmlAutomation-$ModuleName/ArxmlAutomation-$ModuleName.psd1" -Author "LeanMeatFloss" -CompanyName "Song" -Copyright @"
MIT License

Copyright (c) 2022 Hansong Li

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"@ -FunctionsToExport ("*") -CmdletsToExport ("*") -LicenseUri 'https://raw.githubusercontent.com/LeanMeatFloss/ArxmlAutomation/main/LICENSE' -RootModule "Module/ArxmlAutomation-$ModuleName.psm1"
Set-Location $initLocation