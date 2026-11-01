open_hw_manager
connect_hw_server -url localhost:3121
set targets [get_hw_targets]
if {[llength $targets] != 1} {
    error "Expected one target for a bounded scan, found [llength $targets]."
}
set target [lindex $targets 0]
current_hw_target $target
set found 0
foreach frequency {1000000 250000} {
    catch {close_hw_target}
    set_property PARAM.FREQUENCY $frequency $target
    puts "SCAN_FREQUENCY: $frequency"
    if {[catch {open_hw_target} message]} {
        puts "SCAN_FAILURE: $message"
    } else {
        set devices [get_hw_devices -quiet]
        puts "SCAN_DEVICE_COUNT: [llength $devices]"
        foreach device $devices {
            puts "SCAN_DEVICE: $device PART=[get_property PART $device]"
        }
        if {[llength $devices] > 0} {
            set found 1
            break
        }
    }
}
catch {close_hw_target}
disconnect_hw_server
close_hw_manager
puts "SCAN_FOUND_DEVICE: $found"
