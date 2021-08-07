Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

# Adapted from these Baboo videos:                     https://youtu.be/qWESrvP_uU8
# Adapted from this AdamX's video REG scripts:         https://youtu.be/hQSkPmZRCjc
# Adapted from this ChrisTitus script:                 https://github.com/ChrisTitusTech/win10script
# Adapted from this Sycnex script:                     https://github.com/Sycnex/Windows10Debloater
# Adapted from this kalaspuffar/Daniel Persson script: https://github.com/kalaspuffar/windows-debloat

function OptimizePrivacyAndPerformance() {

    Title1 -Text "Privacy And Performance Tweaks"
    Section1 -Text "Personalization Section"
    Caption1 -Text "? & ? & Start & Lockscreen"

    Write-Host "$($EnableStatus[0]) Show me the windows welcome experience after updates..."
    Write-Host "$($EnableStatus[0]) 'Get fun facts and tips, etc. on lock screen'..."
    
    $ContentDeliveryManagerDisableOnZero = @(
        "SubscribedContent-310093Enabled"
        "SubscribedContent-314559Enabled"
        "SubscribedContent-314563Enabled"
        "SubscribedContent-338387Enabled"
        "SubscribedContent-338388Enabled"
        "SubscribedContent-338389Enabled"
        "SubscribedContent-338393Enabled"
        "SubscribedContent-353698Enabled"
        "RotatingLockScreenOverlayEnabled"
        "RotatingLockScreenEnabled"
        # Prevents Apps from re-installing
        "ContentDeliveryAllowed"
        "FeatureManagementEnabled"
        "OemPreInstalledAppsEnabled"
        "PreInstalledAppsEnabled"
        "PreInstalledAppsEverEnabled"
        "RemediationRequired"
        "SilentInstalledAppsEnabled"
        "SoftLandingEnabled"
        "SubscribedContentEnabled"
        "SystemPaneSuggestionsEnabled"
    )

    Write-Warning "[?][Priv&Perf] From Path: [$PathToContentDeliveryManager]"
    ForEach ($Name in $ContentDeliveryManagerDisableOnZero) {
        Write-Host "$($EnableStatus[0]) $($Name): $Zero"
        Set-ItemProperty -Path "$PathToContentDeliveryManager" -Name "$Name" -Type DWord -Value $Zero
    }

    Write-Host "[-][Priv&Perf] Disabling 'Suggested Content in the Settings App'..."
    If (Test-Path "$PathToContentDeliveryManager\Subscriptions") {
        Remove-Item -Path "$PathToContentDeliveryManager\Subscriptions" -Recurse
    }
    
    Write-Host "$($EnableStatus[0]) 'Show Suggestions' in Start..."
    If (Test-Path "$PathToContentDeliveryManager\SuggestedApps") {
        Remove-Item -Path "$PathToContentDeliveryManager\SuggestedApps" -Recurse
    }
        
    Section1 -Text "Privacy Section -> Windows Permissions"
    Caption1 -Text "General"
    
    Write-Host "$($EnableStatus[0]) Let apps use my advertising ID..."
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Type DWord -Value $Zero
    If (!(Test-Path "$PathToAdvertisingInfoPol")) {
        New-Item -Path "$PathToAdvertisingInfoPol" -Force | Out-Null
    }
    Set-ItemProperty -Path "$PathToAdvertisingInfoPol" -Name "DisabledByGroupPolicy" -Type DWord -Value $One
    
    Write-Host "$($EnableStatus[0]) 'Let websites provide locally relevant content by accessing my language list'..."
    Set-ItemProperty -Path "HKCU:\Control Panel\International\User Profile" -Name "HttpAcceptLanguageOptOut" -Type DWord -Value $One
    
    Caption1 -Text "Speech"
    
    Write-Host "[@] (0 = Decline, 1 = Accept)"
    Write-Host "$($EnableStatus[0]) Online Speech Recognition..."
    If (!(Test-Path "$PathToOnlineSpeech")) {
        New-Item -Path "$PathToOnlineSpeech" -Force | Out-Null
    }
    Set-ItemProperty -Path "$PathToOnlineSpeech" -Name "HasAccepted" -Type DWord -Value $Zero
    
    Caption1 -Text "Inking & Typing Personalization"
    
    Set-ItemProperty -Path "$PathToInputPersonalization\TrainedDataStore" -Name "HarvestContacts" -Type DWord -Value $Zero
    Set-ItemProperty -Path "$PathToInputPersonalization" -Name "RestrictImplicitInkCollection" -Type DWord -Value $One
    Set-ItemProperty -Path "$PathToInputPersonalization" -Name "RestrictImplicitTextCollection" -Type DWord -Value $One
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy" -Type DWord -Value $Zero
    
    Caption1 -Text "Diagnostics & Feedback"
    
    Write-Host "[@] (0 = Security (Enterprise only), 1 = Basic Telemetry, 2 = Enhanced Telemetry, 3 = Full Telemetry)"
    Write-Host "$($EnableStatus[0]) telemetry..."
    Set-ItemProperty -Path "$PathToTelemetry" -Name "AllowTelemetry" -Type DWord -Value $Zero
    Set-ItemProperty -Path "$PathToTelemetry2" -Name "AllowTelemetry" -Type DWord -Value $Zero
    Set-ItemProperty -Path "$PathToTelemetry" -Name "AllowDeviceNameInTelemetry" -Type DWord -Value $Zero
    
    Write-Host "$($EnableStatus[0]) send inking and typing data to Microsoft..."
    If (!(Test-Path "$PathToTIPC")) {
        New-Item -Path "$PathToTIPC" -Force | Out-Null
    }
    Set-ItemProperty -Path "$PathToTIPC" -Name "Enabled" -Type DWord -Value $Zero
    
    Write-Host "$($EnableStatus[0]) Tailored Experiences..."
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Type DWord -Value $Zero

    Write-Host "$($EnableStatus[0]) View diagnostic data..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack\EventTranscriptKey" -Name "EnableEventTranscript" -Type DWord -Value $Zero
    
    Write-Host "$($EnableStatus[0]) feedback frequency"
    If (!(Test-Path "$PathToSiufRules")) {
        New-Item -Path "$PathToSiufRules" -Force | Out-Null
    }
    If ((Test-Path "$PathToSiufRules\PeriodInNanoSeconds")) {
        Remove-ItemProperty -Path "$PathToSiufRules" -Name "PeriodInNanoSeconds"
    }
    Set-ItemProperty -Path "$PathToSiufRules" -Name "NumberOfSIUFInPeriod" -Type DWord -Value $Zero

    Caption1 -Text "Activity History"

    Write-Host "$($EnableStatus[0]) Activity History..."
    $ActivityHistoryDisableOnZero = @(
        "EnableActivityFeed"
        "PublishUserActivities"
        "UploadUserActivities"
    )

    Write-Warning "[?][Priv&Perf] From Path: [$PathToActivityHistory]"
    ForEach ($Name in $ActivityHistoryDisableOnZero) {
        Write-Host "$($EnableStatus[0]) $($Name): $Zero"
        Set-ItemProperty -Path "$PathToActivityHistory" -Name "$ActivityHistoryDisableOnZero" -Type DWord -Value $Zero
    }
    
    Section1 -Text "Privacy Section -> Apps Permissions"
    Caption1 -Text "Location"
    
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Value "Deny"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Value "Deny"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" -Name "SensorPermissionState" -Type DWord -Value $Zero
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration" -Name "EnableStatus" -Type DWord -Value $Zero
    
    Caption1 -Text "Notifications"
    
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userNotificationListener" -Name "Value" -Value "Deny"
    
    Caption1 -Text "App Diagnostics"
    
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appDiagnostics" -Name "Value" -Value "Deny"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appDiagnostics" -Name "Value" -Value "Deny"
    
    Caption1 -Text "Account Info Access"
    
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation" -Name "Value" -Value "Deny"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation" -Name "Value" -Value "Deny"
    
    Caption1 -Text "Other Devices"

    # Disable sharing information with unpaired devices
    Write-Host "[-][Priv&Perf] Denying device access..."
    If (!(Test-Path "$PathToDeviceAccessGlobal\LooselyCoupled")) {
        New-Item -Path "$PathToDeviceAccessGlobal\LooselyCoupled" -Force | Out-Null
    }
    Set-ItemProperty -Path "$PathToDeviceAccessGlobal\LooselyCoupled" -Name "Value" -Value "Deny"
    ForEach ($key in (Get-ChildItem "$PathToDeviceAccessGlobal")) {
        If ($key.PSChildName -EQ "LooselyCoupled") {
            continue
        }
        Write-Host "$($EnableStatus[1]) Setting $($key.PSChildName) value to Deny..."
        Set-ItemProperty -Path ("$PathToDeviceAccessGlobal\" + $key.PSChildName) -Name "Value" -Value "Deny"
    }

    Caption1 -Text "Background Apps"
    
    Write-Host "$($EnableStatus[0]) Background Apps..."
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Type DWord -Value $One
    Set-ItemProperty -Path "$PathToSearch" -Name "BackgroundAppGlobalToggle" -Type DWord -Value $Zero
    
    Section1 -Text "Update & Security Section"
    Caption1 -Text "Windows Update"
    
    If (!(Test-Path "$PathToWindowsUpdate")) {
        New-Item -Path "$PathToWindowsUpdate" -Force | Out-Null
    }
    Write-Host "[@] (2 = Notify before download, 3 = Automatically download and notify of installation)"
    Write-Host "[@] (4 = Automatically download and schedule installation, 5 = Automatic Updates is required and users can configure it)"
    Write-Host "[-][Priv&Perf] Disabling Automatic Download and Installation of Windows Updates..."
    Set-ItemProperty -Path "$PathToWindowsUpdate" -Name "AUOptions" -Type DWord -Value 2

    Write-Host "[@] (0 = Enable Automatic Updates, 1 = Disable Automatic Updates)"
    Write-Host "$($EnableStatus[1]) Automatic Updates..."
    Set-ItemProperty -Path "$PathToWindowsUpdate" -Name "NoAutoUpdate" -Type DWord -Value $Zero

    Write-Host "[@] (0 = Every day, 1~7 = The days of the week from Sunday (1) to Saturday (7) (Only valid if AUOptions = 4))"
    Write-Host "[+][Priv&Perf] Setting Scheduled Day to Every day..."
    Set-ItemProperty -Path "$PathToWindowsUpdate" -Name "ScheduledInstallDay" -Type DWord -Value 0

    Write-Host "[@] (0-23 = The time of day in 24-hour format)"
    Write-Host "[-][Priv&Perf] Setting Scheduled time to 03h00m..."
    Set-ItemProperty -Path "$PathToWindowsUpdate" -Name "ScheduledInstallTime" -Type DWord -Value 3

    Write-Host "[=] Enabling automatic driver updates..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching" -Name "SearchOrderConfig" -Type DWord -Value 1
    
    Write-Host "$($EnableStatus[1]) Change Windows Updates to 'Notify to schedule restart'..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "UxOption" -Type DWord -Value $One
    
    Write-Host "[@] (0 = Off, 1 = Local Network only, 2 = Local Network private peering only)"
    Write-Host "[@] (3 = Local Network and Internet,  99 = Simply Download mode, 100 = Bypass mode)"
    Write-Host "$($EnableStatus[1]) Restricting Windows Update P2P downloads for Local Network only..."
    If (!(Test-Path "$PathToDeliveryOptimizationCfg")) {
        New-Item -Path "$PathToDeliveryOptimizationCfg" -Force | Out-Null
    }
    Set-ItemProperty -Path "$PathToDeliveryOptimizationCfg" -Name "DODownloadMode" -Type DWord -Value $One

    Caption1 -Text "Troubleshooting"

    Write-Host "[+][Priv&Perf] Enabling Automatic Recommended Troubleshooting, then notify me..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsMitigation" -Name "UserPreference" -Type DWord -Value 3

    Write-Host "$($EnableStatus[0]) Windows Spotlight Features..."
    Write-Host "$($EnableStatus[0]) Third Party Suggestions..."
    Write-Host "$($EnableStatus[0]) More Telemetry Features..."
    
    $CloudContentDisableOnOne = @(
        "DisableWindowsSpotlightFeatures"
        "DisableWindowsSpotlightOnActionCenter"
        "DisableWindowsSpotlightOnSettings"
        "DisableWindowsSpotlightWindowsWelcomeExperience"
        "DisableTailoredExperiencesWithDiagnosticData"      # Tailored Experiences
        "DisableThirdPartySuggestions"
    )

    Write-Warning "[?][Priv&Perf] From Path: [$PathToCloudContent]"
    ForEach ($Name in $CloudContentDisableOnOne) {
        Write-Host "$($EnableStatus[0]) $($Name): $One"
        Set-ItemProperty -Path "$PathToCloudContent" -Name "$Name" -Type DWord -Value $One
    }
    If (!(Test-Path "$PathToCloudContent")) {
        New-Item -Path "$PathToCloudContent" -Force | Out-Null
    }
    Set-ItemProperty -Path "$PathToCloudContent" -Name "ConfigureWindowsSpotlight" -Type DWord -Value 2
    Set-ItemProperty -Path "$PathToCloudContent" -Name "IncludeEnterpriseSpotlight" -Type DWord -Value $Zero
    
    Write-Host "$($EnableStatus[0]) Apps Suggestions..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableThirdPartySuggestions" -Type DWord -Value $One
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -Type DWord -Value $One
    
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" -Name "PreventDeviceMetadataFromNetwork" -Type DWord -Value $One
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows" -Name "CEIPEnable" -Type DWord -Value $Zero
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" -Name "AITEnable" -Type DWord -Value $Zero
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" -Name "DisableUAR" -Type DWord -Value $One

    # Details: https://docs.microsoft.com/pt-br/windows-server/remote/remote-desktop-services/rds-vdi-recommendations-2004#windows-system-startup-event-traces-autologgers
    Write-Host "$($EnableStatus[0]) some startup event traces (AutoLoggers)..."
    If (!(Test-Path "$PathToAutoLogger\AutoLogger-Diagtrack-Listener")) {
        New-Item -Path "$PathToAutoLogger\AutoLogger-Diagtrack-Listener" -Force | Out-Null
    }
    Set-ItemProperty -Path "$PathToAutoLogger\AutoLogger-Diagtrack-Listener" -Name "Start" -Type DWord -Value $Zero
    Set-ItemProperty -Path "$PathToAutoLogger\SQMLogger" -Name "Start" -Type DWord -Value $Zero
    
    Write-Host "$($EnableStatus[0]) 'WiFi Sense: HotSpot Sharing'..."
    If (!(Test-Path "$PathToWifiPol\AllowWiFiHotSpotReporting")) {
        New-Item -Path "$PathToWifiPol\AllowWiFiHotSpotReporting" -Force | Out-Null
    }
    Set-ItemProperty -Path "$PathToWifiPol\AllowWiFiHotSpotReporting" -Name "value" -Type DWord -Value $Zero
    
    Write-Host "$($EnableStatus[0]) 'WiFi Sense: Shared HotSpot Auto-Connect'..."
    If (!(Test-Path "$PathToWifiPol\AllowAutoConnectToWiFiSenseHotspots")) {
        New-Item -Path "$PathToWifiPol\AllowAutoConnectToWiFiSenseHotspots" -Force | Out-Null
    }
    Set-ItemProperty -Path "$PathToWifiPol\AllowAutoConnectToWiFiSenseHotspots" -Name "value" -Type DWord -Value $Zero
    
    Section1 -Text "Gaming Section"
    
    Write-Host "$($EnableStatus[0]) Game Bar & Game DVR..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowGameDVR" -Name "value" -Type DWord -Value $Zero
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Type DWord -Value $Zero
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Type DWord -Value $Zero
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Type DWord -Value $Zero
    
    Write-Host "$($EnableStatus[1]) game mode..."
    Set-ItemProperty -Path "$PathToGameBar" -Name "AllowAutoGameMode" -Type DWord -Value $One
    Set-ItemProperty -Path "$PathToGameBar" -Name "AutoGameModeEnabled" -Type DWord -Value $One
    
    Section1 -Text "System Section"
    Caption1 -Text "Display"

    Write-Host "[+][Priv&Perf] Enable Hardware Accelerated GPU Scheduling... (Windows 10 20H1+ - Needs Restart)"
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Type DWord -Value 2

    # Show Task Manager details - Applicable to 1607 and later - Although this functionality exist even in earlier versions, the Task Manager's behavior is different there and is not compatible with this tweak
    Write-Host "$($EnableStatus[1]) Showing task manager details..."
    $taskmgr = Start-Process -WindowStyle Hidden -FilePath taskmgr.exe -PassThru
    Do {
        Start-Sleep -Milliseconds 100
        $preferences = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -ErrorAction SilentlyContinue
    } Until ($preferences)
    Stop-Process $taskmgr
    $preferences.Preferences[28] = 0
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -Type Binary -Value $preferences.Preferences
    
    Caption1 "Deleting useless registry keys..."
        
    $KeysToDelete = @(
        # Remove Background Tasks
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\46928bounde.EclipseManager_2.2.4.51_neutral__a5h4egax66k6y"
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.MicrosoftOfficeHub_17.7909.7600.0_x64__8wekyb3d8bbwe"
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"
        # Windows File
        "HKCR:\Extensions\ContractId\Windows.File\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
        # Registry keys to delete if they aren't uninstalled by RemoveAppXPackage/RemoveAppXProvisionedPackage
        "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\46928bounde.EclipseManager_2.2.4.51_neutral__a5h4egax66k6y"
        "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
        "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
        "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
        "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"
        # Scheduled Tasks to delete
        "HKCR:\Extensions\ContractId\Windows.PreInstalledConfigTask\PackageId\Microsoft.MicrosoftOfficeHub_17.7909.7600.0_x64__8wekyb3d8bbwe"
        # Windows Protocol Keys
        "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
        "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
        "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
        "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"
        # Windows Share Target
        "HKCR:\Extensions\ContractId\Windows.ShareTarget\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
    )

    ForEach ($Key in $KeysToDelete) {
        If ((Test-Path $Key)) {
            Write-Host "[Priv&Perf] Removing Key: [$Key]..."
            Remove-Item $Key -Recurse
        }
    }

    Title1 -Text "Performance Tweaks"
    
    # As SysMain was already disabled on the Services, just need to remove it's key
    Write-Host "[@] (0 = Disable SysMain, 1 = Enable when program is launched, 2 = Enable on Boot, 3 = Enable on everything)"
    Write-Host "$($EnableStatus[0]) SysMain/Superfetch..."
    Set-ItemProperty -Path "$PathToPrefetchParams" -Name "EnableSuperfetch" -Type DWord -Value $Zero

    Write-Host "$($EnableStatus[0]) Remote Assistance..."
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Type DWord -Value $Zero
    
    Write-Host "[-][Priv&Perf] Disabling Ndu High RAM Usage..."
    Set-ItemProperty -Path "HKLM:\SYSTEM\ControlSet001\Services\Ndu" -Name "Start" -Type DWord -Value 4

    # Details: https://www.tenforums.com/tutorials/94628-change-split-threshold-svchost-exe-windows-10-a.html
    Write-Host "[+][Priv&Perf] Splitting SVCHost processes to lower RAM usage..."
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "SvcHostSplitThresholdInKB" -Type DWord -Value $(4 * 1mb)

    Write-Host "[+][Priv&Perf] Unlimiting your network bandwitdh for all your system..." # Based on this Chris Titus video: https://youtu.be/7u1miYJmJ_4
    If (!(Test-Path "$PathToPsched")) {
        New-Item -Path "$PathToPsched" -Force | Out-Null
    }
    Set-ItemProperty -Path "$PathToPsched" -Name "NonBestEffortLimit" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Type DWord -Value 0xffffffff

    Write-Host "[@] (2 = Disable, 4 = Enable)"
    Write-Host "[-][Priv&Perf] Disabling Windows Store apps Automatic Updates..."
    If (!(Test-Path "$PathToWindowsStore")) {
        New-Item -Path "$PathToWindowsStore" -Force | Out-Null
    }
    Set-ItemProperty -Path "$PathToWindowsStore" -Name "AutoDownload" -Type DWord -Value 2

    Section1 -Text "Power Plan Tweaks"

    Write-Host "[+][Priv&Perf] Setting Power Plan to High Performance..."
    powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

    # Found on the registry: HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power\User\Default\PowerSchemes
    Write-Host "[+][Priv&Perf] Enabling (Not setting) the Ultimate Performance Power Plan..."
    powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61

    Section1 -Text "Network & Internet"
    Caption1 -Text "Proxy"

    # Code from: https://www.reddit.com/r/PowerShell/comments/5iarip/set_proxy_settings_to_automatically_detect/?utm_source=share&utm_medium=web2x&context=3
    Write-Host "[-][Priv&Perf] Fixing Edge slowdown by NOT Automatically Detecting Settings..."
    $key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections'
    $data = (Get-ItemProperty -Path $key -Name DefaultConnectionSettings).DefaultConnectionSettings
    $data[8] = 3
    Set-ItemProperty -Path $key -Name DefaultConnectionSettings -Value $data

}

function Main() {

    # Initialize all Path variables used to Registry Tweaks
    $Global:PathToActivityHistory = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
    $Global:PathToAdvertisingInfoPol = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo"
    $Global:PathToAutoLogger = "HKLM:\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger"
    $Global:PathToCloudContent = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
    $Global:PathToContentDeliveryManager = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
    $Global:PathToDeliveryOptimizationCfg = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config"
    $Global:PathToDeviceAccessGlobal = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global"
    $Global:PathToGameBar = "HKCU:\SOFTWARE\Microsoft\GameBar"
    $Global:PathToInputPersonalization = "HKCU:\SOFTWARE\Microsoft\InputPersonalization"
    $Global:PathToOnlineSpeech = "HKCU:\SOFTWARE\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy"
    $Global:PathToPrefetchParams = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters"
    $Global:PathToPsched = "HKLM:\SOFTWARE\Policies\Microsoft\Psched"
    $Global:PathToSearch = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
    $Global:PathToSiufRules = "HKCU:\SOFTWARE\Microsoft\Siuf\Rules"
    $Global:PathToTelemetry = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
    $Global:PathToTelemetry2 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
    $Global:PathToTIPC = "HKCU:\SOFTWARE\Microsoft\Input\TIPC"
    $Global:PathToWifiPol = "HKLM:\Software\Microsoft\PolicyManager\default\WiFi"
    $Global:PathToWindowsStore = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"
    $Global:PathToWindowsUpdate = "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate\AU"

    $Zero = 0
    $One = 1
    $EnableStatus = @(
        "[-][Priv&Perf] Disabling",
        "[+][Priv&Perf] Enabling"
    )

    if (($Revert)) {
        Write-Warning "[<][Priv&Perf] Reverting: $Revert"

        $Zero = 1
        $One = 0
        $EnableStatus = @(
            "[<][Priv&Perf] Re-Enabling",
            "[<][Priv&Perf] Re-Disabling"
        )
      
    }

    OptimizePrivacyAndPerformance  # Disable Registries that causes slowdowns and privacy invasion

}

Main