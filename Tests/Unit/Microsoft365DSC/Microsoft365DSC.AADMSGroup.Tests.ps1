[CmdletBinding()]
param(
    [Parameter()]
    [string]
    $CmdletModule = (Join-Path -Path $PSScriptRoot `
            -ChildPath "..\Stubs\Microsoft365.psm1" `
            -Resolve)
)
$GenericStubPath = (Join-Path -Path $PSScriptRoot `
    -ChildPath "..\Stubs\Generic.psm1" `
    -Resolve)
Import-Module -Name (Join-Path -Path $PSScriptRoot `
        -ChildPath "..\UnitTestHelper.psm1" `
        -Resolve)

$Global:DscHelper = New-M365DscUnitTestHelper -StubModule $CmdletModule `
    -DscResource "AADMSGroup" -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope

        $secpasswd = ConvertTo-SecureString "test@password1" -AsPlainText -Force
        $GlobalAdminAccount = New-Object System.Management.Automation.PSCredential ("tenantadmin", $secpasswd)

        Mock -CommandName Close-SessionsAndReturnError -MockWith {

        }

        Mock -CommandName Test-MSCloudLogin -MockWith {

        }

        Mock -CommandName Get-PSSession -MockWith {

        }

        Mock -CommandName Remove-PSSession -MockWith {

        }

        Mock -CommandName Set-AzureADMSGroup -MockWith {

        }

        Mock -CommandName Remove-AzureADMSGroup -MockWith {

        }

        Mock -CommandName New-AzureADMSGroup -MockWith {

        }
        # Test contexts
        Context -Name "The Group should exist but it DOES NOT" -Fixture {
            $testParams = @{
                DisplayName                   = "DSCGroup"
                Description                   = "Microsoft DSC Group"
                SecurityEnabled               = $True
                MailEnabled                   = $False
                MailNickname                  = "M365DSC"
                GroupTypes                     = @("Unified")
                Visibility                    = "Private"
                Ensure                        = "Present"
                GlobalAdminAccount            = $GlobalAdminAccount;
            }

            Mock -CommandName Get-AzureADMSGroup -MockWith {
                return $null
            }
            It "Should return Values from the Get method" {
                (Get-TargetResource @testParams).Ensure | Should be 'Absent'
                Assert-MockCalled -CommandName "Get-AzureADMSGroup" -Exactly 1
            }
            It 'Should return false from the Test method' {
                Test-TargetResource @testParams | Should Be $false
            }
            It 'Should Create the group from the Set method' {
                Set-TargetResource @testParams
                Assert-MockCalled -CommandName "New-AzureADMSGroup" -Exactly 1
            }
        }

        Context -Name "The Group exists but it SHOULD NOT" -Fixture {
            $testParams = @{
                DisplayName                   = "DSCGroup"
                Description                   = "Microsoft DSC Group"
                SecurityEnabled               = $True
                MailEnabled                   = $False
                MailNickname                  = "M365DSC"
                GroupTypes         = @("Unified")
                Visibility                    = "Private"
                Ensure                        = "Absent"
                GlobalAdminAccount            = $GlobalAdminAccount;
            }

            Mock -CommandName Get-AzureADMSGroup -MockWith {
                return @{DisplayName = "DSCGroup"
                         ID = "12345-12345-12345-12345"    }
            }

            It "Should return Values from the Get method" {
                (Get-TargetResource @testParams).Ensure | Should be 'Present'
                Assert-MockCalled -CommandName "Get-AzureADMSGroup" -Exactly 1
            }

            It 'Should return true from the Test method' {
                Test-TargetResource @testParams | Should Be $false
            }

            It 'Should Remove the group from the Set method' {
                Set-TargetResource @testParams
                Assert-MockCalled -CommandName "Remove-AzureADMSGroup" -Exactly 1
            }
        }
        Context -Name "The Group Exists and Values are already in the desired state" -Fixture {
            $testParams = @{
                DisplayName                   = "DSCGroup"
                Description                   = "Microsoft DSC Group"
                SecurityEnabled               = $True
                MailEnabled                   = $False
                MailNickname                  = "M365DSC"
                GroupTypes                    = @("Unified")
                Visibility                    = "Private"
                Ensure                        = "Present"
                GlobalAdminAccount            = $GlobalAdminAccount;
            }

            Mock -CommandName Get-AzureADMSGroup -MockWith {
                return @{
                    DisplayName                   = "DSCGroup"
                    Description                   = "Microsoft DSC Group"
                    SecurityEnabled               = $True
                    MailEnabled                   = $False
                    MailNickname                  = "M365DSC"
                    GroupTypes                    = @("Unified")
                    Visibility                    = "Private"
                    Ensure                        = "Present"
                }
            }

            It "Should return Values from the Get method" {
                Get-TargetResource @testParams
                Assert-MockCalled -CommandName "Get-AzureADMSGroup" -Exactly 1
            }

            It 'Should return true from the Test method' {
                Test-TargetResource @testParams | Should Be $true
            }
        }

        Context -Name "The Group exists and values are NOT in the desired state" -Fixture {
            $testParams = @{
                DisplayName                   = "DSCGroup"
                Description                   = "Microsoft DSC Group"
                SecurityEnabled               = $True
                MailEnabled                   = $False
                MailNickname                  = "M365DSC"
                GroupTypes                    = @("Unified")
                Visibility                    = "Private"
                Ensure                        = "Present"
                GlobalAdminAccount            = $GlobalAdminAccount;
            }

            Mock -CommandName Get-AzureADMSGroup -MockWith {
                return @{
                    DisplayName                   = "DSCGroup"
                    Description                   = "Microsoft DSC" #Drift
                    SecurityEnabled               = $True
                    GroupTypes                    = @("Unified")
                    MailEnabled                   = $False
                    MailNickname                  = "M365DSC"
                    Visibility                    = "Private"
                }
            }

            Mock -CommandName Get-AzureADMSGroup -MockWith {
                return @{DisplayName = "DSCGroup"
                         ID = "12345-12345-12345-12345"    }
            }


            It "Should return Values from the Get method" {
                Get-TargetResource @testParams
                Assert-MockCalled -CommandName "Get-AzureADMSGroup" -Exactly 1
            }

            It 'Should return false from the Test method' {
                Test-TargetResource @testParams | Should Be $false
            }

            It "Should call the Set method" {
                Set-TargetResource @testParams
                Assert-MockCalled -CommandName 'Set-AzureADMSGroup' -Exactly 1
            }
        }

        Context -Name "ReverseDSC Tests" -Fixture {
            $testParams = @{
                GlobalAdminAccount = $GlobalAdminAccount
            }

            Mock -CommandName Get-AzureADMSGroup -MockWith {
                return @{
                    DisplayName = "Test Team"
                    ID = "12345-12345-12345-12345"
   #                 GroupTypes         = @("Unified")
                }
            }

            It "Should Reverse Engineer resource from the Export method" {
                Export-TargetResource @testParams
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
