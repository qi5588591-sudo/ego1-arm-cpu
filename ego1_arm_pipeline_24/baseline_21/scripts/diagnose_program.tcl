# Run manually from the user's existing Vivado Hardware Manager.
# This is a one-shot diagnostic, not a replacement for startup validation.
proc ego1_probe_log {ch message} {
    puts $message
    puts $ch $message
    flush $ch
}

proc ego1_probe_body {ch root} {
    set devices [get_hw_devices -quiet xc7a35t_0]
    if {[llength $devices] != 1} {
        error "STOP: xc7a35t_0 is not detected. Recover the connection first."
    }
    set target [current_hw_target]
    set freq [get_property PARAM.FREQUENCY $target]
    ego1_probe_log $ch "JTAG_HZ=$freq"
    if {$freq != 125000} {error "STOP: set JTAG to 125000 Hz before this test."}
    set device [lindex $devices 0]
    set bitfile [file join $root download ego1_arm_pipeline_manual_start.bit]
    if {![file exists $bitfile] || [file size $bitfile] != 645123} {
        error "STOP: expected the verified 645123-byte manual-start bitstream."
    }
    current_hw_device $device
    ego1_probe_log $ch "DEVICE=$device"
    ego1_probe_log $ch "FILE=$bitfile"
    ego1_probe_log $ch "EXPECTED_USR_ACCESS=4D535431"
    ego1_probe_log $ch "DIAGNOSTIC ONLY: automatic EOS check is skipped; no success claim follows."
    set_property PROBES.FILE {} $device
    set_property FULL_PROBES.FILE {} $device
    set_property PROGRAM.FILE $bitfile $device
    set rc [catch {program_hw_devices -disable_eos_check $device} message]
    ego1_probe_log $ch "PROGRAM_RC=$rc RESULT=$message"
    if {$rc} {error "Programming itself failed; see PROGRAM_RC above."}

    # Read through the existing object; never disconnect/reprogram/restart here.
    set rc [catch {refresh_hw_device -update_hw_probes false $device} message]
    ego1_probe_log $ch "REFRESH_RC=$rc RESULT=$message"
    if {$rc} {error "Configuration status could not be read: connection failed."}
    foreach property {REGISTER.CONFIG_STATUS REGISTER.BOOT_STATUS REGISTER.USR_ACCESS} {
        set rc [catch {get_property $property $device} value]
        ego1_probe_log $ch "$property RC=$rc VALUE=$value"
        if {$rc} {continue}
        if {$property eq {REGISTER.CONFIG_STATUS}} {
            if {[regexp {^[01]{32}$} $value]} {
                scan $value %b status
            } elseif {[regexp {^(0x)?[0-9a-fA-F]{8}$} $value]} {
                scan $value %x status
            } else {
                ego1_probe_log $ch "Status format not recognized; keep raw value."
                continue
            }
            # AMD UG470 STAT register fields; retain raw status above as evidence.
            foreach {name bit} {CRC_ERROR 0 EOS 4 GWE 6 INIT_B 12 DONE 14 ID_ERROR 15 DEC_ERROR 16} {
                ego1_probe_log $ch "$name=[expr {($status >> $bit) & 1}]"
            }
        }
    }
    ego1_probe_log $ch "PROBE FINISHED. Check status, image marker and board behavior; command completion alone is not proof of success."
}

set probe_root [file normalize [file join [file dirname [info script]] ..]]
set probe_log [file join $probe_root diagnostics "program_probe_[clock format [clock seconds] -format %Y%m%d_%H%M%S].txt"]
set probe_ch [open $probe_log w]
ego1_probe_log $probe_ch "LOG=$probe_log"
set probe_rc [catch {ego1_probe_body $probe_ch $probe_root} probe_result]
ego1_probe_log $probe_ch "FINAL_RC=$probe_rc RESULT=$probe_result"
close $probe_ch
puts "Diagnostic log saved: $probe_log"
if {$probe_rc} {error $probe_result}
