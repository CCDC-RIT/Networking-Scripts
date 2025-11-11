<?php
require_once("config.inc");
require_once("functions.inc");

// Load current configuration
$config = parse_config(true);

// Initialize syslog array if it doesn't exist
if (!is_array($config['syslog'])) {
    $config['syslog'] = array();
}

// Enable all syslog facilities and set to maximum verbosity
$syslog_facilities = array(
    'dhcp' => 'DHCP service events',
    'hostapd' => 'Wireless hostapd events', 
    'logportalauth' => 'Captive portal authentication',
    'portalauth' => 'Captive portal events',
    'vpn' => 'VPN events (IPSec, OpenVPN, etc.)',
    'ppp' => 'PPP events',
    'relayd' => 'Load balancer events',
    'hostapd' => 'Wireless events',
    'system' => 'System events',
    'resolver' => 'DNS resolver events',
    'pf' => 'Firewall events'
);

foreach ($syslog_facilities as $facility => $description) {
    $config['syslog'][$facility] = true;
    echo "Enabled logging for: $description\n";
}

// Configure system log settings for maximum capture
$config['syslog']['enable'] = true;
$config['syslog']['logall'] = true;
$config['syslog']['logfilesize'] = '2048000'; // 2GB max log file size
$config['syslog']['nentries'] = '500000'; // Maximum log entries in GUI

// Configure remote syslog if not already set
if (!isset($config['syslog']['remoteserver'])) {
    echo "Note: Remote syslog server not configured. Consider setting up remote logging.\n";
}

// Enable firewall logging for all actions
if (!is_array($config['syslog']['filterdescriptions'])) {
    $config['syslog']['filterdescriptions'] = array();
}
$config['syslog']['filterdescriptions']['1'] = true; // Log packets matched by firewall rules

// Configure advanced syslog options
$config['syslog']['logdefaultblock'] = true; // Log packets blocked by default rule
$config['syslog']['logdefaultpass'] = false; // Don't overwhelm with default pass logs
$config['syslog']['logbogons'] = true; // Log bogon networks
$config['syslog']['logprivatenets'] = true; // Log private networks

// Set log rotation
$config['syslog']['rotatecount'] = '10'; // Keep 10 rotated files
$config['syslog']['rotatetime'] = '24'; // Rotate every 24 hours

// Configure kernel logging
$config['system']['enablekernel'] = true;
$config['system']['enableserial'] = false; // Disable serial logging to avoid clutter

echo "Syslog configuration completed.\n";

// Write configuration
write_config("Maximum syslog configuration applied via script");
?>