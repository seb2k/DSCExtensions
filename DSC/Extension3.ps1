Configuration Main
{

Param ( [string] $nodeName )

Import-DscResource -ModuleName PSDesiredStateConfiguration

Node $nodeName
  {
    #region Add-TLS
    # Add TLS 1.0 / 1.1 / 1.2
    $tlsVersion = "TLS 1.0", "TLS 1.1"#, "TLS 1.2"
    foreach ($x in $tlsVersion)
    {
        $name = $x.Replace(".", "").Replace(" ","")
        Registry "EnableServer$name"
        {
            Key = "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$x\Server"
            ValueName = "Enabled"
            ValueType = "Dword"
            ValueData = "00000000" #Chagned from 0 to 00000000
            Ensure = "Present"
            Hex = $false #ALE --| Changed to False
            Force = $true
        }

        Registry "DisabledByDefaultServer$name"
        {
            Key = "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$x\Server"
            ValueName = "DisabledByDefault"
            ValueType = "Dword"
            ValueData = "00000000" #Chagned from 0 to 00000000
            Ensure = "Present"
            Hex = $false #ALE --| Changed to False
            Force = $true
        }

        Registry "EnableClient$name"
        {
            Key = "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$x\Client"
            ValueName = "Enabled"
            ValueType = "Dword"
            ValueData = "0xffffffff"
            Ensure = "Present"
            Hex = $true
            Force = $true
        }

        Registry "DisableByDefaultClient$name"
        {
            Key = "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$x\Client"
            ValueName = "DisabledByDefault"
            ValueType = "Dword"
            ValueData = "00000000" #Chagned from 0 to 00000000
            Ensure = "Present"
            Hex = $false #ALE --| Changed to False
            Force = $true
        }
    }
    #endregion Add-TLS

    #region Enable-TLS
    $EnabletlsVersion = "TLS 1.2"
    foreach ($x in $EnabletlsVersion)
    {
        $name = $x.Replace(".", "").Replace(" ","")
        Registry "EnableServer$name"
        {
            Key = "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$x\Server"
            ValueName = "Enabled"
            ValueType = "Dword"
            ValueData = "0xffffffff"
            Ensure = "Present"
            Hex = $true
            Force = $true
        }

        Registry "DisabledByDefaultServer$name"
        {
            Key = "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$x\Server"
            ValueName = "DisabledByDefault"
            ValueType = "Dword"
            ValueData = "00000000" #Chagned from 0 to 00000000
            Ensure = "Present"
            Hex = $false #ALE --| Changed to False
            Force = $true
        }

        Registry "EnableClient$name"
        {
            Key = "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$x\Client"
            ValueName = "Enabled"
            ValueType = "Dword"
            ValueData = "0xffffffff"
            Ensure = "Present"
            Hex = $true
            Force = $true
        }

        Registry "DisableByDefaultClient$name"
        {
            Key = "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$x\Client"
            ValueName = "DisabledByDefault"
            ValueType = "Dword"
            ValueData = "00000000" #Chagned from 0 to 00000000
            Ensure = "Present"
            Hex = $false #ALE --| Changed to False
            Force = $true
        }
    }

    #endregion Enable-TLS

    #region RestartBat
    Script EnsurePresent
    {
        TestScript = {
            Test-Path "C:\temp\Reboot.bat"
        }
        SetScript ={
            if (!(Test-Path "C:\temp")){
                New-Item     C:\temp -ItemType Directory -Force
            }
            "shutdown -r -t 00 -f" | Out-File "C:\temp\Reboot.bat" -Force
            #Set-Content -Value "shutdown -r -t 00 -f" -Path "C:\temp\Reboot.bat" 
        }
        GetScript = {@{Result = "EnsurePresent"}}
    }
    #endregion RestartBat

    #region DisableFirewall
    Script DisableFirewall
    {
        GetScript = {
            @{
                GetScript = $GetScript
                SetScript = $SetScript
                TestScript = $TestScript
                Result = -not('True' -in (Get-NetFirewallProfile -All).Enabled)
            }
        }

        SetScript = {
            Set-NetFirewallProfile -All -Enabled False -Verbose
        }

        TestScript = {
            $Status = -not('True' -in (Get-NetFirewallProfile -All).Enabled)
            $Status -eq $True
        }
    }
    #endregion DisableFirewall
  }
}
